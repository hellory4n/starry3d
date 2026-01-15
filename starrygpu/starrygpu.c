/// read the readme
/// copyright me

#include "starrygpu.h"

sgpu_error_t sgpu_init(sgpu_settings_t settings, sgpu_ctx_t* out_ctx) {
    sgpu_ctx_t ctx = {
        .settings = settings,
    };

    ctx.initialized = true;
    *out_ctx = ctx;
    return SGPU_OK;
}

void sgpu_deinit(sgpu_ctx_t* ctx) {
    ctx->initialized = false;
}
