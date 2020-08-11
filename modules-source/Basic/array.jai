array_unordered_remove :: inline (array: *[..] $T, item: T) -> S64 {
    removed: S64 = 0;
    size := size_of(T);

    for i : 0..array.count-1 {
        current := cast (*U8) array.data + i * size;
        if (memcmp(current, *item, xx size) == 0) {
            source := cast (*U8) array.data + (array.count - 1) * size;
            memcpy(current, source, xx size);

            array.count -= 1;
            removed += 1;
            i -= 1;
        }
    }
    
    return removed;
}

array_unordered_remove_by_index :: inline (array: *[..] $T, index: S64) -> S64 {
    assert(index >= 0);
    assert(index < array.count);
    
    size := size_of(T);

    current := cast (*U8) array.data + index * size;      
    source := cast (*U8) array.data + (array.count - 1) * size;
    memcpy(current, source, xx size);

    array.count -= 1;   
    return 1;
}


array_ordered_remove_by_index :: inline (array_pointer: *[..] $T, index: S64) {
    assert(index >= 0);
    assert(index < array_pointer.count);
    
    array := << array_pointer;

    for i: index..array.count-2 { array[i] = array[i+1]; }


    array_pointer.count -= 1;
}

array_find :: (array: [] $T, item: T) -> S64 {
    for array {
        if it == item { return it_index; }
    }
    return -1;  // Not found.
}

array_add :: (array: *[..] $T, item: T) { 
    if array.count >= array.allocated {
        reserve := 2 * array.allocated;
        if reserve < 8 { reserve = 8; }

        array_reserve(array, reserve);
    }

    array.data[array.count] = item;
    array.count += 1;
}


array_add_if_unique :: (array: *[..] $T, item: T) -> S64 {   // Return true if added; also return index.
    index := array_find(<< array, item);
    if index != -1 { return -1; }

    array_add(array, item);
    return array.count-1;
}
                

array_reserve :: (array: *[..] $T, reserve: S64) {
    if reserve <= array.allocated return;

    size := size_of(T);
    num_bytes := reserve * size;

    if !array.allocator {
        array.allocator = context.allocator;
        array.allocator_data = context.allocator_data;
    }

    assert(array.allocator != null);
    allocator := array.allocator;

    new_memory := allocator(Allocator_Mode.RESIZE, num_bytes, array.count * size, array.data, array.allocator_data, 0);
    assert(new_memory != null);

    array.data = new_memory;
    array.allocated = reserve;
}

array_reset :: (array: *[..] $T) {
    // @Incomplete: If we allocated a lot of RAM, release it?
    array.count = 0;
}

find_empty_slot :: (array: [] * $T) -> S64 {
    for array {
        if it == null { return it_index; }
    }
    return -1;
}
