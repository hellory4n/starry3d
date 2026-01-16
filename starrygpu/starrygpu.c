#include "starrygpu.h"
#ifdef SGPU_D3D11
#include "backend_d3d11.h"
#endif

sgpu_error_t sgpu_init(sgpu_settings_t settings, sgpu_ctx_t* out_ctx) {
    sgpu_settings_default(&settings);

    sgpu_ctx_t ctx = {
        .settings = settings,
    };

#ifdef SGPU_D3D11
    sgpu_d3d11_init(settings, &ctx);
#endif

    ctx.initialized = true;
    *out_ctx = ctx;
    return SGPU_OK;
}

void sgpu_deinit(sgpu_ctx_t* ctx) {
#ifdef SGPU_D3D11
    sgpu_d3d11_deinit(ctx);
#endif

    ctx->initialized = false;
}
