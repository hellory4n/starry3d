const std = @import("std");
const defs = @import("defs.zig");

pub const Error = error{
    /// fuck you
    CompilationFailed,
};

pub fn compile(alloc: std.mem.Allocator, src: defs.SourceFile) !defs.Output {
    const glsl = try std.fs.cwd().readFileAlloc(alloc, src.path, std.math.maxInt(usize));
    defer alloc.free(glsl);

    const argv = std.ArrayList([]const u8).empty;
    defer argv.deinit(alloc);
    try argv.append(alloc, "glslc");

    try argv.append(alloc, switch (src.stage) {
        .vertex => "-fshader-stage=vertex",
        .fragment => "-fshader-stage=fragment",
        .compute => "-fshader-stage=compute",
    });

    try argv.append(alloc, switch (src.mode) {
        .Debug => "-O0",
        // i don't think safe shaders are a thing
        .ReleaseFast, .ReleaseSafe => "-O",
        .ReleaseSmall => "-Os",
    });

    // TODO finish this lmao

    // const glslc_cmd = try std.process.Child.run(.{
    //     .argv = &[_][]const u8{
    //         "glslc",
    //         "--target-env=vulkan1.2",
    //         shader_stage,
    //         "-o",
    //         output_spirv,
    //         src,
    //     },
    //     .allocator = alloc,
    // });
    // _ = try std.fs.File.stdout().write(glslc_cmd.stdout);
    // _ = try std.fs.File.stderr().write(glslc_cmd.stderr);
    // defer alloc.free(glslc_cmd.stdout);
    // defer alloc.free(glslc_cmd.stderr);
}
