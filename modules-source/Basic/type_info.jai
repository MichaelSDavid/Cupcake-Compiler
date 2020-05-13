// TODO(Wase): Add location information to struct?

_type_table: [] *Type_Info @@typeinfo_table

Type_Info_Tag :: enum U8 @@typeinfo_tag {
	VOID 		: 0,	 @@typeinfo_tag_field("void")
	INTEGER 	: 1,	 @@typeinfo_tag_field("integer")
	FLOAT 		: 2,	 @@typeinfo_tag_field("float")
	BOOL 		: 3,	 @@typeinfo_tag_field("boolean")
	POINTER 	: 4,	 @@typeinfo_tag_field("pointer")
	STRUCT 		: 5,	 @@typeinfo_tag_field("structure")
	ENUM 		: 6,	 @@typeinfo_tag_field("enum")
	ARRAY 		: 7,	 @@typeinfo_tag_field("array")
	STRING 		: 8,	 @@typeinfo_tag_field("string")
	ALIAS 		: 9,	 @@typeinfo_tag_field("alias")
	PROCEDURE 	: 10,	 @@typeinfo_tag_field("procedure")
	VARIADIC 	: 11,	 @@typeinfo_tag_field("variadic")	// NOTE(Wase): NEVER USED
	TYPE 		: 12,	 @@typeinfo_tag_field("type")
}

Type_Info :: struct 
	@@typeinfo_base 
{
	// NOTE(Wase): This is a better name! But I am following Jons way ATM. 
	//tag: Type_Info_Tag.strict 
	type: Type_Info_Tag.strict 
}

Type_Info_Integer :: struct 
	@@typeinfo_integer 
{
	using info: Type_Info

	size_in_bits: U32
	signed: Bool
}

Type_Info_Float :: struct 
	@@typeinfo_float
{
	using info: Type_Info

	size_in_bits: U32
}

Type_Info_Pointer :: struct
	@@typeinfo_pointer
{
	using info: Type_Info

	pointer_to: *Type_Info
}

Type_Info_Struct :: struct
	@@typeinfo_struct
{
	using info: Type_Info
	name: String
	size_in_bits: U32

	members: [] Type_Info_Struct_Member
	arguments: [] Argument

	Argument :: struct @@typeinfo_struct_argument {
		name: String
		value: Any
	}
}

Type_Info_Struct_Member :: struct 
	@@typeinfo_struct_member
{
	name: String
	offset_in_bytes: U32 

	type: *Type_Info
    notes: [] Type_Info_Note;

	flags : U32;
	constant_pointer: *Void;

    CONSTANT :: 0x1
    IMPORTED :: 0x2
    USING    :: 0x4
}

Type_Info_Enum :: struct
	@@typeinfo_enum
{
	using info: Type_Info

	name: String
	internal_type: *Type_Info

	names: [] String
	values: [] *Void
}

Type_Info_Array :: struct
	@@typeinfo_array
{
	using info: Type_Info

	element_type : *Type_Info
	soa_packing: S32 // -1 means no SOA. 0 means no size limit. >0 is AOSOA of that chunk size.

    array_type: U32
    array_count: S64  // -1 unless this array is FIXED.

    // These are the array types:
    FIXED   :: 0;
    STATIC  :: 1;
    DYNAMIC :: 2;
}

Type_Info_Alias :: struct
	@@typeinfo_alias
{
	using info: Type_Info

	name: String
	base_type: *Type_Info
}

Type_Info_Procedure :: struct
	@@typeinfo_procedure
{
	using info: Type_Info

	argument_types	: [] *Type_Info
	return_types	: [] *Type_Info
}

Type_Info_Note :: struct 
	@@typeinfo_note_data 
{
	name: String
	values: [] Any
}
