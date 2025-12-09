const std = @import("std");
const sokol = @import("sokol");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const starry_mod = b.addModule("starry3d", .{
        .root_source_file = b.path("starry/root.zig"),
        .target = target,
    });
    const deps = installStarryDeps(b, starry_mod, target, optimize);
    try compileShaders(b, starry_mod, deps);

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

    sandbox(b, target, optimize, starry_mod);
}

/// hsit
const StarryDependencies = struct {
    sokol: *std.Build.Dependency,
};

fn installStarryDeps(
    b: *std.Build,
    mod: *std.Build.Module,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) StarryDependencies {
    const sokol_dep = b.dependency("sokol", .{
        .target = target,
        .optimize = optimize,
        .gl = true,
    });
    mod.addImport("sokol", sokol_dep.module("sokol"));

    return .{
        .sokol = sokol_dep,
    };
}

fn compileShaders(b: *std.Build, mod: *std.Build.Module, deps: StarryDependencies) !void {
    const shdc = deps.sokol.builder.dependency("shdc", .{});
    const basic_shader = try sokol.shdc.createModule(b, "basic.glsl", deps.sokol.module("sokol"), .{
        .shdc_dep = shdc,
        .input = "starry/shader/basic.glsl",
        .output = "basic.glsl.zig",
        .slang = .{
            .glsl430 = true,
        },
    });
    mod.addImport("basic.glsl", basic_shader);
}

fn sandbox(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    starry_mod: *std.Build.Module,
) void {
    const exe = b.addExecutable(.{
        .name = "sandbox",
        .root_module = b.createModule(.{
            .root_source_file = b.path("sandbox/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "starry3d", .module = starry_mod },
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
}
