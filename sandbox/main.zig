const std = @import("std");
const starry = @import("starry3d");
const zm = @import("zmath");

pub const std_options = starry.util.std_options;

const mouse_sensitivity: f32 = 0.15;
const player_speed: f32 = 5.0;

fn initApp() !void {
    std.log.info("hi", .{});
    starry.world.current_camera = .{
        .position = .{ 0, 0, 1 },
        .fov = std.math.degreesToRadians(90),
    };
}

fn deinitApp() void {
    std.log.info("bye", .{});
}

pub fn updateApp(dt: f32) void {
    // crap
    if (starry.app.isKeyJustPressed(.escape)) {
        starry.app.lockMouse(!starry.app.isMouseLocked());
    }
    if (!starry.app.isMouseLocked()) {
        return;
    }

    // fps controller
    const mpos = starry.app.deltaMousePosition();
    starry.world.current_camera.rotation[1] += std.math.degreesToRadians(mpos[0] * mouse_sensitivity);
    starry.world.current_camera.rotation[0] += std.math.degreesToRadians(mpos[1] * mouse_sensitivity);
    // don't break your neck
    starry.world.current_camera.rotation[0] = std.math.clamp(
        starry.world.current_camera.rotation[0],
        std.math.degreesToRadians(-89.0),
        std.math.degreesToRadians(89.0),
    );

    var move: @Vector(3, f32) = .{ 0, 0, 0 };
    if (starry.app.isKeyHeld(.w)) {
        move += @Vector(3, f32){
            @sin(starry.world.current_camera.rotation[1]) * 1,
            0,
            @cos(starry.world.current_camera.rotation[1]) * -1,
        };
    }
    if (starry.app.isKeyHeld(.s)) {
        move += @Vector(3, f32){
            @sin(starry.world.current_camera.rotation[1]) * -1,
            0,
            @cos(starry.world.current_camera.rotation[1]) * 1,
        };
    }
    if (starry.app.isKeyHeld(.a)) {
        move += @Vector(3, f32){
            @sin(starry.world.current_camera.rotation[1] - @as(f32, std.math.pi) / 2) * 1,
            0,
            @cos(starry.world.current_camera.rotation[1] - @as(f32, std.math.pi) / 2) * -1,
        };
    }
    if (starry.app.isKeyHeld(.d)) {
        move += @Vector(3, f32){
            @sin(starry.world.current_camera.rotation[1] - @as(f32, std.math.pi) / 2) * -1,
            0,
            @cos(starry.world.current_camera.rotation[1] - @as(f32, std.math.pi) / 2) * 1,
        };
    }
    if (starry.app.isKeyHeld(.space)) {
        move[1] += 1;
    }
    if (starry.app.isKeyHeld(.left_shift)) {
        move[1] -= 1;
    }

    // ctrl is normal run
    // alt is ultra fast run for when youre extra impatient
    var run: f32 = 1.0;
    if (starry.app.isKeyHeld(.left_ctrl)) {
        run += 3;
    }
    if (starry.app.isKeyHeld(.left_alt)) {
        run += 6;
    }
    // zmath is weird
    const move4 = @Vector(4, f32){ move[0], move[1], move[2], 1 };
    const normalized = zm.normalize3(move4);
    var normalized3 = @Vector(3, f32){ normalized[0], normalized[1], normalized[2] };
    // nanma balls
    if (std.math.isNan(normalized3[0])) normalized3[0] = 0;
    if (std.math.isNan(normalized3[1])) normalized3[1] = 0;
    if (std.math.isNan(normalized3[2])) normalized3[2] = 0;

    // bloody hell mate
    starry.world.current_camera.position +=
        normalized3 * @Vector(3, f32){ player_speed, player_speed, player_speed } *
        @Vector(3, f32){ run, run, run } * @Vector(3, f32){ dt, dt, dt };
}

pub fn main() !void {
    try starry.app.run(.{
        .name = "sandbox",
        .init = initApp,
        .deinit = deinitApp,
        .update = updateApp,
        .logfiles = &[_][]const u8{"log.txt"},
    });
}
