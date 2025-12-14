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
pub const intVecFromFloatVec = math.intVecFromFloatVec;
pub const floatVecFromIntVec = math.floatVecFromIntVec;
pub const intVecCast = math.intVecCast;
pub const floatVecCast = math.floatVecCast;

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
