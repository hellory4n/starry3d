pub const app = @import("app.zig");
pub const window = @import("window.zig");
pub const util = @import("util.zig");
pub const log = @import("log.zig");
pub const gpu = @import("gpu/main.zig");
pub const math = @import("math.zig");
pub const ScratchAllocator = @import("scratch.zig").ScratchAllocator;

const std = @import("std");
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
