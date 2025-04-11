#ifndef ST_ST3D_CORE_H
#define ST_ST3D_CORE_H
#include <libtrippin.h>

#ifdef __cplusplus
extern "C" {
#endif

// starry3d version :D
#define ST3D_VERSION "v0.2.0"

typedef struct {
	int32_t die;
} St3diRenderCommand;

// Initializes the engine and all of its subsystems
void st3d_init(const char* app, const char* assets, int32_t width, int32_t height);

// Frees the engine and all of its subsystems
void st3d_free(void);

// WebGPU has to tick.
void st3di_tick(void);

// Internal utility to add commands to the render queue. Modern rendering is tricky. Use
// `st3di_queue_batch_submit` if you want to send multiple commands at once
void st3di_queue_submit(St3diRenderCommand cmd);

// Similar to `st3di_queue_submit`, but with multiple commands.
void st3di_queue_batch_submit(TrSlice cmds);

#ifdef __cplusplus
}
#endif

#endif // ST_ST3D_CORE_H
