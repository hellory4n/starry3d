#ifndef _ST3D_CORE_H
#define _ST3D_CORE_H
#include <libtrippin.h>

#ifdef __cplusplus
extern "C" {
#endif

// Starry3D version :D
#define ST3D_VERSION "v0.1.0"

// Default size for buffers storing paths. It's 260 because that's the limit on Windows.
#define ST3D_PATH_SIZE 260

// Initializes the engine and all of its subsystems
void st3d_init(const char* app, const char* assets, uint32_t width, uint32_t height);

// Frees the engine and all of its subsystems
void st3d_free(void);

// If true, the window is closing and dying.
bool st3d_is_closing(void);

// It closes the window :)
void st3d_close(void);

// It's just `glfwPollEvents()`
void st3d_poll_events(void);

// Returns the internal window handle. This is just a `GLFWwindow*` because we only use GLFW.
void* st3d_get_window_handle(void);

// Returns the window size.
TrVec2i st3d_window_size(void);

// Gets the directory of the executable, and outputs it into out
void st3d_app_dir(TrString* out);

// Gets the directory where you're supposed to save things, and outputs it into out
void st3d_user_dir(TrString* out);

// Shorthand for getting paths. Start with `app:` to get from the assets directory, and `usr:`
// to get from the directory where you save things. For example, `app:images/bob.png`, and `usr:espionage.txt`.
// Writes the actual path to out, which should be at least 260 characters because Windows.
void st3d_path(const char* s, TrString* out);

#ifdef __cplusplus
}
#endif

#endif
