#pragma once
#include "starrygpu.h"
#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

// a wee bit of macro slop to not lose it
#define SGPU_LENGTHOF(array) (sizeof(array) / sizeof((array)[0]))

#define SGPU_TRY(x)                                                                                \
    do {                                                                                           \
        sgpu_error_t err = (x);                                                                    \
        if (err != SGPU_OK) {                                                                      \
            return err;                                                                            \
        }                                                                                          \
    } while (false)

#define SGPU_UNREACHABLE()                                                                         \
    do {                                                                                           \
        sgpu_log_error("what the fuck?");                                                          \
        sgpu_trap();                                                                               \
    } while (false)

typedef struct sgpu_backend_shader_t {
    sgpu_shader_settings_t settings;
    union {
        struct {
            uint32_t id;
        } gl;
    } u;
    bool occupied;
} sgpu_backend_shader_t;

typedef struct sgpu_backend_pipeline_t {
    sgpu_pipeline_settings_t settings;
    union {
        struct {
            uint32_t program;
        } gl;
    } u;
    bool occupied;
} sgpu_backend_pipeline_t;

typedef struct sgpu_ctx_t {
    sgpu_settings_t settings;
    void* gl;

    sgpu_backend_shader_t shaders[32];
    sgpu_backend_pipeline_t pipelines[128];

    /// validation layer stuff
    bool initialized;
} sgpu_ctx_t;

extern sgpu_ctx_t sgpu_ctx;

// shitty implementation of sunshine.handle in C
// trying to implement generics in C is dogwater
// so it's easier to just copypaste everything :)

// TODO error on dangling handle (it's not that hard i just can't be bothered)

sgpu_error_t sgpu_get_shader_slot(sgpu_shader_t handle, sgpu_backend_shader_t** out) {
    if (handle.id > SGPU_LENGTHOF(sgpu_ctx.shaders)) {
        *out = NULL;
        return SGPU_ERROR_BROKEN_HANDLE;
    }

    *out = &sgpu_ctx.shaders[handle.id];
    return SGPU_OK;
}

static inline sgpu_error_t sgpu_new_shader_slot(sgpu_shader_t* out) {
    for (uint32_t i = 0; i < SGPU_LENGTHOF(sgpu_ctx.shaders); i++) {
        if (!sgpu_ctx.shaders[i].occupied) {
            sgpu_ctx.shaders[i].occupied = true;
            *out = (sgpu_shader_t) { .id = i };
            return SGPU_OK;
        }
    }

    return SGPU_ERROR_TOO_MANY_HANDLES;
}

sgpu_error_t sgpu_get_pipeline_slot(sgpu_pipeline_t handle, sgpu_backend_pipeline_t** out) {
    if (handle.id > SGPU_LENGTHOF(sgpu_ctx.pipelines)) {
        *out = NULL;
        return SGPU_ERROR_BROKEN_HANDLE;
    }

    *out = &sgpu_ctx.pipelines[handle.id];
    return SGPU_OK;
}

static inline sgpu_error_t sgpu_new_pipeline_slot(sgpu_pipeline_t* out) {
    for (uint32_t i = 0; i < SGPU_LENGTHOF(sgpu_ctx.pipelines); i++) {
        if (!sgpu_ctx.pipelines[i].occupied) {
            sgpu_ctx.pipelines[i].occupied = true;
            *out = (sgpu_pipeline_t) { .id = i };
            return SGPU_OK;
        }
    }

    return SGPU_ERROR_TOO_MANY_HANDLES;
}

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
