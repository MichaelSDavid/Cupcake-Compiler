// NOTE(Wase): Copied from Blows code
// Needed for the generating of c code

Thread_Index :: #type S32;
Thread_Proc  :: #type (*Thread) -> S32;

HANDLE :: #type *Void

Thread_Os_Specific :: struct {
    windows_thread:    HANDLE;
    windows_thread_id: S32;
}

Thread :: struct {  // @Volatile! If you tweak with this, you need to change things like THREAD_STRUCT_STARTING_CONTEXT_OFFSET in the compiler's general.h and also in boilerplates.h
    index : Thread_Index;
    proc  : Thread_Proc;
    data  : *Void;
    workspace : Workspace;  // This will be 0 if running a final program, nonzero inside the compiler.
    
    starting_context: Context;
    use_this_starting_context := false;
    require_exit := false;

    using specific : Thread_Os_Specific;
}