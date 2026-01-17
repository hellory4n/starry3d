#pragma once
#include "starrygpu.h"
#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

static inline void sgpu_log_debug(sgpu_ctx_t* ctx, const char* fmt, ...) {
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

static inline void sgpu_log_info(sgpu_ctx_t* ctx, const char* fmt, ...) {
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

static inline void sgpu_log_warn(sgpu_ctx_t* ctx, const char* fmt, ...) {
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

static inline void sgpu_log_error(sgpu_ctx_t* ctx, const char* fmt, ...) {
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
