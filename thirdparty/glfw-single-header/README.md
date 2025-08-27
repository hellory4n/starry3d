# glfw-single-header

From: https://github.com/SasLuca/glfw-single-header

A python3 script that generates a single-header and single-header+single-source version of GLFW.
Currently it compiles on windows easily, here is an example with gcc:
```sh
gcc example/*.c -I example/ -lgdi32
```

And also MacOS,

```sh
export SDKROOT=$(xcrun --show-sdk-path)
gcc -ObjC example/*.c -I example/ -framework Cocoa -framework IOkit
```
