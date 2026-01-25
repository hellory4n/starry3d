const std = @import("std");
const starry = @import("starry3d");
const sunshine = @import("sunshine");
const zglm = @import("zglm");

const mouse_sensitivity: f64 = 30;
const player_speed: f64 = 5.0;
var cam_pitch: f64 = 0;
var cam_yaw: f64 = 0;

fn initApp() !void {
    std.log.info("hi", .{});
    starry.world.current_camera = .{
        .position = .{ 0, 0, 5 },
        .fov = zglm.radians(90),
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
    const mouse = starry.app.deltaMousePosition();
    // quite the mouthful
    cam_pitch = zglm.clamp(cam_pitch + mouse[1] * mouse_sensitivity * dt, -89, 89);
    cam_yaw += mouse[0] * mouse_sensitivity * dt;
    starry.world.current_camera.rotation = .{ zglm.radians(cam_pitch), zglm.radians(cam_yaw), 0 };

    var move: zglm.Vec3d = @splat(0);
    if (starry.app.isKeyHeld(.w)) {
        move +=
            .{ zglm.sin(zglm.radians(cam_yaw)) * 1, 0, zglm.cos(zglm.radians(cam_yaw)) * -1 };
    }
    if (starry.app.isKeyHeld(.s)) {
        move +=
            .{ zglm.sin(zglm.radians(cam_yaw)) * -1, 0, zglm.cos(zglm.radians(cam_yaw)) * 1 };
    }
    if (starry.app.isKeyHeld(.a)) {
        move +=
            .{ zglm.sin(zglm.radians(cam_yaw - 90)) * 1, 0, zglm.cos(zglm.radians(cam_yaw - 90)) * -1 };
    }
    if (starry.app.isKeyHeld(.d)) {
        move +=
            .{ zglm.sin(zglm.radians(cam_yaw - 90)) * -1, 0, zglm.cos(zglm.radians(cam_yaw - 90)) * 1 };
    }
    if (starry.app.isKeyHeld(.space)) {
        move[1] += 1;
    }
    if (starry.app.isKeyHeld(.left_shift)) {
        move[1] -= 1;
    }

    starry.world.current_camera.position +=
        zglm.normalize(move) * @as(zglm.Vec3d, @splat(player_speed)) * @as(zglm.Vec3d, @splat(dt));
}

pub const std_options = sunshine.std_options;

pub fn main() !void {
    try @import("softrender.zig").render();
    // var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    // defer _ = gpa.deinit();

    // sunshine.initLog(gpa.allocator());
    // defer sunshine.deinitLog();
    // try sunshine.addLogPath("log.txt");

    // starry.app.run(gpa.allocator(), .{
    //     .name = "sandbox",
    //     .init = initApp,
    //     .deinit = deinitApp,
    //     .update = updateApp,
    // });
}
