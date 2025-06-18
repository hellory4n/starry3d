# Conventions

## NOTE: This is old

This was written for the original 1.x libtrippin in C. While most things from here still apply, I don't feel
like writing my opinion on every C++ feature just yet.

These are the conventions I use for libtrippin and my other crap too.

## Spacing and stuff.

Use tabs for indentation.

Tabs should be 4 spaces long.

Also if you have more than 4 indents please reconsider your life choices. (the last indent should mostly
be used if you have really long function calls)

Lines shouldn't be longer than 100 characters.

Pointers are aligned with the type:

- correct: `void* var`
- wrong: `void *var`

Functions don't have a space:

- correct: `function(...)`
- wrong: `function (...)`

But control flow does have spaces:

- correct: `if (true)`
- wrong: `if(true)`

Braces are K&R style:

```c
int main(int argc, char *argv[])
{
    while (x == y) {
        do_something();
        do_something_else();
    }
    final_thing();
}
```

But if-else statements are slightly different:

```c
if (true) {
    // ...
}
else {
    // ...
}
```

DON'T do this though:

```c
if (true)
    // ...
else
    // ...
```

Braces should only be omitted if it's really tiny and if you're really lazy:

```c
if (true) // ...
else // ...
```

Switch statements are indented like this:

```c
switch (var) {
case 1:
    // ...
    break;
case 2:
    // ...
    break;
}
```

This is also allowed:

```c
switch (var) {
    case 1: /* ... */ break;
    case 2: /* ... */ break;
}
```

## Naming

The project should have a short prefix e.g. `tr`

Use `snake_case` for everything except types which are in `PascalCase`, and macros which are `UPPERCASE`

Examples:

- `tr_the_thingamabob`
- `TrThingamabobPro`
- `TR_MACRO`

Local variables are in `snake_case` with no prefix, except for global variables which do have the prefix,
for example `tr_randdeez`

Enum members should start with the enum name, e.g. `TR_ENUM_OPTION1`

C doesn't have methods so instead have functions like `<prefix>_<type>_<function>`, e.g. `tr_thingamabob_die`

Functions for initializing/freeing should be called `new`/`free` respectively

## Other

ALWAYS use long numbers (int64_t, uint64_t, double, size_t) unless you have a good reason not to.

`char` should only be used for strings, use `int8_t`/`uint8_t` everywhere else.

Use include guards, following the format `_<LIBRARY PREFIX>_<NAME>_H`, e.g. `_TR_THINGAMBOB_H`

Files should be snake case, e.g. `assets/the_thingamabob.png`
