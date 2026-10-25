<#
.SYNOPSIS
    Makes a VC6 executable's PDB reference discoverable by VS Code's debugger.

.DESCRIPTION
    WHY THIS IS NEEDED

    Loader is compiled with VC6's /Z7 option, which embeds debug information in
    each OBJ. The VC6 linker collects it into Peter.pdb when linking with /DEBUG.
    That PDB contains the source lines, functions, types, and local variables.

    The EXE also needs to tell the debugger which PDB belongs to it. A Windows
    executable is a PE (Portable Executable) file. Its debug directory contains
    entries describing different kinds of debug data. An IMAGE_DEBUG_TYPE_CODEVIEW
    entry (type 2) points to a small record identifying the external PDB. This
    record is a reference to the symbols, not the symbols themselves.

    VC6 writes that reference in the older NB10 format. With our installed
    cppvsdbg debugger, the unmodified EXE was reported as "Binary was not built
    with debug information." Source breakpoints stayed unbound. However, DIA
    (Microsoft's Debug Interface Access API for reading debug information) could
    open the same EXE/PDB pair and enumerate its source lines and typed locals.
    Thus a successful standalone DIA check did not prove debugger compatibility:
    this debugger was not recognizing the EXE's legacy PDB-reference record.

    Replacing that reference with RSDS lets the debugger discover and load the
    existing VC6 PDB. This was checked with the actual vsdbg shipped in the
    Microsoft C/C++ VS Code extension: it reported "Symbols loaded", bound and
    hit a source breakpoint in Main.cpp, and displayed typed local variables.

    WHAT NB10 AND RSDS MEAN

    NB10 and RSDS are four-byte ASCII format signatures (magic values) at the
    beginning of a CodeView record. They select different binary layouts:

        NB10 -- the legacy PDB reference used by VC6 / PDB 2.00
        Offset  Size  Field
         0       4    ASCII "NB10"
         4       4    Legacy offset field (unused for this external PDB reference)
         8       4    PDB timestamp signature / identifier
        12       4    PDB age
        16       ...  Null-terminated PDB path

        RSDS -- the GUID-based reference normally used with newer PDBs
        Offset  Size  Field
         0       4    ASCII "RSDS"
         4      16    PDB GUID
        20       4    PDB age
        24       ...  Null-terminated PDB path

    Integer fields are little-endian. The signature or GUID, together with the
    age, identifies the matching PDB; a matching filename alone is insufficient.
    The NB10 timestamp is treated as an opaque PDB identifier, not the EXE's
    timestamp or its filesystem modification time. The age is a PDB revision
    counter, not a duration, and must be preserved along with the identifier.

    HOW THE REPLACEMENT MATCHES THE EXISTING PDB

    PDB 2.00 predates GUID-based identification. When DIA exposes this legacy
    PDB's identity as a GUID, Data1 is its 32-bit timestamp signature and the
    remaining 12 bytes are zero. We use precisely that identity in the RSDS
    record, and copy the original age. We do not invent a new GUID, change the
    PDB's identity, or rewrite the PDB into a newer storage format.

    RSDS has an eight-byte larger fixed header than NB10. Using just the PDB
    filename (Peter.pdb), instead of Wine's absolute build path, makes the new
    record fit in the original allocation for this build. The debugger finds
    it beside Peter.exe or through launch.json's symbolSearchPath. Source-file
    lookup is separate: launch.json's sourceFileMap translates Z:\workspace
    paths stored inside the PDB back to the local checkout.

    The script locates the PE debug directory, replaces the record in place,
    clears its unused trailing bytes, and updates the entry's SizeOfData. It
    preserves the EXE's code, section headers/layout, file size, and the PDB
    contents. The existing PointerToRawData remains valid; no new section or
    relocation is needed. An existing RSDS record is left alone so repeated
    incremental builds do not keep modifying the EXE. A fresh VC6 link writes
    NB10 again, so build-loader-debug.ps1 runs this after every successful build.

    This is a compatibility adjustment for the tested VC6/VS Code workflow,
    not a general-purpose symbol converter. It allows the compiler and linker
    to remain in the Wine image without requiring a local Visual Studio install.

.EXAMPLE
    ./scripts/set-vc6-pdb-reference.ps1 -Executable ./Peter250src/Loader/Debug/Peter.exe

.LINK
    https://learn.microsoft.com/windows/win32/debug/pe-format#debug-directory-image-only
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Executable
)

$ErrorActionPreference = "Stop"
$path = (Resolve-Path -LiteralPath $Executable).ProviderPath
$image = [System.IO.File]::ReadAllBytes($path)
# The DOS header's e_lfanew field points to the PE signature and COFF header.
$pe = [BitConverter]::ToUInt32($image, 0x3c)
$optional = $pe + 24
if ([BitConverter]::ToUInt32($image, $pe) -ne 0x4550 -or
    [BitConverter]::ToUInt16($image, $optional) -ne 0x10b) {
    throw "Expected a PE32 executable: $path"
}

# For PE32, data directories start at optional-header offset 96. Entry 6 is
# IMAGE_DIRECTORY_ENTRY_DEBUG; each entry contains an RVA and size (8 bytes).
$debugRva = [BitConverter]::ToUInt32($image, $optional + 96 + 6 * 8)
$debugSize = [BitConverter]::ToUInt32($image, $optional + 96 + 6 * 8 + 4)
$sections = $optional + [BitConverter]::ToUInt16($image, $pe + 20)
$sectionCount = [BitConverter]::ToUInt16($image, $pe + 6)
$debugOffset = $null
# Convert the directory's relative virtual address to a file offset through
# its containing section. An RVA is not generally the same as a raw file offset.
for ($i = 0; $i -lt $sectionCount; $i++) {
    $section = $sections + $i * 40
    $rva = [BitConverter]::ToUInt32($image, $section + 12)
    $rawSize = [BitConverter]::ToUInt32($image, $section + 16)
    if ($debugRva -ge $rva -and $debugRva -lt $rva + $rawSize) {
        $debugOffset = [BitConverter]::ToUInt32($image, $section + 20) + $debugRva - $rva
        break
    }
}
if ($null -eq $debugOffset) { throw "No debug directory found in $path" }

# IMAGE_DEBUG_DIRECTORY is 28 bytes. Its CodeView data can be outside the mapped
# image (as in this VC6 build), so use PointerToRawData rather than AddressOfRawData.
for ($entry = $debugOffset; $entry -lt $debugOffset + $debugSize; $entry += 28) {
    if ([BitConverter]::ToUInt32($image, $entry + 12) -ne 2) { continue }
    $size = [BitConverter]::ToUInt32($image, $entry + 16)
    $offset = [BitConverter]::ToUInt32($image, $entry + 24)
    $format = [System.Text.Encoding]::ASCII.GetString($image, $offset, 4)
    if ($format -eq "RSDS") { return }
    if ($format -ne "NB10") { throw "Expected an NB10 PDB reference in $path" }

    # A filename-only reference lets the debugger find the PDB beside the EXE.
    $pdbName = [System.IO.Path]::ChangeExtension([System.IO.Path]::GetFileName($path), ".pdb")
    $name = [System.Text.Encoding]::UTF8.GetBytes($pdbName + [char]0)
    $record = [byte[]]::new(24 + $name.Length)
    if ($record.Length -gt $size) { throw "The RSDS reference does not fit in $path" }
    [System.Text.Encoding]::ASCII.GetBytes("RSDS").CopyTo($record, 0)
    # A new byte array is zero-filled: copying just Data1 leaves the other
    # 12 GUID bytes zero, matching DIA's GUID representation of this PDB 2.00.
    [Array]::Copy($image, $offset + 8, $record, 4, 4) # PDB timestamp -> GUID Data1
    [Array]::Copy($image, $offset + 12, $record, 20, 4) # Preserve the PDB age
    $name.CopyTo($record, 24)
    [Array]::Clear($image, $offset, $size)
    $record.CopyTo($image, $offset)
    # Only the data length changes in the directory entry; its location stays put.
    [BitConverter]::GetBytes([uint32]$record.Length).CopyTo($image, $entry + 16)
    [System.IO.File]::WriteAllBytes($path, $image)
    Write-Host "==> Updated Loader's PDB reference for VS Code."
    return
}
throw "No CodeView PDB reference found in $path"
