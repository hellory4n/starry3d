#ifndef ST_ST3D_CORE_H
#define ST_ST3D_CORE_H
#include <libtrippin.h>

#ifdef __cplusplus
extern "C" {
#endif

// starry3d version :D
#define ST3D_VERSION "v0.2.0"

// Initializes the engine and all of its subsystems
void st3d_init(const char* app, const char* assets, int32_t width, int32_t height);

// Frees the engine and all of its subsystems
void st3d_free(void);

// If true, the window is closing and dying.
bool st3d_is_closing(void);

// It closes the window :)
void st3d_close(void);

// Does some fuckery that ends drawing.
void st3d_end_drawing(TrColor clear_color);

// It's just `glfwPollEvents()`
void st3d_poll_events(void);

#ifdef __cplusplus
}
#endif

#endif // ST_ST3D_CORE_H
