const std = @import("std");
const sokol = @import("sokol");

// TODO this sucks

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const starry_mod = b.addModule("starry3d", .{
        .root_source_file = b.path("starry/root.zig"),
        .target = target,
    });
    const deps = installStarryDeps(b, starry_mod, target, optimize);

    const test_step = b.step("test", "Run Starry tests");
    const tests = b.addTest(.{
        .name = "starry3d-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("starry/root.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    b.installArtifact(tests);
    test_step.dependOn(&b.addRunArtifact(tests).step);

    sandbox(b, target, optimize, starry_mod, deps.zglm.module("zglm"), deps.zgpu.module("root"));
}

/// hsit
const StarryDependencies = struct {
    glfw: *std.Build.Dependency,
    zgpu: *std.Build.Dependency,
    zglm: *std.Build.Dependency,
};

fn installStarryDeps(
    b: *std.Build,
    mod: *std.Build.Module,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) StarryDependencies {
    const glfw_dep = b.dependency("zglfw", .{ .target = target, .optimize = optimize });
    mod.addImport("zglfw", glfw_dep.module("root"));
    mod.linkLibrary(glfw_dep.artifact("glfw"));

    const zglm_dep = b.dependency("zglm", .{});
    mod.addImport("zglm", zglm_dep.module("zglm"));

    const zgpu_dep = b.dependency("zgpu", .{});
    mod.addImport("zgpu", zgpu_dep.module("root"));

    return .{
        .glfw = glfw_dep,
        .zgpu = zgpu_dep,
        .zglm = zglm_dep,
    };
}

fn sandbox(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    starry_mod: *std.Build.Module,
    zglm_mod: *std.Build.Module,
    zgpu_mod: *std.Build.Module,
) void {
    const exe = b.addExecutable(.{
        .name = "sandbox",
        .root_module = b.createModule(.{
            .root_source_file = b.path("sandbox/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "starry3d", .module = starry_mod },
                .{ .name = "zglm", .module = zglm_mod },
                .{ .name = "zgpu", .module = zgpu_mod },
            },
        }),
    });
    b.installArtifact(exe);

    const run_step = b.step("run-sandbox", "Run sandbox");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    @import("zgpu").addLibraryPathsTo(exe);
}
