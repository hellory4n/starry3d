#pragma once
#include "sgpu_internal.h"
#include "starrygpu.h"

// shitty implementation of sunshine.handle in C
// trying to implement generics in C is dogwater
// so it's easier to just copypaste everything :)

// TODO error on dangling handle (it's not that hard i just can't be bothered)

extern sgpu_backend_shader_t sgpu_shaders[32];

/// sets out to null on error
static inline sgpu_error_t sgpu_get_shader_slot(sgpu_shader_t handle, sgpu_backend_shader_t** out) {
    if (handle.id > SGPU_LENGTHOF(sgpu_shaders)) {
        *out = NULL;
        return SGPU_ERROR_BROKEN_HANDLE;
    }

    *out = &sgpu_shaders[handle.id];
    return SGPU_OK;
}

static inline sgpu_error_t sgpu_new_shader_slot(sgpu_shader_t* out) {
    for (uint32_t i = 0; i < SGPU_LENGTHOF(sgpu_shaders); i++) {
        if (!sgpu_shaders[i].occupied) {
            sgpu_shaders[i].occupied = true;
            *out = (sgpu_shader_t) { .id = i };
            return SGPU_OK;
        }
    }

    return SGPU_ERROR_TOO_MANY_HANDLES;
}
