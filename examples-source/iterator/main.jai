#import "../../modules/Print.jai"

// Copied from one of Jonathan Blows demos.
Table :: struct (Key_Type: Type, Value_Type: Type) {
    allocated:  S64
    count:      S64

    allocator: Allocator

    unfound_value: Value_Type

    Slot :: struct SOA {
        occupied: Bool
        hash: U32
        key: Key_Type
        value: Value_Type
    }

    Pair :: struct {
        key: Key_Type
        value: Value_Type
    }

    slots: [] Slot

    SIZE_MIN :: 32
}

allocate :: (table: *$T/Table, size: S64) {
    table.allocated = size

    new_context := context
    if table.allocator
        new_context.allocator = table.allocator

    push_context new_context {
        S :: table.Slot
        table.slots = new [size] S
        // TODO: table.slots = new [size] table.Slot
    }
}

expand :: (table: *$T/Table) {
    new_context := context
    if table.allocator
        new_context.allocator = table.allocator

    push_context new_context {
        old_slots := table.slots

        new_size := table.allocated * 2
        if new_size < table.SIZE_MIN
            new_size = table.SIZE_MIN

        allocate(table, new_size)

        for old_slots if it.occupied {
            put(table, it.key, it.value)
        }

        delete old_slots
    }
}

put :: (table: *$T/Table, key: T.Key_Type, value: T.Value_Type) {
    hash := get_hash(key)
    index := find_index(table, key, hash)

    if index == -1 {
        if table.count * 2 >= table.allocated
            expand(table)

        assert(table.count <= table.allocated)

        hash := get_hash(key) // TODO: Why not use the hash above??
        index = hash % table.allocated

        while table.slots[index].occupied {
            index += 1
            if index >= table.allocated
                index = 0
        }

        table.count += 1
    }

    slot := *table.slots[index]
    slot.value = value
    slot.key = key
    slot.occupied = true
    slot.hash = hash
}

find_index :: (table: *$T/Table, key: T.Key_Type, hash: U32) -> S64 {
    index := hash % table.allocated

    for 0..table.allocated {
        slot := table.slots[(index + it) % table.allocated]
        if slot.key == key
            return index
    }

    return -1
}

find :: (table: *$T/Table, key: T.Key_Type) -> T.Value_Type {
    index := find_index(table, key, get_hash(key))
    if index == -1 
        return table.unfound_value


    return table.slots[index].value
}

get_hash :: (value: S64) -> U32 {
    lower := cast(U32) (value & 0xFFFFFFFF)
    upper := cast(U32) ((value >> 32) & 0xFFFFFFFF)

    return lower + (lower ^ upper) + (lower & upper);
}

get_hash :: (value: String) -> U32 {
    hash: U32 = 5381
    for value hash = (hash << 5) + hash + it
    return hash
}

// Iterator Code
Table_Iterator :: struct (Table_Type: Type) {
    table: *Table_Type
    slot_index: S64
}

iterator_make :: (table: *$T/Table) -> Table_Iterator(T) {
    iterator: Table_Iterator(T) = ---
    iterator.table = table
    iterator.slot_index = 0

   while iterator.slot_index < iterator.table.slots.count {
        slot := *iterator.table.slots[iterator.slot_index]
        if slot.occupied break

        iterator.slot_index += 1
    }

    return iterator
}

iterator_next :: (using iterator: *$I/Table_Iterator) {
    slot_index += 1
    while slot_index < table.slots.count {
        slot := *table.slots[slot_index]

        if slot.occupied return;
        slot_index += 1
    }
}

iterator_get_value :: (using iterator: *$I/Table_Iterator) -> I.Table_Type.Pair, Bool {
    pair: I.Table_Type.Pair

    if slot_index < 0 || slot_index >= table.allocated
        return pair, false

    slot := *table.slots[slot_index]
    if !slot.occupied
        return pair, false

    pair.key = slot.key
    pair.value = slot.value
    return pair, true
}

iterator_remove :: (using iterator: *$I/Table_Iterator) {
    table.slots[slot_index].occupied = false
}

#run main()
main :: () {
    table: Table(String, S64)
    allocate(*table, 32)

    for 0..35 put(*table, "Hello", it)
    for 0..42 put(*table, "Sailor", it)

    found := find(*table, "Hello")
    print("\"Hello\" found is %\n", found)

    found = find(*table, "Sailor")
    print("\"Sailor\" found is %\n", found)
    
    pa := *table.slots[0].occupied
    pb := *table.slots[1].occupied

    print("pb - pa = %\n", pb - pa)
    print("\n")

    for table {
        print("Table[%]: %\n", it_index.slot_index, it)

        if(it.key == "Hello")
            remove;
    }

    print("\n")
    for table {
        print("Table[%]: %\n", it_index.slot_index, it)
    }
}
