# libtrippin coding style

> [!NOTE]
> This is just an exact copy of the [libtrippin coding style](https://github.com/hellory4n/libtrippin/blob/main/CONVENTIONS.md)

libtrippin is great, but how does one truly libtrippin? In this document, we detail how to libtrippin all over the place.

Small formatting choices (spaces, parenthesis, braces, etc) should follow the formatting options in `.clang-format`. Most editors can be configured to format automatically using clang-format. clang-format 19 or higher is required.

## Naming

A mix of snake_case, PascalCase, and SCREAMING_CASE should be used:
- Use PascalCase in a class, struct, enum, typedef, union, concept, template parameter, or macro argument
- Use snake_case in variable and function names
- Use SCREAMING_CASE for enum members, constexpr variables, and macros.

Never capitalize acronyms/abbreviations in PascalCase names. (`JsonDocument` is right, `JSONDocument` isn't)

```cpp
// right
struct Data;
usize buffer_size;
tr::String absolute_path();

// wrong
struct data_t;
usize bufferSize;
tr::String AbsolutePath();
```

Use abbreviations sparingly.

Private and protected members should be prefixed with a single underscore. Private functions outside of classes should also be prefixed with a single underscore. (this includes static functions and just normal functions that shouldn't be used by the user)

Global variables and functions should be accessed by their namespace (and if they're not in a namespace, they should be).

```cpp
// right
app::_count++;

// wrong
_count++; // where is this from?
```

Setters should be prefixed with `set_`. Getters have no prefix.

```cpp
// right
void set_count(int);
int count() const;

// wrong
void count_set(int);
int get_count() const;
```

Never use `using namespace`.

## Slightly pedantic rules

Prefer `constexpr` to `#define`/`const`. Prefer inline/constexpr functions over function-like macros.

Prefer enum classes over regular enums or constants.

Prefer index or range for loops over iterators.

```cpp
// right
for (auto [i, child] : children) {
        child.do_child_thing();
}

// also right
for (int64 i = 0; i < SOME_CONST; i++) {
        do_thing(i);
}

// wrong
for (auto it = children.begin(); it != children.end(); ++it) {
        (*it)->do_child_thing();
}
```

## Pointers vs refernces

Prefer references to pointers. If you need optional values with `nullptr`, use `tr::Maybe<T&>` instead. If you need pointers for arrays, use `tr::Array<T>` instead. Pointers should be reserved to frightening low-level code. (pointer scary!)

An out argument of a function should be passed by reference except rare cases where it is optional in which case it should be passed by pointer. (but you should probably be using a struct here)

## Classes

If a class is mainly used as a simple container for data, it should be a struct instead. If the details on how the class stores that data are hidden from the user, it should be a class.

Avoid static classes. (classes with only static members (this isn't java))

```cpp
// right
float64 deg2rad(float64 deg);
float64 rad2deg(float64 rad);

// wrong
class Math {
public:
        float64 deg2rad(float64 deg);
        float64 rad2deg(float64 rad);
};
```

Use a constructor to do an implicit conversion when the argument is reasonably thought of as a type conversion and the type conversion is fast. Otherwise, use the `explicit` keyword or a function returning the type. This only applies to single argument constructors.

```cpp
// right
class BigDecimal {
public:
        BigDecimal(float64 x);
};

class Vector {
public:
        explicit Vector(usize size); // not a type conversion
        static Vector from_array(Array array); // expensive conversion
};

// wrong
class Task {
public:
        Task(ExecutionContext&); // not a type conversion
        explicit Task(); // no arguments
        explicit Task(ExecutionContext&, Other); // more than one argument
};
```

Avoid inheritance, except for abstract classes (interfaces). Use the `override` keyword.

## Types

Omit `int` when using the `unsigned` modifier. Do not use the `signed` modifier. Use `int` by itself instead.

```cpp
// right
unsigned a;
int b;

// wrong
unsigned int a;
signed b;
signed int c;
```

Prefer `int64`/`uint64`/`usize`/`isize` over raw `int`/`unsigned int`. Prefer libtrippin's number typedefs from `trippin/common.h` over `stdint.h`.

```cpp
// right
int x = c_lib_function();
usize buffer_size = 256;
int64 count();

// wrong
int32 x = c_lib_function(); // c library uses int, not int32
int buffer_size; // usize should be used to store sizes
int count(); // int is platform dependent, this code isn't
```

## Object-oriented patterns

Please don't.

Just write code like a C developer.

## Comments

Explain why the code does something. The code itself should already say what is happening.

```cpp
// right:
i++; // go to the next page

// we could just fopen(path, "r") then check if that's null, but then it would return false
// on permission errors, even though it does in fact exist
struct stat buffer = {};
return stat(path, &buffer) == 0;

// even better:
page_index++;

// wrong:
i++; // increment i

// stat the file and return true if it is 0
struct stat buffer = {};
return stat(path, &buffer) == 0;
```

## Casting

Before you consider a cast, please see if your problem can be solved another way that avoids the visual clutter.

- Integer constants can be specified to have (some) specific sizes with postfixes like u, l, ul etc. The same goes for single-precision floating-point constants with f.
- Working with smaller-size integers in arithmetic expressions is hard because of implicit promotion. Generally, it is fine to use `int` and other "large" types in local variables, and then cast at the end.
- Please don't use `const_cast`, like, ever.

If you do need to cast: Don't use C-style casts. The C-style cast has complex behavior that is undesired in many instances. Be aware of what sort of type conversion the code is trying to achieve, and use the appropriate C++ cast operator, like `static_cast`, `reinterpret_cast`, `dynamic_cast`, etc.

There is a single exception to this rule: marking a function parameter: `(void)arg;`.

## RAII

Don't use RAII. (Resource Acquisition Is Initialization)

RAII is not only overly implicit (best case is you notice you forgot a `&` and fix it years later for a free performance boost, worst case is an insane debugging session), but also just a pain in the rear end in general.

libtrippin provides a simple alternative: `TR_DEFER`, and functions. For example:

```cpp
void function() {
        Doohickey a = {};
        TR_DEFER(a.free());

        // do stuff...

        Thingamabob b = {};
        TR_DEFER(b.free());

        // do more stuff...

        // b.free() gets called
        // a.free() gets called
}
```

Instead of copy constructors, you can use more functions:

```cpp
// optionally delete the copy constructors
Doohickey(const Doohickey&) = delete;
Doohickey& operator=(const Doohickey&) = delete;

Doohickey duplicate() const;
```

It's more explicit but that's the point.

## Exceptions

Exceptions also have a similar issue of being overly implicit. Instead, use `tr::Result<T, E>`. I already made documentation for that.

## STL

We don't use the STL. (that's why this repo exists)

There are a few exceptions:
- interacting with C++ libraries
- C++ wrappers for libc (as that's not really the STL)

Few parts of the STL can be used too:
- `<type_traits>`
- `<new>`
- `<utility>` functions
- `std::function`
- the entire threading library

These all share either being pointless to implement in libtrippin, or a pain in the rear end to implement yourself, or both.

## Notes

Some parts of this document are from the [Ladybird coding style](https://github.com/LadybirdBrowser/ladybird/blob/master/Documentation/CodingStyle.md) (i may or may not be legally required to mention this, i'm not sure) (it's a good document)
