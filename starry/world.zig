//! Interacts with the world and stuff.
const std = @import("std");
const zglm = @import("zglm");
const app = @import("app.zig");

pub const forward = zglm.vec3f(0, 0, -1);
pub const right = zglm.vec3f(1, 0, 0);
pub const up = zglm.vec3f(0, 1, 0);

pub const Projection = enum { perspective, orthographic };

/// i saw the sun
pub const Camera = struct {
    position: zglm.Vec3f = zglm.vec3f(0, 0, 0),
    /// in radians
    rotation: zglm.Vec3f = zglm.vec3f(0, 0, 0),
    /// in radians, only used for a perspective camera
    fov: f32 = zglm.deg2rad(45),
    /// only used for an orthographic camera
    zoom: f32 = 10,
    near: f32 = 0.001,
    far: f32 = 10_000,
    projection: Projection = .perspective,

    /// Returns the view matrix for the camera
    pub fn viewMatrix(cam: Camera) zglm.Mat4x4 {
        const pos = zglm.Mat4x4.translate(cam.position.neg());

        const rot = zglm.Mat4x4.rotateX(cam.rotation.x())
            .mul(.rotateY(cam.rotation.y()))
            .mul(.rotateZ(cam.rotation.z()));

        return rot.mul(pos);
    }

    /// Returns the centered view matrix (no translation) for the camera
    pub fn centeredViewMatrix(cam: Camera) zglm.Mat4x4 {
        return zglm.Mat4x4.rotateX(cam.rotation.x())
            .mul(.rotateY(cam.rotation.y()))
            .mul(.rotateZ(cam.rotation.z()));
    }

    /// Returns the projection matrix for the camera
    pub fn projectionMatrix(cam: Camera) zglm.Mat4x4 {
        const aspect = app.aspectRatio();

        if (cam.projection == .perspective) {
            return .perspective(cam.fov, aspect, cam.near, cam.far);
        } else {
            // TODO this may be fucked im not sure
            const l = -cam.zoom / 2;
            const r = cam.zoom / 2;

            const height = cam.zoom * aspect;
            const b = -height / 2;
            const t = height / 2;
            return .ortho(l, r, b, t, cam.near, cam.far);
        }
    }
};

/// It's the current camera. What did you expect.
pub var current_camera: Camera = .{};
