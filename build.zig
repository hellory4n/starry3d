const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const starry_mod = b.addModule("starry3d", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("starry/root.zig"),
    });

    // dependencies
    const zglfw_dep = b.dependency("zglfw", .{
        .target = target,
        .optimize = optimize,
    });
    const zglfw_mod = zglfw_dep.module("root");
    starry_mod.addImport("zglfw", zglfw_mod);
    starry_mod.linkLibrary(zglfw_dep.artifact("glfw"));

    const zglm_dep = b.dependency("zglm", .{
        .target = target,
        .optimize = optimize,
    });
    const zglm_mod = zglm_dep.module("zglm");
    starry_mod.addImport("zglm", zglm_mod);

    // testing it<3
    const test_step = b.step("test", "Run starry tests");
    const tests = b.addTest(.{
        .name = "starry3d-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("starry/root.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    test_step.dependOn(&b.addRunArtifact(tests).step);

    // glad fuckery
    starry_mod.addIncludePath(b.path("starry/c"));
    starry_mod.addCSourceFile(.{ .file = b.path("starry/c/glad.c") });

    try sandbox(b, .{
        .target = target,
        .optimize = optimize,
        .starry = starry_mod,
        .zglm = zglm_mod,
    });
}

pub fn sandbox(b: *Build, options: struct {
    target: Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    starry: *Build.Module,
    zglm: *Build.Module,
}) !void {
    const sandbox_exe = b.addExecutable(.{
        .name = "sandbox",
        .root_module = b.createModule(.{
            .target = options.target,
            .optimize = options.optimize,
            .root_source_file = b.path("sandbox/main.zig"),
            .imports = &.{
                .{ .name = "starry3d", .module = options.starry },
                .{ .name = "zglm", .module = options.zglm },
            },
        }),
    });

    const run_step = b.step("run-sandbox", "Run sandbox");
    const run_cmd = b.addRunArtifact(sandbox_exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
}
