#include "starrygpu.h"
#include "sgpu_internal.h"
#ifdef SGPU_GL
#include "backend_gl.h"
#endif

sgpu_error_t sgpu_init(sgpu_settings_t settings, sgpu_ctx_t* out_ctx) {
    sgpu_settings_default(&settings);

    sgpu_ctx_t ctx = {
        .settings = settings,
    };

#ifdef SGPU_GL
    sgpu_log_info(&ctx, "using OpenGL 4.5 Core");
    sgpu_gl_init(settings, &ctx);
#endif

    ctx.initialized = true;
    *out_ctx = ctx;
    sgpu_log_info(&ctx, "initialized successfully");
    return SGPU_OK;
}

void sgpu_deinit(sgpu_ctx_t* ctx) {
#ifdef SGPU_GL
    sgpu_log_info(ctx, "deinitializing OpenGL");
    sgpu_gl_deinit(ctx);
    sgpu_log_info(ctx, "deinitialized successfully");
#endif

    ctx->initialized = false;
}

sgpu_device_t sgpu_query_device(sgpu_ctx_t* ctx) {
#ifdef SGPU_GL
    return sgpu_gl_query_device(ctx);
#else
    return (sgpu_device_t) { 0 };
#endif
}

void sgpu_start_render_pass(sgpu_ctx_t* ctx, sgpu_render_pass_t render_pass) {
#ifdef SGPU_GL
    sgpu_gl_start_render_pass(ctx, render_pass);
#else
    (void)ctx;
    (void)render_pass;
#endif
}

void sgpu_end_render_pass(sgpu_ctx_t* ctx) {
#ifdef SGPU_GL
    sgpu_gl_end_render_pass(ctx);
#else
    (void)ctx;
#endif
}

void sgpu_set_viewport(sgpu_ctx_t* ctx, sgpu_viewport_t viewport) {
#ifdef SGPU_GL
    sgpu_gl_set_viewport(ctx, viewport);
#else
    (void)ctx;
    (void)viewport;
#endif
}
