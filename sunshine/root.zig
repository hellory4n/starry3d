const std = @import("std");

pub const logfn = @import("log.zig").logfn;
pub const addLogPath = @import("log.zig").addLogPath;
pub const initLog = @import("log.zig").init;
pub const deinitLog = @import("log.zig").deinit;
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
