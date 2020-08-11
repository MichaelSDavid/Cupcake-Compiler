
size_from_type_info :: (info: *Type_Info) -> S64 {
    using Type_Info_Tag;

    if info.type == INTEGER {
        integer_info := cast(*Type_Info_Integer) info;
        return integer_info.size_in_bits / 8;
    }

    if info.type == FLOAT {
        float_info := cast(*Type_Info_Float) info;
        return float_info.size_in_bits / 8;
    }

    if info.type == STRUCT {
        struct_info := cast(*Type_Info_Struct) info;
        return struct_info.size_in_bits / 8;
    }

    if info.type == ENUM {
        enum_info := cast(*Type_Info_Enum) info;
        return size_from_type_info(enum_info.internal_type);
    }

    if info.type == ALIAS {
        alias_info := cast(*Type_Info_Alias) info;
        return size_from_type_info(alias_info.base_type);
    }

    if info.type == POINTER || info.type == PROCEDURE {
        return size_of(*Void);
    }

    return -1;
}

type_info_remove_alias :: (info: *Type_Info) -> *Type_Info {
    using Type_Info_Tag;
    
    if !info { return null; }

    if info.type != ALIAS { return info; }

    alias := cast(*Type_Info_Alias) info;
    return alias.base_type;
}

type_argument_get_integer :: (fake_info: *Type_Info, argument_name: String) -> S64, Bool {
    using Type_Info_Tag;

    info := type_info_remove_alias(fake_info);
    if !info { return 0, false; }

    if info.type != STRUCT { return 0, false }

    structure := cast(*Type_Info_Struct) info;
    for argument: structure.arguments {
        ptr := argument.value.value_pointer;
        int_ptr := cast(*S64) ptr;

        if argument.name == argument_name {
            return << int_ptr, true;
        }
    }

    return 0, false;
}

type_argument_get_integer :: (type: Type, argument_name: String) -> S64, Bool { 
    // return type_argument_get_integer(type_info(type), argument_name);     // TODO(Wase): Return multiple values at the same time
    A, B := type_argument_get_integer(type_info(type), argument_name);
    return A, B;
}
