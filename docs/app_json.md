# app.json

`app.json` is the file used to configure Starry applications. It must be placed in the same directory as `starry.exe`.

```jsonc
// note: this is actually JSON5, not regular JSON
{
	// the name of the application
	"name": "a Starry app",
	// path to the main lua script (relative to starry.exe)
	"main": "main.lua",

	// optional
	"flags": [
		"no_resize", // disable resizing the app's window
		"no_high_dpi", // forces the application to be high DPI-unaware
	],
}
```
