# MrShader

Simple tool for turning shaders into C/C++ headers.

## Requirements

- lua
- a shader
- that's it

## Usage

Your shader should be formatted like this:

```glsl
// version specified once
#version 330 core

#pragma mrshader vertex
// vertex shader goes here

#pragma mrshader fragment
// fragment shader goes here
```

The command is `./mrshader.lua [shader] [header] [string name]`

Example: `./mrshader.lua shader.glsl shader.glsl.h SOME_SHADER`

Now you can just include the header and use `SOME_SHADER_VERTEX` and `SOME_SHADER_FRAGMENT`
