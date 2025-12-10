const std = @import("std");
pub const app = @import("app.zig");
pub const util = @import("util.zig");
pub const log = @import("log.zig");
pub const math = @import("math.zig");
pub const render = @import("render.zig");
pub const ScratchAllocator = @import("scratch.zig").ScratchAllocator;

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
