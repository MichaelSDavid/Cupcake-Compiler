// PRE

//#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
//#include <cmath>

typedef float f32;
typedef double f64;

typedef unsigned char u8;
typedef signed char s8;
typedef unsigned short u16;
typedef signed short s16;
typedef unsigned int u32;
typedef signed int s32;
typedef unsigned long long u64;
typedef signed long long s64;

typedef f32 __F32;
typedef f64 __F64;

typedef u8 __U8;
typedef s8 __S8;
typedef u16 __U16;
typedef s16 __S16;
typedef u32 __U32;
typedef s32 __S32;
typedef u64 __U64;
typedef s64 __S64;

typedef void __Void;
typedef bool __Bool;

typedef f32 __s0_F32_instance0;
typedef f64 __s0_F64_instance0;

typedef u8 __s0_U8_instance0;
typedef s8 __s0_S8_instance0;
typedef u16 __s0_U16_instance0;
typedef s16 __s0_S16_instance0;
typedef u32 __s0_U32_instance0;
typedef s32 __s0_S32_instance0;
typedef u64 __s0_U64_instance0;
typedef s64 __s0_S64_instance0;

typedef f32 __s0_F32;
typedef f64 __s0_F64;

typedef u8 __s0_U8;
typedef s8 __s0_S8;
typedef u16 __s0_U16;
typedef s16 __s0_S16;
typedef u32 __s0_U32;
typedef s32 __s0_S32;
typedef u64 __s0_U64;
typedef s64 __s0_S64;

typedef void __s0_Void_instance0;
typedef bool __s0_Bool_instance0;

typedef __s0_Bool_instance0 __s0_U1_instance0;
typedef __s0_Bool_instance0 __s0_S1_instance0;

typedef __s0_Bool_instance0 __s0_U1;
typedef __s0_Bool_instance0 __s0_S1;

typedef void* __Type;


struct SELF_REF {
    size_t index;
    size_t offset;
};

#define STACK_SIZE (1024 * 1024 * 1) // 1 MB


struct __s0_Context_instance0;
__s0_Context_instance0* global_context;

union _reg {
	u8 u8;
	u16 u16;
	u32 u32;
	u64 u64;
	s8 s8;
	s16 s16;
	s32 s32;
	s64 s64;
	void* ptr;
	f32 f32;
	f64 f64;
};

typedef _reg (__stdcall *_STD_Function_)(char*& stack_pointer);
typedef _reg (__cdecl *_CDECL_Function_)(char*& stack_pointer);
typedef _reg (*_Function_)(char*& stack_pointer);


bool running_at_compile_time() {
	return false;
}

void __ccpanic() {
	//printf("*** PANIC ***");
    s64* a = nullptr;
    *a = 0;
}

void __ccufr(const char* function_name) {
	//printf ("'%s' is ONLY available at compiletime!\nExiting...\n", function_name);
    s64* a = nullptr;
    *a = 0;
}
/*
// printf fix
__Void bc_printf(__U8* format, ...) {
	va_list list;
	va_start(list, format);

	vprintf((const char*)format, list);
}

__Void bc_sprintf(__U8* buffer, __U8* format, ...) {
	va_list list;
	va_start(list, format);

	vsprintf((char*)buffer, (const char*)format, list);
}
*/
#define IMPORT_OUTSIDE extern "C" __declspec(dllimport)

#define IB_DEF(x) template<typename T> __s0_U##x IB##x(T input) { return *(__s0_U##x *)(&input); }

IB_DEF(8);
IB_DEF(16);
IB_DEF(32);
IB_DEF(64);
