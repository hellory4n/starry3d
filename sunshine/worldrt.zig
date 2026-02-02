//! Blazingly fast next-gen voxel storage for CPU usage that will touch you in places. The 'rt'
//! is runtime, not raytracing. If it was raytracing I'd just call it "raytracing".
//!
//! If you're interested in the inner details just read this post except it's slightly outdated
//! because I changed some of the naming and props aren't whatever bytes you want anymore
//! because that's questionable since Zig doesn't have a stable ABI unless you use the C ABI
//! which is kinda dogwater to use with Zig also other languages exist and they have their own
//! ABI fuckery just read the post
//! https://hellory4n.substack.com/p/the-grand-voxel-world-runtime
//!
//! All coordinates are right handed (+Y up, -Z forward) and in individual voxel resolution
//!
//! This currently doesn't support streaming, it assumes the whole world fits in memory.
//! But can you trust that in this economy?
//!
//! Also don't use this directly for rendering. It'll run like shit.

const std = @import("std");

/// The runtime in question. This is also how you interact with anything in the world.
pub const World = struct {
    regions: std.AutoHashMap(@Vector(3, i32), *Region),
    prop_tags: std.AutoHashMap(Tag, PropSettings),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !World {
        return .{
            .regions = try .init(allocator),
            .prop_tags = try .init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(world: *World) void {
        world.regions.deinit();
        world.prop_tags.deinit();
    }

    /// Adds a new type of prop so that you can prop all over the place
    pub fn addPropTag(
        world: *World,
        settings: PropSettings,
        /// you probably want .keep_old_version unless you're doing something weird
        if_already_exists: enum { always_overwrite, keep_old },
    ) !void {
        switch (if_already_exists) {
            .always_overwrite => world.prop_tags.put(settings.tag, settings),
            .keep_old => {
                const exists = world.prop_tags.get(settings.tag) == null;
                if (exists) {
                    world.prop_tags.put(settings.tag, settings);
                }
            },
        }
    }

    /// returns the voxel at that position if available
    fn getVoxelPtr(world: *World, pos: @Vector(3, i32)) ?*PackedVoxel {
        const region = world.regions.get(pos) orelse return null;
        const brick_idx = pos % region_size_vec;
        const brick = region.bricks[brick_idx[0]][brick_idx[1]][brick_idx[2]];

        const voxel_idx = pos % brick_size_vec;
        return &brick.voxels[voxel_idx[0]][voxel_idx[1]][voxel_idx[2]];
    }

    /// places a voxel (allocating memory if necessary) and returns its pointer
    fn putVoxel(world: *World, pos: @Vector(3, i32)) !*PackedVoxel {
        var region = world.regions.get(pos);
        if (region == null) {
            region = try Region.init();
            world.regions.put(pos, region);
        }

        const brick_idx = pos % region_size_vec;
        const brick = region.?.bricks[brick_idx[0]][brick_idx[1]][brick_idx[2]];

        const voxel_idx = pos % brick_size_vec;
        return &brick.voxels[voxel_idx[0]][voxel_idx[1]][voxel_idx[2]];
    }

    /// reallocates a voxel for new props. note this isn't necessary if the props are the
    /// same, and only the values changes.
    fn replaceVoxel(world: *World, pos: @Vector(3, i32)) *PackedVoxel {}
};

const brick_size = 8;
const brick_size_vec = @as(@Vector(3, i32), @splat(brick_size));
const region_size = 16;
const region_size_vec = @as(@Vector(3, i32), @splat(region_size));

const Region = struct {
    arena: std.heap.ArenaAllocator,
    bricks: [region_size][region_size][region_size]Brick = .{
        [_]Brick{.{}} ** region_size,
        [_]Brick{.{}} ** region_size,
        [_]Brick{.{}} ** region_size,
    },

    pub fn init() !Region {
        return .{
            .arena = std.heap.ArenaAllocator.init(std.heap.page_allocator),
            .bricks = .{},
        };
    }

    pub fn deinit(region: *Region) void {
        region.arena.deinit();
    }
};

const Brick = struct {
    voxels: [brick_size][brick_size][brick_size]?PackedVoxel = .{
        [_]?PackedVoxel{null} ** brick_size,
        [_]?PackedVoxel{null} ** brick_size,
        [_]?PackedVoxel{null} ** brick_size,
    },
};

/// a dumb tagged union would take up too much space, instead do evil bit fuckery
const PackedVoxel = struct {
    data: []u8,

    pub fn getTag(vox: PackedVoxel, world: *const World, tag: Tag) ?PropData {
        // poor man's parser
        // hopefully not horrible for performance :))))))))))))))
        var i: usize = 0;
        while (i < vox.data.len) : (i += 1) {
            const cur_tag: Tag = @bitCast(vox.data[i .. i + 1]);
            const prop_settings = world.prop_tags.get(cur_tag) orelse return null;
            const typeof = prop_settings.typeof();
            const sizeof = typeof.sizeof();

            if (cur_tag == tag) {
                if (typeof == .void) {
                    return .{ .void = {} };
                }

                // fuck alignment
                const payload = vox.data[i + 1 .. i + 1 + sizeof].ptr;
                return switch (typeof) {
                    .void => unreachable, // just handled that
                    .bool => .{ .bool = @as(*const bool, @ptrCast(payload)).* },
                    .i8 => .{ .i8 = @as(*const i8, @ptrCast(payload)).* },
                    .i16 => .{ .i16 = @as(*const i16, @ptrCast(payload)).* },
                    .i32 => .{ .i32 = @as(*const i32, @ptrCast(payload)).* },
                    .i64 => .{ .i64 = @as(*const i64, @ptrCast(payload)).* },
                    .u8 => .{ .u8 = @as(*const u8, @ptrCast(payload)).* },
                    .u16 => .{ .u16 = @as(*const u16, @ptrCast(payload)).* },
                    .u32 => .{ .u32 = @as(*const u32, @ptrCast(payload)).* },
                    .u64 => .{ .u64 = @as(*const u64, @ptrCast(payload)).* },
                    .f16 => .{ .f16 = @as(*const f16, @ptrCast(payload)).* },
                    .f32 => .{ .f32 = @as(*const f32, @ptrCast(payload)).* },
                    .f64 => .{ .f64 = @as(*const f64, @ptrCast(payload)).* },
                    .isize => .{ .isize = @as(*const isize, @ptrCast(payload)).* },
                    .usize => .{ .usize = @as(*const usize, @ptrCast(payload)).* },
                };
            }

            i += sizeof - 1;
        }

        return null;
    }
};

pub const Tag = i16;

pub fn isProp(tag: Tag) bool {
    return tag.val >= 0;
}

pub fn isPrefab(tag: Tag) bool {
    return tag.val < 0;
}

pub const PropType = enum {
    void,
    bool,
    i8,
    i16,
    i32,
    i64,
    u8,
    u16,
    u32,
    u64,
    f16,
    f32,
    f64,
    isize,
    usize,

    pub fn sizeof(ptype: PropType) usize {
        return switch (ptype) {
            .void => @sizeOf(void),
            .bool => @sizeOf(bool),
            .i8 => @sizeOf(i8),
            .i16 => @sizeOf(i16),
            .i32 => @sizeOf(i32),
            .i64 => @sizeOf(i64),
            .u8 => @sizeOf(u8),
            .u16 => @sizeOf(u16),
            .u32 => @sizeOf(u32),
            .u64 => @sizeOf(u64),
            .f16 => @sizeOf(f16),
            .f32 => @sizeOf(f32),
            .f64 => @sizeOf(f64),
            .isize => @sizeOf(isize),
            .usize => @sizeOf(usize),
        };
    }
};

pub const PropData = union(enum) {
    void: void,
    bool: bool,
    i8: i8,
    i16: i16,
    i32: i32,
    i64: i64,
    u8: u8,
    u16: u16,
    u32: u32,
    u64: u64,
    f16: f16,
    f32: f32,
    f64: f64,
    isize: isize,
    usize: usize,
};

pub const PropSettings = struct {
    tag: Tag,
    default: PropData,

    pub fn typeof(settings: PropSettings) PropType {
        // mate
        return switch (settings.default) {
            .void => .void,
            .bool => .bool,
            .i8 => .i8,
            .i16 => .i16,
            .i32 => .i32,
            .i64 => .i64,
            .u8 => .u8,
            .u16 => .u16,
            .u32 => .u32,
            .u64 => .u64,
            .f16 => .f16,
            .f32 => .f32,
            .f64 => .f64,
            .isize => .isize,
            .usize => .usize,
        };
    }
};

pub const Prop = struct {};

/// Only used for the public API. See the World functions.
pub const Voxel = []const PropData;
