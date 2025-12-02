pub const app = @import("app.zig");
pub const window = @import("window.zig");
pub const ScratchAllocator = @import("scratch.zig").ScratchAllocator;

const std = @import("std");
pub const version = std.SemanticVersion{
    .major = 0,
    .minor = 7,
    .patch = 0,
    .pre = "dev",
};
