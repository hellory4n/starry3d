const std = @import("std");
const builtin = @import("builtin");
const build_options = @import("starry3d_options");

pub const logfn = @import("log.zig").logfn;
pub const addLogPath = @import("log.zig").addLogPath;
pub const initLog = @import("log.zig").init;
pub const deinitLog = @import("log.zig").deinit;
pub const handle = @import("handle.zig");
pub const world = @import("world.zig");
pub const ScratchAllocator = @import("ScratchAllocator.zig");

/// Recommended std options, or something. You have to set it yourself in your own program. (e.g.
/// `pub const std_options = sunshine.std_options`). This is required for the custom logging to
/// work, otherwise it'll just use the default implementation.
pub const std_options = std.Options{
    .log_level = .debug,
    .logFn = logfn,
};

/// If true, the file at that path does in fact exist and is alive and well and stuff.
pub fn fileExists(path: []const u8) !bool {
    _ = std.fs.cwd().statFile(path) catch |err| {
        if (err == error.FileNotFound) {
            return false;
        } else {
            return err;
        }
    };
    return true;
}

test {
    std.testing.refAllDecls(@This());

    if (build_options.benchmark) {
        if (builtin.mode != .ReleaseFast) {
            std.testing.log_level = .debug;
            std.log.warn("running {s} benchmarks", .{@tagName(builtin.mode)});
        }
        std.testing.refAllDecls(@import("benchmark.zig"));
    }
}
