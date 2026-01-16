#pragma once
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>

// select backend
#ifdef _WIN32
#define SGPU_D3D11
#else
#error unsupported backend, skill issue, compile to windows for now
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct sgpu_version_t {
    uint32_t major;
    uint32_t minor;
    uint32_t patch;
} sgpu_version_t;

typedef enum {
    SGPU_OK = 0,
    SGPU_ERROR_UNKNOWN,
    SGPU_ERROR_OUT_OF_CPU_MEMORY,
    SGPU_ERROR_OUT_OF_GPU_MEMORY,
    SGPU_ERROR_INCOMPATIBLE_GPU,
} sgpu_error_t;

typedef struct sgpu_settings_t {
    const char* app_name; // optional
    const char* engine_name; // optional
    sgpu_version_t app_version; // optional
    sgpu_version_t engine_version; // optional
    // TODO this should be chosen at compile time for a 0.000000000001% performance increase
    bool validation_enabled;

    struct {
        const void* userdata; // optional
        void* win32_handle; // if using d3d11

        int32_t (*get_width)(const void* userdata);
        int32_t (*get_height)(const void* userdata);

        // TODO MSAA support
        // TODO swapchains would probably have to be explicit if you want multiple windows
    } window_system;

    /// optional
    struct {
        /// may return null on error
        void* (*malloc)(size_t size);
        void (*free)(void* ptr);
    } allocator;
} sgpu_settings_t;

static inline void sgpu_settings_default(sgpu_settings_t* old) {
    if (!old->app_name) {
        old->app_name = "A Starry app";
    }
    if (!old->engine_name) {
        old->engine_name = "A Starrygpu engine";
    }
    if (!old->allocator.malloc) {
        old->allocator.malloc = malloc;
    }
    if (!old->allocator.free) {
        old->allocator.free = free;
    }
}

typedef struct sgpu_ctx_t {
    sgpu_settings_t settings;
    void* d3d11;

    /// validation layer stuff
    bool initialized;
} sgpu_ctx_t;

/// Initializes the graphics context
sgpu_error_t sgpu_init(sgpu_settings_t settings, sgpu_ctx_t* out_ctx);

/// Deinitializes the graphics context
void sgpu_deinit(sgpu_ctx_t* ctx);

#ifdef __cplusplus
} // extern "C"
#endif
