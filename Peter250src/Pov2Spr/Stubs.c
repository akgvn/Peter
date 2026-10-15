
/***************************************************************************\
*																			*
*								Doplňky jádra								*
*																			*
\***************************************************************************/

// Zde jsou doplňky vyžadované překladačem z jádra C++
// POZOR - tento soubor musí zachovat jméno STUB.C !!!!

int _fltused = 0x9875;
//int _ldused = 0x9873;
int __fastflag = 0;
//int _errno = 0;
int errno = 0;
int* _errno() { return &errno; };
//int _except_list;
//int __CxxFrameHandler = 0;

// řízení korekcí chyb procesoru
int _adjust_fdiv = 0;		// 1 = korigovat chyby instrukcí Pentia

// nevolat funkci při inicializaci programu - je to destruktor 
//int atexit(void(*fnc())){ /*fnc();*/ fnc; return 0; };

int atexit(void*(__cdecl *fnc)())
{
	return (fnc == (void*)0) ? -1 : 0;
}

void _chkesp()
{
}

#pragma function(memset, memcpy, memmove)

void* __cdecl memset(void* dst, int c, unsigned count)
{
	char* dst2 = (char*)dst;
	for (; count > 0; count--)
	{
		*dst2 = (char)c;
		dst2++;
	}
	return dst;
}

void* __cdecl memcpy(void* dst, const void* src, unsigned count)
{
	char* dst2 = (char*)dst;
	const char* src2 = (const char*)src;
	for (; count > 0; count--)
	{
		*dst2 = *src2;
		dst2++;
		src2++;
	}
	return dst;
}

void* __cdecl memmove(void* dst, const void* src, unsigned count)
{
	char* dst2 = (char*)dst;
	const char* src2 = (const char*)src;
	if (dst2 < src2)
	{
		for (; count > 0; count--) { *dst2 = *src2; dst2++; src2++; }
	}
	else
	{
		dst2 += count;
		src2 += count;
		for (; count > 0; count--) { dst2--; src2--; *dst2 = *src2; }
	}
	return dst;
}

void __cdecl __report_rangecheckfailure(void)
{
}

#ifdef _M_IX86

__int64 __cdecl _ftol2(double d)
{
	unsigned short	oldstat;
	unsigned short	newstat;
	__int64			result;

	_asm {
		wait
		fnstcw		oldstat
		wait
		mov			ax,oldstat
		or			ah,0xc
		mov			newstat,ax
		fldcw		newstat
		fld			d
		fistp		result
		fldcw		oldstat
	}
	return result;
};

__int64 __cdecl _ftol2_sse(double d)
{
	unsigned short	oldstat;
	unsigned short	newstat;
	__int64			result;

	_asm {
		wait
		fnstcw		oldstat
		wait
		mov			ax,oldstat
		or			ah,0xc
		mov			newstat,ax
		fldcw		newstat
		fld			d
		fistp		result
		fldcw		oldstat
	}
	return result;
};

#endif

//int atexit;
//int atexit() { return 0; };

//void* memset(void* dst, int c, unsigned count);
//{
//	char* dst2 = (char*)dst;
//	for (; count > 0; count--)
//	{
//		*dst2 = (char)c;
//		dst2++;
//	}
//	return dst;
//}


//double __cdecl _fltinf(const char*, int, int, int);

//double strtod(const char* text)
//{
//	return _fltin(text, 10, 0, 0);
//}

//double StrToDouble(LPCTSTR text)
//{
//#ifdef _UNICODE
//	return wcstod(text,0);
//#else
//	return strtod(text);
/*
char ctype = 'A';
char* _pctype = &ctype;
char __decimal_point = '.';

int __mb_cur_max = 2;

// určení typu znaku:
// -----------------
//	_UPPER	0x01
//	_LOWER	0x02
//	_DIGIT	0x04
//	_SPACE	0x08
//	_PUNCT	0x10
// _CONTROL 0x20
//  _BLANK	0x40
//  _HEX    0x80
//  _LEADBYTE 0x8000
//  _ALPHA  (0x0100 | _UPPER | _LOWER)

int __cdecl _isctype(int c, int mask)
{
	int kod = 0;
	if ((c >= 'A') && (c <= 'Z')) kod |= 1;
	if ((c >= 'a') && (c <= 'z')) kod |= 2;
	if ((c >= '0') && (c <= '9')) kod |= 4;
	if ((c == ' ') || (c == 9)) kod |= 8;
	if ((c == '.') || (c == ',')) kod |= 0x10;
	if (c < ' ') kod |= 0x20;

	return (kod & mask);
}
*/
