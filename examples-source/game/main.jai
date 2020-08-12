/*
    Cupcake Demo:a

    Invader game clone from early demos of JAI by Jonathan Blow. The code uses stb-libraries (stb_imagae, stb_truetype) linked
    through a c library. The c library (opengl_library) also givs us an easy way to setup a window and opengl.

    The game will run when you hit compile because we are using the "#run game()" statement on line 85. Remove this if 
    you don't want to run the game every time you compile. After compiling a file will be outputted (path: ./output/output.cpp) 
    containing a cpp file with the convert code, from JAI to cpp.  

    - Julgodis
*/

#import "../../modules/Print.jai";
#import "../../modules/Math.jai";

#load "opengl.jai";
#load "opengl_draw.jai";
#load "resources.jai";
#load "random.jai";
#load "particles.jai";
#load "sound.jai";

#load "entities.jai";

WINDOW_WIDTH  :: 1024; 
WINDOW_HEIGHT :: 768;

initialize_time: F64;
game_time: F64;
delta_time: F64;

entity_manager: *Entity_Manager;

player_bullet_texture: *Texture_Map;
enemy_bullet_texture: *Texture_Map;
pickup_texture_extra: *Texture_Map;
pickup_texture_shield: *Texture_Map;
pickup_texture_spread: *Texture_Map;
smoke_texture: *Texture_Map;

bug_textures: [..] *Texture_Map;
player: *Player;
invader_count := 0;
level := 0;

font: *Font_Map;
sound_manager: *SoundManager;

keys: [Key_Code.count] Bool; 

game_create_window :: () -> *Void {
    handle: *Void ;
    create_window(WINDOW_WIDTH, WINDOW_HEIGHT, to_c_string("Cupcake Demo: Invaders!"), *handle);

    glEnable(_GL_BLEND);
    glBlendFunc(_GL_SRC_ALPHA, _GL_ONE_MINUS_SRC_ALPHA);
    glOrtho(0, WINDOW_WIDTH, WINDOW_HEIGHT, 0, -1, 1);

    glEnable(_GL_TEXTURE_2D);

    return handle;
}

spawn_invaders :: (level: S64) {
    amount := 8 + 8 * level;

    for 0..amount {
        invader := Make(entity_manager, Invader, 0, 0);
        invader.texture = bug_textures[random_get() % bug_textures.count];
        invader.size = make_vector2(60, 60);
        invader.update_procedure = bug_update_procedure_1;

        b :: 0.1;
        invader.target_position.x = WINDOW_WIDTH * random_get_within_range(b, 1.0-b);
        invader.target_position.y = WINDOW_HEIGHT * random_get_within_range(0.1, 0.6);

        invader.position.x = WINDOW_WIDTH * random_get_within_range(b, 1.0-b);
        invader.position.y = WINDOW_HEIGHT * random_get_within_range(0.1, 0.6) - WINDOW_HEIGHT;

        invader_count += 1;
    }
}

// NOTE(Wase): The C code needs a main procedure to function. [No arguments]
main :: () { game(); }

// Might need to change the resource paths locally on your end
#run game();
game :: () {
    handle := game_create_window();
    sound_manager = init_direct_sound(handle);

    music_data := load_sound(sound_manager, "resources/commando.wav");
    sound_manager.music_data = music_data;

    entity_manager = new Entity_Manager;
    font = font_load("resources/KarminaBold.ttf", 48);

    player_bullet_texture = texture_load("resources/player_bullet.png");
    enemy_bullet_texture = texture_load("resources/enemy_bullet.png");
    smoke_texture = texture_load("resources/smoke.png");
    pickup_texture_extra = texture_load("resources/pickup_extra_bullet.png");
    pickup_texture_shield = texture_load("resources/pickup_shield.png");
    pickup_texture_spread = texture_load("resources/pickup_v_shot.png");

    array_add(*bug_textures, texture_load("resources/bug1.png"));
    array_add(*bug_textures, texture_load("resources/bug2.png"));
    array_add(*bug_textures, texture_load("resources/bug3.png"));
    array_add(*bug_textures, texture_load("resources/bug4.png"));

    player = Make(entity_manager, Player, WINDOW_WIDTH/2, WINDOW_HEIGHT*0.5);
    player.texture = texture_load("resources/ship.png");
    player.size = make_vector2(60, 60);

    level = 0;
    spawn_invaders(level);

    initialize_time = get_time();
    game_time = 0;
    delta_time = 0;

    while true {
        current_time := get_time() - initialize_time;
        delta_time := current_time - game_time;
        game_time = current_time;

        sound_update(sound_manager);

        window_clear(0.05, 0.05, 0.05, 1);
        draw_background_gradient();

        event: Event;
        while get_next_event(*event) {
            using Event_Type;
            using event;

            if type == QUIT { return; }
            if type == KEYBOARD {
                if key_pressed == 1 {
                    keys[key_code] = true;
                } else {
                    keys[key_code] = false;
                }
            }
        }

        simulate(delta_time);
        for batch: entity_manager.batches {
            for occupied: batch.occupied {
                if !occupied then { continue; }

                using entity := *batch.entities[it_index];
                if !alive then { continue; }
                if entity_type == Particle_Emitter then {
                    draw_particle_emitter(Down(entity, Particle_Emitter));
                    continue;
                } else if entity_type == Player then {
                    player := Down(entity, Player);

                    shield_on := cos(cast(F32) game_time / 4) * 0.25 * 0.25 + 0.125;
                    shield_off := cast(F32) 1.0;

                    time := cast(F32) player.shield_time;
                    if time < 0 then time = 0;
                    if time > 8 then time = 8;

                    not_red := Lerp(shield_off, shield_on, time / 8.0);
                    glColor4f(1, not_red, not_red, 1);
                    draw_quad_texture(texture, position, size);
                    continue;
                }

                glColor4f(1, 1, 1, 1);
                draw_quad_texture(texture, position, size);
            }
        }

        if player {
            vshot_bar_position := make_vector2(WINDOW_WIDTH/2, WINDOW_HEIGHT - 40 - 10);
            shield_bar_position := make_vector2(WINDOW_WIDTH/2, WINDOW_HEIGHT - 10 - 10);

            vshot_bar_size := make_vector2(WINDOW_WIDTH/2, 20);
            shield_bar_size := make_vector2(WINDOW_WIDTH/2, 20);

            vshot_time := player.vshot_time;
            if vshot_time < 0 then { vshot_time = 0; }
            if vshot_time > 20 then { vshot_time = 20; }

            shield_time := player.shield_time;
            if shield_time < 0 then { shield_time = 0; }
            if shield_time > 8 then { shield_time = 8; }

            vshot_bar_size.x *= cast(F32) (vshot_time / 20.0);
            shield_bar_size.x *= cast(F32) (shield_time / 8.0);

            draw_quad_color(vshot_bar_position, vshot_bar_size, make_vector4(95.0/255.0, 162.0/255.0, 250.0/255.0, 1.0));
            draw_quad_color(shield_bar_position, shield_bar_size, make_vector4(250.0/255.0, 95.0/255.0, 95.0/255.0, 1.0));
        }

        glColor4f(1, 1, 1, 1);
        buffer: String_Buffer;
        sprint(*buffer, "Level: %", level);

        text: String;
        text.data = buffer.data.data;
        text.count = buffer.count;
        draw_text_center(font, text, make_vector2(WINDOW_WIDTH/2, 100));

        swap_buffers();
        update_window_events();
    }
}

bug_update_procedure_1 :: (using self: *Invader, delta_time: F64) {
    // pass
}

bug_update_procedure_2 :: (using self: *Invader, delta_time: F64) {
    rate :: 1.5;
    theta := game_time * TAU64 * rate;

    y := cos(theta);

    self.position.y += cast(F32) y * 4;
}

bug_update_procedure_3 :: (using self: *Invader, delta_time: F64) {
    rate :: 1.5;
    theta := game_time * TAU64 * rate;

    x := cos(theta);
    y := sin(theta);

    position.x += cast(F32) x * 1;
    position.y += cast(F32) y * 1;
}

aabb_collision_test :: (A: Vector4, B: Vector4) -> Bool {
    // TODO(Wase): Is there a better way?
    if (A.x > B.x && A.x < B.z) || (A.z > B.x && A.z < B.z) || (A.x < B.x && A.z > B.z) {
        if (A.y > B.y && A.y < B.w) || (A.w > B.y && A.w < B.w) || (A.y < B.y && A.w > B.w) {
            return true;
        } 
    } 

    return false;
}

test_collision_enemies :: (test: *Entity) -> Bool, *Entity {
    test_aabb: Vector4;
    test_aabb.x = test.position.x - test.size.x / 2;
    test_aabb.y = test.position.y - test.size.y / 2;
    test_aabb.z = test.position.x + test.size.x / 2;
    test_aabb.w = test.position.y + test.size.y / 2;

    for batch: entity_manager.batches {
        for occupied: batch.occupied {
            if !occupied then { continue; }

            entity := *batch.entities[it_index]
            if !entity.alive then { continue; }
            if entity.entity_type == Player then { continue; }
            if entity.entity_type == Bullet then { continue; }
            if entity.entity_type == Particle_Emitter then { continue; }
            if entity.entity_type == Pickup then { continue; }

            entity_aabb: Vector4;
            entity_aabb.x = entity.position.x - entity.size.x / 2;
            entity_aabb.y = entity.position.y - entity.size.y / 2;
            entity_aabb.z = entity.position.x + entity.size.x / 2;
            entity_aabb.w = entity.position.y + entity.size.y / 2;

            if aabb_collision_test(entity_aabb, test_aabb) { return true, entity; }
        }
    }

    return false, null;
}

test_collision_player :: (test: *Entity) -> Bool, *Player {
    test_aabb: Vector4;
    test_aabb.x = test.position.x - test.size.x / 2;
    test_aabb.y = test.position.y - test.size.y / 2;
    test_aabb.z = test.position.x + test.size.x / 2;
    test_aabb.w = test.position.y + test.size.y / 2;

    if !player { return false, null; }

    player_aabb: Vector4;
    player_aabb.x = player.position.x - player.size.x / 2;
    player_aabb.y = player.position.y - player.size.y / 2;
    player_aabb.z = player.position.x + player.size.x / 2;
    player_aabb.w = player.position.y + player.size.y / 2;

    if aabb_collision_test(player_aabb, test_aabb) { return true, player; }

    return false, null;
}

destroy_player :: (using self: *Player) {
    if shield_time > 0 then return;

    {
        emitter := Make(entity_manager, Particle_Emitter, position.x, position.y);
        emitter.texture = smoke_texture;

        emitter.size0 = 30;
        emitter.size1 = 40;

        emitter.speed0 = 100;
        emitter.speed1 = 300;

        emitter.color0 = make_vector4(1, 1, 0.3, 1);
        emitter.color1 = make_vector4(1, 1, 1, 1);

        emitter.fadeout_period = 0.1;
        emitter.emitter_lifetime = 0.2;
    }

    {
        emitter := Make(entity_manager, Particle_Emitter, position.x, position.y);
        emitter.texture = smoke_texture;

        emitter.size0 = 20;
        emitter.size1 = 40;

        emitter.color0 = make_vector4(1, 1, 1, 1);
        emitter.color1 = make_vector4(1, 0.7, 0.1, 1);

        emitter.fadeout_period = 0.3;
        emitter.emitter_lifetime = 0.3;
    }

    alive = false;
    Delete(entity_manager, self);
    player = null;
}

destroy_enemy :: (using entity: *Entity) {
   {
        emitter := Make(entity_manager, Particle_Emitter, entity.position.x, entity.position.y);
        emitter.texture = smoke_texture;

        emitter.size0 = 20;
        emitter.size1 = 40;

        emitter.speed0 = 100;
        emitter.speed1 = 300;

        emitter.color0 = make_vector4(1, 1, 0.3, 1);
        emitter.color1 = make_vector4(1, 1, 1, 1);

        emitter.fadeout_period = 0.1;
        emitter.emitter_lifetime = 0.2;
    }

    {
        emitter := Make(entity_manager, Particle_Emitter, entity.position.x, entity.position.y);
        emitter.texture = smoke_texture;

        emitter.size0 = 10;
        emitter.size1 = 40;

        emitter.color0 = make_vector4(1, 1, 1, 1);
        emitter.color1 = make_vector4(1, 0.7, 0.1, 1);

        emitter.fadeout_period = 0.3;;
        emitter.emitter_lifetime = 0.3
    }

    drop_roll := random_get() % 100;
    if drop_roll < 50 {
        pickup := Make(entity_manager, Pickup, position.x, position.y);
        pickup.direction = make_vector2(0, 200 * random_get_within_range(0.7, 1.7));
        pickup.size = make_vector2(30, 32);

        roll := random_get() % 100;
        if roll < 10 {
            pickup.type = Pickup_Type.Shield;
            pickup.texture = pickup_texture_shield;
        } else if roll < 25 {
            pickup.type = Pickup_Type.V_Shot;
            pickup.texture = pickup_texture_spread;
        } else {
            pickup.type = Pickup_Type.Extra_Bullet;
            pickup.texture = pickup_texture_extra;
        }
    }

    invader_count -= 1;

    alive = false;
    Delete(entity_manager, entity);
}

player_fire_bullet :: (position: Vector2, direction: Vector2) {
    bullet := Make(entity_manager, Bullet, 0, 0);
    bullet.position = position;
    bullet.direction = direction;
    bullet.texture = player_bullet_texture;
    bullet.size = make_vector2(12, 32);

    {
        emitter := Make(entity_manager, Particle_Emitter, bullet.position.x, bullet.position.y);
        emitter.texture = smoke_texture;

        emitter.size0 = 10;
        emitter.size1 = 20;

        emitter.theta0 = TAU * 0.6;
        emitter.theta1 = TAU * 0.9;
        emitter.drag0 = 0.9;
        emitter.drag1 = 0.97;

        k0: F32 = 1.0;
        k1: F32 = 0.1;

        emitter.color0 = make_vector4(k0, k0, k0, 1);
        emitter.color1 = make_vector4(k1, k1, k1, 1);

        bullet.emitter = emitter;
    }
}

player_fire :: (using player: *Player) {
    bullet_position1 := Add(position, make_vector2(0, -28));
    bullet_position2 := Add(position, make_vector2(30, 0));
    bullet_position3 := Add(position, make_vector2(-30, 0));

    bullet_direction1 := make_vector2(0, -1);
    bullet_direction2 := make_vector2(0, -1);
    bullet_direction3 := make_vector2(0, -1);

    if vshot_time > 0 {
        bullet_direction2.x += 0.065;
        bullet_direction3.x -= 0.065;

        if bullets == 0 {
            if shot_index % 2 > 0  {
                bullet_direction1.x = 0.05;
            } else {
                bullet_direction1.x = -0.05;
            }
        }
    }

    if bullets == 0 || bullets == 2 {
        player_fire_bullet(bullet_position1, bullet_direction1);
        shot_index += 1;
    }

    if bullets == 1 || bullets == 2 {
        player_fire_bullet(bullet_position2, bullet_direction2);
        player_fire_bullet(bullet_position3, bullet_direction3);
        shot_index += 2;
    }

    fire_cooldown = 0.3 + 0.1 * bullets;
}

enemy_fire :: (using entity: *Entity) {
    bullet := Make(entity_manager, Bullet, 0, 0);
    bullet.position = position;
    bullet.direction = make_vector2(0, 1);
    bullet.texture = enemy_bullet_texture;
    bullet.size = make_vector2(12, -32);
    bullet.player_friendly = false;
    bullet.lifetime *= 2;

    if random_get() % 2 != 0 then {
        bullet.direction.y *= 0.7;
    } else {
        bullet.direction.y *= 0.4;
    }

    {
        emitter := Make(entity_manager, Particle_Emitter, bullet.position.x, bullet.position.y);
        emitter.texture = smoke_texture;

        emitter.size0 = 10;
        emitter.size1 = 20;

        emitter.theta0 = TAU * 0.6;
        emitter.theta1 = TAU * 0.9;
        emitter.drag0 = 0.9;
        emitter.drag1 = 0.97;

        k0: F32 = 0.7;
        k1: F32 = 0.1;

        emitter.color0 = make_vector4(k0, k0, k0, 1);
        emitter.color1 = make_vector4(0.2, 1.0, 0.1, 1);

        emitter.speed1 = 400;
        emitter.lifetime0 = 0.2;
        emitter.lifetime1 = 0.5;

        bullet.emitter = emitter;
    }
}

simulate :: (delta_time: F64) {
    if invader_count == 0 {
        level += 1;
        spawn_invaders(level);
    }

    for batch: entity_manager.batches {
        for occupied: batch.occupied {
            if !occupied then { continue; }

            entity := *batch.entities[it_index];
            if !entity.alive then { continue; }

            if entity.entity_type == Player {
                speed :: 300;
                using player := Down(entity, Player);

                if fire_cooldown > 0 then { fire_cooldown -= delta_time; }
                if shield_time > 0 then { shield_time -= delta_time; }
                if vshot_time > 0 then { vshot_time -= delta_time; }

                if keys[Key_Code.SHIFT] && fire_cooldown <= 0 {
                    player_fire(player);
                } 

                if keys[Key_Code.ARROW_LEFT] then { position.x -= speed * cast(F32) delta_time; }
                if keys[Key_Code.ARROW_RIGHT] then { position.x += speed * cast(F32) delta_time; }
                if keys[Key_Code.ARROW_UP] then { position.y -= speed * cast(F32) delta_time; }
                if keys[Key_Code.ARROW_DOWN] then { position.y += speed * cast(F32) delta_time; }

                left := 0.0 * WINDOW_WIDTH - size.x / 2;
                right := 1.0 * WINDOW_WIDTH - size.x / 2;

                top := 0.7 * WINDOW_HEIGHT - size.y / 2;
                bottom := 1.0 * WINDOW_HEIGHT - size.y / 2;

                if position.x > right then { position.x = right; }
                if position.y > bottom then { position.y = bottom; }

                if position.x < left then { position.x = left; }
                if position.y < top then { position.y = top; }

            } else if entity.entity_type == Invader {
                using invader := Down(entity, Invader);

                if sleep_countdown < 0 {
                    speed :: 250;
                    delta := speed * delta_time;

                    dp := Sub(target_position, position);
                    denom := 1.0 / Length(dp);

                    dp = Mul(dp, denom);
                    if Distance(position, target_position) <= delta {
                        sleep_countdown = random_get_within_range(0.1, 1.5);
                        position = target_position;
                    } else {
                        position = Add(position, Mul(dp, cast(F32) delta));
                    }
                }

                if sleep_countdown >= 0 {
                    sleep_countdown -= delta_time;

                    if sleep_countdown < 0 {
                        roll := random_get() % 100;
                        if roll < 60 {
                            b :: 0.1;
                            target_position.x = WINDOW_WIDTH * random_get_within_range(b, 1.0-b);
                            target_position.y = WINDOW_HEIGHT * random_get_within_range(0.1, 0.6);

                            update_roll := random_get() % 3;
                            if update_roll == 0 then { update_procedure = bug_update_procedure_1; }
                            if update_roll == 1 then { update_procedure = bug_update_procedure_2; }
                            if update_roll == 2 then { update_procedure = bug_update_procedure_3; }

                            enemy_fire(invader);
                        }
                    }
                }

                success, player := test_collision_player(entity);
                if success {
                    destroy_enemy(entity);
                    destroy_player(player);
                    continue;
                }

                invader.update_procedure(invader, delta_time);
            } else if entity.entity_type == Bullet { 
                using bullet := Down(entity, Bullet);

                speed :: 600;
                position = Add(position, Mul(direction, cast(F32) (speed * delta_time)));
                emitter.position = position;

                lifetime -= delta_time;
                if lifetime < 0 then {
                    alive = false;
                    Delete(entity_manager, emitter);
                    Delete(entity_manager, entity);
                    continue;
                }

                if player_friendly {
                    success, enemy := test_collision_enemies(entity);
                    if success {
                        alive = false;
                        Delete(entity_manager, emitter);
                        Delete(entity_manager, entity);

                        destroy_enemy(enemy);
                    }
                } else {
                    success, player := test_collision_player(entity);
                    if success {
                        alive = false;
                        Delete(entity_manager, emitter);
                        Delete(entity_manager, entity);

                        destroy_player(player);
                    }
                }


            } else if(entity.entity_type == Particle_Emitter) {
                emitter := Down(entity, Particle_Emitter);;
                update_particle_emitter(emitter, delta_time)
            } else if(entity.entity_type == Pickup) {
                using pickup := Down(entity, Pickup);
                position = Add(position, Mul(direction, cast(F32) delta_time));

                success, player := test_collision_player(pickup);
                if success {
                    if player.shield_time <= 0 {
                        if type == Pickup_Type.Shield then { player.shield_time += 8; } // sec
                        if type == Pickup_Type.Extra_Bullet then { player.bullets = (player.bullets + 1) % 3; }
                        if type == Pickup_Type.V_Shot then { player.vshot_time += 20; } // sec
                    }

                    alive = false;
                    Delete(entity_manager, entity);
                }
            }
        }
    }
}

update_particle_emitter :: (using emitter: *Particle_Emitter, delta_time: F64) {
    for *particle: particles {
        simulate_particle(particle, delta_time);
        if particle.elapsed > particle.lifetime { remove particle; }
    }

    dt_per_particle := 1.0 / particles_per_second;
    if running_at_compile_time() then { dt_per_particle *= 8.0; }

    elapsed += cast(F32) delta_time;
    remainder += cast(F32) delta_time;

    if emitter_lifetime >= 0 then {
        emitter_lifetime -= cast(F32) delta_time;
        if emitter_lifetime < 0 { emitter.producing = false; }
    }

    if emitter.producing {
        while remainder > dt_per_particle {
            remainder -= dt_per_particle;
            partciel := spawn_particle(emitter);
            simulate_particle(partciel, remainder);
        }
    } else {
        if particles.count == 0 {
            alive = false;
            Delete(entity_manager, emitter);
        }
    }
  
    spawn_particle :: (using emitter: *Particle_Emitter) -> *Particle {
        particle: Particle;
        
        particle.position = position;
        particle.velocity = velocity;

        particle.size = random_get_within_range(size0, size1);
        particle.drag = random_get_within_range(drag0, drag1);
        particle.lifetime = random_get_within_range(lifetime0, lifetime1);

        color_t : F32 = random_get_within_range(0, 1);
        particle.color = Lerp(color0, color1, color_t);

        speed := random_get_within_range(speed0, speed1);
        theta := random_get_within_range(theta0, theta1);

        ct := cos(theta);
        st := sin(theta);

        v_rel : Vector2;
        v_rel.x = speed * ct;
        v_rel.y = speed * st;
        particle.velocity.x += v_rel.x;
        particle.velocity.y += v_rel.y;

        array_add(*emitter.particles, particle); 
        return *emitter.particles[emitter.particles.count - 1];
    }

    simulate_particle :: (using particle: *Particle, delta_time: F64) {
        position = Add(position, Mul(velocity, cast(F32) delta_time));

        velocity.x *= drag;
        velocity.y *= drag;

        elapsed += cast(F32) delta_time;
    }
}
