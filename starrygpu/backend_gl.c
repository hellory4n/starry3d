#include "backend_gl.h"
#include "sgpu_internal.h"
#include "starrygpu.h"
#include <stdlib.h>
#define GLAD_GL_IMPLEMENTATION
#include "lib/glad.h"

static void _sgpu_gl_debug_callback(GLenum source, GLenum type, GLuint id, GLenum severity,
    GLsizei length, const GLchar* msg, const void* data);

typedef struct sgpu_gl_ctx_t {
    sgpu_device_t device_info;
    bool has_device_info;
} sgpu_gl_ctx_t;

sgpu_error_t sgpu_gl_init(sgpu_settings_t settings, sgpu_ctx_t* ctx) {
    int version = gladLoadGL(settings.gl.load_fn);
    if (!version) {
        sgpu_log_error(ctx, "unsupported OpenGL version!");
        if (glGetString) {
            sgpu_log_error(ctx, "expected v4.5 core, got %s", glGetString(GL_VERSION));
        } else {
            sgpu_log_error(ctx, "expected v4.5 core, got unknown version");
        }
        return SGPU_ERROR_INCOMPATIBLE_GPU;
    }

    ctx->gl = malloc(sizeof(sgpu_gl_ctx_t));

    if (settings.backend_validation_enabled) {
        glEnable(GL_DEBUG_OUTPUT);
        glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS);
        glDebugMessageCallback(_sgpu_gl_debug_callback, ctx);
    }

    // cache the device already so it doesn't have to do more api calls
    sgpu_query_device(ctx);

    // dummy vao so it stops bitching with bufferless rendering
    GLuint vao;
    glGenVertexArrays(1, &vao);
    glBindVertexArray(vao);

    return SGPU_OK;
}

static void _sgpu_gl_debug_callback(GLenum source, GLenum type, GLuint id, GLenum severity,
    GLsizei length, const GLchar* msg, const void* data) {
    (void)source;
    (void)type;
    (void)length;
    const sgpu_ctx_t* ctx = data;

    switch (severity) {
    case GL_DEBUG_SEVERITY_HIGH:
        sgpu_log_error(ctx, "OpenGL %i: %s", id, msg);
        sgpu_trap(ctx);
        break;

    case GL_DEBUG_SEVERITY_MEDIUM:
    case GL_DEBUG_SEVERITY_LOW:
        sgpu_log_warn(ctx, "OpenGL %i: %s", id, msg);
        break;

    default:
        sgpu_log_info(ctx, "OpenGL %i: %s", id, msg);
        break;
    }
}

void sgpu_gl_deinit(sgpu_ctx_t* ctx) { free(ctx->gl); }

sgpu_device_t sgpu_gl_query_device(sgpu_ctx_t* ctx) {
    sgpu_gl_ctx_t* gl = ctx->gl;
    // calling opengl is expensive! or smth
    if (gl->has_device_info) {
        return gl->device_info;
    }

    gl->device_info = (sgpu_device_t) {
        .vendor_name = (const char*)glGetString(GL_VENDOR),
        // it's not really that but close enough
        .device_name = (const char*)glGetString(GL_RENDERER),
    };

    GLint texture2d_size;
    glGetIntegerv(GL_MAX_RECTANGLE_TEXTURE_SIZE, &texture2d_size);
    gl->device_info.max_image_2d_size[0] = texture2d_size;
    gl->device_info.max_image_2d_size[1] = texture2d_size;

    GLint workgroup_size[3];
    glGetIntegeri_v(GL_MAX_COMPUTE_WORK_GROUP_COUNT, 0, &workgroup_size[0]);
    glGetIntegeri_v(GL_MAX_COMPUTE_WORK_GROUP_COUNT, 1, &workgroup_size[1]);
    glGetIntegeri_v(GL_MAX_COMPUTE_WORK_GROUP_COUNT, 2, &workgroup_size[2]);
    gl->device_info.max_compute_workgroup_size[0] = workgroup_size[0];
    gl->device_info.max_compute_workgroup_size[1] = workgroup_size[1];
    gl->device_info.max_compute_workgroup_size[2] = workgroup_size[2];

    GLint max_threads;
    glGetIntegerv(GL_MAX_COMPUTE_WORK_GROUP_INVOCATIONS, &max_threads);
    gl->device_info.max_compute_workgroup_threads = max_threads;

    // conveniently you can't use more than 2 gb because they decided to use an int for this
    GLint storage_buffer_size;
    glGetIntegerv(GL_MAX_SHADER_STORAGE_BLOCK_SIZE, &storage_buffer_size);
    gl->device_info.max_storage_buffer_size = storage_buffer_size;

    GLint storage_buffer_bindings;
    glGetIntegerv(GL_MAX_SHADER_STORAGE_BUFFER_BINDINGS, &storage_buffer_bindings);
    gl->device_info.max_storage_buffer_bindings = storage_buffer_bindings;

    gl->has_device_info = true;
    return gl->device_info;
}

void sgpu_gl_submit(sgpu_ctx_t* ctx) {
    (void)ctx;
    // TODO manage an internal command buffer for multithreading
    // for now this is a noop
}

void sgpu_gl_start_render_pass(sgpu_ctx_t* ctx, sgpu_render_pass_t pass) {
    (void)ctx;

    if (pass.frame.load_action == SGPU_LOAD_ACTION_CLEAR) {
        glClearColor(pass.frame.clear_color.r, pass.frame.clear_color.g, pass.frame.clear_color.b,
            pass.frame.clear_color.a);
        glClear(GL_COLOR_BUFFER_BIT);
    }
}

void sgpu_gl_end_render_pass(sgpu_ctx_t* ctx) {
    (void)ctx;
    // TODO i don't think you can emulate the store op in opengl
    // so this is a noop here
}

void sgpu_gl_set_viewport(sgpu_ctx_t* ctx, sgpu_viewport_t viewport) {
    (void)ctx;
    glViewport(viewport.top_left_x, viewport.top_left_y, viewport.width, viewport.height);
    glDepthRangef(viewport.min_depth, viewport.max_depth);
}
