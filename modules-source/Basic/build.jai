// NOTE(Wase): DON'T CHANGE
Optimization_Level :: enum U8 {
    DEBUG   : 0,
    RELEASE : 1
}

// NOTE(Wase): DON'T CHANGE
Array_Bounds_Check_Mode :: enum U8 {
    OFF    : 0,
    ON     : 1,
    ALWAYS : 2
}

Build_Options :: struct @@type_build_options {
    optimization_level  : Optimization_Level        @@type_build_options_field("optimization_level")
    array_bounds_check  : Array_Bounds_Check_Mode   @@type_build_options_field("array_bounds_check")

    executable_name     : String                    @@type_build_options_field("executable_name")
    output_path         : String                    @@type_build_options_field("output_path")

    generate_code       : Bool                      @@type_build_options_field("generate_code") 

    emit_line_directives: Bool
}

build_options: Build_Options @@build_options