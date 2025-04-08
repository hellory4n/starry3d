#ifndef ST3D_WINDOW_H
#define ST3D_WINDOW_H
#include "st3d_core.h"

#ifdef __cplusplus
extern "C" {
#endif

// Meant to be called from st3d_init
void st3di_window_new(St3dCtx* ctx, int32_t width, int32_t height, const char* title);

// Meant to be called from st3d_free
void st3di_window_free(St3dCtx* ctx);

#ifdef __cplusplus
}
#endif

#endif // ST3D_WINDOW_H
