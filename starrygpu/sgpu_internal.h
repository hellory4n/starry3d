#pragma once
#include "starrygpu.h"
#include <inttypes.h>
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
        sgpu_error_t _err = (x);                                                                   \
        if (_err != SGPU_OK) {                                                                     \
            return _err;                                                                           \
        }                                                                                          \
    } while (false)

#define SGPU_UNREACHABLE()                                                                         \
    do {                                                                                           \
        sgpu_log_error("what the fuck?");                                                          \
        sgpu_trap();                                                                               \
    } while (false)

#ifdef __GNUC__
#define SGPU_ATTR_PRINTF(fmtidx, argidx) __attribute__((format(printf, fmtidx, argidx)))
#else
#define SGPU_ATTR_PRINTF(fmtidx, argidx)
#endif

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

static inline sgpu_error_t sgpu_get_shader_slot(sgpu_shader_t handle, sgpu_backend_shader_t** out) {
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

static inline sgpu_error_t sgpu_get_pipeline_slot(
    sgpu_pipeline_t handle, sgpu_backend_pipeline_t** out) {
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

SGPU_ATTR_PRINTF(1, 2) static inline void sgpu_log_debug(const char* fmt, ...) {
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

SGPU_ATTR_PRINTF(1, 2) static inline void sgpu_log_info(const char* fmt, ...) {
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

SGPU_ATTR_PRINTF(1, 2) static inline void sgpu_log_warn(const char* fmt, ...) {
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

SGPU_ATTR_PRINTF(1, 2) static inline void sgpu_log_error(const char* fmt, ...) {
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

static inline void sgpu_print_dev(sgpu_device_t dev) {
    sgpu_log_info("using device '%s' by '%s'", dev.device_name, dev.vendor_name);
    sgpu_log_info(
        "- max_image_2d_size = %ux%u", dev.max_image_2d_size[0], dev.max_image_2d_size[1]);
    sgpu_log_info(
        "- max_storage_buffer_size = %" PRIu64 "MB", dev.max_storage_buffer_size / 1024 / 1024);
    sgpu_log_info("- max_storage_buffer_bindings = %u", dev.max_storage_buffer_bindings);
    sgpu_log_info("- max_compute_workgroup_size = %ux%ux%u", dev.max_compute_workgroup_size[0],
        dev.max_compute_workgroup_size[1], dev.max_compute_workgroup_size[2]);
    sgpu_log_info("- max_compute_workgroup_threads = %u", dev.max_compute_workgroup_threads);
}

#ifdef __cplusplus
} // extern "C"
#endif
