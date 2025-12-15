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
    rotation: m.Rot(f32) = m.rot(f32, 0, 0, 0),
    /// in radians
    fov: f32 = std.math.degreesToRadians(45),
    near: f32 = 0.01,
    far: f32 = 1000,

    // TODO figure out orthographic cameras

    /// Returns the view matrix
    pub fn viewMatrix(cam: Camera) m.Mat4x4 {
        const pos_mat = m.translation4x4(cam.position);

        var rot_mat = m.identity4x4();
        rot_mat = m.rotatex4x4(rot_mat, cam.rotation.x());
        rot_mat = m.rotatey4x4(rot_mat, cam.rotation.y());
        rot_mat = m.rotatez4x4(rot_mat, cam.rotation.z());

        return m.mul4x4(rot_mat, pos_mat);
    }
};

/// It's the current camera. What did you expect.
pub var current_camera: Camera = .{};
