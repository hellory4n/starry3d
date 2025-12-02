const std = @import("std");
const window = @import("window.zig");

const Engine = struct {
    window: window.Window = undefined,
};
pub var engine: Engine = .{};
