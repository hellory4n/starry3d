const std = @import("std");
pub const app = @import("app.zig");
pub const util = @import("util.zig");
pub const log = @import("log.zig");
pub const world = @import("world.zig");

// no external api functions, so it's private
const render = @import("render.zig");

pub const ScratchAllocator = @import("scratch.zig").ScratchAllocator;

// doubly namespaced math is a bit much
pub const math = @import("math.zig");
pub const Vec2 = math.Vec2;
pub const Vec3 = math.Vec3;
pub const Vec4 = math.Vec4;
pub const vec2 = math.vec2;
pub const vec3 = math.vec3;
pub const vec4 = math.vec4;
pub const Rgb = math.Rgb;
pub const Rgba = math.Rgba;
pub const rgb = math.rgb;
pub const rgba = math.rgba;
pub const Rot = math.Rot;
pub const rot = math.rot;
pub const intVecFromFloatVec = math.intVecFromFloatVec;
pub const floatVecFromIntVec = math.floatVecFromIntVec;
pub const intVecCast = math.intVecCast;
pub const floatVecCast = math.floatVecCast;
pub const add2 = math.add2;
pub const add3 = math.add3;
pub const add4 = math.add4;
pub const sub2 = math.sub2;
pub const sub3 = math.sub3;
pub const sub4 = math.sub4;
pub const mul2 = math.mul2;
pub const mul3 = math.mul3;
pub const mul4 = math.mul4;
pub const muls2 = math.muls2;
pub const muls3 = math.muls3;
pub const muls4 = math.muls4;
pub const div2 = math.div2;
pub const div3 = math.div3;
pub const div4 = math.div4;
pub const divs2 = math.divs2;
pub const divs3 = math.divs3;
pub const divs4 = math.divs4;
pub const mod2 = math.mod2;
pub const mod3 = math.mod3;
pub const mod4 = math.mod4;
pub const mods2 = math.mods2;
pub const mods3 = math.mods3;
pub const mods4 = math.mods4;
pub const equal2 = math.equal2;
pub const equal3 = math.equal3;
pub const equal4 = math.equal4;
pub const notEqual2 = math.notEqual2;
pub const notEqual3 = math.notEqual3;
pub const notEqual4 = math.notEqual4;
pub const neg2 = math.neg2;
pub const neg3 = math.neg3;
pub const neg4 = math.neg4;
pub const swizzle = math.swizzle;
pub const length2 = math.length2;
pub const length3 = math.length3;
pub const length4 = math.length4;
pub const distance2 = math.distance2;
pub const distance3 = math.distance3;
pub const distance4 = math.distance4;
pub const dot2 = math.dot2;
pub const dot3 = math.dot3;
pub const dot4 = math.dot4;
pub const cross3 = math.cross3;
pub const normalize2 = math.normalize2;
pub const normalize3 = math.normalize3;
pub const normalize4 = math.normalize4;
pub const Mat4x4 = math.Mat4x4;
pub const zero4x4 = math.zero4x4;
pub const identity4x4 = math.identity4x4;
pub const add4x4 = math.add4x4;
pub const sub4x4 = math.sub4x4;
pub const transpose4x4 = math.transpose4x4;
pub const mul4x4 = math.mul4x4;
pub const muls4x4 = math.muls4x4;
pub const divs4x4 = math.divs4x4;
pub const mulv4x4 = math.mulv4x4;
pub const determinant4x4 = math.determinant4x4;
pub const inv4x4 = math.inv4x4;
pub const orthographic4x4 = math.orthographic4x4;
pub const perspective4x4 = math.perspective4x4;
pub const translation4x4 = math.translation4x4;
pub const rotatex4x4 = math.rotatex4x4;
pub const rotatey4x4 = math.rotatey4x4;
pub const rotatez4x4 = math.rotatez4x4;

pub const version = std.SemanticVersion{
    .major = 0,
    .minor = 7,
    .patch = 0,
    .pre = "dev",
};

// otherwise tests don't work
test {
    std.testing.refAllDecls(@This());
}
