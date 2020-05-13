
// NOTE(Wase): When using #foreign for standard c functions everything works in bytecode but
// when compiling the outputed c code we can get multiple linkage errors. (Have only tested with Visual Studios compiler)

// #compiler "_name" fixes this by declaring a bolierplate function that lter calls the standard c function.

// The Standard Library for JAI should contain all of this later!

printf :: __cdecl #no_context (format: *U8, args: ...) -> Void #compiler "_printf"
sprintf :: __cdecl #no_context (dest: *U8, s: *U8, args: ...) -> S32 #compiler "_sprintf"

fopen :: (filename: *U8, mode: *U8) -> *Void #compiler "_fopen"
fclose :: (stream: *Void) -> S32 #compiler "_fclose"
fread :: (ptr: *Void, size: S32, count: S32, stream: *Void) -> S32 #compiler "_fread"

SEEK_SET :: 0
SEEK_CUR :: 1
SEEK_END :: 2
fseek :: (stream: *Void, offset: S32, origin: S32) -> S32 #compiler "_fseek"
ftell :: (stream: *Void) -> S32 #compiler "_ftell"

calloc :: __cdecl  #no_context (size: S32) -> *Void #foreign "malloc"
cfree :: __cdecl  #no_context (ptr: *Void) #foreign "free"

memcpy :: __cdecl #no_context (dst: *Void, src: *Void, length: S32) -> *Void #foreign
memset :: __cdecl #no_context (dst: *Void, value: S32, length: S32) -> *Void #foreign
memcmp :: __cdecl #no_context (A: *Void, B: *Void, length: S32) -> S32 #foreign
