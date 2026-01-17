#pragma once
#include "starrygpu.h"

#ifdef __cplusplus
extern "C" {
#endif

sgpu_error_t sgpu_d3d11_init(sgpu_settings_t settings, sgpu_ctx_t* ctx);
void sgpu_d3d11_deinit(sgpu_ctx_t* ctx);
sgpu_device_t sgpu_d3d11_query_device(sgpu_ctx_t* ctx);

void sgpu_d3d11_swap_buffers(sgpu_ctx_t* ctx);
sgpu_error_t sgpu_d3d11_recreate_swapchain(sgpu_ctx_t* ctx);

void sgpu_d3d11_start_render_pass(sgpu_ctx_t* ctx, sgpu_render_pass_t render_pass);
void sgpu_d3d11_end_render_pass(sgpu_ctx_t* ctx);
void sgpu_d3d11_set_viewport(sgpu_ctx_t* ctx, sgpu_viewport_t viewport);

#ifdef __cplusplus
} // extern "C"
#endif
