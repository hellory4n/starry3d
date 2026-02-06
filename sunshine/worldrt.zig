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
//! This currently doesn't support streaming, it assumes the whole world fits in memory.
//! But can you trust that in this economy?
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
const region_size = 8;
const region_size_vec = @as(zglm.Vec3i, @splat(region_size));

/// Voxel props are stored in an SoA for Fast, limited to 32 bits for Fast and Small
const Brick = struct {
    pub const PropList = struct {
        tag: Tag,
        data: [brick_size][brick_size][brick_size]u32,
    };

    solid: [brick_size][brick_size][brick_size]bool = @splat(@splat(@splat(false))),
    data: std.ArrayList(PropList) = .empty,
};

/// Allocates bricks together for Fast and data-oriented Dee Oh Dee design (fast)
const Region = struct {
    arena: std.heap.ArenaAllocator,
    bricks: [region_size][region_size][region_size]Brick = @splat(@splat(@splat(.{}))),

    pub fn init(allocator: std.mem.Allocator) Region {
        return .{
            .arena = std.heap.ArenaAllocator.init(allocator),
        };
    }

    pub fn deinit(region: *Region) void {
        region.arena.deinit();
    }
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

// TODO
// - fill brush (use a packed struct for the params)
// - World.fill(brush: *const Brush, params: anytype) void
//      - work in groups of 8, then discard the areas out of bounds

/// The titular world runtime
pub const World = struct {
    regions: std.AutoHashMap(zglm.Vec3i, *Region),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !World {
        return .{
            .allocator = allocator,
            .regions = .init(allocator),
        };
    }

    pub fn deinit(world: *World) void {
        var iter = world.regions.valueIterator();
        while (iter.next()) |region| {
            region.*.deinit();
            world.allocator.destroy(region.*);
        }
        world.regions.deinit();
    }

    /// Returns a prop from a voxel at a specified position. The returned data may be interpreted any way you'd like (through `@bitCast`) as long as it fits in 32 bits.
    pub fn getVoxelProp(world: *const World, pos: zglm.Vec3i, tag: Tag) OptionalProp {
        const region_idx = @divFloor(pos, region_size_vec);

        const region = world.regions.get(region_idx);
        if (region == null) {
            return .unloaded;
        }

        const brick_idx: zglm.Vec3iu = @intCast(@mod(pos, region_size_vec));
        const brick = region.?.bricks[brick_idx[0]][brick_idx[1]][brick_idx[2]];

        const voxel_idx: zglm.Vec3iu = @intCast(@mod(pos, brick_size_vec));
        if (!brick.solid[voxel_idx[0]][voxel_idx[1]][voxel_idx[2]]) {
            return .empty;
        }

        // hashing is overkill here i think tbh ong icl fr
        for (brick.data.items) |list| {
            if (list.tag == tag) {
                return .{ .exists = list.data[voxel_idx[0]][voxel_idx[1]][voxel_idx[2]] };
            }
        }
        return .no_such_prop;
    }

    /// Note this returns false if the voxel is unloaded/out of bounds. If you need to check that,
    /// use `isVoxelLoaded`. It also returns true if the voxel has no color prop, which shouldn't
    /// matter unless you're doing something weird.
    pub fn isVoxelSolid(world: *const World, pos: zglm.Vec3i) bool {
        const region_idx = @divFloor(pos, region_size_vec);

        const region = world.regions.get(region_idx);
        if (region == null) {
            return false;
        }

        const brick_idx: zglm.Vec3iu = @intCast(@mod(pos, region_size_vec));
        const brick = region.?.bricks[brick_idx[0]][brick_idx[1]][brick_idx[2]];

        const voxel_idx: zglm.Vec3iu = @intCast(@mod(pos, brick_size_vec));
        return brick.solid[voxel_idx[0]][voxel_idx[1]][voxel_idx[2]];
    }

    /// Note this returns true if the voxel is empty. If you need to check that,
    /// use `isVoxelSolid`.
    pub fn isVoxelLoaded(world: *const World, pos: zglm.Vec3i) bool {
        const region_idx = @divFloor(pos, region_size_vec);

        const region = world.regions.get(region_idx);
        return region != null;
    }

    /// Sets a prop for a voxel, and places it in the world if it's not there yet.
    pub fn setVoxelProp(world: *World, pos: zglm.Vec3i, tag: Tag, val: u32) !void {
        const region_idx = @divFloor(pos, region_size_vec);

        var region = world.regions.get(region_idx);
        if (region == null) {
            region = try world.allocator.create(Region);
            region.?.* = Region.init(world.allocator);
            try world.regions.put(region_idx, region.?);
        }

        const brick_idx: zglm.Vec3i = @intCast(@mod(pos, region_size_vec));
        const brick = &region.?.bricks[brick_idx[0]][brick_idx[1]][brick_idx[2]];

        const voxel_idx: zglm.Vec3iu = @intCast(@mod(pos, brick_size_vec));
        brick.solid[voxel_idx[0]][voxel_idx[1]][voxel_idx[2]] = true;

        // hashing is overkill here i think tbh ong icl fr
        for (brick.data.items) |*list| {
            if (list.tag == tag) {
                list.data[voxel_idx[0]][voxel_idx[1]][voxel_idx[2]] = val;
            }
        }

        // no list, add one
        // this also means that bricks only store the props they use(d), which is nice
        const alloc = region.?.arena.allocator();
        // i think appending just 1 item instead of doubling capacity (like an array list usually does)
        // is fine since adding new tags is relatively rare and it saves up space except it's an arena
        // fuck shit
        try brick.data.append(alloc, .{
            .tag = tag,
            .data = @splat(@splat(@splat(0))),
        });

        const list = &brick.data.items[brick.data.items.len - 1];
        list.data[voxel_idx[0]][voxel_idx[1]][voxel_idx[2]] = val;
    }

    /// Brutally murders the voxel in cold blood. Poor voxel.
    pub fn removeVoxel(world: *World, pos: zglm.Vec3i) void {
        const region_idx = @divFloor(pos, region_size_vec);

        const region = world.regions.get(region_idx);
        if (region == null) {
            return;
        }

        const brick_idx: zglm.Vec3iu = @intCast(@mod(pos, region_size_vec));
        const brick = &region.?.bricks[brick_idx[0]][brick_idx[1]][brick_idx[2]];

        const voxel_idx: zglm.Vec3iu = @intCast(@mod(pos, brick_size_vec));
        brick.solid[voxel_idx[0]][voxel_idx[1]][voxel_idx[2]] = false;
    }

    /// Fills a cubic area with a brush. `brush` must be an inline function. `brush_params`
    /// must either be a packed struct of 64 bits, or `nullparams` (for when the brush doesn't
    /// take in parameters)
    pub fn fill(
        world: *World,
        start: zglm.Vec3i,
        end: zglm.Vec3i,
        brush: *const Brush,
        brush_params: anytype,
    ) !void {
        checkParams(@TypeOf(brush_params));
        const params: u64 = @bitCast(brush_params);

        var fill_thingy = FillThingy{};
        try fill_thingy.run(world, start, end, brush, params);
    }
};

/// null isn't enough
pub const OptionalProp = union(enum) {
    exists: u32,
    no_such_prop,
    empty,
    unloaded,

    /// Literally just `nullable orelse whatever` but with this custom union which has several types of null
    pub fn orElse(optprop: OptionalProp, altval: u32) u32 {
        return switch (optprop) {
            .exists => |val| val,
            else => altval,
        };
    }
};

/// tricky stuff
const FillThingy = struct {
    // TODO there's probably a way to have to fetch this less times but idk
    region: *Region = undefined,
    region_idx: zglm.Vec3i = undefined,

    pub fn run(
        fill: *FillThingy,
        world: *World,
        start: zglm.Vec3i,
        end: zglm.Vec3i,
        brush: *const Brush,
        brush_params: u64,
    ) !void {}

    fn forEachBrick(fill: *FillThingy, world: *World, pos: zglm.Vec3i) !void {
        const this_region_idx = @divFloor(pos, region_size_vec);
        if (this_region_idx != fill.region_idx) {
            fill.region_idx = this_region_idx;
            fill.region = world.regions.get(fill.region_idx);
            if (fill.region == null) {
                fill.region = try world.allocator.create(Region);
                fill.region.?.* = Region.init(world.allocator);
                try world.regions.put(fill.region_idx, fill.region.?);
            }
        }
    }
};

test "get/set/remove voxels and props" {
    var world = try World.init(testing.allocator);
    defer world.deinit();

    var colorof = world.getVoxelProp(.{ 1, 2, 3 }, tag_color);
    try testing.expectEqual(.unloaded, colorof);

    const mystery_tag = 61;
    try world.setVoxelProp(.{ 1, 2, 3 }, mystery_tag, 76816425);
    try testing.expect(world.isVoxelLoaded(.{ 1, 2, 3 }));
    try testing.expect(world.isVoxelSolid(.{ 1, 2, 3 }));

    colorof = world.getVoxelProp(.{ 1, 2, 3 }, tag_color);
    try testing.expectEqual(.no_such_prop, colorof);

    world.removeVoxel(.{ 1, 2, 3 });
    colorof = world.getVoxelProp(.{ 1, 2, 3 }, tag_color);
    try testing.expectEqual(.empty, colorof);

    try world.setVoxelProp(.{ 1, 2, 3 }, tag_color, 0xff0000ff);
    colorof = world.getVoxelProp(.{ 1, 2, 3 }, tag_color);
    try testing.expectEqual(OptionalProp{ .exists = 0xff0000ff }, colorof);

    colorof = world.getVoxelProp(.{ -1, -2, -3 }, tag_color);
    try testing.expectEqual(.unloaded, colorof);

    // since it's negative it has to make a new region since that's how math works
    try world.setVoxelProp(.{ -1, -2, -3 }, tag_color, 0x00ff00ff);
    colorof = world.getVoxelProp(.{ -1, -2, -3 }, tag_color);
    try testing.expectEqual(OptionalProp{ .exists = 0x00ff00ff }, colorof);

    // sanity check
    colorof = world.getVoxelProp(.{ 1, 2, 3 }, tag_color);
    try testing.expectEqual(OptionalProp{ .exists = 0xff0000ff }, colorof);

    // another sanity check
    try world.setVoxelProp(.{ 1, 2, 4 }, tag_color, 0x0000ffff);
    colorof = world.getVoxelProp(.{ 1, 2, 4 }, tag_color);
    try testing.expectEqual(OptionalProp{ .exists = 0x0000ffff }, colorof);
}
