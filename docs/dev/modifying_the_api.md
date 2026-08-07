# Modifying the API

Note: "module" refers to the table in which the functions are defined, e.g. `app` or `gfx`

There are 4 places where functions are defined:
- odin implementation in `starry/`
- lua binding in `starry/lua_<module>.odin`
- LSP definition in `lualibs/<module>.d.lua`
- documentation entry in `docs/api_reference`

If the module is written in Lua, its implementation is the LSP definition, and you only need the documentation entry.

In addition to that, there are also tests in either `test/` or `samples/` (samples have a window, tests don't).

To modify the API, simply update all those places, and then check for every sample and every test ever.
