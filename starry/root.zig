const std = @import("std");
pub const app = @import("app.zig");
pub const world = @import("world.zig");
pub const gpu = @import("gpu.zig");

pub const version = std.SemanticVersion{
    .major = 0,
    .minor = 7,
    .patch = 0,
    .pre = "dev",
};

// otherwise tests don't work
test {
    std.testing.refAllDecls(@This());
}
