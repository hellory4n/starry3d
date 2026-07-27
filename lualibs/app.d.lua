--- @meta app

--- @class applib: table
app = {}

--- Reads an entire file, relative to the app directory.
--- @param path string
--- @return string
function app.read_from_app_dir(path) end

--- Returns the app directory. (usually this is where the executable is located)
--- @return string
function app.dir() end

--- Returns the time since the engine started, in seconds
--- @return number
function app.now_secs() end

--- Returns the time between the current frame and last frame, in seconds
--- @return number
function app.delta_time() end

--- Returns the current mouse position.
--- @return Vec2
function app.mouse_pos() end

--- Returns the difference between the current mouse position and the mouse position from the last frame.
--- @return Vec2
function app.delta_mouse_pos() end

--- Returns true if the key started being pressed this frame.
--- @param key app.Key
--- @return boolean
function app.key_just_pressed(key) end

--- Returns true if the key is being held.
--- @param key app.Key
--- @return boolean
function app.key_held(key) end

--- Returns true if the key was just released this frame.
--- @param key app.Key
--- @return boolean
function app.key_just_released(key) end

--- Returns true if the key is not pressed.
--- @param key app.Key
--- @return boolean
function app.key_not_pressed(key) end

--- Returns true if the mouse button started being pressed this frame.
--- @param button app.MouseButton
--- @return boolean
function app.mouse_just_pressed(button) end

--- Returns true if the mouse button is being held.
--- @param button app.MouseButton
--- @return boolean
function app.mouse_held(button) end

--- Returns true if the mouse button was just released this frame.
--- @param button app.MouseButton
--- @return boolean
function app.mouse_just_released(button) end

--- Returns true if the mouse button is not pressed.
--- @param button app.MouseButton
--- @return boolean
function app.mouse_not_pressed(button) end

--- Returns the width and height of the window.
--- @return Vec2
function app.frame_size() end

--- Returns the aspect ratio of the window. (`width / height`)
--- @return number
function app.aspect_ratio() end

--- Returns true if the window is high DPI aware, and if it is running in a high DPI setting.
--- @return boolean
function app.high_dpi() end

--- Returns the scale factor of the OS. This will be 1 if the window is not high DPI aware, or if it is not running in a high DPI setting.
--- @return number
function app.scale_factor() end

--- If true, locks the mouse inside the window and enables raw mouse input, otherwise unlocks it.
--- @param lock boolean
function app.lock_mouse(lock) end

--- Returns true if the mouse is currently locked inside the window.
--- @return boolean
function app.mouse_locked() end

--- Gracefully closes the window, and exits the app.
function app.request_quit() end

--- Sets the title of the window.
--- @param title string
function app.set_title(title) end
