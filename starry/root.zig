const std = @import("std");
pub const app = @import("app.zig");
pub const log = @import("log.zig");
pub const world = @import("world.zig");
pub const ScratchAllocator = @import("ScratchAllocator.zig");

pub const version = std.SemanticVersion{
    .major = 0,
    .minor = 7,
    .patch = 0,
    .pre = "dev",
};

/// Recommended std options, or something. You have to set it yourself in your own program. (e.g.
/// `pub const std_options = starry.std_options;`). This is required for `starry.log` to work,
/// otherwise it'll just use the default implementation.
pub const std_options = std.Options{
    .log_level = .debug,
    .logFn = log.logfn,
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

// otherwise tests don't work
test {
    std.testing.refAllDecls(@This());
}
