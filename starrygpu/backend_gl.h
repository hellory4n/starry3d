#pragma once
#include "starrygpu.h"

#ifdef __cplusplus
extern "C" {
#endif

sgpu_error_t sgpu_gl_init(sgpu_settings_t settings);
void sgpu_gl_deinit(void);
sgpu_device_t sgpu_gl_query_device(void);
void sgpu_gl_submit(void);

void sgpu_gl_start_render_pass(sgpu_render_pass_t pass);
void sgpu_gl_end_render_pass(void);
void sgpu_gl_set_viewport(sgpu_viewport_t viewport);

sgpu_error_t sgpu_gl_compile_shader(sgpu_shader_settings_t settings, sgpu_shader_t* out_shader);
void sgpu_gl_deinit_shader(sgpu_shader_t shader);

#ifdef __cplusplus
} // extern "C"
#endif
