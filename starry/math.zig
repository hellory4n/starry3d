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
    return comptime VectorWithLen(vec_info.len, vec_info.child);
}

fn ChildTypeOfVector(comptime T: type) type {
    const vec_info = vecInfo(T);
    return vec_info.child;
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

/// Adds 2 vectors together
pub fn add(a: anytype, b: anytype) @TypeOf(a) {
    if (@TypeOf(a) != @TypeOf(b)) {
        @compileError("vector types must be the same");
    }

    var result: @TypeOf(a) = undefined;
    inline for (0..lengthOfVector(@TypeOf(a))) |i| {
        result.setNth(i, a.nth(i) + b.nth(i));
    }
    return result;
}

/// Subtracts 2 vectors together
pub fn sub(a: anytype, b: anytype) @TypeOf(a) {
    if (@TypeOf(a) != @TypeOf(b)) {
        @compileError("vector types must be the same");
    }

    var result: @TypeOf(a) = undefined;
    inline for (0..lengthOfVector(@TypeOf(a))) |i| {
        result.setNth(i, a.nth(i) - b.nth(i));
    }
    return result;
}

/// Multiplies 2 vectors together
pub fn mul(a: anytype, b: anytype) @TypeOf(a) {
    if (@TypeOf(a) != @TypeOf(b)) {
        @compileError("vector types must be the same");
    }

    var result: @TypeOf(a) = undefined;
    inline for (0..lengthOfVector(@TypeOf(a))) |i| {
        result.setNth(i, a.nth(i) * b.nth(i));
    }
    return result;
}

/// Multiplies a vector by a scalar. `a` *must* be a vector.
pub fn muls(a: anytype, b: anytype) @TypeOf(a) {
    if (ChildTypeOfVector(@TypeOf(a)) != @TypeOf(b)) {
        @compileError("vector types must be the same");
    }

    var result: @TypeOf(a) = undefined;
    inline for (0..lengthOfVector(@TypeOf(a))) |i| {
        result.setNth(i, a.nth(i) * b);
    }
    return result;
}

/// Divides 2 vectors together. Does *not* handle division by zero.
pub fn div(a: anytype, b: anytype) @TypeOf(a) {
    if (@TypeOf(a) != @TypeOf(b)) {
        @compileError("vector types must be the same");
    }

    var result: @TypeOf(a) = undefined;
    inline for (0..lengthOfVector(@TypeOf(a))) |i| {
        result.setNth(i, a.nth(i) / b.nth(i));
    }
    return result;
}

/// Divides a vector by a scalar. `a` *must* be a vector. Does *not* handle division by zero.
pub fn divs(a: anytype, b: anytype) @TypeOf(a) {
    if (ChildTypeOfVector(@TypeOf(a)) != @TypeOf(b)) {
        @compileError("vector types must be the same");
    }

    var result: @TypeOf(a) = undefined;
    inline for (0..lengthOfVector(@TypeOf(a))) |i| {
        result.setNth(i, a.nth(i) / b);
    }
    return result;
}

/// Gets the remainder of dividing 2 vectors together. Does *not* handle division by zero.
pub fn mod(a: anytype, b: anytype) @TypeOf(a) {
    if (@TypeOf(a) != @TypeOf(b)) {
        @compileError("vector types must be the same");
    }

    var result: @TypeOf(a) = undefined;
    inline for (0..lengthOfVector(@TypeOf(a))) |i| {
        result.setNth(i, a.nth(i) % b.nth(i));
    }
    return result;
}

/// Gets the remainder of diving a vector by a scalar. `a` *must* be a vector. Does *not* handle
/// division by zero.
pub fn mods(a: anytype, b: anytype) @TypeOf(a) {
    if (ChildTypeOfVector(@TypeOf(a)) != @TypeOf(b)) {
        @compileError("vector types must be the same");
    }

    var result: @TypeOf(a) = undefined;
    inline for (0..lengthOfVector(@TypeOf(a))) |i| {
        result.setNth(i, a.nth(i) % b);
    }
    return result;
}

test "add vectors" {
    const a = vec2(i32, 1, 2);
    const b = vec2(i32, 2, 4);
    try testing.expectEqual(vec2(i32, 3, 6), add(a, b));

    const c = vec3(u64, 1, 2, 3);
    const d = vec3(u64, 2, 4, 6);
    try testing.expectEqual(vec3(u64, 3, 6, 9), add(c, d));

    try testing.expectEqual(vec2(i32, 3, 6), muls(a, @as(i32, 3)));

    // TODO test the rest probably
}

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
