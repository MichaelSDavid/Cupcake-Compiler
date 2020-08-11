#import "Print.jai"
#import "TypeInfo.jai";

cos  :: __cdecl #no_context (theta: F32) -> F32 #compiler "_cosf"; // NOTE(Wase): C-linkage is weird.
sin  :: __cdecl #no_context (theta: F32) -> F32 #compiler "_sinf";
sqrt :: __cdecl #no_context (theta: F32) -> F32 #compiler "_sqrtf";
pow  :: __cdecl #no_context (x: F32, power: F32) -> F32 #compiler "_powf";

cos  :: __cdecl #no_context (theta: F64) -> F64 #compiler "_cos";
sin  :: __cdecl #no_context (theta: F64) -> F64 #compiler "_sin";
sqrt :: __cdecl #no_context (theta: F64) -> F64 #compiler "_sqrt";
pow  :: __cdecl #no_context (x: F64, power: F64) -> F64 #compiler "_pow";

fmod :: __cdecl #no_context (x: F64, divisor: F64) -> F64 #compiler "_fmod";

fabs :: __cdecl #no_context (x: F64) -> F64 #compiler "_fabs";
atan2 :: __cdecl #no_context (y: F32, x: F32) -> F32 #compiler "_atan2";
floor :: __cdecl #no_context (x: F64) -> F64 #compiler "_floor";
abs :: __cdecl #no_context (value: S32) -> S32 #compiler "_abs";

TAU : F32 : 6.283147;
TAU64 : F64 : 6.28318530717958647;

Lerp :: (A: $T, B: T, t: T) -> T {
    return A + (B - A) * t;
}

VECTOR_FIELD_NAMES :: "xyzw";

Vector2 :: #type Vector(2);
Vector3 :: #type Vector(3);
Vector4 :: #type Vector(4);

Vector :: struct (N: S64)
#body {
    N_value := << N;
    if N_value <= 0 || N_value > 4 {
        compiler_report_error(#file, #line, "Vector dimensions too big or too small (watned: (0 < N < 5), got: %lli)", N);
        return "";
    }

    buffer: String_Buffer;
    //sprint(*buffer, "    c: [N] F32\n\n");
    //sprint(*buffer, "    #place c\n");

    for 0..N_value-1 {    
        if it_index <= 4 {
            name: String = ---;
            name.data = VECTOR_FIELD_NAMES.data + it_index;
            name.count = 1;
            sprint(*buffer, "    %: F32\n", name);
        } else {
            sprint(*buffer, "    e%: F32\n", it_index);
        }
    }

    sprint(*buffer, "    \n");
    sprint(*buffer, "    print :: vector_print\n");

    output: String;
    output.data = buffer.data.data;
    output.count = buffer.count;
    return output;
}

Add :: (A: $T/Vector, B: T) -> T
#body { return Vector_Operation_Body_VV(type_argument_get_integer(T, "N"), "+"); }

Sub :: (A: $T/Vector, B: T) -> T
#body { return Vector_Operation_Body_VV(type_argument_get_integer(T, "N"), "-"); }

Mul :: (A: $T/Vector, B: T) -> T
#body { return Vector_Operation_Body_VV(type_argument_get_integer(T, "N"), "*"); }

Div :: (A: $T/Vector, B: T) -> T
#body { return Vector_Operation_Body_VV(type_argument_get_integer(T, "N"), "/"); }

Length2 :: (A: $T/Vector) -> F32 
#body { 
    buffer: String_Buffer;
    N := type_argument_get_integer(T, "N");
    sprint(*buffer, "    r: % = ", return0);

    for 0..N-1 {
        if it_index <= 4 {
            name: String = ---;
            name.data = VECTOR_FIELD_NAMES.data + it_index;
            name.count = 1;
            sprint(*buffer, "(A.% * A.%)", name, name);
        } else {
            sprint(*buffer, "(A.e% * A.e%)", it_index, it_index);
        }

        if (it_index + 1 < N) { buffer_append_string(*buffer, " + "); }
    }

    sprint(*buffer, "    \n");
    sprint(*buffer, "    return r\n");

    output: String;
    output.data = buffer.data.data;
    output.count = buffer.count;
    return output;
}

Length :: (A: $T/Vector) -> F32 {
    return sqrt(Length2(A));
}

Distance :: (A: $T/Vector, B: T) -> F32 {
    X := Sub(A, B);
    return Length(X);
}

// TODO(Wase): Create a lerp procedure with #body_text

Lerp :: (A: Vector2, B: Vector2, t: F32) -> Vector2 {
    R: Vector2 = ---;
    R.x = Lerp(A.x, B.x, t);
    R.y = Lerp(A.y, B.y, t);
    return R;
}

Lerp :: (A: Vector3, B: Vector3, t: F32) -> Vector3 {
    R: Vector3 = ---;
    R.x = Lerp(A.x, B.x, t);
    R.y = Lerp(A.y, B.y, t);
    R.z = Lerp(A.z, B.z, t);
    return R;
}

Lerp :: (A: Vector4, B: Vector4, t: F32) -> Vector4 {
    R: Vector4 = ---;
    R.x = Lerp(A.x, B.x, t);
    R.y = Lerp(A.y, B.y, t);
    R.z = Lerp(A.z, B.z, t);
    R.w = Lerp(A.w, B.w, t);
    return R;
}



Mul :: (A: $T/Vector, B: F32) -> T 
#body { return Vector_Operation_Body_VF(type_argument_get_integer(T, "N"), "*"); }

Div :: (A: $T/Vector, B: F32) -> T 
#body { return Vector_Operation_Body_VF(type_argument_get_integer(T, "N"), "/"); }

Vector_Operation_Body_VV :: (N: S64, operator: String) -> String {
    buffer: String_Buffer;
    sprint(*buffer, "    r: T = ---\n");

    for 0..N-1 {
        if it_index <= 4 {
            name: String = ---;
            name.data = VECTOR_FIELD_NAMES.data + it_index;
            name.count = 1;
            sprint(*buffer, "    r.% = A.% % B.%\n", name, name, operator, name);
        } else {
            sprint(*buffer, "    r.e% = A.e% % B.e%\n", it_index, it_index, operator, it_index);
        }
    }

    sprint(*buffer, "    \n");
    sprint(*buffer, "    return r\n");

    output: String;
    output.data = buffer.data.data;
    output.count = buffer.count;
    return output;
}

Vector_Operation_Body_VF :: (N: S64, operator: String) -> String {
    buffer: String_Buffer;
    sprint(*buffer, "    r: T = ---\n");

    for 0..N-1 {
        if it_index <= 4 {
            name: String = ---;
            name.data = VECTOR_FIELD_NAMES.data + it_index;
            name.count = 1;
            sprint(*buffer, "    r.% = A.% % B\n", name, name, operator);
        } else {
            sprint(*buffer, "    r.e% = A.e% % B\n", it_index, it_index, operator);
        }
    }

    sprint(*buffer, "    \n");
    sprint(*buffer, "    return r\n");

    output: String;
    output.data = buffer.data.data;
    output.count = buffer.count;
    return output;
}

vector_print :: (buffer: *String_Buffer, any: Any) {
    N, S := type_argument_get_integer(any.type, "N");
    if !S {
        print("(unknown vector)");
        return;
    }

    buffer_append_string(buffer, "{ ");
    vec := cast(*Vector2) any.value_pointer;
    ptr := *(vec.x);

    for 0..N-1 {
        value: Any = ---;
        value.type = type_info(type_of(vec.x));
        value.value_pointer = ptr + it_index;

        if it_index <= 4 {
            name: String = ---;
            name.data = VECTOR_FIELD_NAMES.data + it_index;
            name.count = 1;

            sprint(buffer, "% = ", name);
            buffer_append_any(buffer, value);
        } else {
            sprint(buffer, "e% = ", it_index);
            buffer_append_any(buffer, value);
        }

        if(it_index + 1 < N)
            buffer_append_string(buffer, ", ");
    }

    buffer_append_string(buffer, " }");
}

make_vector2 :: (x: F32, y: F32) -> Vector2 {
    vec: Vector2;
    vec.x = x;
    vec.y = y;
    return vec;
}

make_vector3 :: (x: F32, y: F32, z: F32) -> Vector3 {
    vec: Vector3;
    vec.x = x;
    vec.y = y;
    vec.z = z;
    return vec;
}

make_vector4 :: (x: F32, y: F32, z: F32, w: F32) -> Vector4 {
    vec: Vector4;
    vec.x = x;
    vec.y = y;
    vec.z = z;
    vec.w = w;
    return vec;
}
