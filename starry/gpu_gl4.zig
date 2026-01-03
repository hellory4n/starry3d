//! OpenGL 4 implementation for starry.gpu aka Emerson Victor Kyler Gandalf Joel Pablo Daquavious II Sr.
//! Jr. OBE aka Émerez Víctor Quejador Gandalf Joel Pablo Decavio II Sr. Jr. OBE aka QuejaPalronicador
//! aka Qurjs fhycmjjjjjjjjjjjjjjjjjç aka QuejaGontificador
const std = @import("std");
const builtin = @import("builtin");
const glfw = @import("zglfw");
const c = @cImport({
    @cInclude("glad.h");
});
const gpu = @import("gpu.zig");

const valog = std.log.scoped(.gl_debug);

var global: struct {
    // validation layer stuff
    backend_initialized: bool = false,
    in_render_pass: bool = false,

    device: gpu.Device = undefined,
    has_device: bool = false,

    current_pipeline: ?gpu.Pipeline = null,

    // mappings from opaque handles to real resources
    // TODO i think theres a fancy way to handle use after free but i don't care rn
    // TODO resource system can be shared between backends probably
    shaders: [gpu.max_shaders]?GlShader = [_]?GlShader{null} ** gpu.max_shaders,
    pipelines: [gpu.max_pipelines]?GlPipeline = [_]?GlPipeline{null} ** gpu.max_pipelines,
} = .{};

const GlShader = struct {
    id: c.GLuint,
    settings: gpu.ShaderSettings,
};

const GlPipeline = struct {
    shader_program: c.GLuint,
    settings: gpu.PipelineSettings,
};

pub fn init() gpu.BackendError!void {
    const version = c.gladLoadGL(@ptrCast(&glfw.getProcAddress));
    if (version == 0) {
        return gpu.BackendError.DeviceUnsupported;
    }

    // ReleaseSafe relies only on our own custom validation layers
    // Debug can crash and die all it wants
    if (builtin.mode == .Debug) {
        c.glEnable(c.GL_DEBUG_OUTPUT);
        c.glEnable(c.GL_DEBUG_OUTPUT_SYNCHRONOUS);
        c.glDebugMessageCallback(debugCallback, null);
    }

    global.backend_initialized = true;

    // cache the device already so it doesn't have to do more api calls
    _ = queryDevice();
}

fn debugCallback(
    source: c.GLenum,
    @"type": c.GLenum,
    id: c.GLuint,
    severity: c.GLenum,
    length: c.GLsizei,
    msg: [*c]const c.GLchar,
    data: ?*const anyopaque,
) callconv(.c) void {
    _ = data;
    _ = length;
    _ = source;
    _ = @"type";

    switch (severity) {
        c.GL_DEBUG_SEVERITY_HIGH => {
            valog.err("from OpenGL id({d}): {s}", .{ id, msg });
            @trap();
        },
        c.GL_DEBUG_SEVERITY_MEDIUM, c.GL_DEBUG_SEVERITY_LOW => {
            valog.warn("from OpenGL id({d}): {s}", .{ id, msg });
        },
        else => {
            valog.info("from OpenGL id({d}): {s}", .{ id, msg });
        },
    }
}

fn assertBackendInitialized() void {
    if (gpu.validationEnabled() and !global.backend_initialized) {
        valog.err("gpu backend hasn't initialized yet", .{});
        @trap();
    }
}

pub fn deinit() void {
    assertBackendInitialized();

    // we have garbage collection at home
    for (global.shaders, 0..) |shader, i| {
        if (shader != null) {
            deinitShader(.{ .id = @intCast(i) });
        }
    }
    for (global.pipelines, 0..) |pipeline, i| {
        if (pipeline != null) {
            deinitPipeline(.{ .id = @intCast(i) });
        }
    }

    global.backend_initialized = false;
}

pub fn queryDevice() gpu.Device {
    assertBackendInitialized();
    if (global.has_device) {
        return global.device;
    }

    var texture_size: c.GLint = undefined;
    c.glGetIntegerv(c.GL_MAX_RECTANGLE_TEXTURE_SIZE, &texture_size);
    global.device.max_image_2d_size = @splat(@as(i32, @intCast(texture_size)));

    var workgroup_size: @Vector(3, c.GLint) = undefined;
    c.glGetIntegeri_v(c.GL_MAX_COMPUTE_WORK_GROUP_COUNT, 0, &workgroup_size[0]);
    c.glGetIntegeri_v(c.GL_MAX_COMPUTE_WORK_GROUP_COUNT, 1, &workgroup_size[1]);
    c.glGetIntegeri_v(c.GL_MAX_COMPUTE_WORK_GROUP_COUNT, 2, &workgroup_size[2]);
    global.device.max_compute_workgroup_dispatch = @intCast(workgroup_size);

    // conveniently you can't use more than 2 gb because they decided to use an int for this
    var storage_buffer_size: c.GLint = undefined;
    c.glGetIntegerv(c.GL_MAX_SHADER_STORAGE_BLOCK_SIZE, &storage_buffer_size);
    global.device.max_storage_buffer_size = @intCast(storage_buffer_size);

    var storage_buffer_bindings: c.GLint = undefined;
    c.glGetIntegerv(c.GL_MAX_SHADER_STORAGE_BUFFER_BINDINGS, &storage_buffer_bindings);
    global.device.max_storage_buffer_bindings = @intCast(storage_buffer_bindings);

    global.has_device = true;
    return global.device;
}

pub fn compileShader(settings: gpu.ShaderSettings) gpu.ShaderError!gpu.Shader {
    assertBackendInitialized();

    // find a free slot
    var shader_idx: u32 = undefined;
    for (global.shaders, 0..) |slot, i| {
        if (slot == null) {
            shader_idx = @intCast(i);
            break;
        }
    } else {
        return gpu.BackendError.TooManyHandles;
    }

    const stage: c.GLenum = switch (settings.stage) {
        .vertex => c.GL_VERTEX_SHADER,
        .fragment => c.GL_FRAGMENT_SHADER,
        .compute => c.GL_COMPUTE_SHADER,
    };
    const id = c.glCreateShader(stage);
    c.glShaderSource(id, 1, &settings.glsl_src.ptr, null);
    c.glCompileShader(id);

    var success: c.GLint = undefined;
    c.glGetShaderiv(id, c.GL_COMPILE_STATUS, &success);

    if (success == 0) {
        var info_log: [1024:0]c.GLchar = undefined;
        c.glGetShaderInfoLog(id, info_log.len, null, &info_log);
        const len = std.mem.indexOfSentinel(u8, 0, &info_log);

        valog.err("compiling shader '{s}' failed: {s}", .{
            settings.label,
            info_log[0..len],
        });
        return gpu.ShaderError.CompilationFailed;
    }

    global.shaders[shader_idx] = .{
        .id = id,
        .settings = settings,
    };

    return .{
        .id = shader_idx,
    };
}

pub fn deinitShader(shader: gpu.Shader) void {
    assertBackendInitialized();

    if (gpu.validationEnabled()) {
        if (shader.id >= gpu.max_shaders) {
            valog.err("invalid shader handle {d}", .{shader.id});
            @trap();
        }
        if (global.shaders[shader.id] == null) {
            valog.err("invalid shader handle {d}", .{shader.id});
            @trap();
        }
    }

    c.glDeleteShader(global.shaders[shader.id].?.id);
    global.shaders[shader.id] = null;
}

pub fn startPass(pass: gpu.RenderPass) void {
    assertBackendInitialized();
    global.in_render_pass = true;

    if (pass.action.load_op == .clear) {
        const clear_color = pass.action.clear_color orelse .{ 0, 0, 0, 1 };
        c.glClearColor(clear_color[0], clear_color[1], clear_color[2], clear_color[3]);
        c.glClear(c.GL_COLOR_BUFFER_BIT);
    }
}

pub fn endPass() void {
    assertBackendInitialized();

    // TODO i don't think you can emulate the store op in opengl
    // so this is a noop here
    global.in_render_pass = false;
}

pub fn setViewport(viewport: gpu.Viewport) void {
    assertBackendInitialized();
    c.glViewport(
        @intCast(viewport.viewport_pos[0]),
        @intCast(viewport.viewport_pos[1]),
        @intCast(viewport.viewport_size[0]),
        @intCast(viewport.viewport_size[1]),
    );
}

pub fn setScissor(scissor: gpu.Scissor) void {
    assertBackendInitialized();

    // i hope opengl isn't stupid enough to tell the gpu to enable/disable it every fucking frame
    if (scissor == .window) {
        c.glDisable(c.GL_SCISSOR_TEST);
    } else if (scissor == .portion) {
        c.glEnable(c.GL_SCISSOR_TEST);
        c.glScissor(
            @intCast(scissor.portion.pos[0]),
            @intCast(scissor.portion.pos[1]),
            @intCast(scissor.portion.size[0]),
            @intCast(scissor.portion.size[1]),
        );
    }
}

pub fn initPipeline(settings: gpu.PipelineSettings) gpu.ShaderError!gpu.Pipeline {
    assertBackendInitialized();

    // find a free slot
    var idx: u32 = undefined;
    for (global.pipelines, 0..) |slot, i| {
        if (slot == null) {
            idx = @intCast(i);
            break;
        }
    } else {
        return gpu.BackendError.TooManyHandles;
    }

    if (settings == .raster) {
        return initRasterPipeline(idx, settings);
    }
}

fn initRasterPipeline(idx: u32, settings: gpu.PipelineSettings) gpu.ShaderError!gpu.Pipeline {
    // opengl pipelines only require linking the shader
    const vert_shader = global.shaders[settings.raster.vertex_shader.id] orelse
        return gpu.ShaderError.InvalidHandle;
    const frag_shader = global.shaders[settings.raster.fragment_shader.id] orelse
        return gpu.ShaderError.InvalidHandle;

    if (gpu.validationEnabled()) {
        // this protects against copy paste errors or some shit
        if (vert_shader.settings.stage != .vertex) {
            valog.err("expected vertex shader, got {s} shader", .{
                @tagName(vert_shader.settings.stage),
            });
        }

        if (frag_shader.settings.stage != .fragment) {
            valog.err("expected fragment shader, got {s} shader", .{
                @tagName(vert_shader.settings.stage),
            });
        }
    }

    const program = c.glCreateProgram();
    c.glAttachShader(program, vert_shader.id);
    c.glAttachShader(program, frag_shader.id);
    c.glLinkProgram(program);

    var success: c.GLint = undefined;
    c.glGetProgramiv(program, c.GL_LINK_STATUS, &success);

    if (success == 0) {
        var info_log: [1024:0]c.GLchar = undefined;
        c.glGetProgramInfoLog(program, info_log.len, null, &info_log);
        const len = std.mem.indexOfSentinel(u8, 0, &info_log);

        valog.err("creating pipeline failed: {s}", .{info_log[0..len]});
        return gpu.ShaderError.LinkingFailed;
    }

    global.pipelines[idx] = .{
        .settings = settings,
        .shader_program = program,
    };

    return .{ .id = idx };
}

pub fn deinitPipeline(pipeline: gpu.Pipeline) void {
    assertBackendInitialized();

    if (gpu.validationEnabled()) {
        if (pipeline.id >= gpu.max_pipelines) {
            valog.err("invalid pipeline handle {d}", .{pipeline.id});
            @trap();
        }
        if (global.pipelines[pipeline.id] == null) {
            valog.err("invalid pipeline handle {d}", .{pipeline.id});
            @trap();
        }
    }

    c.glDeleteProgram(global.pipelines[pipeline.id].?.shader_program);
    global.pipelines[pipeline.id] = null;
}

pub fn applyPipeline(pipeline: gpu.Pipeline) void {
    // TODO get the current opengl state so that it has to do less api calls
    assertBackendInitialized();

    if (gpu.validationEnabled()) {
        if (pipeline.id >= gpu.max_pipelines) {
            valog.err("invalid pipeline handle {d}", .{pipeline.id});
            @trap();
        }
        if (global.pipelines[pipeline.id] == null) {
            valog.err("invalid pipeline handle {d}", .{pipeline.id});
            @trap();
        }
    }

    const pip = global.pipelines[pipeline.id].?;
    global.current_pipeline = pipeline;
    c.glUseProgram(pip.shader_program);

    if (pip.settings == .raster) {
        c.glFrontFace(switch (pip.settings.raster.front_face) {
            .clockwise => c.GL_CW,
            .counter_clockwise => c.GL_CCW,
        });

        if (pip.settings.raster.cull == .none) {
            c.glDisable(c.GL_CULL_FACE);
        } else {
            c.glEnable(c.GL_CULL_FACE);
            c.glCullFace(switch (pip.settings.raster.cull) {
                .front_face => c.GL_FRONT,
                .back_face => c.GL_BACK,
                .front_and_back_faces => c.GL_FRONT_AND_BACK,
                .none => unreachable,
            });
        }
    }
}
