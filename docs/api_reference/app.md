# App module

The `app` module includes various windowing and asset functions.

## Callbacks

### `app.on_init()`

Only ever called once, after the engine has finished initializing. This is where you should put initialization logic for your app.

### `app.on_update(dt: number)`

Called every frame. This is where you should put rendering, and whatever else you need to run every frame. `dt` is the delta time (same as `app.delta_time()`)

### `app.on_reload()`

Called after the app has already been initialized, but is then reloaded with Alt+R.

### `app.on_resize(new_size: vec2)`

Called when the window is resized.

## Assets

### `app.read_from_app_dir(path: string): string`

Reads an entire file, relative to the app directory.

### `app.dir(): string`

Returns the app directory. (usually this is where the executable is located)

## Timing

### `app.now_secs(): number`

Returns the time since the engine started, in seconds

### `app.delta_time(): number`

Returns the time between the current frame and last frame, in seconds

## Input

### `app.mouse_pos(): vec2`

Returns the current mouse position.

### `app.delta_mouse_pos(): vec2`

Returns the difference between the current mouse position and the mouse position from the last frame.

### `app.mouse_scroll(): vec2`

Returns the mouse scroll value this frame.

### `app.key_just_pressed(key: string): boolean`

Returns true if the key started being pressed this frame. See [keycodes](./keycodes.md).

### `app.key_held(key: string): boolean`

Returns true if the key is being held. See [keycodes](./keycodes.md).

### `app.key_just_released(key: string): boolean`

Returns true if the key was just released this frame. See [keycodes](./keycodes.md).

### `app.key_not_pressed(key: string): boolean`

Returns true if the key is not pressed. See [keycodes](./keycodes.md).

### `app.mouse_just_pressed(button: string): boolean`

Returns true if the mouse button started being pressed this frame. Can be `"left"`, `"right"`, or `"middle"`.

### `app.mouse_held(button: string): boolean`

Returns true if the mouse button is being held. Can be `"left"`, `"right"`, or `"middle"`.

### `app.mouse_just_released(button: string): boolean`

Returns true if the mouse button was just released this frame. Can be `"left"`, `"right"`, or `"middle"`.

### `app.mouse_not_pressed(button: string): boolean`

Returns true if the mouse button is not pressed. Can be `"left"`, `"right"`, or `"middle"`.

### `app.lock_mouse(lock: boolean)`

If true, locks the mouse inside the window and enables raw mouse input, otherwise unlocks it.

### `app.mouse_locked(): boolean`

Returns true if the mouse is currently locked inside the window.

## Windowing

### `app.frame_size(): vec2`

Returns the width and height of the window.

### `app.aspect_ratio(): number`

Returns the aspect ratio of the window. (`width / height`)

### `app.high_dpi(): boolean`

Returns true if the window is high DPI aware, and if it is running in a high DPI setting.

### `app.scale_factor(): number`

Returns the scale factor of the OS. This will be 1 if the window is not high DPI aware, or if it is not running in a high DPI setting.

### `app.request_quit()`

Gracefully closes the window, and exits the app.

### `app.set_title(title: string)`

Sets the title of the window.

## Misc

### `app.engine_info(): table`

Returns a table with various information about the engine:

```lua
{
	authors = "hellory4n",
	version_num = 00800, -- for example 12301 = v1.23.1
	version_major = 0,
	version_minor = 8,
	version_patch = 0,
	version_str = "v0.8.0",
}
```
