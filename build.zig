const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build) !void {
    const target = b.standardTargetOptions(.{
        .whitelist = &.{
            std.Target.Query{
                .cpu_arch = .x86_64,
                .os_tag = .windows,
                .os_version_min = .{ .windows = .win10 },
                // force avx instructions
                .cpu_model = .{ .explicit = &std.Target.x86.cpu.x86_64_v3 },
            },
            std.Target.Query{
                .cpu_arch = .x86_64,
                .os_tag = .linux,
                // force avx instructions
                .cpu_model = .{ .explicit = &std.Target.x86.cpu.x86_64_v3 },
            },

            // not really supported/tested but you can try it if you want lmao
            std.Target.Query{
                .cpu_arch = .aarch64,
                .os_tag = .linux,
            },
            std.Target.Query{
                .cpu_arch = .aarch64,
                .os_tag = .windows,
            },
            std.Target.Query{
                .cpu_arch = .aarch64,
                .os_tag = .macos,
            },
            std.Target.Query{
                .cpu_arch = .x86_64,
                .os_tag = .macos,
            },
            std.Target.Query{
                .cpu_arch = .x86_64,
                .os_tag = .freebsd,
            },
            std.Target.Query{
                .cpu_arch = .x86_64,
                .os_tag = .openbsd,
            },
            std.Target.Query{
                .cpu_arch = .x86_64,
                .os_tag = .netbsd,
            },
        },
    });
    const optimize = b.standardOptimizeOption(.{});
    const opt_strip = b.option(
        bool,
        "strip",
        "Omit debug symbols",
    );
    const opt_omit_frame_pointer = b.option(
        bool,
        "omit-frame-pointer",
        "Omit the stack frame pointer",
    ) orelse false;
    const opt_valgrind = b.option(
        bool,
        "valgrind",
        "Include valgrind client requests",
    );
    const opt_llvm = b.option(
        bool,
        "llvm",
        "Force-enable LLVM",
    );
    const opt_benchmark = b.option(
        bool,
        "benchmark",
        "Enables running benchmark tests",
    ) orelse false;

    const options = b.addOptions();
    options.addOption(bool, "benchmark", opt_benchmark);

    // deps
    const zglfw_dep = b.dependency("zglfw", .{
        .target = target,
        .optimize = optimize,
    });
    const zglm_dep = b.dependency("zglm", .{
        .target = target,
        .optimize = optimize,
    });

    // sunshine
    const sunshine_mod = b.addModule("sunshine", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("sunshine/root.zig"),

        .strip = opt_strip,
        .omit_frame_pointer = opt_omit_frame_pointer,
        .valgrind = opt_valgrind,
        .link_libc = true,
    });
    sunshine_mod.addOptions("starry3d_options", options);
    sunshine_mod.addImport("zglm", zglm_dep.module("zglm"));
    sunshine_mod.addIncludePath(b.path("include"));
    sunshine_mod.addCSourceFile(.{ .file = b.path("include/stb_image_write.c") });

    // main starry engine
    const starry_mod = b.addModule("starry3d", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("starry/root.zig"),

        .strip = opt_strip,
        .omit_frame_pointer = opt_omit_frame_pointer,
        .valgrind = opt_valgrind,
    });
    starry_mod.addImport("sunshine", sunshine_mod);

    starry_mod.addImport("zglfw", zglfw_dep.module("root"));
    starry_mod.addImport("zglm", zglm_dep.module("zglm"));
    starry_mod.linkLibrary(zglfw_dep.artifact("glfw"));

    // starry renderer
    // compiled separately because debug mode is too slow to be usable
    // i think that's the only way to force the optimize mode on a specific file?
    const starryrender_mod = b.createModule(.{
        .target = target,
        .optimize = if (optimize == .Debug) .ReleaseSafe else optimize,
        .root_source_file = b.path("starry/render.zig"),
    });
    starryrender_mod.addIncludePath(b.path("starry/c"));
    starryrender_mod.addCSourceFile(.{ .file = b.path("starry/c/glad.c") });
    starryrender_mod.addImport("starry3d", starry_mod);
    starryrender_mod.addImport("sunshine", sunshine_mod);
    starryrender_mod.addImport("zglfw", zglfw_dep.module("root"));
    starryrender_mod.addImport("zglm", zglm_dep.module("zglm"));
    starryrender_mod.linkLibrary(zglfw_dep.artifact("glfw"));
    starry_mod.addImport("starry3d_render", starryrender_mod);

    // testing it<3
    const test_step = b.step("test", "Run starry tests");
    const sunshine_tests = b.addTest(.{
        .name = "sunshine-tests",
        .root_module = sunshine_mod,
        .use_llvm = opt_llvm,
    });
    const starry_tests = b.addTest(.{
        .name = "starry3d-tests",
        .root_module = starry_mod,
        .use_llvm = opt_llvm,
    });
    test_step.dependOn(&b.addRunArtifact(sunshine_tests).step);
    test_step.dependOn(&b.addRunArtifact(starry_tests).step);

    try sandbox(b, .{
        .target = target,
        .optimize = optimize,
        .starry = starry_mod,
        .sunshine = sunshine_mod,
        .zglm = zglm_dep.module("zglm"),
        .opt_llvm = opt_llvm,
    });
}

pub fn sandbox(b: *Build, options: struct {
    target: Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    starry: *Build.Module,
    sunshine: *Build.Module,
    zglm: *Build.Module,
    opt_llvm: ?bool,
}) !void {
    const sandbox_exe = b.addExecutable(.{
        .name = "sandbox",
        .use_llvm = options.opt_llvm,
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
    b.installArtifact(sandbox_exe);

    const run_step = b.step("run-sandbox", "Run sandbox");
    const run_cmd = b.addRunArtifact(sandbox_exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
}
