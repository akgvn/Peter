# NB10/RSDS identity compatibility for legacy PDBs

Recorded 2026-10-25. This document separates Microsoft's documented legacy-PDB
identity convention from the narrower, locally verified practice of replacing an
executable's NB10 reference with an RSDS reference.

## Summary

The representation used by the Peter patch is an intentional Microsoft
compatibility convention, not an identity invented by the patch:

```text
GUID.Data1       = legacy 32-bit PDB signature
GUID.Data2       = 0
GUID.Data3       = 0
GUID.Data4       = eight zero bytes
age              = original PDB age
```

Microsoft's DbgHelp documentation explicitly says that a legacy PDB signature is
copied into the first DWORD of a GUID when no real GUID is available. Microsoft's
published PDB implementation additionally shows that the remaining GUID bytes
are zero and that validation can recover the legacy signature from `Data1`.

This supports the identity mapping itself. It does **not** establish a general,
documented contract that every RSDS consumer must accept an unchanged PDB 2.00
file after an NB10 record is rewritten as RSDS. That complete patching scenario
has been verified for Peter's tested DIA/vsdbg toolchain, not guaranteed for every
debugger, symbol server, or other consumer.

## The data types and record layouts

A Windows GUID is a 16-byte structure:

```c
struct GUID {
    uint32_t Data1;
    uint16_t Data2;
    uint16_t Data3;
    uint8_t  Data4[8];
};
```

The legacy CodeView reference in an EXE conceptually contains:

```c
struct NB10_PDB_REFERENCE {
    char     signature[4];
    uint32_t offset;
    uint32_t pdbSignature;
    uint32_t age;
    char     pdbPath[];
};
```

The newer reference contains:

```c
struct RSDS_PDB_REFERENCE {
    char     signature[4];
    GUID     pdbGuid;
    uint32_t age;
    char     pdbPath[];
};
```

The first record's `signature` is `"NB10"`; the second's is `"RSDS"`. The path is
null-terminated in both formats. These records identify an external PDB; they do
not contain its symbols, types, or source-line information.

The legacy `pdbSignature` is an opaque PDB identifier, not the PE header's
timestamp or the filesystem modification time. The age is a PDB revision value,
not a duration.

For example, this legacy identity:

```text
pdbSignature = 0x12345678
age          = 7
```

has this synthetic GUID representation:

```text
pdbGuid = {12345678-0000-0000-0000-000000000000}
age     = 7
```

On disk, `Data1` is stored little-endian, so `0x12345678` appears as
`78 56 34 12`.

## What Microsoft's documentation establishes

### DbgHelp explicitly documents the first-DWORD mapping

The documentation for
[`SYMSRV_INDEX_INFO`](https://learn.microsoft.com/en-us/windows/win32/api/dbghelp/ns-dbghelp-symsrv_index_info)
contains separate `GUID guid`, `DWORD sig`, and `DWORD age` members. Its description
of `guid` says:

> If there is no GUID available, the signature of the .pdb file is copied into
> first DWORD of the GUID.

The first DWORD of `GUID` is `Data1`, so this directly documents the central
mapping from a legacy PDB signature to `GUID.Data1`. The same page describes
`sig` as the signature used with old-style PDB files and `age` as the PDB age.

This documentation does not specify the values of the remaining twelve GUID
bytes and does not describe rewriting NB10 as RSDS.

### DIA exposes legacy and GUID identities separately

[`IDiaDataSource::loadAndValidateDataFromPdb`](https://learn.microsoft.com/en-us/visualstudio/debugger/debug-interface-access/idiadatasource-loadandvalidatedatafrompdb?view=visualstudio)
accepts all three identity inputs:

```c
HRESULT loadAndValidateDataFromPdb(
    LPCOLESTR pdbPath,
    GUID*     pcsig70,
    DWORD     sig,
    DWORD     age
);
```

The documentation describes `pcsig70` as the GUID signature, `sig` as the 32-bit
signature, and `age` as the age used to detect an out-of-sync PDB. It says that
validation compares the supplied signature and age with the PDB. This confirms
that DIA's public validation model supports both identity generations, but this
page does not define the synthetic-GUID mapping.

[`IDiaDataSource::loadDataFromCodeViewInfo`](https://learn.microsoft.com/en-us/visualstudio/debugger/debug-interface-access/idiadatasource-loaddatafromcodeviewinfo?view=visualstudio)
explicitly states that both RSDS and NB10 CodeView headers are supported. Thus,
DIA's acceptance of an original NB10 reference does not imply that every debugger
front end accepts one.

## What Microsoft's published PDB source establishes

Microsoft's archived [`microsoft-pdb`](https://github.com/microsoft/microsoft-pdb)
repository provides stronger evidence than the public API documentation alone.
It is implementation evidence, rather than a promise covering arbitrary tools.

### The complete synthetic GUID is defined

[`PDB/dbi/pdb1.h`](https://github.com/microsoft/microsoft-pdb/blob/master/PDB/dbi/pdb1.h#L10-L39)
contains this conversion:

```c
inline SIG70 Sig70FromSig(SIG dwSig)
{
    SIG70 sig70;
    memset(&sig70, 0, sizeof(SIG70));
    sig70.Data1 = dwSig;
    return sig70;
}
```

`SIG70` is an alias for `GUID`. This establishes the complete mapping, including
the zero bytes omitted from the DbgHelp documentation.

The same file distinguishes a real GUID from this synthetic representation by
checking whether any bytes after `Data1` are nonzero:

```c
static inline BOOL IsRealSig70(const SIG70& sig70)
{
    static SIG70 sig70Null;
    const int size = sizeof SIG70 - sizeof(sig70.Data1);
    return memcmp(&sig70.Data2, &sig70Null.Data2, size) != 0;
}
```

Its reverse conversion returns `sig70.Data1`. Consequently, a GUID whose last
twelve bytes are zero is treated as a legacy 32-bit identity, while a GUID with
any nonzero trailing byte is treated as a full GUID identity.

### Older PDBs expose the synthetic representation

In [`PDB/dbi/pdb.cpp`](https://github.com/microsoft/microsoft-pdb/blob/master/PDB/dbi/pdb.cpp#L1371-L1384),
`PDB1::QuerySignature2` returns the real stored GUID for newer PDBs and synthesizes
one from the legacy signature for older PDBs:

```c
if (pdbStream.impv >= impvVC70)
    memcpy(psig70, &pdbStream.sig70, sizeof(SIG70));
else
    *psig70 = Sig70FromSig(pdbStream.sig);
```

This is the source-level basis for saying that the legacy PDB's identity can be
represented as the timestamp-derived GUID used by Peter's patch.

### Validation recognizes the synthetic representation

In the same file,
[`PDB1::OpenValidate4`](https://github.com/microsoft/microsoft-pdb/blob/master/PDB/dbi/pdb.cpp#L806-L859)
uses full GUID comparison only when `IsRealSig70` says that the supplied identity
is a real GUID. Otherwise, when no separate 32-bit signature was supplied, it
recovers the signature with `SigFromSig70(*pcsig70)` and compares it with the
PDB's legacy `QuerySignature()` value. Age validation remains separate.

Conceptually, the relevant behavior is:

```text
if the supplied GUID has nonzero bytes after Data1:
    validate the complete GUID
else:
    validate Data1 as the legacy 32-bit PDB signature

validate age separately
```

This is why the synthetic RSDS identity is not a random GUID and does not bypass
PDB matching. It is an alternate encoding of the original identity.

## What this means for Peter's patch

Peter's helper at `scripts/set-vc6-pdb-reference.py` performs the equivalent
transformation in the EXE's CodeView record:

1. Read `pdbSignature` and `age` from NB10.
2. Write `"RSDS"` as the record signature.
3. Write a zeroed GUID whose `Data1` is the original `pdbSignature`.
4. Preserve `age`.
5. Write the PDB filename and null terminator.

The PDB itself is not opened or modified. The build must supply a correctly
matched EXE/PDB pair; the helper does not independently validate the PDB before
patching.

The tested debugger behavior separates two capabilities:

```text
Original NB10 reference:
    vsdbg rejects the reference during symbol discovery
    DIA can nevertheless read the matching PDB

Synthetic RSDS reference:
    vsdbg accepts the reference during symbol discovery
    the symbol reader validates the legacy identity and age
    the same PDB 2.00 contents provide lines, types, and locals
```

The patch therefore relies on a genuine Microsoft identity-compatibility
mechanism, while using it to cross a discovery restriction in the tested vsdbg
version.

## Scope and unresolved guarantees

The evidence supports these statements:

- The `Data1` mapping is explicitly documented by Microsoft for symbol indexing.
- The zero-filled remainder and reverse validation behavior are explicit in
  Microsoft's published PDB implementation.
- DIA publicly supports both legacy 32-bit and GUID PDB identities.
- The exact RSDS-reference/PDB-2.00 combination works in Peter's recorded tests.

The evidence does **not** establish these stronger claims:

- Every Microsoft component treats RSDS as container-neutral.
- Every debugger accepts a legacy PDB when its EXE reference is changed to RSDS.
- Symbol-server indexing, caching, remote debugging, dumps, and every DIA version
  handle this combination identically.
- Microsoft documents the EXE rewrite itself as a supported general conversion.

The most precise characterization is therefore: **an intentional Microsoft
legacy-identity convention, used in a locally verified compatibility patch whose
broader consumer support is not guaranteed by the cited documentation.**
