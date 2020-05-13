// TODO(Wase): Rewrite without the C standard library
default_allocator :: (
    mode: Allocator_Mode, 
    size: S64, 
    old_size: S64, 
    old_memory_pointer: *Void, 
    allocator_data: *Void, 
    options: S64) -> *Void 
    @@default_allocator_procedure
{
    using Allocator_Mode

    inside_alloc :: inline (size: S64) -> *Void {
        // TODO(Wase): REMOVE C STANDARD
        // TODO(Wase): What happens if size > 4GB ???
        p := calloc(cast(S32) size);
        return p;
    }

    inside_free :: inline (pointer: *Void) {
        // TODO(Wase): REMOVE C STANDARD
        cfree(pointer)
    }

    inside_memory_copy :: inline (dst: *Void, src: *Void, size: S64) {
        // TODO(Wase): REMOVE C STANDARD
        memcpy(dst, src, cast(S32) size)
    }


    if mode == ALLOCATE 
        return inside_alloc(size)
    else if mode == RESIZE {
        // NOTE(Blow): For now, we dont even bother with realloc, just allocate, copy, free.
        result := inside_alloc(size);
        if result == null 
            return null

        if old_memory_pointer != null && old_size > 0 {
            inside_memory_copy(result, old_memory_pointer, old_size)
            inside_free(old_memory_pointer)
        }

        return result
    } else if mode == FREE {
        inside_free(old_memory_pointer)
        return null
    } else if mode == FREE_ALL {
        // NOTE(Blow):
        // @Incomplete: Not supported while we are using C malloc...
        // Use Windows heaps or else an off-the-shelf malloc that gives us control.
        // @Incomplete: Panic.
        // assert(false);

        panic()
        return null
    } else {
        // NOTE(Blow):
        // @Incomplete: Panic.
        // assert(false);   Don't want to pull in assert, as that currently does a printf, ugh!

        panic()
        return null
    }

    // TODO(Wase): Fix this error
    return null
}

default_logger :: (
    message : String, 
    ident   : String, 
    mode    : Log_Mode, 
    data    : *Void) 
    @@default_logger_procedure
{ 
    // TODO(Wase): Add something here!
    return;
}


// NOTE(Wase): Used for typechecking the alloc procedures
// TODO(Wase): have the type definition hardcoded, because the 
// user should not be able to change the type. If changed -> CRASH
__AllocProcedureType :: #type (size: S64) -> *Void  @@new_procedure_type
__FreeProcedureType :: #type (memory: *Void)        @@delete_procedure_type

alloc :: (size: S64) -> *Void @@new_procedure {
    return context.allocator(Allocator_Mode.ALLOCATE, size, 0, null, context.allocator_data, 0);
}

free :: (memory: *Void) @@delete_procedure {
    context.allocator(Allocator_Mode.FREE, 0, 0, memory, context.allocator_data, 0);
}

log :: (message: String, ident: String, mode: Log_Mode = Log_Mode.EVERYDAY) {
    context.logger(message, ident, mode, context.logger_data);
}

//

panic :: (print_stacktrace: Bool = false, skip_functions: S64 = 0) {
    // NOTE(Wase): Bytecode code is never executed
    // when running normally
    if print_stacktrace
        #bytecode { stacktrace skip_functions }

    #bytecode { hlt }

    // NOTE(Wase): Bad break?
    A : **Void
    << A = null
}

assert_at :: (
    condition: Bool,
    file: String,
    line: S64)
{
    if !condition {
        print("\n#----------------------------#\n")
        print("#    ****   ASSERT   ****    #\n")
        print("#----------------------------#\n")
        print(" file: %\n", cast(S32) file.count, file.data)
        print(" line: %\n", line)
        print("\n")

        // NOTE(Wase): Skip the last 2 procedures
        // 1. assert_at
        // 2. panic
        panic(true, 2)
    }
}

assert :: (
    condition: Bool, 
    print_stacktrace: Bool = true, 
    skip_functions: S64 = 2) 
{
    if !condition {
        print("\n#----------------------------#\n")
        print("#    ****   ASSERT   ****    #\n")
        print("#----------------------------#\n\n")

        // NOTE(Wase): Skip the last 'skip_functions' procedures
        // 1. assert_at
        // 2. panic
        panic(print_stacktrace, skip_functions)
    }
}

__ABCFailProcedureType :: #type (index: S64, limit: S64, file: String, line: S64) @@abc_fail_procedure_type
__array_bound_check :: (index: S64, limit: S64, file: String, line: S64)  @@abc_fail_procedure
{
    // TODO(Wase): Make this cleaner
    print("-- ABC --\n")
    print("(index: %) is out of bounds (limit: %), this occured at\n", index, limit);
    print(" file: %\n", cast(S32) file.count, file.data);
    print(" line: %\n", line);
    assert(false, true, 3)
}

// NOTE(Wase):  This function is requierd for any remove statement.
//              The item does not correspond to &array[index] but the 
//              stack address of the item from the for-loop
for_remove :: (array: *[..] $T, index: $B, item_ptr: *T) @@for_remove_procedure {
    array_unordered_remove_by_index(array, index)
}

// NOTE(Wase): Move out to the standard library later

copy_string :: (s: String) -> String {
    t : String
    if s.count == 0 
        return t

    t.count = s.count
    t.data = alloc(s.count)
    memcpy(t.data, s.data, xx s.count)

    return t;
}

to_c_string :: (s: String) -> *U8 {
    result : *U8 = alloc(s.count + 1)
    memcpy(result, s.data, xx s.count)
    result[s.count] = 0

    return result
}

to_string :: (s: *U8) -> String {
    strlen :: (x: *U8) -> S64 {
        count := 0
        while << x  { 
            x += 1;
            count += 1;
        }

        return count
    }

    length := strlen(s)

    result: String
    result.count = length
    result.data = cast(*U8) s
    return result
}

// TODO(Wase): Temp function until we add operator overloding
StringEqualProcedureType :: #type (left: String, right: String) -> Bool @@string_equal_procedure_type
string_equal :: (left: String, right: String) -> Bool @@string_equal_procedure
{
    if left.count != right.count 
        return false

    return memcmp(left.data, right.data, xx left.count) == 0
}

