//! I love the Graphics Processing Unit

const std = @import("std");
const testing = std.testing;
pub const c = @cImport({
    @cInclude("starrygpu.h");
});

pub const Error = error{
    Unknown,
    OutOfCpuMemory,
    OutOfGpuMemory,
    IncompatibleGpu,
};

pub fn check(err_code: c.sgpu_error_t) Error!void {
    return switch (err_code) {
        c.SGPU_ERROR_UNKNOWN => Error.Unknown,
        c.SGPU_ERROR_OUT_OF_CPU_MEMORY => Error.OutOfCpuMemory,
        c.SGPU_ERROR_OUT_OF_GPU_MEMORY => Error.OutOfGpuMemory,
        c.SGPU_ERROR_INCOMPATIBLE_GPU => Error.IncompatibleGpu,
        else => {},
    };
}

test "tringl" {
    var ctx: c.sgpu_ctx_t = undefined;
    try check(c.sgpu_init(.{
        .app_name = "Balls",
        .engine_name = "libballs",
        .app_version = .{ .major = 1, .minor = 0, .patch = 0 },
        .engine_version = .{ .major = 1, .minor = 0, .patch = 0 },
    }, &ctx));
    try testing.expect(ctx.initialized);
}
