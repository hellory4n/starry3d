//! Interacts with the world and stuff.
const std = @import("std");
const m = @import("math.zig");
const app = @import("app.zig");

const forward = m.vec3(f32, 0, 0, -1);
const right = m.vec3(f32, 1, 0, 0);
const up = m.vec3(f32, 0, 1, -1);

/// i saw the sun
pub const Camera = struct {
    position: m.Vec3(f32) = m.vec3(f32, 0, 0, 0),
    rotation: m.Quat = m.quat(0, 0, 0, 1),
    /// in radians
    fov: f32 = std.math.degreesToRadians(45),
    near: f32 = 0.01,
    far: f32 = 1000,
};

/// It's the current camera. What did you expect.
pub var current_camera: Camera = .{};
