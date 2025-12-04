//! Small functions and stuff that I couldn't find another place for
const std = @import("std");
const log = @import("log.zig");

/// Recommended std options, or something. You have to set it yourself in your own program. (e.g.
/// `pub const std_options = starry.util.std_options;`). This is required for `starry.log` to work,
/// otherwise it'll just use the default implementation.
pub const std_options = std.Options{
    .log_level = .debug,
    .logFn = log.logfn,
};

/// As the name implies, it converts a Zig string (ptr + len) to a C string (ptr with a null terminator)
pub fn zigstrToCstr(alloc: std.mem.Allocator, s: []const u8) ![*:0]const u8 {
    var newstr = try alloc.alloc(u8, s.len + 1);
    @memcpy(newstr, s);
    newstr[s.len] = 0;
    return newstr;
}

/// For use with C libraries, using a max of 0 makes it go forever (how safe!)
pub fn strnlen(s: [*]const u8, max: usize) usize {
    var max_real = max;
    if (max == 0) max_real = std.math.maxInt(usize);

    var len: usize = 0;
    while (len < max_real) : (len += 1) {
        if (s[len] == 0) {
            return len;
        }
    }
    return len;
}

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
