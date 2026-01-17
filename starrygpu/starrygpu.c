#include "starrygpu.h"
#include "sgpu_internal.h"
#ifdef SGPU_D3D11
#include "backend_d3d11.h"
#endif

sgpu_error_t sgpu_init(sgpu_settings_t settings, sgpu_ctx_t* out_ctx) {
    sgpu_settings_default(&settings);

    sgpu_ctx_t ctx = {
        .settings = settings,
    };

#ifdef SGPU_D3D11
    sgpu_log_info(&ctx, "using Direct3D 11");
    sgpu_d3d11_init(settings, &ctx);
#endif

    ctx.initialized = true;
    *out_ctx = ctx;
    sgpu_log_info(&ctx, "initialized successfully");
    return SGPU_OK;
}

void sgpu_deinit(sgpu_ctx_t* ctx) {
#ifdef SGPU_D3D11
    sgpu_log_info(ctx, "deinitializing Direct3D 11");
    sgpu_d3d11_deinit(ctx);
    sgpu_log_info(ctx, "deinitialized successfully");
#endif

    ctx->initialized = false;
}

sgpu_device_t sgpu_query_device(sgpu_ctx_t* ctx) {
#ifdef SGPU_D3D11
    return sgpu_d3d11_query_device(ctx);
#else
    return (sgpu_device_t) { 0 };
#endif
}

void sgpu_start_render_pass(sgpu_ctx_t* ctx, sgpu_render_pass_t render_pass) {
#ifdef SGPU_D3D11
    sgpu_d3d11_start_render_pass(ctx, render_pass);
#else
    (void)ctx;
    (void)render_pass;
#endif
}

void sgpu_end_render_pass(sgpu_ctx_t* ctx) {
#ifdef SGPU_D3D11
    sgpu_d3d11_end_render_pass(ctx);
#else
    (void)ctx;
#endif
}

void sgpu_swap_buffers(sgpu_ctx_t* ctx) {
#ifdef SGPU_D3D11
    sgpu_d3d11_swap_buffers(ctx);
#else
    (void)ctx;
#endif
}

void sgpu_recreate_swapchain(sgpu_ctx_t* ctx) {
#ifdef SGPU_D3D11
    sgpu_d3d11_recreate_swapchain(ctx);
#else
    (void)ctx;
#endif
}

void sgpu_set_viewport(sgpu_ctx_t* ctx, sgpu_viewport_t viewport) {
#ifdef SGPU_D3D11
    sgpu_d3d11_set_viewport(ctx, viewport);
#else
    (void)ctx;
    (void)viewport;
#endif
}
