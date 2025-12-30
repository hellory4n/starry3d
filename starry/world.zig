//! Interacts with the world and stuff.
const std = @import("std");
const zglm = @import("zglm");
const app = @import("app.zig");

pub const forward = zglm.Vec3f{ 0, 0, -1 };
pub const right = zglm.Vec3f{ 1, 0, 0 };
pub const up = zglm.Vec3f{ 0, 1, 0 };

pub const Projection = enum { perspective, orthographic };

/// i saw the sun
pub const Camera = struct {
    position: zglm.Vec3f = @splat(0),
    /// in radians, X is pitch, Y is yaw, and Z is roll
    rotation: zglm.Vec3f = @splat(0),
    /// in radians, only used for a perspective camera
    fov: f32 = zglm.radians(45),
    /// only used for an orthographic camera
    zoom: f32 = 10,
    near: f32 = 0.001,
    far: f32 = 10_000,
    projection: Projection = .perspective,

    /// Returns the view matrix for the camera
    pub fn viewMatrix(cam: Camera) zglm.Mat4x4 {
        const pos = zglm.identity4x4f().translate(-cam.position);

        const rot = zglm.identity4x4f()
            .rotate(cam.rotation[0], .{ 1, 0, 0 })
            .rotate(cam.rotation[1], .{ 0, 1, 0 })
            .rotate(cam.rotation[2], .{ 0, 0, 1 });

        return rot.mul(pos);
    }

    /// Returns the projection matrix for the camera
    pub fn projectionMatrix(cam: Camera) zglm.Mat4x4 {
        const aspect = app.aspectRatio();

        if (cam.projection == .perspective) {
            return zglm.perspective(.{
                .fovy_rad = cam.fov,
                .aspect_ratio = aspect,
                .z_near = cam.near,
                .z_far = cam.far,
            });
        } else {
            // TODO this may be fucked im not sure
            const l = -cam.zoom / 2;
            const r = cam.zoom / 2;

            const height = cam.zoom * aspect;
            const b = -height / 2;
            const t = height / 2;

            return zglm.ortho(.{
                .left = l,
                .right = r,
                .bottom = b,
                .top = t,
                .z_near = cam.near,
                .z_far = cam.far,
            });
        }
    }
};

/// It's the current camera. What did you expect.
pub var current_camera: Camera = .{};
