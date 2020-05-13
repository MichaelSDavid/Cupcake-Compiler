Workspace :: #type *Void

Compiler_Message :: struct {
    Kind :: enum U8 {
        UNKNOWN : 0,
        FILE    : 1,
        STRING  : 2,
        COMPILATION_PHASE : 3,
        TYPECHECK : 4, CODE_TYPECHECKED : 4,
        ERROR: 9,
        COMPLETE: 10,
    }

    kind        : Kind
    workspace   : Workspace
}


compiler_create_workspace       :: __cdecl (name := "") -> Workspace #compiler
compiler_destory_workspace       :: __cdecl (workspace: Workspace)  #compiler

compiler_get_build_options 		:: __cdecl (workspace: Workspace) -> Build_Options #compiler
compiler_update_build_options 	:: __cdecl (workspace: Workspace, options: Build_Options) #compiler

compiler_add_build_file         :: __cdecl (workspace: Workspace, file_path: String) -> Bool #compiler
compiler_add_build_string       :: __cdecl (workspace: Workspace, code: String) -> Bool #compiler

compiler_begin_intercept       :: __cdecl (workspace: Workspace) #compiler
compiler_end_intercept         :: __cdecl (workspace: Workspace) #compiler

compiler_wait_for_message       :: __cdecl () -> *Compiler_Message #compiler
running_at_compile_time         :: __cdecl #no_context () -> Bool #compiler

compiler_current_workspace      :: __cdecl () -> Workspace #compiler
compiler_get_type_table         :: __cdecl () -> [] *Type_Info #compiler

get_current_workspace      :: __cdecl () -> Workspace #compiler

compiler_modify_procedure:: (w: Workspace, d: *Void) { }
compiler_report_error    :: (filename: String, line_number: S64, error_text: String, args: ..) { }

compile_and_get_single_procedure :: (name: String, inputs: ..) -> *Void {
    return null;
}

// NOTE(Wase): I don't like these :(
add_build_file :: __cdecl (w: Workspace, filename: String) #compiler "add_build_file_on_workspace"
add_build_string :: __cdecl (w: Workspace, data: String) #compiler "add_build_string_on_workspace"
set_build_file_path :: __cdecl (w: Workspace, filename: String) #compiler "set_build_file_path_on_workspace"
update_build_options :: __cdecl (w: Workspace, options: Build_Options) #compiler "update_build_options_on_workspace"
get_build_options :: __cdecl (w: Workspace) -> Build_Options #compiler "get_build_options_on_workspace"

add_build_file :: __cdecl (filename: String) #compiler "add_build_file_on_current_workspace"
add_build_string :: __cdecl (data: String) #compiler "add_build_string_on_current_workspace"
set_build_file_path :: __cdecl (filename: String) #compiler "set_build_file_path_on_current_workspace"
update_build_options :: __cdecl (options: Build_Options) #compiler "update_build_options_on_current_workspace"
get_build_options :: __cdecl () -> Build_Options #compiler "get_build_options_on_current_workspace"

