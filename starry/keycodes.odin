package starry

import "core:fmt"

// keyboard keys on your keyboard which is key. values are the same as GLFW.
Key :: enum u32 {
	INVALID         = 0,
	SPACE           = 32,
	APOSTROPHE      = 39, // '
	COMMA           = 44, // ,
	MINUS           = 45, // -
	PERIOD          = 46, // .
	SLASH           = 47, // /
	NUM_0           = 48,
	NUM_1           = 49,
	NUM_2           = 50,
	NUM_3           = 51,
	NUM_4           = 52,
	NUM_5           = 53,
	NUM_6           = 54,
	NUM_7           = 55,
	NUM_8           = 56,
	NUM_9           = 57,
	SEMICOLON       = 59, // ;
	EQUAL           = 61, // =
	A               = 65,
	B               = 66,
	C               = 67,
	D               = 68,
	E               = 69,
	F               = 70,
	G               = 71,
	H               = 72,
	I               = 73,
	J               = 74,
	K               = 75,
	L               = 76,
	M               = 77,
	N               = 78,
	O               = 79,
	P               = 80,
	Q               = 81,
	R               = 82,
	S               = 83,
	T               = 84,
	U               = 85,
	V               = 86,
	W               = 87,
	X               = 88,
	Y               = 89,
	Z               = 90,
	LEFT_BRACKET    = 91, // [
	BACKSLASH       = 92, // \
	RIGHT_BRACKET   = 93, // ]
	GRAVE_ACCENT    = 96, // `
	INTERNATIONAL_1 = 161, // non-us #1
	INTERNATIONAL_2 = 162, // non-us #2
	ESCAPE          = 256,
	ENTER           = 257,
	TAB             = 258,
	BACKSPACE       = 259,
	INSERT          = 260,
	DELETE          = 261,
	RIGHT           = 262,
	LEFT            = 263,
	DOWN            = 264,
	UP              = 265,
	PAGE_UP         = 266,
	PAGE_DOWN       = 267,
	HOME            = 268,
	END             = 269,
	CAPS_LOCK       = 280,
	SCROLL_LOCK     = 281,
	NUM_LOCK        = 282,
	PRINT_SCREEN    = 283,
	PAUSE           = 284,
	F1              = 290,
	F2              = 291,
	F3              = 292,
	F4              = 293,
	F5              = 294,
	F6              = 295,
	F7              = 296,
	F8              = 297,
	F9              = 298,
	F10             = 299,
	F11             = 300,
	F12             = 301,
	F13             = 302,
	F14             = 303,
	F15             = 304,
	F16             = 305,
	F17             = 306,
	F18             = 307,
	F19             = 308,
	F20             = 309,
	F21             = 310,
	F22             = 311,
	F23             = 312,
	F24             = 313,
	F25             = 314,
	KP_0            = 320,
	KP_1            = 321,
	KP_2            = 322,
	KP_3            = 323,
	KP_4            = 324,
	KP_5            = 325,
	KP_6            = 326,
	KP_7            = 327,
	KP_8            = 328,
	KP_9            = 329,
	KP_DECIMAL      = 330,
	KP_DIVIDE       = 331,
	KP_MULTIPLY     = 332,
	KP_SUBTRACT     = 333,
	KP_ADD          = 334,
	KP_ENTER        = 335,
	KP_EQUAL        = 336,
	LEFT_SHIFT      = 340,
	LEFT_CTRL       = 341,
	LEFT_ALT        = 342,
	LEFT_SUPER      = 343,
	RIGHT_SHIFT     = 344,
	RIGHT_CTRL      = 345,
	RIGHT_ALT       = 346,
	RIGHT_SUPER     = 347,
	MENU            = 348,
	LAST            = MENU,
}

// for interop with lua
key_from_string :: proc(s: string) -> Key
{
	switch s {
	case "invalid":
		return .INVALID
	case "space", " ":
		return .SPACE
	case "apostrophe", "'":
		return .APOSTROPHE
	case "comma", ",":
		return .COMMA
	case "minus", "-":
		return .MINUS
	case "period", ".":
		return .PERIOD
	case "slash", "/":
		return .SLASH
	case "num0", "0":
		return .NUM_0
	case "num1", "1":
		return .NUM_1
	case "num2", "2":
		return .NUM_2
	case "num3", "3":
		return .NUM_3
	case "num4", "4":
		return .NUM_4
	case "num5", "5":
		return .NUM_5
	case "num6", "6":
		return .NUM_6
	case "num7", "7":
		return .NUM_7
	case "num8", "8":
		return .NUM_8
	case "num9", "9":
		return .NUM_9
	case "semicolon", ";":
		return .SEMICOLON
	case "equal", "=":
		return .EQUAL
	case "a", "A":
		return .A
	case "b", "B":
		return .B
	case "c", "C":
		return .C
	case "d", "D":
		return .D
	case "e", "E":
		return .E
	case "f", "F":
		return .F
	case "g", "G":
		return .G
	case "h", "H":
		return .H
	case "i", "I":
		return .I
	case "j", "J":
		return .J
	case "k", "K":
		return .K
	case "m", "M":
		return .M
	case "n", "N":
		return .N
	case "o", "O":
		return .O
	case "p", "P":
		return .P
	case "q", "Q":
		return .Q
	case "r", "R":
		return .R
	case "s", "S":
		return .S
	case "t", "T":
		return .T
	case "u", "U":
		return .U
	case "v", "V":
		return .V
	case "w", "W":
		return .W
	case "x", "X":
		return .X
	case "y", "Y":
		return .Y
	case "z", "Z":
		return .Z
	case "left_bracket", "[":
		return .LEFT_BRACKET
	case "backslash", "\\":
		return .BACKSLASH
	case "right_bracket", "]":
		return .RIGHT_BRACKET
	case "grave", "grave_accent", "`":
		return .GRAVE_ACCENT
	case "international1":
		return .INTERNATIONAL_1
	case "international2":
		return .INTERNATIONAL_2
	case "escape", "esc":
		return .ESCAPE
	case "enter", "return":
		return .ENTER
	case "tab":
		return .TAB
	case "backspace":
		return .BACKSPACE
	case "insert", "ins":
		return .INSERT
	case "delete", "del":
		return .DELETE
	case "right":
		return .RIGHT
	case "left":
		return .LEFT
	case "down":
		return .DOWN
	case "up":
		return .UP
	case "page_up":
		return .PAGE_UP
	case "page_down":
		return .PAGE_DOWN
	case "home":
		return .HOME
	case "end":
		return .END
	case "caps_lock":
		return .CAPS_LOCK
	case "scroll_lock":
		return .SCROLL_LOCK
	case "num_lock":
		return .NUM_LOCK
	case "print", "print_screen":
		return .PRINT_SCREEN
	case "pause", "pause_break":
		return .PAUSE
	case "F1", "f1":
		return .F1
	case "F2", "f2":
		return .F2
	case "F3", "f3":
		return .F3
	case "F4", "f4":
		return .F4
	case "F5", "f5":
		return .F5
	case "F6", "f6":
		return .F6
	case "F7", "f7":
		return .F7
	case "F8", "f8":
		return .F8
	case "F9", "f9":
		return .F9
	case "F10", "f10":
		return .F10
	case "F11", "f11":
		return .F11
	case "F12", "f12":
		return .F12
	case "F13", "f13":
		return .F13
	case "F14", "f14":
		return .F14
	case "F15", "f15":
		return .F15
	case "F16", "f16":
		return .F16
	case "F17", "f17":
		return .F17
	case "F18", "f18":
		return .F18
	case "F19", "f19":
		return .F19
	case "F20", "f20":
		return .F20
	case "F21", "f21":
		return .F21
	case "F22", "f22":
		return .F22
	case "F23", "f23":
		return .F23
	case "F24", "f24":
		return .F24
	case "F25", "f25":
		return .F25
	case "kp0":
		return .KP_0
	case "kp1":
		return .KP_1
	case "kp2":
		return .KP_2
	case "kp3":
		return .KP_3
	case "kp4":
		return .KP_4
	case "kp5":
		return .KP_5
	case "kp6":
		return .KP_6
	case "kp7":
		return .KP_7
	case "kp8":
		return .KP_8
	case "kp9":
		return .KP_9
	case "kp_decimal":
		return .KP_DECIMAL
	case "kp_divide":
		return .KP_DIVIDE
	case "kp_multiply":
		return .KP_MULTIPLY
	case "kp_subtract":
		return .KP_SUBTRACT
	case "kp_add":
		return .KP_ADD
	case "kp_enter":
		return .KP_ENTER
	case "kp_equal":
		return .KP_EQUAL
	case "left_shift", "lshift":
		return .LEFT_SHIFT
	case "left_ctrl", "left_control", "lctrl", "lcontrol":
		return .LEFT_CTRL
	case "left_alt", "lalt":
		return .LEFT_ALT
	case "left_super", "lsuper":
		return .LEFT_SUPER
	case "right_shift", "rshift":
		return .RIGHT_SHIFT
	case "right_ctrl", "right_control", "rctrl", "rcontrol":
		return .RIGHT_CTRL
	case "right_alt", "ralt":
		return .RIGHT_ALT
	case "right_super", "rsuper":
		return .RIGHT_SUPER
	case "menu":
		return .MENU
	}
	fmt.panicf("invalid key %q", s)
}

// the buttons located on your pointing device technological artifice. Values are the same as GLFW
MouseButton :: enum u32 {
	BTN_1  = 0,
	BTN_2  = 1,
	BTN_3  = 2,
	BTN_4  = 3,
	BTN_5  = 4,
	BTN_6  = 5,
	BTN_7  = 6,
	BTN_8  = 7,
	LEFT   = BTN_1,
	RIGHT  = BTN_2,
	MIDDLE = BTN_3,
	LAST   = BTN_8,
}

// for interop with lua
mouse_button_from_string :: proc(s: string) -> MouseButton
{
	switch s {
	case "1":
		return .BTN_1
	case "2":
		return .BTN_2
	case "3":
		return .BTN_3
	case "4":
		return .BTN_4
	case "5":
		return .BTN_5
	case "6":
		return .BTN_6
	case "7":
		return .BTN_7
	case "8":
		return .BTN_8
	case "left":
		return .LEFT
	case "right":
		return .RIGHT
	case "middle":
		return .MIDDLE
	}
	fmt.panicf("invalid mouse button %q", s)
}

// values are the same as glfw
ModifierKey :: enum {
	SHIFT     = 0x1,
	CTRL      = 0x2,
	ALT       = 0x4,
	SUPER     = 0x8,
	CAPS_LOCK = 0x10,
	NUM_LOCK  = 0x20,
}
ModifierKeys :: bit_set[ModifierKey]

InputState :: enum {
	NOT_PRESSED,
	JUST_PRESSED,
	HELD,
	JUST_RELEASED,
}
