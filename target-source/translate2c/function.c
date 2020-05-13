// FUNCTIONS

typedef __s0_Workspace __Workspace;
typedef __s0_Build_Options_instance0 __Build_Options;
typedef __s0_Bool_instance0 __Bool;
typedef __s0_String_instance0 __String;
typedef __s0_Context_instance0 __Context;
typedef __s0_Static_Array_instance0 __Array;
typedef __s0_Compiler_Message_instance0 __Compiler_Message;

__Void* get_workspace(__Workspace workspace_id, __Context* context) {
	__ccufr("get_workspace");
	return false;
}

 __Build_Options compiler_get_build_options(__Workspace workspace_id, __Context* context) {
 	__ccufr("compiler_get_build_options");
	return {};
}

__Void compiler_update_build_options(__Workspace workspace_id, __Build_Options options, __Context* context) {
 	__ccufr("compiler_update_build_options");
}

__Bool compiler_add_build_file(__Workspace workspace_id, __String file_path, __Context* context) {
 	__ccufr("compiler_add_build_file");
	return true;
}

__Bool compiler_add_build_string(__Workspace workspace_id, __String code, __Context*  context) {
 	__ccufr("compiler_add_build_string");
	return false;
}

__Void compiler_begin_intercept(__Workspace workspace_id, __Context*  context) {
 	__ccufr("compiler_begin_intercept");
}

__Void compiler_end_intercept(__Workspace workspace_id, __Context*  context) {
 	__ccufr("compiler_end_intercept");
}

__Compiler_Message* compiler_wait_for_message(__Context*  context) { 
 	__ccufr("compiler_wait_for_message");
	return nullptr;
}

__Workspace compiler_create_workspace(__String name, __Context*  context) { 
 	__ccufr("compiler_create_workspace");
	return (__Workspace)0;
}

__Workspace compiler_current_workspace(__Context* context) {
	__ccufr("compiler_current_workspace");
	return (__Workspace)0;
}

void compiler_get_type_table(__Array* array, __Context* context) {
	array->m_count = 0;
	array->m_data = nullptr;
}

__Workspace get_current_workspace(__Context* context) {
	__ccufr("get_current_workspace");
	return (__Workspace)0;
}

__S32 _sprintf(char* buffer, const char* format, ...) {
	va_list v;
	va_start(v, format);

	return vsprintf(buffer, format, v);
}

__S32 _printf(const char* format, ...) {
	va_list v;
	va_start(v, format);

	return vprintf(format, v);
}


FILE* _fopen(char* filename, char* mode) {
	return fopen(filename, mode);
}

size_t _fread(char* buffer, size_t esize, size_t ecount, FILE* file) {
	return fread(buffer, esize, ecount, file);
}

size_t _fclose(FILE* stream) {
	return fclose(stream);
}


size_t _fseek(FILE* stream, s32 offset, s32 origin) {
	return fseek(stream, offset, origin);
}

size_t _ftell(FILE* stream) {
	return ftell(stream);
}

/*

void __bytecode_printf(__String format, ...) { 
	va_list v;
	va_start(v, format);

	char buffer[1024];
	for(auto i = 0; i < format.m_count; i++)
		((u8*)buffer)[i] = ((u8*)format.m_data)[i];
	buffer[format.m_count] = 0;
	vprintf(buffer, v);
	va_end(v);
}

__S32 __bytecode_sprintf(char* output, __String format, ...) {
	va_list v;
	va_start(v, format);

	char buffer[1024];
	for(auto i = 0; i < format.m_count; i++)
		((u8*)buffer)[i] = ((u8*)format.m_data)[i];
	buffer[format.m_count] = 0;
	auto s = vsprintf(output, buffer, v);
	va_end(v);
	return s;
}

__Void* __bytecode_alloc(__S32 size, __Context* context) {
	return malloc((size_t) size);
}

__Void __bytecode_free(__Void* ptr, __Context* context) {
	free(ptr);
}

float __sinf(float r) { 
	return sinf(r);
}

 float __cosf(float r) {
	return cosf(r);
}

 float __tanf(float r) {
	return tanf(r);
}

 float __sqrtf(float r) {
	return sqrtf(r);
}

float __powf(float a, float b) {
	return powf(a, b);
}

double __fmod(double a, double b) {
	return fmod(a, b);
}

double __atan2(double a, double b) {
	return atan2(a, b);
}

__S32 __sprintf(char* buffer, const char* format, ...) {
	va_list v;
	va_start(v, format);

	return vsprintf(buffer, format, v);
}

__S32 __sscanf(char* buffer, const char* format, ...) {
	va_list v;
	va_start(v, format);

	return vsscanf(buffer, format, v);
}

double __sin(double r) { 
	return sin(r);
}

double __cos(double r) {
	return cos(r);
}

double __tanf(double r) {
	return tan(r);
}

double __sqrt(double r) {
	return sqrt(r);
}

double __pow(double a, double b) {
	return pow(a, b);
}

double __floor(double a) {
	return floor(a);
}

double __fabs(double a) {
	return fabs(a);
}

__S32 __abs(__S32 a) {
	return abs(a);
}*/

__S32 __stdcall __jai_windows_thread_entry_proc(void* parameter) {
	auto thread = (__s0_Thread_instance0*)parameter;
	auto func = thread->m_proc;

	auto context = (__s0_Context_instance0*)malloc(sizeof(__s0_Context_instance0));
	memcpy(context, global_context, sizeof(__s0_Context_instance0));

	auto status = ((__S64(*)(__s0_Thread_instance0*, __s0_Context_instance0*))func)(thread, context);

    // TODO(Wase): What about if a thread is terminated???
    free(context);
	return status;
}

/*
// NOTE(Wase): What about functions that don't expect contextes? Maybe
// only expect function that uses contexts
__S32 __stdcall __jai_windows_thread_entry_proc(void* parameter) {
	auto thread = (__s0_Thread*)parameter;
	auto func = (_Function_)thread->m_proc;

	auto stack_data = (char*)malloc(STACK_SIZE);
	auto stack_pointer = stack_data + STACK_SIZE;

	auto context = (__s0_Context*)malloc(sizeof(__s0_Context));
	memcpy(context, global_context, sizeof(__s0_Context));


	_reg r14{};
	_reg r00{};
	r14.ptr = stack_pointer;

	// PUSH CONTEXT
	(r14).u64 -= sizeof(size_t);
    *((__Context**)((r14).ptr)) = context;

	// PUSH THREAD
	(r14).u64 -= sizeof(size_t);
    *((__s0_Thread**)((r14).ptr)) = thread;

	// PUSH RETRUN PTR
	(r14).u64 -= sizeof(size_t);
    stack_pointer = (char*)(r14.ptr);
	//r00 = func(stack_pointer);

    // TODO(Wase): What about if a thread is terminated???
    free(context);
    free(stack_data);

	return (r00).s32;
}
*/