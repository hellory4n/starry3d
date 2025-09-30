# MrShader

Janky shader preprocessor. Turns your GLSL shaders into C/C++ headers (and other things too)

## Requirements

- lua
- a shader
- that's it

## Usage

Your shader should be formatted like this:

```glsl
// version specified once
#version 330 core
// set the C define prefix
#pragma mrshader name SOME_SHADER

#pragma mrshader vertex
// vertex shader goes here

#pragma mrshader fragment
// fragment shader goes here
```

Setting defines for the generated C header is also possible, e.g.
```glsl
#pragma mrshader define VS_POS 0
layout(location = 0) in vec3 vs_pos;

// becomes
#define SOME_SHADER_VS_POS 0
```

And you can even include other GLSL files:
```glsl
#pragma mrshader include other_file.glsl

// you still need include guards tho
#ifndef _OTHER_FILE_H
#define _OTHER_FILE_H
// ...
#endif
```

The command is `./mrshader.lua [shader] [header] [string name]`

Example: `./mrshader.lua shader.glsl shader.glsl.h SOME_SHADER`

Now you can just include the header and use `SOME_SHADER_VERTEX` and `SOME_SHADER_FRAGMENT`
