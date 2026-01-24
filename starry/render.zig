//! This renderer is called Emerson Victor. Be nice to Emerson Victor.
//!
//! burger
//! 🟧🟩🟥🟫🟧
//! fries
//! 🟨🟨🟨🟨🟥

const std = @import("std");
const log = std.log.scoped(.starry);
const glfw = @import("zglfw");
const zglm = @import("zglm");
const sgpu = @import("starrygpu");
const app = @import("app.zig");
const world = @import("world.zig");
const rtshader = @import("shader/rt.zig");

var ctx: struct {
    pipeline: sgpu.Pipeline = undefined,
} = .{};

const Uniforms = extern struct {
    u_model: [16]f32 = zglm.Mat4x4f.identity().toArray1D(),
    u_view: [16]f32 = zglm.Mat4x4f.identity().toArray1D(),
    u_proj: [16]f32 = zglm.Mat4x4f.identity().toArray1D(),
};

pub fn init() !void {
    const vert_shader = try sgpu.compileShader(.{
        .src = @embedFile("shader/tri.vert"),
        .src_len = @embedFile("shader/tri.vert").len,
        .stage = .vertex,
        .entry_point = "main",
        .label = "triangle.vert",
    });
    defer sgpu.deinitShader(vert_shader);

    const frag_shader = try sgpu.compileShader(.{
        .src = @embedFile("shader/tri.frag"),
        .src_len = @embedFile("shader/tri.frag").len,
        .stage = .fragment,
        .entry_point = "main",
        .label = "triangle.frag",
    });
    defer sgpu.deinitShader(frag_shader);

    ctx.pipeline = try sgpu.compilePipeline(.{
        .type = .raster,
        .raster = .{
            .vertex_shader = vert_shader,
            .fragment_shader = frag_shader,
        },
        .label = "triangle pipeline",
    });

    log.info("initialized renderer", .{});
}

pub fn deinit() void {
    sgpu.deinitPipeline(ctx.pipeline);

    log.info("deinitialized renderer", .{});
}

pub fn draw() void {
    sgpu.startRenderPass(.{
        .frame = .{
            .load_action = .clear,
            .store_action = .ignore,
            .clear_color = .{ .r = 0, .g = 0, .b = 0, .a = 1 },
        },
        .swapchain = .{
            .width = @intCast(app.framebufferSize()[0]),
            .height = @intCast(app.framebufferSize()[1]),
        },
    });

    sgpu.applyPipeline(ctx.pipeline);

    sgpu.draw(0, 3, 1);

    sgpu.endRenderPass();
    sgpu.submit();
}
