S64 :: struct #empty @@type_size(64) @@type_integer(false);
S32 :: struct #empty @@type_size(32) @@type_integer(false);
S16 :: struct #empty @@type_size(16) @@type_integer(false);
S8  :: struct #empty @@type_size(8)  @@type_integer(false);

U64 :: struct #empty @@type_size(64) @@type_integer(true);
U32 :: struct #empty @@type_size(32) @@type_integer(true);
U16 :: struct #empty @@type_size(16) @@type_integer(true);
U8  :: struct #empty @@type_size(8)  @@type_integer(true);

F64 :: struct #empty @@type_size(64) @@type_float;
F32 :: struct #empty @@type_size(32) @@type_float;

Bool :: struct #empty @@type_size(1) @@type_boolean;

Int :: #type S64;
Float :: #type F32;

// JONATHAN BLOW COMPATIBILITY LAYER
s64 :: #type S64;
s32 :: #type S32;
s16 :: #type S16;
s8  :: #type S8 ;

u64 :: #type U64;
u32 :: #type U32;
u16 :: #type U16;
u8  :: #type U8;

f64 :: #type F64;
f32 :: #type F32;

float64 :: #type F64;
float32 :: #type F32;

int :: #type S64;
float :: #type F32;

//

String :: struct @@type_string
{
	count 	: S64 @@type_string_field("count");
	data 	: *U8 @@type_string_field("data");
}

Static_Array :: struct @@type_array
{
	count 	: S64	@@type_array_field("count");
	data 	: *Void	@@type_array_field("data");
}

Dynamic_Array :: struct @@type_dynamic_array
{
	count 			: S64		@@type_dynamic_array_field("count");
	allocated 		: S64		@@type_dynamic_array_field("capacity");
	data 			: *Void		@@type_dynamic_array_field("data");
	allocator 		: Allocator	@@type_dynamic_array_field("allocator");
	allocator_data 	: *Void		@@type_dynamic_array_field("allocator_data");
}

SOA_Pointer :: struct @@type_soa_pointer
{
    data  : *Void @@type_soa_pointer_field("data");
    index : U32   @@type_soa_pointer_field("index");
    count : U32   @@type_soa_pointer_field("count");
}

Any :: struct @@type_any
{
	value_pointer: 	*Void		@@type_any_field("value_pointer");
	type: 			*Type_Info	@@type_any_field("type");
}

Allocator :: #type (
	mode 				: Allocator_Mode, 
	size 				: S64, 
	old_size 			: S64, 
	old_memory_pointer 	: *Void, 
	allocator_data 		: *Void, 
	options 			: S64) -> *Void 
	@@type_allocator_procedure

Logger :: #type (
	message 	: String, 
	ident 		: String, 
	mode 		: Log_Mode, 
	data 		: *Void) -> Void 
	@@type_logger_procedure

Allocator_Mode :: enum { 
    ALLOCATE  : 0,
    RESIZE    : 1,
    FREE      : 2,
    FREE_ALL  : 3
}

Log_Mode :: enum {
    NONE     : 0,
    MINIMAL  : 1,
    EVERYDAY : 2,
    VERBOSE  : 3
}

Context :: struct @@type_context 
{
    thread_index   : U32		@@type_context_field("thread_index");

    user_index     : U32		@@type_context_field("user_index");
    user_data      : *Void		@@type_context_field("user_data");

    allocator      : Allocator	@@type_context_field("allocator");
    allocator_data : *Void 		@@type_context_field("allocator_data");

    logger         : Logger		@@type_context_field("logger");
    logger_data    : *Void		@@type_context_field("logger_data");
}
