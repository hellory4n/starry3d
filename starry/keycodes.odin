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
	case "0":
		return .NUM_0
	case "1":
		return .NUM_1
	case "2":
		return .NUM_2
	case "3":
		return .NUM_3
	case "4":
		return .NUM_4
	case "5":
		return .NUM_5
	case "6":
		return .NUM_6
	case "7":
		return .NUM_7
	case "8":
		return .NUM_8
	case "9":
		return .NUM_9
	case ";":
		return .SEMICOLON
	case "=":
		return .EQUAL
	case "a":
		return .A
	case "b":
		return .B
	case "c":
		return .C
	case "d":
		return .D
	case "e":
		return .E
	case "f":
		return .F
	case "g":
		return .G
	case "h":
		return .H
	case "i":
		return .I
	case "j":
		return .J
	case "k":
		return .K
	case "m":
		return .M
	case "n":
		return .N
	case "o":
		return .O
	case "p":
		return .P
	case "q":
		return .Q
	case "r":
		return .R
	case "s":
		return .S
	case "t":
		return .T
	case "u":
		return .U
	case "v":
		return .V
	case "w":
		return .W
	case "x":
		return .X
	case "y":
		return .Y
	case "z":
		return .Z
	case "left bracket", "lbracket", "[":
		return .LEFT_BRACKET
	case "backslash", "\\":
		return .BACKSLASH
	case "right bracket", "rbracket", "]":
		return .RIGHT_BRACKET
	case "grave", "grave accent", "`":
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
	case "page up":
		return .PAGE_UP
	case "page down":
		return .PAGE_DOWN
	case "home":
		return .HOME
	case "end":
		return .END
	case "caps lock":
		return .CAPS_LOCK
	case "scroll lock":
		return .SCROLL_LOCK
	case "num lock":
		return .NUM_LOCK
	case "print", "print screen":
		return .PRINT_SCREEN
	case "pause", "pause break":
		return .PAUSE
	case "f1":
		return .F1
	case "f2":
		return .F2
	case "f3":
		return .F3
	case "f4":
		return .F4
	case "f5":
		return .F5
	case "f6":
		return .F6
	case "f7":
		return .F7
	case "f8":
		return .F8
	case "f9":
		return .F9
	case "f10":
		return .F10
	case "f11":
		return .F11
	case "f12":
		return .F12
	case "f13":
		return .F13
	case "f14":
		return .F14
	case "f15":
		return .F15
	case "f16":
		return .F16
	case "f17":
		return .F17
	case "f18":
		return .F18
	case "f19":
		return .F19
	case "f20":
		return .F20
	case "f21":
		return .F21
	case "f22":
		return .F22
	case "f23":
		return .F23
	case "f24":
		return .F24
	case "f25":
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
	case "kp decimal":
		return .KP_DECIMAL
	case "kp divide":
		return .KP_DIVIDE
	case "kp multiply":
		return .KP_MULTIPLY
	case "kp subtract":
		return .KP_SUBTRACT
	case "kp add":
		return .KP_ADD
	case "kp enter":
		return .KP_ENTER
	case "kp equal":
		return .KP_EQUAL
	case "left shift", "lshift":
		return .LEFT_SHIFT
	case "left ctrl", "left control", "lctrl", "lcontrol":
		return .LEFT_CTRL
	case "left alt", "lalt":
		return .LEFT_ALT
	case "left super", "lsuper":
		return .LEFT_SUPER
	case "right shift", "rshift":
		return .RIGHT_SHIFT
	case "right ctrl", "right control", "rctrl", "rcontrol":
		return .RIGHT_CTRL
	case "right alt", "ralt":
		return .RIGHT_ALT
	case "right super", "rsuper":
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

InputState :: enum {
	NOT_PRESSED,
	JUST_PRESSED,
	HELD,
	JUST_RELEASED,
}
