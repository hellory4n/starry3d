#pragma once

#include "lib/dcimgui.h"
#include "starrygpu.h"

#ifdef __cplusplus
extern "C" {
#endif

void cImGui_ImplSgpu_Init(sgpu_ctx_t* ctx);
void cImGui_ImplSgpu_Shutdown(sgpu_ctx_t* ctx);
void cImGui_ImplSgpu_NewFrame(sgpu_ctx_t* ctx);
void cImGui_ImplSgpu_RenderDrawData(ImDrawData* draw_data, sgpu_ctx_t* ctx);

#ifdef __cplusplus
} // extern "C"
#endif
