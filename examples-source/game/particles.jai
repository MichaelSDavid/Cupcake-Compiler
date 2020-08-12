Particle :: struct {
    position: Vector2;
    velocity: Vector2;

    size: F32 = 0;
    lifetime: F32 = 2;
    drag: F32 = 1;
    color: Vector4;

    elapsed: F32 = 0;
}
 
Particle_Emitter :: struct {
    using entity: *Entity;

    particles: [..] Particle;
    fadeout_period: F32 = 0.1;
    particles_per_second: F32 = 150;

    speed0: F32 = 50;
    speed1: F32 = 400;

    size0: F32 = 50;
    size1: F32 = 30;

    drag0: F32 = 0.9999;
    drag1: F32 = 0.9;

    lifetime0: F32 = 0.4;
    lifetime1: F32 = 1.0;

    emitter_lifetime: F32 = -1.0;

    theta0: F32 = 0;
    theta1: F32 = TAU;

    color0: Vector4;
    color1: Vector4;

    elapsed: F32 = 0;
    remainder: F32 = 0;

    producing := true;
}
