#pragma once
#include "starrygpu.h"
#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

#define SGPU_LENGTHOF(array) sizeof(array) / sizeof(array[0])

typedef struct sgpu_backend_shader_t {
    sgpu_shader_settings_t settings;
    union {
        struct {
            uint32_t id;
        } gl;
    } u;
    bool occupied;
} sgpu_backend_shader_t;

typedef struct sgpu_ctx_t {
    sgpu_settings_t settings;
    void* gl;

    /// validation layer stuff
    bool initialized;
} sgpu_ctx_t;

extern sgpu_ctx_t sgpu_ctx;

static inline void sgpu_log_debug(const char* fmt, ...) {
    va_list arg;
    va_start(arg, fmt);
    char buffer[256];
    vsnprintf(buffer, sizeof(buffer), fmt, arg);
    va_end(arg);

    if (!sgpu_ctx.settings.logger.debug) {
        fprintf(stderr, "starrygpu: %s\n", buffer);
    } else {
        sgpu_ctx.settings.logger.debug(buffer);
    }
}

static inline void sgpu_log_info(const char* fmt, ...) {
    va_list arg;
    va_start(arg, fmt);
    char buffer[256];
    vsnprintf(buffer, sizeof(buffer), fmt, arg);
    va_end(arg);

    if (!sgpu_ctx.settings.logger.info) {
        fprintf(stderr, "starrygpu: %s\n", buffer);
    } else {
        sgpu_ctx.settings.logger.info(buffer);
    }
}

static inline void sgpu_log_warn(const char* fmt, ...) {
    va_list arg;
    va_start(arg, fmt);
    char buffer[256];
    vsnprintf(buffer, sizeof(buffer), fmt, arg);
    va_end(arg);

    if (!sgpu_ctx.settings.logger.warn) {
        fprintf(stderr, "starrygpu: %s\n", buffer);
    } else {
        sgpu_ctx.settings.logger.warn(buffer);
    }
}

static inline void sgpu_log_error(const char* fmt, ...) {
    va_list arg;
    va_start(arg, fmt);
    char buffer[256];
    vsnprintf(buffer, sizeof(buffer), fmt, arg);
    va_end(arg);

    if (!sgpu_ctx.settings.logger.error) {
        fprintf(stderr, "starrygpu: %s\n", buffer);
    } else {
        sgpu_ctx.settings.logger.error(buffer);
    }
}

static inline void sgpu_trap(void) {
    if (!sgpu_ctx.settings.logger.trap) {
        abort();
    } else {
        sgpu_ctx.settings.logger.trap();
    }
}

#ifdef __cplusplus
} // extern "C"
#endif
