# config.lua

All the options for the `config.lua` file, used for configuring Starry projects using Lua.

```lua
return {
	name = "A Starry game",
	-- the first script ran by the engine
	main = "path/to/main.lua",

	-- defaults to "0.0.0"
	-- must be 3 numbers separated by dots
	version = "1.0.0",

	-- defaults to "modern"
	-- - "modern": uses OpenGL 4.3, required for the voxel renderer
	-- - "compatibility": uses OpenGL 3.3 for compatibility with older devices
	graphics_profile = "modern",
}
```
