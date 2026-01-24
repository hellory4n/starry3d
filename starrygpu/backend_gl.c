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

    sgpu_pipeline_t current_pipeline;
} sgpu_gl_ctx_t;

sgpu_error_t sgpu_gl_init(sgpu_settings_t settings) {
    int version = gladLoadGL(settings.gl.load_fn);
    if (!version) {
        sgpu_log_error("unsupported OpenGL version!");
        if (glGetString) {
            sgpu_log_error("expected v4.5 core, got %s", glGetString(GL_VERSION));
        } else {
            sgpu_log_error("expected v4.5 core, got unknown version");
        }
        return SGPU_ERROR_INCOMPATIBLE_GPU;
    }

    sgpu_ctx.gl = calloc(1, sizeof(sgpu_gl_ctx_t));

    if (settings.backend_validation_enabled) {
        glEnable(GL_DEBUG_OUTPUT);
        glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS);
        glDebugMessageCallback(_sgpu_gl_debug_callback, NULL);
    }

    // cache the device already so it doesn't have to do more api calls
    sgpu_device_t dev = sgpu_query_device();
    sgpu_print_dev(dev);

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
    (void)data;

    switch (severity) {
    case GL_DEBUG_SEVERITY_HIGH:
        sgpu_log_error("OpenGL %i: %s", id, msg);
        sgpu_trap();
        break;

    case GL_DEBUG_SEVERITY_MEDIUM:
    case GL_DEBUG_SEVERITY_LOW:
        sgpu_log_warn("OpenGL %i: %s", id, msg);
        break;

    default:
        sgpu_log_info("OpenGL %i: %s", id, msg);
        break;
    }
}

void sgpu_gl_deinit(void) { free(sgpu_ctx.gl); }

sgpu_device_t sgpu_gl_query_device(void) {
    sgpu_gl_ctx_t* gl = sgpu_ctx.gl;
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

void sgpu_gl_submit(void) {
    // TODO manage an internal command buffer for multithreading
    // for now this is a noop
}

void sgpu_gl_start_render_pass(sgpu_render_pass_t pass) {
    if (pass.frame.load_action == SGPU_LOAD_ACTION_CLEAR) {
        glClearColor(pass.frame.clear_color.r, pass.frame.clear_color.g, pass.frame.clear_color.b,
            pass.frame.clear_color.a);
        glClear(GL_COLOR_BUFFER_BIT);
    }
}

void sgpu_gl_end_render_pass(void) {
    // TODO i don't think you can emulate the store op in opengl
    // so this is a noop here
}

void sgpu_gl_set_viewport(sgpu_viewport_t viewport) {
    glViewport(viewport.top_left_x, viewport.top_left_y, viewport.width, viewport.height);
    glDepthRangef(viewport.min_depth, viewport.max_depth);
}

void sgpu_gl_set_scissor(sgpu_scissor_t scissor) {
    if (scissor.enabled) {
        glEnable(GL_SCISSOR_TEST);
        glScissor(scissor.top_left_x, scissor.top_left_y, scissor.width, scissor.height);
    } else {
        glDisable(GL_SCISSOR_TEST);
    }
}

sgpu_error_t sgpu_gl_compile_shader(sgpu_shader_settings_t settings, sgpu_shader_t* out_shader) {
    sgpu_shader_settings_default(&settings);
    sgpu_shader_t handle;
    SGPU_TRY(sgpu_new_shader_slot(&handle));

    GLenum stage = 0;
    switch (settings.stage) {
    case SGPU_SHADER_STAGE_VERTEX:
        stage = GL_VERTEX_SHADER;
        break;
    case SGPU_SHADER_STAGE_FRAGMENT:
        stage = GL_FRAGMENT_SHADER;
        break;
    case SGPU_SHADER_STAGE_COMPUTE:
        stage = GL_COMPUTE_SHADER;
        break;
    }

    GLuint id = glCreateShader(stage);
    glShaderSource(id, 1, &settings.src, NULL);
    glCompileShader(id);

    GLint success;
    glGetShaderiv(id, GL_COMPILE_STATUS, &success);
    if (!success) {
        char info_log[1024] = { 0 };
        glGetShaderInfoLog(id, SGPU_LENGTHOF(info_log), NULL, info_log);
        info_log[SGPU_LENGTHOF(info_log) - 1] = '\0';

        sgpu_log_error("compiling shader '%s' failed: %s", settings.label, info_log);
        return SGPU_ERROR_SHADER_COMPILATION_FAILED;
    }

    sgpu_backend_shader_t* bkshader;
    SGPU_TRY(sgpu_get_shader_slot(handle, &bkshader));
    bkshader->settings = settings;
    bkshader->u.gl.id = id;

    *out_shader = handle;
    return SGPU_OK;
}

void sgpu_gl_deinit_shader(sgpu_shader_t shader) {
    sgpu_backend_shader_t* bkshader;
    if (sgpu_get_shader_slot(shader, &bkshader) != SGPU_OK) {
        return;
    }

    glDeleteShader(bkshader->u.gl.id);
    bkshader->occupied = false;
}

sgpu_error_t sgpu_gl_compile_pipeline(sgpu_pipeline_settings_t settings, sgpu_pipeline_t* out) {
    sgpu_pipeline_t handle;
    SGPU_TRY(sgpu_new_pipeline_slot(&handle));

    if (settings.type == SGPU_PIPELINE_TYPE_RASTER) {
        // shader linking crap
        sgpu_backend_shader_t* vert_shader;
        sgpu_backend_shader_t* frag_shader;
        SGPU_TRY(sgpu_get_shader_slot(settings.raster.vertex_shader, &vert_shader));
        SGPU_TRY(sgpu_get_shader_slot(settings.raster.fragment_shader, &frag_shader));

        GLuint program = glCreateProgram();
        glAttachShader(program, vert_shader->u.gl.id);
        glAttachShader(program, frag_shader->u.gl.id);
        glLinkProgram(program);

        GLint success;
        glGetProgramiv(program, GL_LINK_STATUS, &success);
        if (!success) {
            char info_log[1024] = { 0 };
            glGetProgramInfoLog(program, SGPU_LENGTHOF(info_log), NULL, info_log);

            sgpu_log_error("compiling pipeline '%s' failed: %s", settings.label, info_log);
            return SGPU_ERROR_PIPELINE_COMPILATION_FAILED;
        }

        sgpu_backend_pipeline_t* pip;
        SGPU_TRY(sgpu_get_pipeline_slot(handle, &pip));
        pip->settings = settings;
        pip->u.gl.program = program;
        *out = handle;
        return SGPU_OK;
    } else if (settings.type == SGPU_PIPELINE_TYPE_COMPUTE) {
        // shader linking crap
        sgpu_backend_shader_t* shader;
        SGPU_TRY(sgpu_get_shader_slot(settings.raster.vertex_shader, &shader));

        GLuint program = glCreateProgram();
        glAttachShader(program, shader->u.gl.id);
        glLinkProgram(program);

        GLint success;
        glGetProgramiv(program, GL_LINK_STATUS, &success);
        if (!success) {
            char info_log[1024] = { 0 };
            glGetProgramInfoLog(program, SGPU_LENGTHOF(info_log), NULL, info_log);

            sgpu_log_error("compiling pipeline '%s' failed: %s", settings.label, info_log);
            return SGPU_ERROR_PIPELINE_COMPILATION_FAILED;
        }

        sgpu_backend_pipeline_t* pip;
        SGPU_TRY(sgpu_get_pipeline_slot(handle, &pip));
        pip->settings = settings;
        pip->u.gl.program = program;
        *out = handle;
        return SGPU_OK;
    }

    SGPU_UNREACHABLE();
    return SGPU_OK;
}

void sgpu_gl_deinit_pipeline(sgpu_pipeline_t handle) {
    sgpu_backend_pipeline_t* pip;
    if (sgpu_get_pipeline_slot(handle, &pip) != SGPU_OK) {
        return;
    }

    glDeleteProgram(pip->u.gl.program);
    pip->occupied = false;
}

void sgpu_gl_apply_pipeline(sgpu_pipeline_t handle) {
    sgpu_backend_pipeline_t* pip;
    if (sgpu_get_pipeline_slot(handle, &pip) != SGPU_OK) {
        return;
    }
    sgpu_gl_ctx_t* gl_ctx = sgpu_ctx.gl;
    gl_ctx->current_pipeline = handle;

    glUseProgram(pip->u.gl.program);

    if (pip->settings.type == SGPU_PIPELINE_TYPE_RASTER) {
        GLenum front_face;
        switch (pip->settings.raster.front_face) {
        case SGPU_WINDING_ORDER_CLOCKWISE:
            front_face = GL_CW;
            break;
        case SGPU_WINDING_ORDER_COUNTER_CLOCKWISE:
            front_face = GL_CCW;
            break;
        }
        glFrontFace(front_face);

        if (pip->settings.raster.cull == SGPU_CULL_MODE_NONE) {
            glDisable(GL_CULL_FACE);
        } else {
            glEnable(GL_CULL_FACE);

            GLenum cull_face;
            switch (pip->settings.raster.cull) {
            case SGPU_CULL_MODE_FRONT_FACE:
                cull_face = SGPU_CULL_MODE_FRONT_FACE;
                break;
            case SGPU_CULL_MODE_BACK_FACE:
                cull_face = SGPU_CULL_MODE_BACK_FACE;
                break;
            case SGPU_CULL_MODE_FRONT_AND_BACK_FACES:
                cull_face = SGPU_CULL_MODE_FRONT_AND_BACK_FACES;
                break;
            case SGPU_CULL_MODE_NONE:
                cull_face = SGPU_CULL_MODE_NONE;
                break;
            }
            glCullFace(cull_face);
        }
    }
}

void sgpu_gl_set_blend(sgpu_blend_test_t blend) {
    GLenum src_factor;
    switch (blend.src_factor) {
    case SGPU_BLEND_SCALE_FACTOR_ZERO:
        src_factor = GL_ZERO;
        break;
    case SGPU_BLEND_SCALE_FACTOR_ONE:
        src_factor = GL_ONE;
        break;
    case SGPU_BLEND_SCALE_FACTOR_SRC_COLOR:
        src_factor = GL_SRC_COLOR;
        break;
    case SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_SRC_COLOR:
        src_factor = GL_ONE_MINUS_SRC_COLOR;
        break;
    case SGPU_BLEND_SCALE_FACTOR_DST_COLOR:
        src_factor = GL_DST_COLOR;
        break;
    case SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_DST_COLOR:
        src_factor = GL_ONE_MINUS_DST_COLOR;
        break;
    case SGPU_BLEND_SCALE_FACTOR_SRC_ALPHA:
        src_factor = GL_SRC_ALPHA;
        break;
    case SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_SRC_ALPHA:
        src_factor = GL_ONE_MINUS_SRC_ALPHA;
        break;
    case SGPU_BLEND_SCALE_FACTOR_DST_ALPHA:
        src_factor = GL_DST_ALPHA;
        break;
    case SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_DST_ALPHA:
        src_factor = GL_ONE_MINUS_DST_ALPHA;
        break;
    case SGPU_BLEND_SCALE_FACTOR_CONSTANT_COLOR:
        src_factor = GL_CONSTANT_COLOR;
        break;
    case SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_CONSTANT_COLOR:
        src_factor = GL_ONE_MINUS_CONSTANT_COLOR;
        break;
    case SGPU_BLEND_SCALE_FACTOR_CONSTANT_ALPHA:
        src_factor = GL_CONSTANT_ALPHA;
        break;
    case SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_CONSTANT_ALPHA:
        src_factor = GL_ONE_MINUS_CONSTANT_ALPHA;
        break;
    case SGPU_BLEND_SCALE_FACTOR_SRC_ALPHA_SATURATE:
        src_factor = GL_SRC_ALPHA_SATURATE;
        break;
    case SGPU_BLEND_SCALE_FACTOR_SRC1_COLOR:
        src_factor = GL_SRC1_COLOR;
        break;
    case SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_SRC1_COLOR:
        src_factor = GL_ONE_MINUS_SRC1_COLOR;
        break;
    case SGPU_BLEND_SCALE_FACTOR_SRC1_ALPHA:
        src_factor = GL_SRC1_ALPHA;
        break;
    case SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_SRC1_ALPHA:
        src_factor = GL_ONE_MINUS_SRC1_ALPHA;
        break;
    }

    GLenum dst_factor;
    switch (blend.dst_factor) {
    case SGPU_BLEND_SCALE_FACTOR_ZERO:
        dst_factor = GL_ZERO;
        break;
    case SGPU_BLEND_SCALE_FACTOR_ONE:
        dst_factor = GL_ONE;
        break;
    case SGPU_BLEND_SCALE_FACTOR_SRC_COLOR:
        dst_factor = GL_SRC_COLOR;
        break;
    case SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_SRC_COLOR:
        dst_factor = GL_ONE_MINUS_SRC_COLOR;
        break;
    case SGPU_BLEND_SCALE_FACTOR_DST_COLOR:
        dst_factor = GL_DST_COLOR;
        break;
    case SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_DST_COLOR:
        dst_factor = GL_ONE_MINUS_DST_COLOR;
        break;
    case SGPU_BLEND_SCALE_FACTOR_SRC_ALPHA:
        dst_factor = GL_SRC_ALPHA;
        break;
    case SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_SRC_ALPHA:
        dst_factor = GL_ONE_MINUS_SRC_ALPHA;
        break;
    case SGPU_BLEND_SCALE_FACTOR_DST_ALPHA:
        dst_factor = GL_DST_ALPHA;
        break;
    case SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_DST_ALPHA:
        dst_factor = GL_ONE_MINUS_DST_ALPHA;
        break;
    case SGPU_BLEND_SCALE_FACTOR_CONSTANT_COLOR:
        dst_factor = GL_CONSTANT_COLOR;
        break;
    case SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_CONSTANT_COLOR:
        dst_factor = GL_ONE_MINUS_CONSTANT_COLOR;
        break;
    case SGPU_BLEND_SCALE_FACTOR_CONSTANT_ALPHA:
        dst_factor = GL_CONSTANT_ALPHA;
        break;
    case SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_CONSTANT_ALPHA:
        dst_factor = GL_ONE_MINUS_CONSTANT_ALPHA;
        break;
    case SGPU_BLEND_SCALE_FACTOR_SRC_ALPHA_SATURATE:
        dst_factor = GL_SRC_ALPHA_SATURATE;
        break;
    case SGPU_BLEND_SCALE_FACTOR_SRC1_COLOR:
        dst_factor = GL_SRC1_COLOR;
        break;
    case SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_SRC1_COLOR:
        dst_factor = GL_ONE_MINUS_SRC1_COLOR;
        break;
    case SGPU_BLEND_SCALE_FACTOR_SRC1_ALPHA:
        dst_factor = GL_SRC1_ALPHA;
        break;
    case SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_SRC1_ALPHA:
        dst_factor = GL_ONE_MINUS_SRC1_ALPHA;
        break;
    }

    glEnable(GL_BLEND);
    glBlendFunc(src_factor, dst_factor);
    glBlendColor(blend.constant_color.r, blend.constant_color.g, blend.constant_color.b,
        blend.constant_color.a);
}

void sgpu_gl_draw(uint32_t base_elem, uint32_t count, uint32_t instances) {
    sgpu_gl_ctx_t* gl_ctx = sgpu_ctx.gl;
    sgpu_backend_pipeline_t* pip;
    if (sgpu_get_pipeline_slot(gl_ctx->current_pipeline, &pip) != SGPU_OK) {
        return;
    }

    GLenum topology;
    switch (pip->settings.raster.topology) {
    case SGPU_TOPOLOGY_TRIANGLE_LIST:
        topology = GL_TRIANGLES;
        break;
    case SGPU_TOPOLOGY_TRIANGLE_STRIP:
        topology = GL_TRIANGLE_STRIP;
        break;
    case SGPU_TOPOLOGY_TRIANGLE_FAN:
        topology = GL_TRIANGLE_FAN;
        break;
    }

    glDrawArraysInstanced(topology, base_elem, count, instances);
}
