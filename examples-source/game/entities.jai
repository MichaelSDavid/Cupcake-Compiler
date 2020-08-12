Entity_Manager :: struct {{
    batches: [..] *Entity_Batch;
}

BATCH_SIZE :: 100
Entity_Batch :: struct {
    entities: [BATCH_SIZE] Entity;
    occupied: [BATCH_SIZE] Bool;
}

batch_find_empty :: (using batch: *Entity_Batch) -> S64 {
    for occupied {
        if !it { return it_index; }
    }

    return -1;
}

register_entity :: (using manager: *Entity_Manager) -> *Entity {
    for batch : batches {
        found := batch_find_empty(batch);
        if found >= 0 {
            entity := *batch.entities[found];
            entity.entity_slot = cast(U32) found;
            entity.entity_batch = cast(U32) it_index;
            entity.alive = true;

            batch.occupied[found] = true;
            return entity;
        } 
    }

    batch := new Entity_Batch;
    array_add(*batches, batch);

    found := batch_find_empty(batch);
    if found >= 0 {
        entity := *batch.entities[found];
        entity.entity_slot = cast(U32) found;
        entity.entity_batch = cast(U32) batches.count - 1;
        entity.alive = true;

        batch.occupied[found] = true;
        return entity;
    } 

    print("ERROR: No space for entities left.");
    return null;
}

unregister_entity :: (using manager: *Entity_Manager, entity: *Entity) {
    batches[entity.entity_batch].occupied[entity.entity_slot] = false;
}

Entity :: struct {
    position: Vector2;
    velocity: Vector2;
    size: Vector2;

    texture: *Texture_Map;
    alive: Bool = true;

    entity_slot: U32;
    entity_batch: U32;
    entity_type: Type;
    derivied_pointer: *Void;
}

Invader :: struct {
    using entity: *Entity;

    sleep_countdown: F64;
    target_position: Vector2;

    update_procedure: (invader: *Invader, delta_time: F64) -> Void;
}

Player :: struct {
    using entity: *Entity;

    bullets: S64 = 0; // NOTE(Wase): bullets + 1 = how many bullets the ship shootin'
    shot_index: S64 = 0;

    vshot_time: F64 = 0;
    shield_time: F64 = 0;
    fire_cooldown: F64;
}

Bullet :: struct {
    using entity: *Entity;

    color: Vector4;
    direction: Vector2;
    lifetime: F64 = 3;

    emitter: *Particle_Emitter;
    player_friendly := true;
}

Pickup_Type :: enum {
    Extra_Bullet,
    V_Shot,
    Shield
}

Pickup :: struct {
    using entity: *Entity;

    type: Pickup_Type;
    direction: Vector2;
}

// NOTE(Wase): Particle_Emitter is also an entity.

Make :: (manager: *Entity_Manager, $$ type: Type, x: F32, y: F32) -> *type {
    result := new type;

    result.entity = register_entity(manager);
    result.entity.derivied_pointer = result;
    result.entity_type = type;
    result.texture = null;

    result.position.x = x;
    result.position.y = y;

    return result;
}

Delete :: (manager: *Entity_Manager, entity: *Entity) {
    delete entity.derivied_pointer;
    unregister_entity(manager, entity);
}

Down :: inline (using entity: *Entity, $$ target: Type) -> *target {
    return cast(*target) derivied_pointer;
}
