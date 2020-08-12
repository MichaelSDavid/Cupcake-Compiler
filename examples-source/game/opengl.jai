#foreign_library "opengl_library.dll";

create_window :: #no_context (width: S64, height: S64, name: *U8, window_handle_return: **Void) -> Bool #foreign;
update_window_events :: #no_context () -> Void #foreign;
window_clear :: #no_context (red: F32, green: F32, blue: F32, alpha: F32) -> Void #foreign;
swap_buffers :: #no_context () -> Void #foreign;

GetForegroundWindow :: #no_context () -> *Void #foreign;

glColor4f       :: __stdcall #no_context (r: F32, g: F32, b: F32, a: F32) -> Void #foreign;
glColor3f       :: __stdcall #no_context (r: F32, g: F32, b: F32) -> Void #foreign;
glBlendFunc     :: __stdcall #no_context (sfactor : S32, dfactor : S32) #foreign;
glEnable        :: __stdcall #no_context (cap : S32) #foreign;
glDisable       :: __stdcall #no_context (cap : S32) #foreign;
glGenTextures   :: __stdcall #no_context (count: S32, result: * U32) #foreign;
glTexParameteri :: __stdcall #no_context (target: S32, pname: S32, param: S32) #foreign;
glTexParameterf :: __stdcall #no_context (target: S32, pname: S32, param: F32) #foreign;
glBindTexture   :: __stdcall #no_context (target: S32, texture: U32) #foreign;
glTexImage2D    :: __stdcall #no_context (target: S32, level: S32, international_format: S32, width: S32, height: S32, border: S32, format: S32, type: S32, pixels: * Void) #foreign;

_GL_ZERO: S32 =                 0x0000;
_GL_ONE: S32 =                  0x0001;
_GL_TRIANGLES : S32 =           0x0004;
_GL_QUADS: S32 = 0x0007;
_GL_BLEND : S32 =               0x0BE2;
_GL_SRC_ALPHA : S32 =           0x0302;
_GL_ONE_MINUS_SRC_ALPHA : S32 = 0x0303;
_GL_TEXTURE_2D : S32 =          0x0DE1;
_GL_RGBA8 : S32 =               0x8058;  
_GL_UNSIGNED_BYTE : S32 =       0x1401;
_GL_BGRA_EXT : S32 =            0x80E1;
_GL_TEXTURE_MAX_LEVEL : S32 =   0x813D;
_GL_RGBA : S32 =                0x1908;
_GL_ALPHA : S32 =               0x1906;

_GL_TEXTURE_MAX_ANISOTROPY_EXT : S32 = 0x84FE;

_GL_TEXTURE_MAG_FILTER : S32 =             0x2800;
_GL_TEXTURE_MIN_FILTER : S32 =             0x2801;
_GL_TEXTURE_WRAP_S     : S32 =             0x2802;
_GL_TEXTURE_WRAP_T     : S32 =             0x2803;

_GL_NEAREST   : S32 =                     0x2600;
_GL_LINEAR    : S32 =                     0x2601;


glBegin :: __stdcall #no_context (mode: S32) #foreign;
glEnd :: __stdcall #no_context () #foreign;
glVertex3f :: __stdcall #no_context (x: F32, y: F32, z: F32) #foreign;
glTexCoord2f :: __stdcall #no_context (u: F32, v: F32) #foreign;

glLoadIdentity :: __stdcall #no_context () -> Void #foreign;

glOrtho :: __stdcall #no_context (left: F64, right: F64,
            bottom: F64, top: F64, 
            near: F64, far: F64) -> Void #foreign;



get_next_event :: #no_context (result: *Event) -> S64 #foreign "get_next_event";  // Should be a bool.

Event_Type :: enum U32 {  // If we set this to u8, our packing will stop matching C's.
    UNINITIALIZED : 0,
    KEYBOARD : 1,
    WINDOW : 2,
    QUIT : 3
}

Key_Code :: enum U32 {
    UNKNOWN : 0,
    ARROW_LEFT : 1,
    ARROW_RIGHT : 2,
    ARROW_UP : 3,
    ARROW_DOWN : 4,
    SHIFT : 5,
    ESCAPE : 6,
    MOUSE_BUTTON_LEFT : 7,
    MOUSE_BUTTON_RIGHT : 8,
}

Event :: struct {
    type : Event_Type = Event_Type.UNINITIALIZED;

    // If keyboard event:
    key_pressed : U32 = 0;  // If not pressed, it's a key release.
    key_code : Key_Code = Key_Code.UNKNOWN;
}


get_time :: #no_context () -> F64 #foreign;
sleep_milliseconds :: #no_context (x: F64)  #foreign;

