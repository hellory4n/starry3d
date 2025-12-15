//! Touching linear algebra library inspired by GLSL. Everything uses OpenGL conventions, with
//! column-major matrices, +Y is up, right-handed coordinates, etc.
const std = @import("std");
const testing = std.testing;

/// A vector with 2 components. Extraordinary.
pub fn Vec2(comptime T: type) type {
    return struct {
        repr: @Vector(2, T),

        pub fn x(vec: @This()) T {
            return vec.repr[0];
        }

        pub fn setX(vec: *@This(), val: T) void {
            vec.repr[0] = val;
        }

        pub fn y(vec: @This()) T {
            return vec.repr[1];
        }

        pub fn setY(vec: *@This(), val: T) void {
            vec.repr[1] = val;
        }

        pub fn nth(vec: @This(), comptime idx: comptime_int) T {
            return vec.repr[idx];
        }

        pub fn setNth(vec: *@This(), comptime idx: comptime_int, val: T) void {
            vec.repr[idx] = val;
        }

        pub fn toArray(vec: @This()) [2]T {
            return [2]T{ vec.x(), vec.y() };
        }
    };
}

/// A vector with 3 components. Extraordinary.
pub fn Vec3(comptime T: type) type {
    return struct {
        repr: @Vector(3, T),

        pub fn x(vec: @This()) T {
            return vec.repr[0];
        }

        pub fn setX(vec: *@This(), val: T) void {
            vec.repr[0] = val;
        }

        pub fn y(vec: @This()) T {
            return vec.repr[1];
        }

        pub fn setY(vec: *@This(), val: T) void {
            vec.repr[1] = val;
        }

        pub fn z(vec: @This()) T {
            return vec.repr[2];
        }

        pub fn setZ(vec: *@This(), val: T) void {
            vec.repr[2] = val;
        }

        pub fn r(vec: @This()) T {
            return vec.repr[0];
        }

        pub fn setR(vec: *@This(), val: T) void {
            vec.repr[0] = val;
        }

        pub fn g(vec: @This()) T {
            return vec.repr[1];
        }

        pub fn setG(vec: *@This(), val: T) void {
            vec.repr[1] = val;
        }

        pub fn b(vec: @This()) T {
            return vec.repr[2];
        }

        pub fn setB(vec: *@This(), val: T) void {
            vec.repr[2] = val;
        }

        pub fn nth(vec: @This(), comptime idx: comptime_int) T {
            return vec.repr[idx];
        }

        pub fn setNth(vec: *@This(), comptime idx: comptime_int, val: T) void {
            vec.repr[idx] = val;
        }

        pub fn toArray(vec: @This()) [3]T {
            return [3]T{ vec.x(), vec.y(), vec.z() };
        }
    };
}

/// A vector with 4 components. Extraordinary.
pub fn Vec4(comptime T: type) type {
    return struct {
        repr: @Vector(4, T),

        pub fn x(vec: @This()) T {
            return vec.repr[0];
        }

        pub fn setX(vec: *@This(), val: T) void {
            vec.repr[0] = val;
        }

        pub fn y(vec: @This()) T {
            return vec.repr[1];
        }

        pub fn setY(vec: *@This(), val: T) void {
            vec.repr[1] = val;
        }

        pub fn z(vec: @This()) T {
            return vec.repr[2];
        }

        pub fn setZ(vec: *@This(), val: T) void {
            vec.repr[2] = val;
        }

        pub fn w(vec: @This()) T {
            return vec.repr[3];
        }

        pub fn setW(vec: *@This(), val: T) void {
            vec.repr[3] = val;
        }

        pub fn r(vec: @This()) T {
            return vec.repr[0];
        }

        pub fn setR(vec: *@This(), val: T) void {
            vec.repr[0] = val;
        }

        pub fn g(vec: @This()) T {
            return vec.repr[1];
        }

        pub fn setG(vec: *@This(), val: T) void {
            vec.repr[1] = val;
        }

        pub fn b(vec: @This()) T {
            return vec.repr[2];
        }

        pub fn setB(vec: *@This(), val: T) void {
            vec.repr[2] = val;
        }

        pub fn a(vec: @This()) T {
            return vec.repr[3];
        }

        pub fn setA(vec: *@This(), val: T) void {
            vec.repr[3] = val;
        }

        pub fn nth(vec: @This(), comptime idx: comptime_int) T {
            return vec.repr[idx];
        }

        pub fn setNth(vec: *@This(), comptime idx: comptime_int, val: T) void {
            vec.repr[idx] = val;
        }

        pub fn toArray(vec: @This()) [4]T {
            return [4]T{ vec.x(), vec.y(), vec.z(), vec.w() };
        }
    };
}

/// Makes a vector of 2. Impressive. Very nice.
pub fn vec2(comptime T: type, x: T, y: T) Vec2(T) {
    return Vec2(T){ .repr = .{ x, y } };
}

/// Makes a vector of 3. Impressive. Very nice.
pub fn vec3(comptime T: type, x: T, y: T, z: T) Vec3(T) {
    return Vec3(T){ .repr = .{ x, y, z } };
}

/// Makes a vector of 4. Impressive. Very nice.
pub fn vec4(comptime T: type, x: T, y: T, z: T, w: T) Vec4(T) {
    return Vec4(T){ .repr = .{ x, y, z, w } };
}

test "basic vectors" {
    const v2: Vec2(i32) = vec2(i32, 1, 2);
    try testing.expectEqual(v2.x(), 1);
    try testing.expectEqual(v2.nth(0), v2.x());
    try testing.expectEqual(v2.toArray()[0], v2.nth(0));
    try testing.expectEqual(v2.y(), 2);
    try testing.expectEqual(v2.nth(1), v2.y());
    try testing.expectEqual(v2.toArray()[1], v2.nth(1));

    const v3: Vec3(i32) = vec3(i32, 1, 2, 3);
    try testing.expectEqual(v3.x(), 1);
    try testing.expectEqual(v3.r(), v3.x());
    try testing.expectEqual(v3.nth(0), v3.r());
    try testing.expectEqual(v3.toArray()[0], v3.nth(0));
    try testing.expectEqual(v3.y(), 2);
    try testing.expectEqual(v3.g(), v3.y());
    try testing.expectEqual(v3.nth(1), v3.g());
    try testing.expectEqual(v3.toArray()[1], v3.nth(1));
    try testing.expectEqual(v3.z(), 3);
    try testing.expectEqual(v3.b(), v3.z());
    try testing.expectEqual(v3.nth(2), v3.b());
    try testing.expectEqual(v3.toArray()[2], v3.nth(2));

    const v4: Vec4(i32) = vec4(i32, 1, 2, 3, 4);
    try testing.expectEqual(v4.x(), 1);
    try testing.expectEqual(v4.r(), v4.x());
    try testing.expectEqual(v4.nth(0), v4.r());
    try testing.expectEqual(v4.toArray()[0], v4.nth(0));
    try testing.expectEqual(v4.y(), 2);
    try testing.expectEqual(v4.g(), v4.y());
    try testing.expectEqual(v4.nth(1), v4.g());
    try testing.expectEqual(v4.toArray()[1], v4.nth(1));
    try testing.expectEqual(v4.z(), 3);
    try testing.expectEqual(v4.b(), v4.z());
    try testing.expectEqual(v4.nth(2), v4.b());
    try testing.expectEqual(v4.toArray()[2], v4.nth(2));
    try testing.expectEqual(v4.w(), 4);
    try testing.expectEqual(v4.a(), v4.a());
    try testing.expectEqual(v4.nth(3), v4.a());
    try testing.expectEqual(v4.toArray()[3], v4.nth(3));
}

// why not
pub const Rgb = Vec3;
pub const Rgba = Vec4;
pub const rgb = vec3;
pub const rgba = vec4;
/// Euler rotation in radians
pub const Rot = Vec3;
pub const rot = vec3;

const VecInfo = struct {
    len: comptime_int,
    child: type,
};

fn vecInfo(comptime T: type) VecInfo {
    if (@typeInfo(T) != .@"struct") {
        @compileError("not a vector");
    }
    if (!@hasField(T, "repr")) {
        @compileError("not a vector");
    }
    const mn = @typeInfo(@FieldType(T, "repr")).vector;
    return .{ .len = mn.len, .child = mn.child };
}

fn VectorWithLen(comptime len: comptime_int, comptime T: type) type {
    return switch (len) {
        2 => Vec2(T),
        3 => Vec3(T),
        4 => Vec4(T),
        else => @compileError("invalid vector length"),
    };
}

fn TypeOfVector(vec: anytype) type {
    const vec_info = vecInfo(@TypeOf(vec));
    return VectorWithLen(vec_info.len, vec_info.child);
}

fn lengthOfVector(comptime T: type) comptime_int {
    return vecInfo(T).len;
}

/// Casting it rn
pub fn intVecFromFloatVec(
    comptime To: type,
    vec: anytype,
) VectorWithLen(lengthOfVector(@TypeOf(vec)), To) {
    return switch (lengthOfVector(@TypeOf(vec))) {
        2 => vec2(To, @intFromFloat(vec.x()), @intFromFloat(vec.y())),
        3 => vec3(To, @intFromFloat(vec.x()), @intFromFloat(vec.y()), @intFromFloat(vec.z())),
        4 => vec4(To, @intFromFloat(vec.x()), @intFromFloat(vec.y()), @intFromFloat(vec.z()), @intFromFloat(vec.w())),
        else => @compileError("invalid vector length"),
    };
}

/// Casting it rn
pub fn floatVecFromIntVec(
    comptime To: type,
    vec: anytype,
) VectorWithLen(lengthOfVector(@TypeOf(vec)), To) {
    return switch (lengthOfVector(@TypeOf(vec))) {
        2 => vec2(To, @floatFromInt(vec.x()), @floatFromInt(vec.y())),
        3 => vec3(To, @floatFromInt(vec.x()), @floatFromInt(vec.y()), @floatFromInt(vec.z())),
        4 => vec4(To, @floatFromInt(vec.x()), @floatFromInt(vec.y()), @floatFromInt(vec.z()), @floatFromInt(vec.w())),
        else => @compileError("invalid vector length"),
    };
}

/// Casting it rn
pub fn intVecCast(
    comptime To: type,
    vec: anytype,
) VectorWithLen(lengthOfVector(@TypeOf(vec)), To) {
    return switch (lengthOfVector(@TypeOf(vec))) {
        2 => vec2(To, @intCast(vec.x()), @intCast(vec.y())),
        3 => vec3(To, @intCast(vec.x()), @intCast(vec.y()), @intCast(vec.z())),
        4 => vec4(To, @intCast(vec.x()), @intCast(vec.y()), @intCast(vec.z()), @intCast(vec.w())),
        else => @compileError("invalid vector length"),
    };
}

/// Casting it rn
pub fn floatVecCast(
    comptime To: type,
    vec: anytype,
) VectorWithLen(lengthOfVector(@TypeOf(vec)), To) {
    return switch (lengthOfVector(@TypeOf(vec))) {
        2 => vec2(To, @floatCast(vec.x()), @floatCast(vec.y())),
        3 => vec3(To, @floatCast(vec.x()), @floatCast(vec.y()), @floatCast(vec.z())),
        4 => vec4(To, @floatCast(vec.x()), @floatCast(vec.y()), @floatCast(vec.z()), @floatCast(vec.w())),
        else => @compileError("invalid vector length"),
    };
}

test "vector casting" {
    const v2i = vec2(i32, 1, 2);
    const v2f = vec2(f64, 1, 2);
    try testing.expectEqual(intVecCast(i16, v2i), vec2(i16, 1, 2));
    try testing.expectEqual(floatVecCast(f32, v2f), vec2(f32, 1, 2));
    try testing.expectEqual(floatVecFromIntVec(f32, v2i), vec2(f32, 1, 2));
    try testing.expectEqual(intVecFromFloatVec(i32, v2f), vec2(i32, 1, 2));
}

/// Adds 2 vector2s together
pub fn add2(comptime T: type, a: Vec2(T), b: Vec2(T)) Vec2(T) {
    return .{ .repr = a.repr + b.repr };
}

/// Adds 2 vector3s together
pub fn add3(comptime T: type, a: Vec3(T), b: Vec3(T)) Vec3(T) {
    return .{ .repr = a.repr + b.repr };
}

/// Adds 2 vector4s together
pub fn add4(comptime T: type, a: Vec4(T), b: Vec4(T)) Vec4(T) {
    return .{ .repr = a.repr + b.repr };
}

/// Subtracts 2 vector2s together
pub fn sub2(comptime T: type, a: Vec2(T), b: Vec2(T)) Vec2(T) {
    return .{ .repr = a.repr - b.repr };
}

/// Subtracts 2 vector3s together
pub fn sub3(comptime T: type, a: Vec3(T), b: Vec3(T)) Vec3(T) {
    return .{ .repr = a.repr - b.repr };
}

/// Subtracts 2 vector4s together
pub fn sub4(comptime T: type, a: Vec4(T), b: Vec4(T)) Vec4(T) {
    return .{ .repr = a.repr - b.repr };
}

/// Multiplies 2 vector2s together
pub fn mul2(comptime T: type, a: Vec2(T), b: Vec2(T)) Vec2(T) {
    return .{ .repr = a.repr * b.repr };
}

/// Multiplies 2 vector3s together
pub fn mul3(comptime T: type, a: Vec3(T), b: Vec3(T)) Vec3(T) {
    return .{ .repr = a.repr * b.repr };
}

/// Multiplies 2 vector4s together
pub fn mul4(comptime T: type, a: Vec4(T), b: Vec4(T)) Vec4(T) {
    return .{ .repr = a.repr * b.repr };
}

/// Multiplies a vector2 by a scalar
pub fn muls2(comptime T: type, a: Vec2(T), b: T) Vec2(T) {
    return .{ .repr = a.repr * @Vector(2, T){ b, b } };
}

/// Multiplies a vector3 by a scalar
pub fn muls3(comptime T: type, a: Vec3(T), b: T) Vec3(T) {
    return .{ .repr = a.repr * @Vector(3, T){ b, b, b } };
}

/// Multiplies a vector4 by a scalar
pub fn muls4(comptime T: type, a: Vec4(T), b: T) Vec4(T) {
    return .{ .repr = a.repr * @Vector(4, T){ b, b, b, b } };
}

/// Divides 2 vector2s together
pub fn div2(comptime T: type, a: Vec2(T), b: Vec2(T)) Vec2(T) {
    return .{ .repr = a.repr / b.repr };
}

/// Divides 2 vector3s together
pub fn div3(comptime T: type, a: Vec3(T), b: Vec3(T)) Vec3(T) {
    return .{ .repr = a.repr / b.repr };
}

/// Divides 2 vector4s together
pub fn div4(comptime T: type, a: Vec4(T), b: Vec4(T)) Vec4(T) {
    return .{ .repr = a.repr / b.repr };
}

/// Divides a vector2 by a scalar
pub fn divs2(comptime T: type, a: Vec2(T), b: T) Vec2(T) {
    return .{ .repr = a.repr / @Vector(2, T){ b, b } };
}

/// Divides a vector3 by a scalar
pub fn divs3(comptime T: type, a: Vec3(T), b: T) Vec3(T) {
    return .{ .repr = a.repr / @Vector(3, T){ b, b, b } };
}

/// Divides a vector4 by a scalar
pub fn divs4(comptime T: type, a: Vec4(T), b: T) Vec4(T) {
    return .{ .repr = a.repr / @Vector(4, T){ b, b, b, b } };
}

/// Gets the remainder of the division between 2 vector2s
pub fn mod2(comptime T: type, a: Vec2(T), b: Vec2(T)) Vec2(T) {
    return .{ .repr = a.repr % b.repr };
}

/// Gets the remainder of the division between 2 vector3s
pub fn mod3(comptime T: type, a: Vec3(T), b: Vec3(T)) Vec3(T) {
    return .{ .repr = a.repr % b.repr };
}

/// Gets the remainder of the division between 2 vector4s
pub fn mod4(comptime T: type, a: Vec4(T), b: Vec4(T)) Vec4(T) {
    return .{ .repr = a.repr % b.repr };
}

/// Gets the remainder of the division between a vector2 and a scalar
pub fn mods2(comptime T: type, a: Vec2(T), b: T) Vec2(T) {
    return .{ .repr = a.repr % @Vector(2, T){ b, b } };
}

/// Gets the remainder of the division between a vector3 and a scalar
pub fn mods3(comptime T: type, a: Vec3(T), b: T) Vec3(T) {
    return .{ .repr = a.repr / @Vector(3, T){ b, b, b } };
}

/// Gets the remainder of the division between a vector4 and a scalar
pub fn mods4(comptime T: type, a: Vec4(T), b: T) Vec4(T) {
    return .{ .repr = a.repr / @Vector(4, T){ b, b, b, b } };
}

/// Returns true if 2 vector2s are equal. Doesn't handle funky float stuff.
pub fn equal2(comptime T: type, a: Vec2(T), b: Vec2(T)) bool {
    const either_equal = a == b;
    return either_equal[0] and either_equal[1];
}

/// Returns true if 2 vector3s are equal. Doesn't handle funky float stuff.
pub fn equal3(comptime T: type, a: Vec3(T), b: Vec3(T)) bool {
    const either_equal = a == b;
    return either_equal[0] and either_equal[1] and either_equal[2];
}

/// Returns true if 2 vector4s are equal. Doesn't handle funky float stuff.
pub fn equal4(comptime T: type, a: Vec4(T), b: Vec4(T)) bool {
    const either_equal = a == b;
    return either_equal[0] and either_equal[1] and either_equal[2] and either_equal[3];
}

/// Returns true if 2 vector2s are equal. Doesn't handle funky float stuff.
pub fn notEqual2(comptime T: type, a: Vec2(T), b: Vec2(T)) bool {
    const either_nequal = a != b;
    return either_nequal[0] and either_nequal[1];
}

/// Returns true if 2 vector3s are equal. Doesn't handle funky float stuff.
pub fn notEqual3(comptime T: type, a: Vec3(T), b: Vec3(T)) bool {
    const either_nequal = a != b;
    return either_nequal[0] and either_nequal[1] and either_nequal[2];
}

/// Returns true if 2 vector4s are equal. Doesn't handle funky float stuff.
pub fn notEqual4(comptime T: type, a: Vec4(T), b: Vec4(T)) bool {
    const either_nequal = a != b;
    return either_nequal[0] and either_nequal[1] and either_nequal[2] and either_nequal[3];
}

// TODO test that (not doing that now :))))))))))) )

const VecComponents = enum { unused, x, y, z, w };

fn getSwizzleComps(comps: anytype) [4]VecComponents {
    const type_info = @typeInfo(@TypeOf(comps));
    if (type_info != .enum_literal) {
        @compileError("components must be an enum literal");
    }

    const comp_str = @tagName(comps);
    if (comp_str.len > 4) {
        @compileError("swizzle literal too long");
    }

    var components: [4]VecComponents = .{ .unused, .unused, .unused, .unused };
    inline for (comp_str, 0..comp_str.len) |comp, i| {
        components[i] = switch (comp) {
            'x', 'r' => .x,
            'y', 'g' => .y,
            'z', 'b' => .z,
            'w', 'a' => .w,
            else => @compileError("invalid swizzle literal"),
        };
    }
    return components;
}

fn TypeFromSwizzleLiteral(comptime T: type, comptime comps: anytype) type {
    const components = getSwizzleComps(comps);
    var component_count = 0;
    inline for (components) |comp| {
        if (comp == .unused) {
            break;
        }
        component_count += 1;
    }
    return VectorWithLen(component_count, T);
}

/// Implements vector swizzling through major amounts of tomfoolery. For example `.xy`, `.zxy`, `.zzzw`,
/// really any combination of xyzw that comes to mind. RGBA is also supported, for example `.abgr`.
pub fn swizzle(
    comptime T: type,
    src: anytype,
    comptime components: anytype,
) TypeFromSwizzleLiteral(T, components) {
    // TODO this parses the swizzle literal 3 times who gives a shit
    const comps = comptime getSwizzleComps(components);
    var dst: TypeFromSwizzleLiteral(T, components) = undefined;
    const len = lengthOfVector(@TypeOf(dst));

    inline for (comps, 0..comps.len) |comp, i| {
        if (i >= len) break;
        switch (comp) {
            .x => dst.repr[i] = src.repr[0],
            .y => dst.repr[i] = src.repr[1],
            .z => dst.repr[i] = src.repr[2],
            .w => dst.repr[i] = src.repr[3],
            .unused => break,
        }
    }

    return dst;
}

test "vec2 -> vec2 swizzle" {
    const v = vec2(i32, 1, 2);
    try testing.expectEqual(vec2(i32, 1, 2), swizzle(i32, v, .xy));
    try testing.expectEqual(vec2(i32, 2, 1), swizzle(i32, v, .yx));
    try testing.expectEqual(vec2(i32, 1, 1), swizzle(i32, v, .xx));
    try testing.expectEqual(vec2(i32, 2, 2), swizzle(i32, v, .yy));
}

test "vec2 -> vec3 swizzle" {
    const v = vec2(i32, 2, 3);
    try testing.expectEqual(vec3(i32, 3, 2, 2), swizzle(i32, v, .yxx));
    try testing.expectEqual(vec3(i32, 2, 3, 2), swizzle(i32, v, .xyx));
    try testing.expectEqual(vec3(i32, 3, 3, 2), swizzle(i32, v, .yyx));
}

test "vec3 -> vec2 swizzle" {
    const v = vec3(i32, 4, 5, 6);
    try testing.expectEqual(vec2(i32, 4, 5), swizzle(i32, v, .xy));
    try testing.expectEqual(vec2(i32, 6, 4), swizzle(i32, v, .zx));
    try testing.expectEqual(vec2(i32, 5, 5), swizzle(i32, v, .yy));
}

test "vec3 -> vec3 swizzle" {
    const v = vec3(i32, 7, 8, 9);
    try testing.expectEqual(vec3(i32, 7, 8, 9), swizzle(i32, v, .xyz));
    try testing.expectEqual(vec3(i32, 9, 8, 7), swizzle(i32, v, .zyx));
    try testing.expectEqual(vec3(i32, 8, 7, 8), swizzle(i32, v, .yxy));
}

test "vec3 -> vec4 swizzle" {
    const v = vec3(i32, 1, 2, 3);
    try testing.expectEqual(vec4(i32, 1, 2, 3, 1), swizzle(i32, v, .xyzx));
    try testing.expectEqual(vec4(i32, 3, 3, 2, 1), swizzle(i32, v, .zzyx));
}

test "vec4 swizzle" {
    const v = vec4(i32, 10, 20, 30, 40);
    try testing.expectEqual(
        vec4(i32, 10, 20, 30, 40),
        swizzle(i32, v, .xyzw),
    );
    try testing.expectEqual(
        vec4(i32, 40, 30, 20, 10),
        swizzle(i32, v, .wzyx),
    );
    try testing.expectEqual(
        vec3(i32, 20, 20, 40),
        swizzle(i32, v, .yyw),
    );
}

test "rgba swizzle" {
    const v = vec4(i32, 10, 20, 30, 40);
    try testing.expectEqual(
        vec4(i32, 40, 30, 20, 10),
        swizzle(i32, v, .abgr),
    );
}

/// Returns the length of a vector2
pub fn length2(comptime T: type, v: Vec2(T)) f32 {
    var vector: Vec2(T) = undefined;
    if (@typeInfo(T) == .float) {
        // might be an f64 or f16
        vector = floatVecCast(f32, v);
    } else if (@typeInfo(T) == .int) {
        vector = floatVecFromIntVec(f32, v);
    } else {
        @compileError("invalid type");
    }

    return @sqrt(v.x() * v.x() + v.y() * v.y());
}

/// Returns the length of a vector3
pub fn length3(comptime T: type, v: Vec3(T)) f32 {
    var vector: Vec3(T) = undefined;
    if (@typeInfo(T) == .float) {
        // might be an f64 or f16
        vector = floatVecCast(f32, v);
    } else if (@typeInfo(T) == .int) {
        vector = floatVecFromIntVec(f32, v);
    } else {
        @compileError("invalid type");
    }

    return @sqrt(v.x() * v.x() + v.y() * v.y() + v.z() * v.z());
}

/// Returns the length of a vector4
pub fn length4(comptime T: type, v: Vec4(T)) f32 {
    var vector: Vec4(T) = undefined;
    if (@typeInfo(T) == .float) {
        // might be an f64 or f16
        vector = floatVecCast(f32, v);
    } else if (@typeInfo(T) == .int) {
        vector = floatVecFromIntVec(f32, v);
    } else {
        @compileError("invalid type");
    }

    return @sqrt(v.x() * v.x() + v.y() * v.y() + v.z() * v.z() + v.w() * v.w());
}

/// Returns the distance between 2 vector2s
pub fn distance2(comptime T: type, a: Vec2(T), b: Vec2(T)) f32 {
    var veca: Vec2(T) = undefined;
    if (@typeInfo(T) == .float) {
        // might be an f64 or f16
        veca = floatVecCast(f32, a);
    } else if (@typeInfo(T) == .int) {
        veca = floatVecFromIntVec(f32, a);
    } else {
        @compileError("invalid type");
    }

    var vecb: Vec2(T) = undefined;
    if (@typeInfo(T) == .float) {
        // might be an f64 or f16
        vecb = floatVecCast(f32, b);
    } else if (@typeInfo(T) == .int) {
        vecb = floatVecFromIntVec(f32, b);
    } else {
        @compileError("invalid type");
    }

    const d = sub2(f32, veca, vecb);
    return length2(f32, d);
}

/// Returns the distance between 2 vector3s
pub fn distance3(comptime T: type, a: Vec3(T), b: Vec3(T)) f32 {
    var veca: Vec3(T) = undefined;
    if (@typeInfo(T) == .float) {
        // might be an f64 or f16
        veca = floatVecCast(f32, a);
    } else if (@typeInfo(T) == .int) {
        veca = floatVecFromIntVec(f32, a);
    } else {
        @compileError("invalid type");
    }

    var vecb: Vec3(T) = undefined;
    if (@typeInfo(T) == .float) {
        // might be an f64 or f16
        vecb = floatVecCast(f32, b);
    } else if (@typeInfo(T) == .int) {
        vecb = floatVecFromIntVec(f32, b);
    } else {
        @compileError("invalid type");
    }

    const d = sub3(f32, veca, vecb);
    return length3(f32, d);
}

/// Returns the distance between 2 vector4s
pub fn distance4(comptime T: type, a: Vec4(T), b: Vec4(T)) f32 {
    var veca: Vec4(T) = undefined;
    if (@typeInfo(T) == .float) {
        // might be an f64 or f16
        veca = floatVecCast(f32, a);
    } else if (@typeInfo(T) == .int) {
        veca = floatVecFromIntVec(f32, a);
    } else {
        @compileError("invalid type");
    }

    var vecb: Vec4(T) = undefined;
    if (@typeInfo(T) == .float) {
        // might be an f64 or f16
        vecb = floatVecCast(f32, b);
    } else if (@typeInfo(T) == .int) {
        vecb = floatVecFromIntVec(f32, b);
    } else {
        @compileError("invalid type");
    }

    const d = sub4(f32, veca, vecb);
    return length4(f32, d);
}

/// Returns the dot product of 2 vector2s
pub fn dot2(comptime T: type, a: Vec2(T), b: Vec2(T)) T {
    return a.x() * b.x() + a.y() * b.y();
}

/// Returns the dot product of 2 vector3s
pub fn dot3(comptime T: type, a: Vec3(T), b: Vec3(T)) T {
    return a.x() * b.x() + a.y() * b.y() + a.z() * b.z();
}

/// Returns the dot product of 2 vector4s
pub fn dot4(comptime T: type, a: Vec4(T), b: Vec4(T)) T {
    return a.x() * b.x() + a.y() * b.y() + a.z() * b.z() + a.w() * b.w();
}

/// Returns the cross product of 2 vector3s
pub fn cross3(comptime T: type, a: Vec3(T), b: Vec3(T)) Vec3(T) {
    return vec3(
        T,
        a.y() * b.z() - a.z() * b.y(),
        a.z() * b.x() - a.x() * b.z(),
        a.x() * b.y() - a.y() * b.x(),
    );
}

/// Normalizes a vector2
pub fn normalize2(comptime T: type, v: Vec2(T)) Vec2(f32) {
    var vec: Vec4(T) = undefined;
    if (@typeInfo(T) == .float) {
        // might be an f64 or f16
        vec = floatVecCast(f32, v);
    } else if (@typeInfo(T) == .int) {
        vec = floatVecFromIntVec(f32, v);
    } else {
        @compileError("invalid type");
    }

    const length = length2(f32, vec);
    // consider not dividing by 0
    if (length == 0.0) {
        return vec2(f32, 0, 0);
    }
    return divs2(f32, vec, length);
}

/// Normalizes a vector3
pub fn normalize3(comptime T: type, v: Vec3(T)) Vec3(f32) {
    var vec: Vec3(T) = undefined;
    if (@typeInfo(T) == .float) {
        // might be an f64 or f16
        vec = floatVecCast(f32, v);
    } else if (@typeInfo(T) == .int) {
        vec = floatVecFromIntVec(f32, v);
    } else {
        @compileError("invalid type");
    }

    const length = length3(f32, vec);
    // consider not dividing by 0
    if (length == 0.0) {
        return vec3(f32, 0, 0, 0);
    }
    return divs3(f32, vec, length);
}

/// Normalizes a vector4
pub fn normalize4(comptime T: type, v: Vec4(T)) Vec4(f32) {
    var vec: Vec4(T) = undefined;
    if (@typeInfo(T) == .float) {
        // might be an f64 or f16
        vec = floatVecCast(f32, v);
    } else if (@typeInfo(T) == .int) {
        vec = floatVecFromIntVec(f32, v);
    } else {
        @compileError("invalid type");
    }

    const length = length4(f32, vec);
    // consider not dividing by 0
    if (length == 0.0) {
        return vec4(f32, 0, 0, 0, 0);
    }
    return divs4(f32, vec, length);
}

/// A 4x4 column-major matrix of float32s.
pub const Mat4x4 = struct {
    repr: [4][4]f32,

    pub fn nth(mat: @This(), comptime col: comptime_int, comptime row: comptime_int) f32 {
        return mat.repr[col][row];
    }

    pub fn column(mat: @This(), comptime col: comptime_int) Vec4(f32) {
        return vec4(
            f32,
            mat.nth(col, 0),
            mat.nth(col, 1),
            mat.nth(col, 2),
            mat.nth(col, 3),
        );
    }
};

// TODO no idea if the compiler is optimizing this to use simd

pub fn zero4x4() Mat4x4 {
    return .{ .repr = [4][4]f32{
        [_]f32{ 0, 0, 0, 0 },
        [_]f32{ 0, 0, 0, 0 },
        [_]f32{ 0, 0, 0, 0 },
        [_]f32{ 0, 0, 0, 0 },
    } };
}

pub fn identity4x4() Mat4x4 {
    return .{ .repr = [4][4]f32{
        [_]f32{ 1, 0, 0, 0 },
        [_]f32{ 0, 1, 0, 0 },
        [_]f32{ 0, 0, 1, 0 },
        [_]f32{ 0, 0, 0, 1 },
    } };
}

pub fn add4x4(a: Mat4x4, b: Mat4x4) Mat4x4 {
    var result = zero4x4();
    result.repr[0] = add4(f32, a.column(0), b.column(0)).toArray();
    result.repr[1] = add4(f32, a.column(1), b.column(1)).toArray();
    result.repr[2] = add4(f32, a.column(2), b.column(2)).toArray();
    result.repr[3] = add4(f32, a.column(3), b.column(3)).toArray();
    return result;
}

pub fn sub4x4(a: Mat4x4, b: Mat4x4) Mat4x4 {
    var result = zero4x4();
    result.repr[0] = sub4(f32, a.column(0), b.column(0)).toArray();
    result.repr[1] = sub4(f32, a.column(1), b.column(1)).toArray();
    result.repr[2] = sub4(f32, a.column(2), b.column(2)).toArray();
    result.repr[3] = sub4(f32, a.column(3), b.column(3)).toArray();
    return result;
}

pub fn transpose4x4(m: Mat4x4) Mat4x4 {
    var result = zero4x4();
    for (0..4) |i| {
        for (0..4) |j| {
            result.repr[i][j] = m.repr[j][i];
        }
    }
    return m;
}

/// idk this is stolen
fn linearCombine(a: Vec4(f32), b: Mat4x4) Vec4(f32) {
    var result = vec4(f32, 0, 0, 0, 0);
    result.repr[0] = a.nth(0) * b.column(0).x();
    result.repr[1] = a.nth(0) * b.column(0).y();
    result.repr[2] = a.nth(0) * b.column(0).z();
    result.repr[3] = a.nth(0) * b.column(0).w();

    result.repr[0] += a.nth(1) * b.column(1).x();
    result.repr[1] += a.nth(1) * b.column(1).y();
    result.repr[2] += a.nth(1) * b.column(1).z();
    result.repr[3] += a.nth(1) * b.column(1).w();

    result.repr[0] += a.nth(2) * b.column(2).x();
    result.repr[1] += a.nth(2) * b.column(2).y();
    result.repr[2] += a.nth(2) * b.column(2).z();
    result.repr[3] += a.nth(2) * b.column(2).w();

    result.repr[0] += a.nth(3) * b.column(3).x();
    result.repr[1] += a.nth(3) * b.column(3).y();
    result.repr[2] += a.nth(3) * b.column(3).z();
    result.repr[3] += a.nth(3) * b.column(3).w();
    return result;
}

pub fn mul4x4(a: Mat4x4, b: Mat4x4) Mat4x4 {
    var result = zero4x4();
    result.repr[0] = linearCombine(b.column(0), a).toArray();
    result.repr[1] = linearCombine(b.column(1), a).toArray();
    result.repr[2] = linearCombine(b.column(2), a).toArray();
    result.repr[3] = linearCombine(b.column(3), a).toArray();
    return result;
}

pub fn muls4x4(m: Mat4x4, scalar: f32) Mat4x4 {
    var result = zero4x4();
    for (0..4) |i| {
        for (0..4) |j| {
            result.repr[i][j] = m.repr[i][j] * scalar;
        }
    }
    return m;
}

pub fn divs4x4(m: Mat4x4, scalar: f32) Mat4x4 {
    var result = zero4x4();
    for (0..4) |i| {
        for (0..4) |j| {
            result.repr[i][j] = m.repr[i][j] / scalar;
        }
    }
    return m;
}

pub fn mulv4x4(m: Mat4x4, v: Vec4(f32)) Vec4(f32) {
    return linearCombine(v, m);
}

pub fn determinant4x4(m: Mat4x4) f32 {
    const c01 = cross3(f32, swizzle(f32, m.column(0), .xyz), swizzle(f32, m.column(1), .xyz));
    const c23 = cross3(f32, swizzle(f32, m.column(2), .xyz), swizzle(f32, m.column(3), .xyz));
    const b10 = sub3(
        f32,
        muls3(f32, swizzle(f32, m.column(0), .xyz), m.column(1).w()),
        muls3(f32, swizzle(f32, m.column(1), .xyz), m.column(0).w()),
    );
    const b32 = sub3(
        f32,
        muls3(f32, swizzle(f32, m.column(2), .xyz), m.column(3).w()),
        muls3(f32, swizzle(f32, m.column(3), .xyz), m.column(2).w()),
    );
    return dot3(f32, c01, b32) + dot3(f32, c23, b10);
}

pub fn inv4x4(m: Mat4x4) Mat4x4 {
    var c01 = cross3(f32, swizzle(f32, m.column(0), .xyz), swizzle(f32, m.column(1), .xyz));
    var c23 = cross3(f32, swizzle(f32, m.column(2), .xyz), swizzle(f32, m.column(3), .xyz));
    var b10 = sub3(
        f32,
        muls3(f32, swizzle(f32, m.column(0), .xyz), m.column(1).w()),
        muls3(f32, swizzle(f32, m.column(1), .xyz), m.column(0).w()),
    );
    var b32 = sub3(
        f32,
        muls3(f32, swizzle(f32, m.column(2), .xyz), m.column(3).w()),
        muls3(f32, swizzle(f32, m.column(3), .xyz), m.column(2).w()),
    );

    const inv_determinant = 1.0 / (dot3(f32, c01, b32) + dot3(f32, c23, b10));
    c01 = muls3(f32, c01, inv_determinant);
    c23 = muls3(f32, c23, inv_determinant);
    b10 = muls3(f32, b10, inv_determinant);
    b32 = muls3(f32, b32, inv_determinant);

    // helper to more easily steal from handmade math
    const v4v = struct {
        pub fn v4v(a: Vec3(f32), b: f32) Vec4(f32) {
            return vec4(f32, a.x(), a.y(), a.z(), b);
        }
    }.v4v;

    var result = zero4x4();
    // quite the mouthful
    result.repr[0] = v4v(
        add3(f32, cross3(f32, swizzle(f32, m.column(1), .xyz), b32), muls3(f32, c23, m.column(1).w())),
        -dot3(f32, swizzle(f32, m.column(1), .xyz), c23),
    ).toArray();
    result.repr[1] = v4v(
        sub3(f32, cross3(f32, swizzle(f32, m.column(0), .xyz), b32), muls3(f32, c23, m.column(0).w())),
        dot3(f32, swizzle(f32, m.column(0), .xyz), c23),
    ).toArray();
    result.repr[2] = v4v(
        add3(f32, cross3(f32, swizzle(f32, m.column(3), .xyz), b10), muls3(f32, c01, m.column(3).w())),
        -dot3(f32, swizzle(f32, m.column(3), .xyz), c01),
    ).toArray();
    result.repr[3] = v4v(
        sub3(f32, cross3(f32, swizzle(f32, m.column(2), .xyz), b10), muls3(f32, c01, m.column(2).w())),
        dot3(f32, swizzle(f32, m.column(2), .xyz), c01),
    ).toArray();
    return transpose4x4(result);
}

/// Returns a right-handed orthographic projection matrix with Z ranging from -1 to 1 (the OpenGL
/// convention). `left`, `right`, `bottom`, and `top` specify the coordinates of their respective
/// clipping planes. `near` and `far` specify the distances to the near and far clipping planes.
pub fn orthographic4x4(left: f32, right: f32, bottom: f32, top: f32, near: f32, far: f32) Mat4x4 {
    var result = zero4x4();
    result.repr[0][0] = 2.0 / (right - left);
    result.repr[1][1] = 2.0 / (top - bottom);
    result.repr[2][2] = 2.0 / (near - far);
    result.repr[3][3] = 1.0;

    result.repr[3][0] = (left + right) / (left - right);
    result.repr[3][1] = (bottom + top) / (bottom - top);
    result.repr[3][2] = (near + far) / (near - far);
    return result;
}

/// Returns a right-handed perspective projection matrix with Z ranging from -1 to 1 (the OpenGL
/// convention). `fov` is in radians. `aspect_ratio` is the width divided by the height of where
/// you're rendering things to. `near` and `far` specify the distances to the near and far
/// clipping planes.
pub fn perspective4x4(fov: f32, aspect_ratio: f32, near: f32, far: f32) Mat4x4 {
    var result = zero4x4();
    const cotangent = 1.0 / @tan(fov / 2.0);
    result.repr[0][0] = cotangent / aspect_ratio;
    result.repr[1][1] = cotangent;
    result.repr[2][3] = -1.0;

    result.repr[2][2] = (near + far) / (near - far);
    result.repr[3][2] = (2.0 * near * far) / (near - far);
    return result;
}

pub fn translation4x4(pos: Vec3(f32)) Mat4x4 {
    var result = identity4x4();
    result.repr[3][0] = pos.x();
    result.repr[3][1] = pos.y();
    result.repr[3][2] = pos.z();
    return result;
}

pub fn rotatex4x4(m: Mat4x4, rad: f32) Mat4x4 {
    const s = @sin(rad);
    const c = @cos(rad);
    var r = zero4x4();
    r.repr[0] = [4]f32{ 1, 0, 0, 0 };
    r.repr[1] = [4]f32{ 0, c, s, 0 };
    r.repr[2] = [4]f32{ 0, -s, c, 0 };
    r.repr[3] = [4]f32{ 0, 0, 0, 1 };
    return mul4x4(m, r);
}

pub fn rotatey4x4(m: Mat4x4, rad: f32) Mat4x4 {
    const s = @sin(rad);
    const c = @cos(rad);
    var r = zero4x4();
    r.repr[0] = [4]f32{ c, 0, -s, 0 };
    r.repr[1] = [4]f32{ 0, 1, 0, 0 };
    r.repr[2] = [4]f32{ s, 0, c, 0 };
    r.repr[3] = [4]f32{ 0, 0, 0, 1 };
    return mul4x4(m, r);
}

pub fn rotatez4x4(m: Mat4x4, rad: f32) Mat4x4 {
    const s = @sin(rad);
    const c = @cos(rad);
    var r = zero4x4();
    r.repr[0] = [4]f32{ c, s, 0, 0 };
    r.repr[1] = [4]f32{ -s, c, 0, 0 };
    r.repr[2] = [4]f32{ 0, 0, 1, 0 };
    r.repr[3] = [4]f32{ 0, 0, 0, 1 };
    return mul4x4(m, r);
}
