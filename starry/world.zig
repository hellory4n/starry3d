//! Interacts with the world and stuff.
const std = @import("std");
const zglm = @import("zglm");
const app = @import("app.zig");

pub const forward = zglm.vec3f(0, 0, -1);
pub const right = zglm.vec3f(1, 0, 0);
pub const up = zglm.vec3f(0, 1, 0);

/// i saw the sun
pub const Camera = struct {
    position: zglm.Vec3f = zglm.vec3f(0, 0, 0),
    // rotation: zglm.Quat = zglm.quat(0, 0, 0, 1),
    /// in radians
    fov: f32 = std.math.degreesToRadians(45),
    near: f32 = 0.01,
    far: f32 = 1000,
};

/// It's the current camera. What did you expect.
pub var current_camera: Camera = .{};
