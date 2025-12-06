const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // TODO i don't think it does anything when you disable this
    // idk how you're supposed to build a zig library
    const build_examples = b.option(bool, "build_sandbox", "Build sandbox (the test project for Starry)") orelse true;

    const zhader = b.addExecutable(.{
        .name = "zhader",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/zhader.zig"),
            .target = b.graph.host,
        }),
    });

    const mod = b.addModule("starry3d", .{
        .root_source_file = b.path("starry/root.zig"),
        .target = target,
    });
    installStarryDeps(b, mod);
    try compileShader(b, zhader, mod, b.path("starry/shader/basic.vert"), .vertex);
    try compileShader(b, zhader, mod, b.path("starry/shader/basic.frag"), .fragment);

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

    if (build_examples) {
        sandbox(b, target, optimize, mod);
    }
}

fn installStarryDeps(b: *std.Build, mod: *std.Build.Module) void {
    const zglfw = b.dependency("zglfw", .{});
    mod.addImport("zglfw", zglfw.module("root"));
    mod.linkLibrary(zglfw.artifact("glfw"));

    const registry = b.dependency("vulkan_headers", .{}).path("registry/vk.xml");
    const vulkan = b.dependency("vulkan", .{
        .registry = registry,
    }).module("vulkan-zig");
    mod.addImport("vulkan", vulkan);
}

const ShaderStage = enum {
    vertex,
    fragment,

    pub fn toCompileFlag(stage: ShaderStage) []const u8 {
        return switch (stage) {
            .vertex => "-fshader-stage=vertex",
            .fragment => "-fshader-stage=fragment",
        };
    }
};

fn compileShader(
    b: *std.Build,
    zhader: *std.Build.Step.Compile,
    mod: *std.Build.Module,
    src: std.Build.LazyPath,
    stage: ShaderStage,
) !void {
    const zhader_step = b.addRunArtifact(zhader);
    zhader_step.addArg(stage.toCompileFlag());
    zhader_step.addFileArg(src);
    _ = zhader_step.addOutputFileArg(
        try std.mem.concat(b.allocator, u8, &.{ src.basename(b, null), ".spv" }),
    );
    const output = zhader_step.addOutputFileArg(
        try std.mem.concat(b.allocator, u8, &.{ src.basename(b, null), ".zig" }),
    );

    mod.addAnonymousImport(src.basename(b, null), .{
        .root_source_file = output,
    });
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

    const run_step = b.step("run", "Run sandbox");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
}
