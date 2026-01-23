#pragma once
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

// select backend
#ifdef __APPLE__
#warning apple doesn't support opengl 4.5, skill issue
#endif
#define SGPU_GL

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
    SGPU_ERROR_TOO_MANY_HANDLES,
    SGPU_ERROR_BROKEN_HANDLE,
    SGPU_ERROR_SHADER_COMPILATION_FAILED,
    SGPU_ERROR_PIPELINE_COMPILATION_FAILED,
} sgpu_error_t;

typedef void (*sgpu_gl_api_fn)(void);

typedef struct sgpu_settings_t {
    const char* app_name; // optional
    const char* engine_name; // optional
    sgpu_version_t app_version; // optional
    sgpu_version_t engine_version; // optional
    // TODO this should be chosen at compile time for a 0.000000000001% performance increase
    // TODO actually implement this because i can't be bothered rn
    bool validation_enabled;
    /// The real backend API used may be able to use its own validation layers
    bool backend_validation_enabled;

    struct {
        /// e.g. glfwGetProcAddress
        sgpu_gl_api_fn (*load_fn)(const char* name);
    } gl;

    /// optional
    struct {
        void (*debug)(const char* msg);
        void (*info)(const char* msg);
        void (*warn)(const char* msg);
        void (*error)(const char* msg);
        /// used for validation layers
        void (*trap)(void);
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

/// Initializes the graphics context
sgpu_error_t sgpu_init(sgpu_settings_t settings);

/// Deinitializes the graphics context
void sgpu_deinit(void);

typedef struct sgpu_device_t {
    const char* vendor_name;
    const char* device_name;

    uint32_t max_image_2d_size[2];
    /// Applies to a single storage buffer block; in bytes
    uint64_t max_storage_buffer_size;
    /// How many storage buffers can be bound at the same time, per shader stage
    uint32_t max_storage_buffer_bindings;
    /// The GPU doesn't have infinite cores unfortunately
    uint32_t max_compute_workgroup_size[3];
    uint32_t max_compute_workgroup_threads;
} sgpu_device_t;

/// Returns info about the GPU being used
sgpu_device_t sgpu_query_device(void);

typedef enum sgpu_backend_t {
    SGPU_BACKEND_UNSUPPORTED,
    SGPU_BACKEND_GLCORE,
} sgpu_backend_t;

/// Returns the backend being used
sgpu_backend_t sgpu_query_backend(void);

/// Poor man's command buffer
void sgpu_submit(void);

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
    struct {
        uint32_t width;
        uint32_t height;
        struct {
            /// you can probably just pass 0 here
            uint32_t framebuffer;
        } gl;
    } swapchain;
} sgpu_render_pass_t;

/// render my pass<3
void sgpu_start_render_pass(sgpu_render_pass_t render_pass);
void sgpu_end_render_pass(void);

typedef struct sgpu_viewport_t {
    int32_t top_left_x;
    int32_t top_left_y;
    int32_t width;
    int32_t height;
    float min_depth;
    float max_depth;
} sgpu_viewport_t;

void sgpu_set_viewport(sgpu_viewport_t viewport);

typedef enum sgpu_shader_stage_t {
    SGPU_SHADER_STAGE_VERTEX,
    SGPU_SHADER_STAGE_FRAGMENT,
    SGPU_SHADER_STAGE_COMPUTE,
} sgpu_shader_stage_t;

typedef struct sgpu_shader_settings_t {
    const char* label;
    /// null-terminated GLSL on OpenGL
    const char* src;
    /// doesn't include the null terminator for GLSL
    size_t src_len;
    /// defaults to "main", ignored in OpenGL
    const char* entry_point;
    sgpu_shader_stage_t stage;
} sgpu_shader_settings_t;

static inline void sgpu_shader_settings_default(sgpu_shader_settings_t* src) {
    if (src->label == NULL) {
        src->label = "a Starry shader";
    }
}

typedef struct sgpu_shader_t {
    uint32_t id;
} sgpu_shader_t;

/// Outputs the shader into out, if compilation succeeds.
sgpu_error_t sgpu_compile_shader(sgpu_shader_settings_t settings, sgpu_shader_t* out_shader);
void sgpu_deinit_shader(sgpu_shader_t shader);

typedef enum sgpu_pipeline_type_t {
    SGPU_PIPELINE_TYPE_RASTER,
    SGPU_PIPELINE_TYPE_COMPUTE,
} sgpu_pipeline_type_t;

typedef enum sgpu_topology_t {
    /// Vertices 0, 1, and 2 form a triangle. Vertices 3, 4, and 5 form a triangle. And so on.
    SGPU_TOPOLOGY_TRIANGLE_LIST,
    /// Every group of 3 adjacent vertices forms a triangle. The face direction of the strip is
    /// determined by the winding of the first triangle. Each successive triangle will have its
    /// effective face order reversed, so the system compensates for that by testing it in the
    /// opposite way. A vertex stream of n length will generate n-2 triangles.
    SGPU_TOPOLOGY_TRIANGLE_STRIP,
    /// The first vertex is always held fixed. From there on, every group of 2 adjacent vertices
    /// form a triangle with the first. So with a vertex stream, you get a list of triangles
    /// like so: (0, 1, 2) (0, 2, 3), (0, 3, 4), etc. A vertex stream of n length will
    /// generate n-2 triangles.
    SGPU_TOPOLOGY_TRIANGLE_FAN,
} sgpu_topology_t;

typedef enum sgpu_winding_order_t {
    SGPU_WINDING_ORDER_CLOCKWISE,
    SGPU_WINDING_ORDER_COUNTER_CLOCKWISE,
} sgpu_winding_order_t;

typedef enum sgpu_cull_mode_t {
    SGPU_CULL_MODE_FRONT_FACE,
    SGPU_CULL_MODE_BACK_FACE,
    SGPU_CULL_MODE_FRONT_AND_BACK_FACES,
    SGPU_CULL_MODE_NONE,
} sgpu_cull_mode_t;

typedef struct sgpu_pipeline_settings_t {
    const char* label;
    sgpu_pipeline_type_t type;
    struct {
        sgpu_shader_t vertex_shader;
        sgpu_shader_t fragment_shader;
        sgpu_topology_t topology;
        sgpu_winding_order_t front_face;
        sgpu_cull_mode_t cull;
    } raster;
    struct {
        sgpu_shader_t shader;
    } compute;
} sgpu_pipeline_settings_t;

typedef struct sgpu_pipeline_t {
    uint32_t id;
} sgpu_pipeline_t;

sgpu_error_t sgpu_compile_pipeline(sgpu_pipeline_settings_t settings, sgpu_pipeline_t* out);
void sgpu_deinit_pipeline(sgpu_pipeline_t pip);
void sgpu_apply_pipeline(sgpu_pipeline_t pip);

typedef enum sgpu_blend_scale_factor_t {
    SGPU_BLEND_SCALE_FACTOR_ZERO,
    SGPU_BLEND_SCALE_FACTOR_ONE,
    SGPU_BLEND_SCALE_FACTOR_SRC_COLOR,
    SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_SRC_COLOR,
    SGPU_BLEND_SCALE_FACTOR_DST_COLOR,
    SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_DST_COLOR,
    SGPU_BLEND_SCALE_FACTOR_SRC_ALPHA,
    SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_SRC_ALPHA,
    SGPU_BLEND_SCALE_FACTOR_DST_ALPHA,
    SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_DST_ALPHA,
    SGPU_BLEND_SCALE_FACTOR_CONSTANT_COLOR,
    SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_CONSTANT_COLOR,
    SGPU_BLEND_SCALE_FACTOR_CONSTANT_ALPHA,
    SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_CONSTANT_ALPHA,
    SGPU_BLEND_SCALE_FACTOR_SRC_ALPHA_SATURATE,
    SGPU_BLEND_SCALE_FACTOR_SRC1_COLOR,
    SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_SRC1_COLOR,
    SGPU_BLEND_SCALE_FACTOR_SRC1_ALPHA,
    SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_SRC1_ALPHA,
} sgpu_blend_scale_factor_t;

typedef struct sgpu_blend_test_t {
    sgpu_blend_scale_factor_t src_factor;
    sgpu_blend_scale_factor_t dst_factor;
    /// optional
    struct {
        float r, g, b, a;
    } constant_color;
} sgpu_blend_test_t;

void sgpu_set_blend(sgpu_blend_test_t blend);

/// base draw command with no indices
void sgpu_draw(uint32_t base_elem, uint32_t count, uint32_t instances);

#ifdef __cplusplus
} // extern "C"
#endif
