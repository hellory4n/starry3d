# Starry for C

This is the C API for Starry. It isn't meant to be used itself (though nothing is stopping you), but instead to serve as a portable API for all languages.

## Usage

1. Download and include the Starry header (starry.h)
2. Define these functions in your code:
```c
// they must all have this exact name and be exported
ST_DLLEXPORT void* st_init(st_Api st);
ST_DLLEXPORT void st_free(st_Api st, void* userdata);
```
3. Compile as a DLL

For example for GCC:
```sh
gcc -std=c11 -shared -fPIC -o libapp.so main.c
```

4. Place alongside the Starry exe (it will load the first one with those functions defined)
