RANDRANGE: U32 : 0x10000000;
random_state: S32 = 0xbeefface; 

random_get :: () -> U32 {
    x := random_state;

    hi := x / 127773;
    lo := x % 127773;

    t := 16807 * lo - 2836 * hi;
    if t <= 0 then t += 0x7fffffff;

    random_state = t;
    return cast(U32) t;
}

random_seed :: (new_seed : S32) {
    random_state = new_seed;
}

random_get_zero_to_one :: () -> F32 {
    randint := random_get() % RANDRANGE;
    return (cast(F32) randint) / cast(F32) RANDRANGE; 
}

random_get_within_range :: (min: F32, max: F32) -> F32 {
    randint := random_get() % RANDRANGE;
    addition := (cast(F32) randint / cast(F32) RANDRANGE) * (max - min);

    return min + addition;
}
