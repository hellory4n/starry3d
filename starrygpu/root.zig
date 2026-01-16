//! I love the Graphics Processing Unit
//! This doesn't bother making the Zig API not feel like a C API, it just adds some functions to
//! make things less insalubrious
//! Also all of the tests are here. Fuck you.

const std = @import("std");
const testing = std.testing;
pub const c = @cImport({
    @cInclude("starrygpu.h");
});

pub fn check(err_code: c.sgpu_error_t) !void {
    return switch (err_code) {
        else => {},
    };
}

test "init ctx" {
    var ctx: c.sgpu_ctx_t = undefined;
    try check(c.sgpu_init(.{
        .app_name = "Balls",
        .engine_name = "libballs",
        .app_version = .{ .major = 1, .minor = 0, .patch = 0 },
        .engine_version = .{ .major = 1, .minor = 0, .patch = 0 },
    }, &ctx));
    try testing.expect(ctx.initialized);
}
