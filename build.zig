const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // sunshine
    const sunshine_mod = b.addModule("sunshine", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("sunshine/root.zig"),
    });

    // starrygpu
    const starrygpu_mod = b.addModule("starrygpu", .{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .root_source_file = b.path("starrygpu/root.zig"),
    });
    starrygpu_mod.addIncludePath(b.path("starrygpu"));
    starrygpu_mod.addCSourceFile(.{ .file = b.path("starrygpu/starrygpu.c") });

    // starry
    const starry_mod = b.addModule("starry3d", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("starry/root.zig"),
    });
    starry_mod.addImport("sunshine", sunshine_mod);
    starry_mod.addImport("starrygpu", starrygpu_mod);

    const zglfw_dep = b.dependency("zglfw", .{
        .target = target,
        .optimize = optimize,
    });
    const zglfw_mod = zglfw_dep.module("root");
    starry_mod.addImport("zglfw", zglfw_mod);
    starry_mod.linkLibrary(zglfw_dep.artifact("glfw"));

    const vk_registry = b.dependency("vulkan_headers", .{}).path("registry/vk.xml");
    const vulkan_mod = b.dependency("vulkan", .{
        .registry = vk_registry,
    }).module("vulkan-zig");
    starry_mod.addImport("vulkan", vulkan_mod);

    const vk_kickstart_mod = b.dependency("vk_kickstart", .{
        .target = target,
        .optimize = optimize,
        .registry = vk_registry,
        .verbose = true,
    }).module("vk-kickstart");
    starry_mod.addImport("vk-kickstart", vk_kickstart_mod);

    const vma_dep = b.dependency("VulkanMemoryAllocator", .{
        .target = target,
        .optimize = optimize,
    });
    starry_mod.linkLibrary(vma_dep.artifact("VulkanMemoryAllocator"));

    const zglm_dep = b.dependency("zglm", .{
        .target = target,
        .optimize = optimize,
    });
    const zglm_mod = zglm_dep.module("zglm");
    starry_mod.addImport("zglm", zglm_mod);

    // testing it<3
    const test_step = b.step("test", "Run starry tests");
    const sunshine_tests = b.addTest(.{
        .name = "sunshine-tests",
        .root_module = sunshine_mod,
    });
    const starrygpu_tests = b.addTest(.{
        .name = "starrygpu-tests",
        .root_module = starrygpu_mod,
    });
    const starry_tests = b.addTest(.{
        .name = "starry3d-tests",
        .root_module = starry_mod,
    });
    test_step.dependOn(&b.addRunArtifact(sunshine_tests).step);
    test_step.dependOn(&b.addRunArtifact(starrygpu_tests).step);
    test_step.dependOn(&b.addRunArtifact(starry_tests).step);

    try sandbox(b, .{
        .target = target,
        .optimize = optimize,
        .starry = starry_mod,
        .sunshine = sunshine_mod,
        .zglm = zglm_mod,
    });
}

pub fn sandbox(b: *Build, options: struct {
    target: Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    starry: *Build.Module,
    sunshine: *Build.Module,
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
                .{ .name = "sunshine", .module = options.sunshine },
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
