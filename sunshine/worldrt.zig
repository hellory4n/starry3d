//! Blazingly fast next-gen voxel storage for CPU usage that will touch you in places. The 'rt'
//! is runtime, not raytracing. If it was raytracing I'd just call it "raytracing".
//!
//! If you're interested in the inner details just read this post except it's slightly outdated
//! because I changed some of the naming and props aren't whatever bytes you want anymore
//! because that's questionable now it's only 32 bit ints or floats or whatever the fuck fits
//! in 32 bits
//! https://hellory4n.substack.com/p/the-grand-voxel-world-runtime
//!
//! All coordinates are right handed (+Y up, -Z forward) and in individual voxel resolution
//!
//! This currently doesn't support streaming or chunking, it assumes the whole world fits
//! in memory. But can you trust that in this economy?
//!
//! Also don't use this directly for rendering. It'll run like shit.

const std = @import("std");
const testing = std.testing;
const zglm = @import("zglm");

pub const Tag = u16;
/// Color is pretty important for voxels so it gets the so very special 0 index
pub const tag_color = 0;

const brick_size = 8;
const brick_size_vec = @as(zglm.Vec3i, @splat(brick_size));
const brick_size_vecu = @as(zglm.Vec3iu, @splat(brick_size));

/// Voxel props are stored in an SoA for Fast, limited to 32 bits for Fast and Small
const Brick = struct {
    pub const PropList = struct {
        tag: Tag,
        data: [brick_size][brick_size][brick_size]u32,
    };

    solid: [brick_size][brick_size][brick_size]bool = @splat(@splat(@splat(false))),
    data: std.ArrayList(PropList) = .empty,
};

/// Takes a color (or other prop) (null if the voxel is empty) + a position, and returns
/// a new color (or other prop), or, returns null to remove the voxel. Basically a
/// shader but for voxels. Optionally the caller can pass a 64 bit parameter (plenty of
/// space for bit fucking), or 0 if it's not passed in
pub const Brush = fn (pos: zglm.Vec3i, src: ?u32, params: u64) callconv(.@"inline") ?u32;

/// Like null but for brush parameters
pub const nullparams = 0;

fn checkParams(comptime T: type) void {
    switch (@typeInfo(T)) {
        .@"struct" => |s| {
            if (s.layout != .@"packed") {
                @compileError("struct must be packed");
            }

            if (s.backing_integer.? != u64 and s.backing_integer.? != i64) {
                @compileError("struct must be 64 bits");
            }
        },

        // this is just so null works
        .comptime_int => {},

        else => @compileError("type '" ++ @typeName(T) ++ "' can't be used as brush parameters"),
    }
}

pub const InitError = std.mem.Allocator.Error || error{WorldTooLarge};
pub const EditError = std.mem.Allocator.Error || error{OutOfBounds};

/// The basic world runtime, from which chunking and streaming can be implemented on top of.
/// Or something.
pub const World = struct {
    bricks: []?*Brick, // nullable so it can be lazily allocated
    start: zglm.Vec3i,
    end: zglm.Vec3i,
    size: zglm.Vec3iu,
    // TODO using an arena means it naturally gets less efficient the longer it's used
    // it's like entropy but shit
    arena: std.heap.ArenaAllocator,

    /// start and end are the top left and bottom right corners of the world, respectively
    pub fn init(allocator: std.mem.Allocator, start: zglm.Vec3i, end: zglm.Vec3i) InitError!World {
        var arena = std.heap.ArenaAllocator.init(allocator);
        const arena_alloc = arena.allocator();

        var size = @abs(start) + @abs(end);
        // signed-unsigned conversions break at that point
        if (zglm.any(size >= @as(zglm.Vec3iu, @splat(zglm.maxInt(i32))))) {
            return InitError.WorldTooLarge;
        }

        // some padding so simd stuff doesn't have to check for bounds
        if (zglm.any(size % brick_size_vecu != zglm.Vec3iu{ 0, 0, 0 })) {
            size += brick_size_vecu;
        }
        const bricks = try arena_alloc.alloc(?*Brick, size[0] * size[1] * size[2]);
        for (bricks) |*brick| {
            brick.* = null;
        }

        return .{
            .arena = arena,
            .bricks = bricks,
            .size = size,
            .start = start,
            .end = end,
        };
    }

    pub fn deinit(world: *World) void {
        world.arena.deinit();
    }

    fn getBrick(world: *const World, pos: zglm.Vec3i) ?*Brick {
        const upos = pos + @as(zglm.Vec3i, @intCast(@abs(world.start)));
        const bpos: zglm.Vec3iu = @intCast(upos / brick_size_vec);
        const idx = bpos[0] * (world.size[1] * world.size[2]) + bpos[1] * world.size[2] + bpos[2];
        return world.bricks[idx];
    }

    fn getBrickPtr(world: *const World, pos: zglm.Vec3i) *?*Brick {
        const upos = pos + @as(zglm.Vec3i, @intCast(@abs(world.start)));
        const bpos: zglm.Vec3iu = @intCast(upos / brick_size_vec);
        const idx = bpos[0] * (world.size[1] * world.size[2]) + bpos[1] * world.size[2] + bpos[2];
        return &world.bricks[idx];
    }

    /// Returns a prop from a voxel at a specified position. The returned data may be interpreted any way you'd like (through `@bitCast`) as long as it fits in 32 bits.
    pub fn getVoxelProp(world: *const World, pos: zglm.Vec3i, tag: Tag) OptionalProp {
        if (world.isOutOfBounds(pos)) {
            return .out_of_bounds;
        }
        const brick = world.getBrick(pos);
        if (brick == null) {
            return .empty;
        }
        const voxel_idx: zglm.Vec3iu = @intCast(@mod(pos, brick_size_vec));

        if (!brick.?.solid[voxel_idx[0]][voxel_idx[1]][voxel_idx[2]]) {
            return .empty;
        }

        // hashing is overkill here i think tbh ong icl fr
        for (brick.?.data.items) |list| {
            if (list.tag == tag) {
                return .{ .exists = list.data[voxel_idx[0]][voxel_idx[1]][voxel_idx[2]] };
            }
        }
        return .no_such_prop;
    }

    /// Note this returns false if the voxel is out of bounds. If you need to check that,
    /// use `isOutOfBounds`. It also returns true (solid) even if the voxel has no color prop,
    /// which shouldn't matter unless you're doing something weird.
    pub fn isVoxelSolid(world: *const World, pos: zglm.Vec3i) bool {
        if (world.isOutOfBounds(pos)) {
            return false;
        }
        const brick = world.getBrick(pos);
        if (brick == null) {
            return false;
        }

        const voxel_idx: zglm.Vec3iu = @intCast(@mod(pos, brick_size_vec));
        return brick.?.solid[voxel_idx[0]][voxel_idx[1]][voxel_idx[2]];
    }

    pub fn isOutOfBounds(world: *const World, pos: zglm.Vec3i) bool {
        return zglm.any(pos < world.start) or zglm.any(pos > world.end);
    }

    pub fn area(world: *const World) zglm.Vec3i {
        return @intCast(world.size);
    }

    /// Sets a prop for a voxel, and places it in the world if it's not there yet.
    pub fn setVoxelProp(world: *World, pos: zglm.Vec3i, tag: Tag, val: u32) EditError!void {
        if (world.isOutOfBounds(pos)) {
            return EditError.OutOfBounds;
        }
        var brick = world.getBrick(pos);
        if (brick == null) {
            brick = try world.arena.allocator().create(Brick);
            brick.?.* = .{};
            world.getBrickPtr(pos).* = brick;
        }
        const voxel_idx: zglm.Vec3iu = @intCast(@mod(pos, brick_size_vec));

        brick.?.solid[voxel_idx[0]][voxel_idx[1]][voxel_idx[2]] = true;

        // hashing is overkill here i think tbh ong icl fr
        for (brick.?.data.items) |*list| {
            if (list.tag == tag) {
                list.data[voxel_idx[0]][voxel_idx[1]][voxel_idx[2]] = val;
            }
        }

        // no list, add one
        // this also means that bricks only store the props they use(d), which is nice
        const alloc = world.arena.allocator();
        // i think appending just 1 item instead of doubling capacity (like an array list
        // usually does) is fine since adding new tags is relatively rare and it saves up
        // space except it's an arena fuck shit
        try brick.?.data.append(alloc, .{
            .tag = tag,
            .data = @splat(@splat(@splat(0))),
        });

        const list = &brick.?.data.items[brick.?.data.items.len - 1];
        list.data[voxel_idx[0]][voxel_idx[1]][voxel_idx[2]] = val;
    }

    /// Brutally murders the voxel in cold blood. Poor voxel.
    pub fn removeVoxel(world: *World, pos: zglm.Vec3i) EditError!void {
        if (world.isOutOfBounds(pos)) {
            return EditError.OutOfBounds;
        }
        const brick = world.getBrick(pos);
        if (brick == null) {
            return;
        }

        const voxel_idx: zglm.Vec3iu = @intCast(@mod(pos, brick_size_vec));
        brick.?.solid[voxel_idx[0]][voxel_idx[1]][voxel_idx[2]] = false;
    }

    // /// Fills a cubic area with a brush. `brush` must be an inline function. `brush_params`
    // /// must either be a packed struct of 64 bits, or `nullparams` (for when the brush doesn't
    // /// take in parameters)
    // pub fn fill(
    //     world: *World,
    //     start: zglm.Vec3i,
    //     end: zglm.Vec3i,
    //     tag: Tag,
    //     brush: *const Brush,
    //     brush_params: anytype,
    // ) !void {
    //     checkParams(@TypeOf(brush_params));
    //     const params: u64 = @bitCast(brush_params);

    //     var fill_thingy = FillThingy{};
    //     try fill_thingy.run(world, start, end, brush, params);
    // }
};

/// null isn't enough
pub const OptionalProp = union(enum) {
    exists: u32,
    no_such_prop,
    empty,
    out_of_bounds,

    /// Literally just `nullable orelse whatever` but with this custom union which has several types of null
    pub fn orElse(optprop: OptionalProp, altval: u32) u32 {
        return switch (optprop) {
            .exists => |val| val,
            else => altval,
        };
    }
};

test "get/set/remove voxels and props" {
    var world = try World.init(testing.allocator, .{ -512, -64, -512 }, .{ 512, 64, 512 });
    defer world.deinit();

    var colorof = world.getVoxelProp(.{ 1, 2, 3 }, tag_color);
    try testing.expectEqual(.empty, colorof);
    try testing.expect(!world.isVoxelSolid(.{ 1, 2, 3 }));

    const mystery_tag = 61;
    try world.setVoxelProp(.{ 1, 2, 3 }, mystery_tag, 76816425);
    try testing.expect(!world.isOutOfBounds(.{ 1, 2, 3 }));
    try testing.expect(world.isVoxelSolid(.{ 1, 2, 3 }));

    colorof = world.getVoxelProp(.{ 1, 2, 3 }, tag_color);
    try testing.expectEqual(.no_such_prop, colorof);

    try world.removeVoxel(.{ 1, 2, 3 });
    colorof = world.getVoxelProp(.{ 1, 2, 3 }, tag_color);
    try testing.expectEqual(.empty, colorof);

    try world.setVoxelProp(.{ 1, 2, 3 }, tag_color, 0xff0000ff);
    colorof = world.getVoxelProp(.{ 1, 2, 3 }, tag_color);
    try testing.expectEqual(OptionalProp{ .exists = 0xff0000ff }, colorof);

    colorof = world.getVoxelProp(.{ -1, -2, -3 }, tag_color);
    try testing.expectEqual(.empty, colorof);

    try world.setVoxelProp(.{ -1, -2, -3 }, tag_color, 0x00ff00ff);
    colorof = world.getVoxelProp(.{ -1, -2, -3 }, tag_color);
    try testing.expectEqual(OptionalProp{ .exists = 0x00ff00ff }, colorof);

    colorof = world.getVoxelProp(.{ 1, 2, 3 }, tag_color);
    try testing.expectEqual(OptionalProp{ .exists = 0xff0000ff }, colorof);

    try world.setVoxelProp(.{ 1, 2, 4 }, tag_color, 0x0000ffff);
    colorof = world.getVoxelProp(.{ 1, 2, 4 }, tag_color);
    try testing.expectEqual(OptionalProp{ .exists = 0x0000ffff }, colorof);
}
