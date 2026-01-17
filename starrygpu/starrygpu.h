#pragma once
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>

// select backend
#ifdef _WIN32
#define SGPU_D3D11
#else
#warning unsupported backend, skill issue, compile to windows for now
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
    // TODO actually implement this because i can't be bothered rn
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
        void (*debug)(const char* msg);
        void (*info)(const char* msg);
        void (*warn)(const char* msg);
        void (*error)(const char* msg);
    } logger;
} sgpu_settings_t;

static inline void sgpu_settings_default(sgpu_settings_t* old) {
    if (!old->app_name) {
        old->app_name = "A Starry app";
    }
    if (!old->engine_name) {
        old->engine_name = "A Starrygpu engine";
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

void sgpu_flush(sgpu_ctx_t* ctx);

typedef enum sgpu_load_action_t {
    /// Keep existing contents
    SGPU_LOAD_ACTION_LOAD,
    /// All contents reset and set to a constant
    SGPU_LOAD_ACTION_CLEAR,
    /// Existing contents are undefined and ignored
    SGPU_LOAD_ACTION_IGNORE,
} sgpu_load_action_t;

typedef enum sgpu_store_action_t {
    /// Rendered contents will be stored in memory and can be read later
    SGPU_STORE_ACTION_STORE,
    /// Existing contents are undefined and ignored
    SGPU_STORE_ACTION_IGNORE,
} sgpu_store_action_t;

typedef struct sgpu_render_pass_t {
    struct {
        sgpu_load_action_t load_action;
        sgpu_load_action_t store_action;
        struct {
            float r, g, b, a;
        } clear_color;
    } frame;
} sgpu_render_pass_t;

/// render my pass<3
void sgpu_start_render_pass(sgpu_ctx_t* ctx, sgpu_render_pass_t render_pass);
void sgpu_end_render_pass(sgpu_ctx_t* ctx);

void sgpu_swap_buffers(sgpu_ctx_t* ctx);
void sgpu_recreate_swapchain(sgpu_ctx_t* ctx);

typedef struct sgpu_viewport_t {
    int32_t top_left_x;
    int32_t top_left_y;
    int32_t width;
    int32_t height;
    float min_depth;
    float max_depth;
} sgpu_viewport_t;

void sgpu_set_viewport(sgpu_ctx_t* ctx, sgpu_viewport_t viewport);

#ifdef __cplusplus
} // extern "C"
#endif
