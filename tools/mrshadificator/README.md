# MrShadificator

Turns .glsl shaders into C++ header files.

This works by having a single .glsl file with `#shader vertex`/`#shader fragment`, that then becomes strings
you can use anywhere.

For example:

```glsl
#shader vertex
#version 330 core

layout(location = 0) in vec3 pos;
layout(location = 1) in vec3 color;

out vec3 out_color;

void main()
{
    gl_Position = vec4(pos, 1.0);
    vertexColor = aColor;
}

#shader fragment
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

`lua mrshadificator.lua [shader] [header] [namespace] [string_name]`

Example: `lua mrshadificator.lua shader.glsl shader.glsl.hpp game SOME_SHADER`

Now you can just include the header and use `game::SOME_SHADER_VERTEX` and `game::SOME_SHADER_FRAGMENT`
