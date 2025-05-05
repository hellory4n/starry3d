# MrShadificator

Turns .glsl shaders into C header files.

This works by having a single .glsl file with `#vertex`/`#fragment`, that then become C strings.

## Requirements

- Lua.

## Usage

`lua mrshadificator.lua [shadersrc] [headerdst] [strname]`

Example: `lua mrshadificator.lua shader.glsl shader.glsl.h ST_SOME_SHADER`

Now you can just include the header and use `ST_SOME_SHADER_VERTEX` and `ST_SOME_SHADER_FRAG`
