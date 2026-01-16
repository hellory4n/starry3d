#pragma once
#include "starrygpu.h"

#ifdef __cplusplus
extern "C" {
#endif

sgpu_error_t sgpu_d3d11_init(sgpu_settings_t settings, sgpu_ctx_t* ctx);
void sgpu_d3d11_deinit(sgpu_ctx_t* ctx);
void sgpu_d3d11_swap_buffers(const sgpu_ctx_t* ctx);
sgpu_error_t sgpu_d3d11_recreate_swapchain(sgpu_ctx_t* ctx);

void sgpu_d3d11_flush(const sgpu_ctx_t* ctx);

#ifdef __cplusplus
} // extern "C"
#endif
