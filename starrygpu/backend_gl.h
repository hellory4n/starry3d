#pragma once
#include "starrygpu.h"

#ifdef __cplusplus
extern "C" {
#endif

sgpu_error_t sgpu_gl_init(sgpu_settings_t settings, sgpu_ctx_t* ctx);
void sgpu_gl_deinit(sgpu_ctx_t* ctx);
sgpu_device_t sgpu_gl_query_device(sgpu_ctx_t* ctx);
void sgpu_gl_submit(sgpu_ctx_t* ctx);

void sgpu_gl_start_render_pass(sgpu_ctx_t* ctx, sgpu_render_pass_t pass);
void sgpu_gl_end_render_pass(sgpu_ctx_t* ctx);
void sgpu_gl_set_viewport(sgpu_ctx_t* ctx, sgpu_viewport_t viewport);

#ifdef __cplusplus
} // extern "C"
#endif
