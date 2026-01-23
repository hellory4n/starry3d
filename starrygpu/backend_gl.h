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
void sgpu_gl_set_blend(sgpu_blend_test_t blend);

sgpu_error_t sgpu_gl_compile_shader(sgpu_shader_settings_t settings, sgpu_shader_t* out_shader);
void sgpu_gl_deinit_shader(sgpu_shader_t shader);
sgpu_error_t sgpu_gl_compile_pipeline(sgpu_pipeline_settings_t settings, sgpu_pipeline_t* out);
void sgpu_gl_deinit_pipeline(sgpu_pipeline_t handle);
void sgpu_gl_apply_pipeline(sgpu_pipeline_t handle);

void sgpu_gl_draw(uint32_t base_elem, uint32_t count, uint32_t instances);

#ifdef __cplusplus
} // extern "C"
#endif
