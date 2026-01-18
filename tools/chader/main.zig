//! Compiles sHaders
//! Usage:
//!   chader --output=<hlsl5|spirv> --stage=<vertex|fragment|compute> <input glsl file> <output zon file>
//!
//! The tmp file part is just so it works with the build system
//! chader isn't meant to be used directly, so if you try using args other than that,
//! it'll shit itself

const std = @import("std");
const defs = @import("defs.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer _ = gpa.deinit();
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    const alloc = arena.allocator();

    const argv = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, argv);

    // some fucking parsing
    const shader_stage = argv[1]; // conveniently it maps directly to a glslc flag
    const src = argv[2];
    const output_spirv = argv[3];
    const output_zig = argv[4];

    // i am compiling it
    const glslc_cmd = try std.process.Child.run(.{
        .argv = &[_][]const u8{
            "glslc",
            "--target-env=vulkan1.2",
            shader_stage,
            "-o",
            output_spirv,
            src,
        },
        .allocator = alloc,
    });
    _ = try std.fs.File.stdout().write(glslc_cmd.stdout);
    _ = try std.fs.File.stderr().write(glslc_cmd.stderr);
    defer alloc.free(glslc_cmd.stdout);
    defer alloc.free(glslc_cmd.stderr);
}
