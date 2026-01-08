//! Desktop OpenGL 4.5 implemenation for starry.gpu aka Emerson Victor Kyler Gandalf Joel Pablo
//! Daquavious II Sr. Jr. OBE aka Émerez Víctor Quejador Gandalf Joel Pablo Decavio II Sr. Jr.
//! OBE aka Joel Pablo aka QuejaPalronicador aka Qurjs fhycmjjjjjjjjjjjjjjjjjç aka
//! QuejaGontificador

const std = @import("std");
const builtin = @import("builtin");
const glfw = @import("zglfw");
const c = @cImport({
    @cInclude("glad.h");
});
const gpu = @import("gpu.zig");
const gpubk = @import("gpu_backend.zig");

const log = std.log.scoped(.starrygpu);

var global: struct {
    // validation layer stuff
    backend_initialized: bool = false,
    in_render_pass: bool = false,
    in_compute_pass: bool = false,

    device: ?gpu.Device = null,
} = .{};

pub fn init() gpu.Error!void {
    const version = c.gladLoadGL(@ptrCast(&glfw.getProcAddress));
    if (version == 0) {
        return gpu.Error.DeviceUnsupported;
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
            log.err("from OpenGL id({d}): {s}", .{ id, msg });
            @trap();
        },
        c.GL_DEBUG_SEVERITY_MEDIUM, c.GL_DEBUG_SEVERITY_LOW => {
            log.warn("from OpenGL id({d}): {s}", .{ id, msg });
        },
        else => {
            log.info("from OpenGL id({d}): {s}", .{ id, msg });
        },
    }
}

fn assertBackendInitialized() void {
    if (gpu.validationEnabled() and !global.backend_initialized) {
        log.err("gpu backend hasn't initialized yet", .{});
        @trap();
    }
}

pub fn deinit() void {
    assertBackendInitialized();
    global.backend_initialized = false;
}

pub fn queryDevice() gpu.Device {
    assertBackendInitialized();
    if (global.device) |device| {
        return device;
    }

    global.device = .{};

    const vendor_cstr = c.glGetString(c.GL_VENDOR);
    const vendor_len = std.mem.indexOfSentinel(u8, 0, vendor_cstr);
    global.device.?.vendor_name = vendor_cstr[0..vendor_len];

    // it's not really that but close enough
    const device_name_cstr = c.glGetString(c.GL_RENDERER);
    const device_name_len = std.mem.indexOfSentinel(u8, 0, device_name_cstr);
    global.device.?.device_name = device_name_cstr[0..device_name_len];

    var texture_size: c.GLint = undefined;
    c.glGetIntegerv(c.GL_MAX_RECTANGLE_TEXTURE_SIZE, &texture_size);
    global.device.?.max_image_2d_size = @splat(@as(i32, @intCast(texture_size)));

    var workgroup_size: @Vector(3, c.GLint) = undefined;
    c.glGetIntegeri_v(c.GL_MAX_COMPUTE_WORK_GROUP_COUNT, 0, &workgroup_size[0]);
    c.glGetIntegeri_v(c.GL_MAX_COMPUTE_WORK_GROUP_COUNT, 1, &workgroup_size[1]);
    c.glGetIntegeri_v(c.GL_MAX_COMPUTE_WORK_GROUP_COUNT, 2, &workgroup_size[2]);
    global.device.?.max_compute_workgroup_dispatch = @intCast(workgroup_size);

    // conveniently you can't use more than 2 gb because they decided to use an int for this
    var storage_buffer_size: c.GLint = undefined;
    c.glGetIntegerv(c.GL_MAX_SHADER_STORAGE_BLOCK_SIZE, &storage_buffer_size);
    global.device.?.max_storage_buffer_size = @intCast(storage_buffer_size);

    var storage_buffer_bindings: c.GLint = undefined;
    c.glGetIntegerv(c.GL_MAX_SHADER_STORAGE_BUFFER_BINDINGS, &storage_buffer_bindings);
    global.device.?.max_storage_buffer_bindings = @intCast(storage_buffer_bindings);

    return global.device orelse unreachable;
}

pub fn submit(cmds: []const ?gpubk.Command) void {
    for (cmds, 0..) |cmd, i| {
        // hopefully the compiler cares :)
        if (cmd == null) {
            unreachable;
        }

        switch (cmd.?) {
            .compile_shader => |args| {
                gpubk.returnFromCmd(i, .{ .compile_shader = cmdCompileShader(args.settings) });
            },
            .deinit_shader => |args| cmdDeinitShader(args.shader),
            .compile_pipeline => |args| {
                gpubk.returnFromCmd(i, .{ .compile_pipeline = cmdCompilePipeline(args.settings) });
            },
            .deinit_pipeline => |args| cmdDeinitPipeline(args.pipeline),
            .apply_pipeline => |args| cmdApplyPipeline(args.pipeline),
            .set_viewport => |args| cmdSetViewport(args.viewport),
            .set_scissor => |args| cmdSetScissor(args.scissor),
            .start_render_pass => |args| cmdStartRenderPass(args.pass),
            .end_render_pass => cmdEndRenderPass(),
            .start_compute_pass => cmdStartComputePass(),
            .end_compute_pass => cmdEndComputePass(),
        }
    }
}

fn cmdCompileShader(settings: gpu.ShaderSettings) gpu.Error!gpu.Shader {
    assertBackendInitialized();

    const h = try gpubk.resources.shaders.findFree();

    const stage: c.GLenum = switch (settings.stage) {
        .vertex => c.GL_VERTEX_SHADER,
        .fragment => c.GL_FRAGMENT_SHADER,
        .compute => c.GL_COMPUTE_SHADER,
    };
    const id = c.glCreateShader(stage);
    c.glShaderSource(id, 1, &settings.src_glsl.ptr, null);
    c.glCompileShader(id);

    var success: c.GLint = undefined;
    c.glGetShaderiv(id, c.GL_COMPILE_STATUS, &success);

    if (success == 0) {
        var info_log: [1024:0]c.GLchar = undefined;
        c.glGetShaderInfoLog(id, info_log.len, null, &info_log);
        const len = std.mem.indexOfSentinel(u8, 0, &info_log);

        log.err("compiling shader '{s}' failed: {s}", .{
            settings.label,
            info_log[0..len],
        });
        return gpu.Error.ShaderCompilationFailed;
    }

    gpubk.resources.shaders.setSlot(h, .{
        .settings = settings,
        .gl = .{
            .id = id,
        },
    });
    return .{ .id = h };
}

fn cmdDeinitShader(shader: gpu.Shader) void {
    assertBackendInitialized();

    const glshader = gpubk.resources.shaders.getSlot(shader.id) catch |err| {
        if (gpu.validationEnabled()) {
            log.err("{s}", .{@errorName(err)});
            @trap();
        } else {
            log.warn("{s}", .{@errorName(err)});
            return;
        }
    };
    c.glDeleteShader(glshader.gl.id);

    // every possible error has just been handled
    gpubk.resources.shaders.freeSlot(shader.id) catch unreachable;
}

pub fn cmdCompilePipeline(settings: gpu.PipelineSettings) gpu.Error!gpu.Pipeline {
    assertBackendInitialized();
    if (gpu.validationEnabled()) {
        if (settings.raster == null and settings.compute == null) {
            log.err("pipeline must be raster or compute", .{});
            @trap();
        }

        if (settings.raster != null and settings.compute != null) {
            log.err("pipeline must be raster or compute", .{});
            @trap();
        }
    }

    const h = try gpubk.resources.shaders.findFree();

    if (settings.raster) |raster_pip| {
        // shader linking crap
        const vert_shader = gpubk.resources.shaders.getSlot(raster_pip.vertex_shader.id) catch
            return gpu.Error.InvalidHandle;
        const frag_shader = gpubk.resources.shaders.getSlot(raster_pip.fragment_shader.id) catch
            return gpu.Error.InvalidHandle;

        const program = c.glCreateProgram();
        c.glAttachShader(program, vert_shader.gl.id);
        c.glAttachShader(program, frag_shader.gl.id);
        c.glLinkProgram(program);

        var success: c.GLint = undefined;
        c.glGetProgramiv(program, c.GL_LINK_STATUS, &success);

        if (success == 0) {
            var info_log: [1024:0]c.GLchar = undefined;
            c.glGetProgramInfoLog(program, info_log.len, null, &info_log);
            const len = std.mem.indexOfSentinel(u8, 0, &info_log);

            log.err("creating pipeline '{s}' failed: {s}", .{ settings.label, info_log[0..len] });
            return gpu.Error.PipelineCompilationFailed;
        }

        _ = gpubk.resources.pipelines.setSlot(h, .{
            .settings = settings,
            .gl = .{
                .program = program,
            },
        });
        return .{ .id = h };
    }

    if (settings.compute) |compute_pip| {
        // shader linking crap
        const shader = gpubk.resources.shaders.getSlot(compute_pip.shader.id) catch
            return gpu.Error.InvalidHandle;

        const program = c.glCreateProgram();
        c.glAttachShader(program, shader.gl.id);
        c.glLinkProgram(program);

        var success: c.GLint = undefined;
        c.glGetProgramiv(program, c.GL_LINK_STATUS, &success);

        if (success == 0) {
            var info_log: [1024:0]c.GLchar = undefined;
            c.glGetProgramInfoLog(program, info_log.len, null, &info_log);
            const len = std.mem.indexOfSentinel(u8, 0, &info_log);

            log.err("creating pipeline '{s}' failed: {s}", .{ settings.label, info_log[0..len] });
            return gpu.Error.PipelineCompilationFailed;
        }

        _ = gpubk.resources.pipelines.setSlot(h, .{
            .settings = settings,
            .gl = .{
                .program = program,
            },
        });
        return .{ .id = h };
    }

    unreachable;
}

pub fn cmdDeinitPipeline(pipeline: gpu.Pipeline) void {
    assertBackendInitialized();

    const glpipeline = gpubk.resources.pipelines.getSlot(pipeline.id) catch |err| {
        if (gpu.validationEnabled()) {
            log.err("{s}", .{@errorName(err)});
            @trap();
        } else {
            log.warn("{s}", .{@errorName(err)});
            return;
        }
    };
    c.glDeleteProgram(glpipeline.gl.program);

    // every possible error has just been handled
    gpubk.resources.pipelines.freeSlot(pipeline.id) catch unreachable;
}

pub fn cmdApplyPipeline(pipeline: gpu.Pipeline) void {
    // TODO get the current opengl state so that it has to do less api calls
    assertBackendInitialized();

    const pip = gpubk.resources.pipelines.getSlot(pipeline.id) catch |err| {
        if (gpu.validationEnabled()) {
            std.log.err("{s}", .{@errorName(err)});
            @trap();
        } else {
            return;
        }
    };
    c.glUseProgram(pip.gl.program);

    if (pip.settings.raster) |raster_pip| {
        c.glFrontFace(switch (raster_pip.front_face) {
            .clockwise => c.GL_CW,
            .counter_clockwise => c.GL_CCW,
        });

        if (raster_pip.cull == .none) {
            c.glDisable(c.GL_CULL_FACE);
        } else {
            c.glEnable(c.GL_CULL_FACE);
            c.glCullFace(switch (raster_pip.cull) {
                .front_face => c.GL_FRONT,
                .back_face => c.GL_BACK,
                .front_and_back_faces => c.GL_FRONT_AND_BACK,
                .none => unreachable,
            });
        }
    }
}

pub fn cmdSetViewport(v: gpu.Viewport) void {
    c.glViewport(@intCast(v.pos[0]), @intCast(v.pos[1]), @intCast(v.size[0]), @intCast(v.size[1]));
}

pub fn cmdSetScissor(v: gpu.Scissor) void {
    c.glViewport(@intCast(v.pos[0]), @intCast(v.pos[1]), @intCast(v.size[0]), @intCast(v.size[1]));
}

pub fn cmdStartRenderPass(pass: gpu.RenderPass) void {
    assertBackendInitialized();
    global.in_render_pass = true;

    if (pass.frame.load_action == .clear) {
        const clear_color = pass.frame.clear_color orelse .{ 0, 0, 0, 1 };
        c.glClearColor(clear_color[0], clear_color[1], clear_color[2], clear_color[3]);
        c.glClear(c.GL_COLOR_BUFFER_BIT);
    }
}

pub fn cmdEndRenderPass() void {
    assertBackendInitialized();

    // TODO i don't think you can emulate the store op in opengl
    // so this is a noop here
    global.in_render_pass = true;
}

pub fn cmdStartComputePass() void {
    assertBackendInitialized();
    // noop in opengl
    global.in_compute_pass = true;
}

pub fn cmdEndComputePass() void {
    assertBackendInitialized();
    // noop in opengl
    global.in_compute_pass = false;
}
