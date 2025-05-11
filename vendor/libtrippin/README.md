# libtrippin

Most biggest most massive C library of all time. I'm insane.

## Featuring

- [libtrippin](./libtrippin.h) v1.2.3: Most massive standard library
    - Arenas
    - Math functions and stuff
    - Logging
    - Slices
    - Pure C99 with no external dependencies
- [engineer](./engineerbuild/README.md) v1.0.1: Build system of all time
    - No esoteric language
    - Only external dependency is lua
    - You can specify options and stuff
    - You can control the entire build process
    - Incremental builds
    - Support for clangd's `compile_commands.json`

## Usage

Just add `libtrippin.c` to your project

If you have debug builds make sure you have `DEBUG` defined (it doesn't change a whole lot but i mean why not)

On Linux make sure you linked the math library `-lm`

If some for reason you want to use engineer then [read this](./engineerbuild/README.md)

## Example

Look at the examples folder for something comprehensible

```c
#include "libtrippin.h"

int main(void)
{
    tr_init("log.txt");
    TrArena arena = tr_arena_new(TR_MB(1));
    TrSlice_Vec2f slicema = tr_slice_new(arena, 4, sizeof(TrVec2f));
    TrRand rand = tr_rand_new(123456789);

    TrVec2f vecdeez = {tr_rand_double(&rand, 1, 10), tr_rand_double(&rand, 1, 10)};
    TR_SET_SLICE(&arena, &slicema, TrVec2f,
        (TrVec2f){1, 2},
        vecdeez,
        TR_V2_ADD(vecdeez, vecdeez),
        TR_V2_SMUL(vecdeez, 2),
    );

    for (size_t i = 0; i < slicema.length; i++) {
        TrVec2f vecm = *TR_AT(slicema, TrVec2f, i);
        tr_log( "%f, %f", vecm.x, vecm.y);
    }

    tr_arena_free(arena);
    tr_free();
}
```

## FAQ

### Have you tried \[language] you fucking moron

No fuck off.

### Why?

That's enough questions.
