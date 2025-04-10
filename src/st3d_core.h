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

#ifdef __cplusplus
}
#endif

#endif // ST_ST3D_CORE_H
