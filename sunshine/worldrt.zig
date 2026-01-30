//! Blazingly fast next-gen voxel storage for CPU usage that will touch you in places. The 'rt'
//! is runtime, not raytracing. If it was raytracing I'd just call it "raytracing".

const std = @import("std");

/// Stores crap used by the runtime. How virtual and splendid.
pub const Context = struct {
    allocator: std.mem.Allocator,
    props: []?PropSettings,

    pub fn init(allocator: std.mem.Allocator) !Context {
        const props = try allocator.alloc(?PropSettings, std.math.maxInt(TagUnsigned));

        return .{
            .allocator = allocator,
            .props = props,
        };
    }

    pub fn deinit(ctx: *Context) void {
        ctx.allocator.free(ctx.props);
    }

    pub fn getPropSettings(ctx: Context, tag: Tag) ?PropSettings {
        const idx: TagUnsigned = @bitCast(tag);
        return ctx.props[idx];
    }
};

/// Positive = prop, negative = prefab
pub const Tag = i16;
/// Fuck you.
pub const TagUnsigned = u16;

pub fn isPropTag(tag: Tag) bool {
    return tag >= 0;
}

pub fn isPrefabTag(tag: Tag) bool {
    return tag < 0;
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
    isize,
    usize,
    f16,
    f32,
    f64,
    /// []u8
    bytes,
    /// []const u8
    const_bytes,
    /// ?*anyopaque
    opaque_ptr,
    /// ?*const anyopaque
    const_opaque_ptr,
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
    isize: isize,
    usize: usize,
    f16: f16,
    f32: f32,
    f64: f64,
    /// []u8
    bytes: []u8,
    /// []const u8
    const_bytes: []const u8,
    /// ?*anyopaque
    opaque_ptr: ?*anyopaque,
    /// ?*const anyopaque
    const_opaque_ptr: ?*const anyopaque,
};

pub const PropSettings = struct {
    tag: Tag,
    type: PropType,
    /// note ptr data is unmanaged, you're supposed to free it yourself or use static memory
    default: PropData,

    pub fn register(
        settings: PropSettings,
        ctx: *Context,
        if_existing: enum { keep_old_tag, overwrite, panic_if_exists },
    ) !void {
        const ctx.getPropSettings(settings.tag);
    }
};

// register-ers
