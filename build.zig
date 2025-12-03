const std = @import("std");

const Example = struct {
    name: []const u8,
    root_src: []const u8,
};

const examples: []Example = .{
    Example{
        .name = "setup",
        .root_src = "examples/setup/main.zig",
    },
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // TODO i don't think it does anything when you disable this
    // idk how you're supposed to build a zig library
    const build_examples = b.option(bool, "build_sandbox", "Also build sandbox (the test project for Starry)") orelse true;

    const mod = b.addModule("starry3d", .{
        .root_source_file = b.path("starry/root.zig"),
        .target = target,
    });

    // starry dependencies
    const zglfw = b.dependency("zglfw", .{});
    mod.addImport("zglfw", zglfw.module("root"));
    if (target.result.os.tag != .emscripten) {
        mod.linkLibrary(zglfw.artifact("glfw"));
    }

    if (build_examples) {
        const exe = b.addExecutable(.{
            .name = "sandbox",
            .root_module = b.createModule(.{
                .root_source_file = b.path("sandbox/main.zig"),
                .target = target,
                .optimize = optimize,
                .imports = &.{
                    .{ .name = "starry3d", .module = mod },
                },
            }),
        });
        b.installArtifact(exe);

        const run_step = b.step("run", "Run sandbox");
        const run_cmd = b.addRunArtifact(exe);
        run_step.dependOn(&run_cmd.step);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
    }

    // there's real tests too
    const test_step = b.step("test", "Run zmath tests");

    const tests = b.addTest(.{
        .name = "starry3d-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("starry/root.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    b.installArtifact(tests);
    //tests.root_module.addImport("zmath_options", options_module);
    test_step.dependOn(&b.addRunArtifact(tests).step);
}
