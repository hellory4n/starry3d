//! Common crap used by GPU backends that isn't meant to be public
const std = @import("std");
const log = std.log.scoped(.starrygpu);
const handle = @import("sunshine").handle;
const gpu = @import("gpu.zig");
const bke_glcore = @import("gpu_glcore.zig");

// command buffers

pub const Command = union(enum) {
    compile_shader: struct {
        settings: gpu.ShaderSettings,
    },
    deinit_shader: struct {
        shader: gpu.Shader,
    },
    compile_pipeline: struct {
        settings: gpu.PipelineSettings,
    },
    deinit_pipeline: struct {
        pipeline: gpu.Pipeline,
    },
    apply_pipeline: struct {
        pipeline: gpu.Pipeline,
    },
    set_viewport: struct {
        viewport: gpu.Viewport,
    },
    set_scissor: struct {
        scissor: gpu.Scissor,
    },
    set_blend: struct {
        blend: gpu.BlendTest,
    },
    start_render_pass: struct {
        pass: gpu.RenderPass,
    },
    end_render_pass,
    start_compute_pass,
    end_compute_pass,
    draw: struct {
        base_idx: u32,
        len: u32,
        instances: u32,
    },
};

pub const CommandReturn = union(enum) {
    void,
    compile_shader: gpu.Error!gpu.Shader,
    compile_pipeline: gpu.Error!gpu.Pipeline,
};

var command_buffer = [_]?Command{null} ** 256;
var return_buffer = [_]?CommandReturn{null} ** 256;
var command_len: usize = 0;

/// Returns the command index
pub fn cmdQueue(cmd: Command) usize {
    if (gpu.validationEnabled()) {
        if (command_len >= command_buffer.len) {
            log.err("too many commands!", .{});
            @trap();
        }
    }

    command_buffer[command_len] = cmd;
    command_len += 1;
    return command_len - 1;
}

pub fn returnFromCmd(idx: usize, val: CommandReturn) void {
    return_buffer[idx] = val;
}

/// must be called after cmdSubmit
pub fn getCmdReturn(idx: usize) CommandReturn {
    return return_buffer[idx].?;
}

pub fn cmdSubmit() void {
    switch (comptime gpu.getBackend()) {
        .glcore4 => bke_glcore.submit(command_buffer[0..command_len]),
        .invalid => @compileError("unsupported backend"),
    }
    command_len = 0;
}

// resources

pub const BackendShader = struct {
    settings: gpu.ShaderSettings,
    gl: struct {
        id: c_uint,
    },
};

pub const BackendPipeline = struct {
    settings: gpu.PipelineSettings,
    gl: struct {
        program: c_uint,
    },
};

pub var resources: struct {
    shaders: handle.Table(BackendShader, gpu.max_shaders) = .{},
    pipelines: handle.Table(BackendPipeline, gpu.max_pipelines) = .{},
} = .{};
