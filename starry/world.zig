//! Interacts with the world and stuff.
const zm = @import("zmath");
const app = @import("app.zig");

const forward: @Vector(3, f32) = .{ 0, 0, -1 };
const right: @Vector(3, f32) = .{ 1, 0, 0 };
const up: @Vector(3, f32) = .{ 0, 1, 0 };

/// i saw the sun
pub const Camera = struct {
    position: @Vector(3, f32) = .{ 0, 0, 0 },
    /// in euler radians
    rotation: @Vector(3, f32) = .{ 0, 0, 0 },
    /// in radians
    fov: f32 = 0,
    near: f32 = 0.01,
    far: f32 = 1000,

    // TODO figure out orthographic cameras

    /// Returns the projection matrix for use in OpenGL
    pub fn projectionMatrixGl(cam: Camera) zm.Mat {
        return zm.transpose(zm.perspectiveFovRhGl(cam.fov, app.aspectRatio(), cam.near, cam.far));
    }

    /// Returns the view matrix for use in OpenGL
    pub fn viewMatrixGl(cam: Camera) zm.Mat {
        const pos_mat = zm.translation(-cam.position[0], -cam.position[1], -cam.position[2]);
        const rot_mat = zm.mul(
            zm.rotationX(cam.rotation[0]),
            zm.mul(zm.rotationY(cam.rotation[1]), zm.rotationZ(cam.rotation[2])),
        );
        return zm.transpose(zm.mul(rot_mat, pos_mat));
    }
};

/// It's the current camera. What did you expect.
pub var current_camera: Camera = .{};
