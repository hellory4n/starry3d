const std = @import("std");
const starry = @import("starry3d");
const sm = starry.math;

pub const std_options = starry.util.std_options;

const mouse_sensitivity: f32 = 30;
const player_speed: f32 = 5.0;
var cam_pitch: f32 = 0;
var cam_yaw: f32 = 0;

fn initApp() !void {
    std.log.info("hi", .{});
    starry.world.current_camera = .{
        .position = sm.vec3(f32, 0, 0, 5),
        .fov = std.math.degreesToRadians(45),
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
    cam_pitch = std.math.clamp(cam_pitch + mpos.y() * mouse_sensitivity * dt, -89.0, 89.0);
    cam_yaw += mpos.x() * mouse_sensitivity * dt;

    const pitch_quat = sm.eulerDeg(sm.vec3(f32, cam_pitch, 0, 0));
    const yaw_quat = sm.eulerDeg(sm.vec3(f32, 0, cam_yaw, 0));
    starry.world.current_camera.rotation = sm.normalize(sm.mul(pitch_quat, yaw_quat));

    var move = sm.vec3(f32, 0, 0, 0);
    if (starry.app.isKeyHeld(.w)) {
        move = sm.add(move, sm.vec3(
            f32,
            @sin(starry.world.current_camera.rotation.y()) * 1,
            0,
            @cos(starry.world.current_camera.rotation.y()) * -1,
        ));
    }
    if (starry.app.isKeyHeld(.s)) {
        move = sm.add(move, sm.vec3(
            f32,
            @sin(starry.world.current_camera.rotation.y()) * -1,
            0,
            @cos(starry.world.current_camera.rotation.y()) * 1,
        ));
    }
    if (starry.app.isKeyHeld(.a)) {
        move = sm.add(move, sm.vec3(
            f32,
            @sin(starry.world.current_camera.rotation.y() - @as(f32, std.math.pi) / 2) * 1,
            0,
            @cos(starry.world.current_camera.rotation.y() - @as(f32, std.math.pi) / 2) * -1,
        ));
    }
    if (starry.app.isKeyHeld(.d)) {
        move = sm.add(move, sm.vec3(
            f32,
            @sin(starry.world.current_camera.rotation.y() - @as(f32, std.math.pi) / 2) * -1,
            0,
            @cos(starry.world.current_camera.rotation.y() - @as(f32, std.math.pi) / 2) * 1,
        ));
    }
    if (starry.app.isKeyHeld(.space)) {
        move.setY(move.y() + 1);
    }
    if (starry.app.isKeyHeld(.left_shift)) {
        move.setY(move.y() - 1);
    }
    move = sm.normalize(move);

    // bloody hell mate
    starry.world.current_camera.position = sm.add(
        starry.world.current_camera.position,
        sm.muls(move, player_speed * dt),
    );
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
