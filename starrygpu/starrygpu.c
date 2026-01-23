#include "starrygpu.h"
#include "sgpu_internal.h"
#ifdef SGPU_GL
#include "backend_gl.h"
#endif

sgpu_ctx_t sgpu_ctx;

sgpu_error_t sgpu_init(sgpu_settings_t settings) {
    sgpu_settings_default(&settings);

    sgpu_ctx = (sgpu_ctx_t) {
        .settings = settings,
    };

#ifdef SGPU_GL
    sgpu_log_info("using OpenGL 4.5 Core");
    sgpu_gl_init(settings);
#endif

    sgpu_ctx.initialized = true;
    sgpu_log_info("initialized successfully");
    return SGPU_OK;
}

void sgpu_deinit(void) {
#ifdef SGPU_GL
    sgpu_log_info("deinitializing OpenGL");
    sgpu_gl_deinit();
    sgpu_log_info("deinitialized successfully");
#endif

    sgpu_ctx.initialized = false;
}

sgpu_device_t sgpu_query_device(void) {
#ifdef SGPU_GL
    return sgpu_gl_query_device();
#else
    return (sgpu_device_t) { 0 };
#endif
}

sgpu_backend_t sgpu_query_backend(void) {
#ifdef SGPU_GL
    return SGPU_BACKEND_GLCORE;
#else
    return SGPU_BACKEND_UNSUPPORTED;
#endif
}

void sgpu_start_render_pass(sgpu_render_pass_t render_pass) {
#ifdef SGPU_GL
    sgpu_gl_start_render_pass(render_pass);
#else
    (void)render_pass;
#endif
}

void sgpu_submit(void) {
#ifdef SGPU_GL
    sgpu_gl_submit();
#endif
}

void sgpu_end_render_pass(void) {
#ifdef SGPU_GL
    sgpu_gl_end_render_pass();
#endif
}

void sgpu_set_viewport(sgpu_viewport_t viewport) {
#ifdef SGPU_GL
    sgpu_gl_set_viewport(viewport);
#else
    (void)viewport;
#endif
}

sgpu_error_t sgpu_compile_shader(sgpu_shader_settings_t settings, sgpu_shader_t* out_shader) {
#ifdef SGPU_GL
    return sgpu_gl_compile_shader(settings, out_shader);
#else
    (void)settings;
    (void)out_shader;
#endif
}

void sgpu_deinit_shader(sgpu_shader_t shader) {
#ifdef SGPU_GL
    sgpu_gl_deinit_shader(shader);
#else
    (void)shader;
#endif
}

sgpu_error_t sgpu_compile_pipeline(sgpu_pipeline_settings_t settings, sgpu_pipeline_t* out) {
#ifdef SGPU_GL
    return sgpu_gl_compile_pipeline(settings, out);
#else
    return SGPU_OK;
#endif
}

void sgpu_deinit_pipeline(sgpu_pipeline_t pip) {
#ifdef SGPU_GL
    sgpu_gl_deinit_pipeline(pip);
#endif
}

void sgpu_apply_pipeline(sgpu_pipeline_t pip) {
#ifdef SGPU_GL
    sgpu_gl_apply_pipeline(pip);
#endif
}

void sgpu_set_blend(sgpu_blend_test_t blend) {
#ifdef SGPU_GL
    sgpu_gl_set_blend(blend);
#endif
}

void sgpu_draw(uint32_t base_elem, uint32_t count, uint32_t instances) {
#ifdef SGPU_GL
    sgpu_gl_draw(base_elem, count, instances);
#endif
}
