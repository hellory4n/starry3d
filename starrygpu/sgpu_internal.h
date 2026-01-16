#pragma once
#include "starrygpu.h"
#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

static inline void* sgpu_malloc(sgpu_ctx_t* ctx, size_t size) {
    if (!ctx->settings.allocator.malloc) {
        return malloc(size);
    }
    return ctx->settings.allocator.malloc(size);
}

static inline void sgpu_free(sgpu_ctx_t* ctx, void* ptr) {
    if (!ctx->settings.allocator.free) {
        return free(ptr);
    }
    return ctx->settings.allocator.free(ptr);
}

static inline void sgpu_debug(sgpu_ctx_t* ctx, const char* fmt, ...) {
    va_list arg;
    va_start(arg, fmt);
    char buffer[256];
    vsnprintf(buffer, sizeof(buffer), fmt, arg);
    va_end(arg);

    if (!ctx->settings.logger.debug) {
        fprintf(stderr, "starrygpu: %s\n", buffer);
    } else {
        ctx->settings.logger.debug(buffer);
    }
}

static inline void sgpu_log(sgpu_ctx_t* ctx, const char* fmt, ...) {
    va_list arg;
    va_start(arg, fmt);
    char buffer[256];
    vsnprintf(buffer, sizeof(buffer), fmt, arg);
    va_end(arg);

    if (!ctx->settings.logger.info) {
        fprintf(stderr, "starrygpu: %s\n", buffer);
    } else {
        ctx->settings.logger.info(buffer);
    }
}

static inline void sgpu_warn(sgpu_ctx_t* ctx, const char* fmt, ...) {
    va_list arg;
    va_start(arg, fmt);
    char buffer[256];
    vsnprintf(buffer, sizeof(buffer), fmt, arg);
    va_end(arg);

    if (!ctx->settings.logger.warn) {
        fprintf(stderr, "starrygpu: %s\n", buffer);
    } else {
        ctx->settings.logger.warn(buffer);
    }
}

static inline void sgpu_error(sgpu_ctx_t* ctx, const char* fmt, ...) {
    va_list arg;
    va_start(arg, fmt);
    char buffer[256];
    vsnprintf(buffer, sizeof(buffer), fmt, arg);
    va_end(arg);

    if (!ctx->settings.logger.error) {
        fprintf(stderr, "starrygpu: %s\n", buffer);
    } else {
        ctx->settings.logger.error(buffer);
    }
}

#ifdef __cplusplus
} // extern "C"
#endif
