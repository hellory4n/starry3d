#pragma once
#include "starrygpu.h"
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

static inline void* sgpu_malloc(const sgpu_ctx_t* ctx, size_t size) {
    return ctx->settings.allocator.malloc(size);
}

static inline void sgpu_free(const sgpu_ctx_t* ctx, void* ptr) {
    return ctx->settings.allocator.free(ptr);
}

#ifdef __cplusplus
} // extern "C"
#endif
