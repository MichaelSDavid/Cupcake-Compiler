#import "TypeInfo.jai";

STRING_BUFFER_LENGTH :: 4096;
String_Buffer :: struct {
    data: [STRING_BUFFER_LENGTH] U8;
    count: S64;
}

Formatter :: struct {
    value: Any;
}

FormatInt :: struct {
    using formatter: Formatter;

    base := 10;
    minimum_digits := -1;
}

FormatFloat :: struct {
    using formatter: Formatter;

    trailing_width := -1;
    scientific_notation := false;
}

//

print :: (any: Any) -> printed_bytes: S64 {
    buffer: String_Buffer;

    buffer_append_any(*buffer, any);
    output_buffer(*buffer);

    return buffer.count;
}

print :: (format: String, args: ..) -> printed_bytes: S64 {
    buffer: String_Buffer;

    print_to_buffer(*buffer, format, ..args);
    output_buffer(*buffer);

    return buffer.count;
}

sprint :: (buffer: *String_Buffer, format: String, args: ..) -> count: S64 {
    current_count := buffer.count;

    print_to_buffer(buffer, format, ..args);
    return buffer.count - current_count;
}

buffer_append_string :: (buffer: *String_Buffer, str: String) {
    if buffer.count + str.count >= STRING_BUFFER_LENGTH { return; }

    A := buffer.data.data + buffer.count; // TODO(Wase): buffer.data + buffer.count should work
    for ch: str {
        << A = ch;
        A += 1;
    }

    buffer.count += str.count;
}

buffer_append_character :: (buffer: *String_Buffer, ch: U8) {
    if buffer.count + 1 >= STRING_BUFFER_LENGTH { return; }

    A := buffer.data.data + buffer.count; // TODO(Wase): buffer.data + buffer.count should work
    << A = ch;
    buffer.count += 1;
}

buffer_append_integer :: (buffer: *String_Buffer, format: FormatInt) {
    value := format.value;
    info := value.type;

    assert(info.type == Type_Info_Tag.INTEGER);
    integer_info := cast(*Type_Info_Integer) info;

    length := format.minimum_digits;
    if length < 0 length = 64; // TODO(Wase): Make this more reliable
    if buffer.count + length >= STRING_BUFFER_LENGTH { return; }

    integer: U64;
    if format.base == 10 {
        if integer_info.signed {
            signed_integer := get_signed_integer_by_size(value.value_pointer, integer_info.size_in_bits);

            if signed_integer < 0 {
                buffer_append_character(buffer, #char "-");
                integer = cast(U64) -signed_integer;
            } else
                integer = cast(U64)  signed_integer;
        } else
            integer = get_unsigned_integer_by_size(value.value_pointer, integer_info.size_in_bits);
    } else {
        integer = get_unsigned_integer_by_size(value.value_pointer, integer_info.size_in_bits);
    }

    buffer_append_integer_by_base(buffer, integer, format);


    buffer_append_integer_by_base :: (buffer: *String_Buffer, value: U64, format: FormatInt) {
        base_64_characters :: "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_.";

        base := cast(U64) format.base;
        assert(base >=  2);
        assert(base <= 64);

        digits := format.minimum_digits;
        if digits > 64 { digits = 64; }
        if digits == 0 { return; }

        output: [64] U8;
        buffer_end := output.data + 64;
        buffer_ptr := buffer_end;

        while value || digits > 0 {
            place := value % base;
            value = value / base;

            buffer_ptr -= 1;
            << buffer_ptr = base_64_characters[place];

            digits -= 1;
        }

        // TODO(Wase): Test this
        while digits > 0 || digits == -1 {
            buffer_ptr -= 1;
            << buffer_ptr = #char "0";
            digits -= 1;
        }

        str: String;
        str.data = buffer_ptr;
        str.count = (buffer_end - buffer_ptr);
        buffer_append_string(buffer, str);
    }

    get_signed_integer_by_size :: (ptr: *Void, size: U32) -> S64 {
        if size == 64 return << cast(* S64) ptr;
        if size == 32 return << cast(* S32) ptr;
        if size == 16 return << cast(* S16) ptr;
        if size ==  8 return << cast(* S8)  ptr;
    
        return -1;
    }

    get_unsigned_integer_by_size :: (ptr: *Void, size: U32) -> U64  {
        if size == 64 return << cast(* U64) ptr;
        if size == 32 return << cast(* U32) ptr;
        if size == 16 return << cast(* U16) ptr;
        if size ==  8 return << cast(* U8)  ptr;
    
        return -1;
    }
}

buffer_append_float :: (buffer: *String_Buffer, format: FormatFloat) {
    value := format.value;
    info := value.type;

    assert(info.type == Type_Info_Tag.FLOAT);
    float_info := cast(*Type_Info_Float) info;

    count := 0;
    output: [1024] U8;
    if float_info.size_in_bits == 64 {
        f := << cast(*F64) format.value.value_pointer;;
        format := "%f\0"; // NOTE(Wase): Fake C string
        count = sprintf(output.data, format.data, f);
    } else {
        f := << cast(*F32) format.value.value_pointer;
        format := "%f\0"; // NOTE(Wase): Fake C string
        count = sprintf(output.data, format.data, f);
    }

    str: String = ---;
    str.data = output.data;
    str.count = count;

    buffer_append_string(buffer, str);
}

buffer_append_struct :: (buffer: *String_Buffer, any: Any, struct_info: *Type_Info_Struct) {
    ptr := cast(*U8) any.value_pointer;

    buffer_append_string(buffer, struct_info.name);
    buffer_append_string(buffer, " { ");

    for member: struct_info.members {
        if (member.flags & member.CONSTANT) { continue; }

        if it_index != 0 { buffer_append_string(buffer, ", "); }

        member_ptr := ptr + member.offset_in_bytes;
        member_any: Any;
        member_any.type = member.type;
        member_any.value_pointer = member_ptr;

        buffer_append_string(buffer, member.name);
        buffer_append_string(buffer, " = ");
        buffer_append_any(buffer, member_any);
    }
    
    buffer_append_string(buffer, " }");
}

buffer_append_type :: (buffer: *String_Buffer, info: *Type_Info) {
    using Type_Info_Tag;
    tag := info.type;

    if tag == INTEGER {
        integer_info := cast(*Type_Info_Integer) info;
        if integer_info.signed {
            print_to_buffer(buffer, "S%", integer_info.size_in_bits);
        } else {
            print_to_buffer(buffer, "U%", integer_info.size_in_bits);
        }
        return;
    }

    if tag == FLOAT {
        float_info := cast(*Type_Info_Float) info;
        print_to_buffer(buffer, "F%", float_info.size_in_bits);
        return;
    }

    if tag == STRING {
        buffer_append_string(buffer, "String");
        return;
    }

    if tag == TYPE {
        buffer_append_string(buffer, "Type");
        return;
    }

    if tag == BOOL {
        buffer_append_string(buffer, "Bool");
        return;
    }

    if tag == POINTER {
        pointer_info := cast(*Type_Info_Pointer) info;
        buffer_append_character(buffer, #char "*");
        buffer_append_type(buffer, pointer_info.pointer_to);
        return;
    }

    if tag == ALIAS {
        alias_info := cast(*Type_Info_Alias) info;
        buffer_append_string(buffer, alias_info.name);
        return;
    }

    if tag == STRUCT {
        struct_info := cast(*Type_Info_Struct) info;
        buffer_append_string(buffer, struct_info.name);
        return;
    }

    if tag == PROCEDURE {
        procedure_info := cast(*Type_Info_Procedure) info;
        buffer_append_string(buffer, "(procedure)");
        return;
    }

    buffer_append_string(buffer, "(unknown type)");
}

buffer_append_any :: (buffer: *String_Buffer, any: Any) {
    using Type_Info_Tag;

    info := any.type;
    tag := info.type;
    ptr := any.value_pointer;

    if tag == INTEGER {
        format: FormatInt;
        format.value = any;

        buffer_append_integer(buffer, format);
        return;
    }

    if tag == FLOAT {
        format: FormatFloat;
        format.value = any;

        buffer_append_float(buffer, format);
        return;
    }

    if tag == POINTER {
        ptr_value := << cast(**Void) ptr;
        ptr_integer := cast(U64) ptr_value;

        format: FormatInt;
        format.value = ptr_integer;
        format.base = 16;
        format.minimum_digits = 8;

        buffer_append_string(buffer, "0x");
        buffer_append_integer(buffer, format);
        return;
    }

    if tag == STRING {
        buffer_append_string(buffer, << cast(*String) ptr);
        return;
    }

    if tag == ALIAS {
        alias_info := cast(*Type_Info_Alias) info;

        alias_any: Any;
        alias_any.value_pointer = any.value_pointer;
        alias_any.type = alias_info.base_type;
        buffer_append_any(buffer, alias_any);
        return;
    }

    if tag == STRUCT {
        struct_info := cast(*Type_Info_Struct) info; // TODO(Wase): Should you be able to use keywords as names?
        print_func := find_print_function(struct_info);

        if print_func {
            print_func(buffer, any);
            return;
        }

        buffer_append_struct(buffer, any, struct_info);
        return;
    }

    if tag == ENUM {
        enum_info := cast(*Type_Info_Enum) info;

        buffer_append_string(buffer, enum_info.name);
        buffer_append_string(buffer, ".");

        value_size := size_from_type_info(enum_info.internal_type);
        if value_size < 0 {
            buffer_append_string(buffer, "(unknown)");
            return;
        }

        for name: enum_info.names {
            value_ptr := enum_info.values[it_index];

            if !memcmp(any.value_pointer, value_ptr, xx value_size) {
                buffer_append_string(buffer, name);
                return;
            }
        }

        buffer_append_string(buffer, "(unknown)");
        return;
    }

    if tag == TYPE {
        new_type_info := << cast(**Type_Info) ptr;
        buffer_append_type(buffer, new_type_info);
        return;
    }

    if tag == PROCEDURE {
        ptr_value := << cast(**Void) ptr;
        ptr_procedure := cast(U64) ptr_value;

        format: FormatInt;
        format.value = ptr_procedure;
        format.base = 16;
        format.minimum_digits = 8;

        buffer_append_string(buffer, "(procedure) 0x");
        buffer_append_integer(buffer, format);
        return;
    }

    if tag == BOOL {
        bool_value := << cast(*Bool) ptr;
        
        if bool_value { 
            buffer_append_string(buffer, "true")
        } else { 
            buffer_append_string(buffer, "false")
        }
        return;
    }

    buffer_append_string(buffer, "(unknown type)");
}

Printer :: #type (buffer: *String_Buffer, value: Any) -> Void
find_print_function :: (info: *Type_Info_Struct) -> Printer {
    for member: info.members {
        if (member.flags & Type_Info_Struct_Member.CONSTANT) == 0 { continue; }

        if member.name != "print" { continue; }

        // TODO(Wase): Test procedural type?
        return << cast(* Printer) member.constant_pointer;
    }

    return null;
}

//

print_to_buffer :: (buffer: *String_Buffer, format: String, args: ..) {
    arg_index := 0;

    previous_hash := false;
    for ch: format {

        if ch != #char "%" {
            if previous_hash { 
                if arg_index >= args.count { 
                    print_to_buffer(buffer, "(missing argument #%)", arg_index);
                } else {
                    buffer_append_any(buffer, args[arg_index]);
                }

                arg_index += 1;
            }

            previous_hash = false;
            buffer_append_character(buffer, ch);
            continue;
        }

        if !previous_hash {
            previous_hash = true;
            continue;
        }

        buffer_append_character(buffer, #char "%");
    }

    if previous_hash { 
        if arg_index >= args.count { 
            print_to_buffer(buffer, "(missing argument #%)", arg_index);
            return;
        }

        buffer_append_any(buffer, args[arg_index]);
        arg_index += 1;
    }
}

//

output_buffer :: (buffer: *String_Buffer) {
    format := "%.*s\0"; // NOTE(Wase): Fake C string
    printf(format.data, cast(S32) buffer.count, buffer.data);
}
