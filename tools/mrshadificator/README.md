# MrShadificator

Turns .glsl shaders into C header files.

This works by having a single .glsl file with `#vertex`/`#fragment`, that then become C strings.

For example:

```glsl
#vertex
#version 330 core

layout(location = 0) in vec3 pos;
layout(location = 1) in vec3 color;

out vec3 out_color;

void main()
{
    gl_Position = vec4(pos, 1.0);
    vertexColor = aColor;
}

#fragment
#version 330 core

in vec3 out_color;
out vec4 FragColor;

void main()
{
    FragColor = vec4(out_color, 1.0);
}
```

## Requirements

- Lua
- A shader

## Usage

`lua mrshadificator.lua [shadersrc] [headerdst] [strname]`

Example: `lua mrshadificator.lua shader.glsl shader.glsl.h ST_SOME_SHADER`

Now you can just include the header and use `ST_SOME_SHADER_VERTEX` and `ST_SOME_SHADER_FRAGMENT`
