#ifndef ST_ST3D_CORE_H
#define ST_ST3D_CORE_H
#include <libtrippin.h>

#ifdef __cplusplus
extern "C" {
#endif

// starry3d version :D
#define ST3D_VERSION "v0.1.0"

// I just put the Starry3D context
typedef struct {
	// used for both starry3d and rgfw
	TrArena arena;
	// internal window handle
	void* window;
	// mate
	bool window_closing;
} St3dCtx;

// Initializes the engine and all of its subsystems
St3dCtx st3d_init(const char* title, int32_t width, int32_t height);

// Frees the engine and all of its subsystems
void st3d_free(St3dCtx* ctx);

#ifdef __cplusplus
}
#endif

#endif // ST_ST3D_CORE_H
