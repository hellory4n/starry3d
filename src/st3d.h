#ifndef _ST3D_CORE_H
#define _ST3D_CORE_H
#include <libtrippin.h>

#ifdef __cplusplus
extern "C" {
#endif

// starry3d version :D
#define ST3D_VERSION "v0.2.0"

// Euler rotation in degrees
// TODO move into libtrippin
typedef TrVec3f TrRotation;

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

#ifdef __cplusplus
}
#endif

#endif
