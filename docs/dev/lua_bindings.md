# Lua bindings

Traditionally, Lua bindings are implemented by making these wrappers around the original functions:

```odin
// AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
lua_add :: proc "c" (L: ^lua.State) -> i32
{
	a := lua.L_checknumber(L, 1)
	b := lua.L_checknumber(L, 2)
	res := add(a, b)
	lua.pushnumber(L, res)
	return 1
}
```

Unfortunately, this is Sisyphean. Instead we use LuaJIT's `ffi` module + slightly evil fuckery.

## Step 0 (it's already done)

For God knows why, executables can export symbols as if they were a DLL. This means we can export symbols to ourselves, which means we can export symbols to LuaJIT.

This only requires a single flag on Linux: (Windows already does this by default)

```sh
odin build starry -extra-linker-flags:"-rdynamic"
```

## Step 1

Make a C-wrapper for the Odin function in `starry/lua_api.odin`. This should have the `@(export)` attribute, the `"c"` calling convention, and be prefixed with `st_`.

```odin
@(export)
st_add :: proc "c" (a, b: f32) -> f32
{
	context = global.ctx
	return add(a, b)
}
```

## Step 2

Bind it to Lua in `starry/lua/builtin.lua`:

```lua
ffi.cdef[[
// everything else...
float st_add(float a, float b);
]]
```

## Step 3

Make the real bindings:

```lua
---@param a number
---@param b number
---@return number
function st.add(a, b)
	return ffi.C.st_add(a, b)
end
```

This slightly convoluted system is specially useful for fancy metatables and whatnot.
