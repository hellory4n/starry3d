const std = @import("std");
const starry = @import("starry3d");

pub const std_options = starry.util.std_options;

const mouse_sensitivity: f32 = 0.15;
const player_speed: f32 = 5.0;

fn initApp() !void {
    std.log.info("hi", .{});
    starry.world.current_camera = .{
        .position = starry.math.vec3(f32, 0, 0, 5),
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
    var cam_rot = starry.world.current_camera.rotation;
    cam_rot.setX(cam_rot.x() + std.math.degreesToRadians(mpos.y() * mouse_sensitivity));
    cam_rot.setY(cam_rot.y() + std.math.degreesToRadians(mpos.x() * mouse_sensitivity));
    // don't break your neck
    cam_rot.setY(std.math.clamp(
        cam_rot.y(),
        std.math.degreesToRadians(-89.0),
        std.math.degreesToRadians(89.0),
    ));
    starry.world.current_camera.rotation = cam_rot;

    var move = starry.math.vec3(f32, 0, 0, 0);
    if (starry.app.isKeyHeld(.w)) {
        move = starry.math.add(move, starry.math.vec3(
            f32,
            @sin(starry.world.current_camera.rotation.y()) * 1,
            0,
            @cos(starry.world.current_camera.rotation.y()) * -1,
        ));
    }
    if (starry.app.isKeyHeld(.s)) {
        move = starry.math.add(move, starry.math.vec3(
            f32,
            @sin(starry.world.current_camera.rotation.y()) * -1,
            0,
            @cos(starry.world.current_camera.rotation.y()) * 1,
        ));
    }
    if (starry.app.isKeyHeld(.a)) {
        move = starry.math.add(move, starry.math.vec3(
            f32,
            @sin(starry.world.current_camera.rotation.y() - @as(f32, std.math.pi) / 2) * 1,
            0,
            @cos(starry.world.current_camera.rotation.y() - @as(f32, std.math.pi) / 2) * -1,
        ));
    }
    if (starry.app.isKeyHeld(.d)) {
        move = starry.math.add(move, starry.math.vec3(
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

    // ctrl is normal run
    // alt is ultra fast run for when youre extra impatient
    var run: f32 = 1.0;
    if (starry.app.isKeyHeld(.left_ctrl)) {
        run += 3;
    }
    if (starry.app.isKeyHeld(.left_alt)) {
        run += 6;
    }
    move = starry.math.normalize(move);

    // bloody hell mate
    starry.world.current_camera.position = starry.math.add(
        starry.world.current_camera.position,
        starry.math.muls(starry.math.muls(starry.math.muls(move, player_speed), run), dt),
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
