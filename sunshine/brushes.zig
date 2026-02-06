//! Premade brushes for the world runtime

const zglm = @import("zglm");
const world = @import("worldrt.zig");

// TODO more

/// Annihilates every voxel in its path
pub inline fn eraser(pos: zglm.Vec3i, src: ?u32, params: u64) ?u32 {
    _ = pos;
    _ = src;
    _ = params;
    return null;
}

pub const FillParams = packed struct(u64) {
    color: u32,
    _padding: u32,
};

/// Fills every voxel in its path with a color (FillParams)
pub inline fn fill(pos: zglm.Vec3i, src: ?u32, params: u64) ?u32 {
    _ = pos;
    _ = src;
    const p: FillParams = @bitCast(params);
    return p.color;
}

/// Inverts the color of the src voxel
pub inline fn invert(pos: zglm.Vec3i, src: ?u32, params: u64) ?u32 {
    _ = pos;
    _ = params;
    if (src) |rgba| {
        var rgb = rgba & 0xffffff00;
        const a = rgba & 0x000000ff;
        rgb ^= 0xffffff00;
        return rgb | a;
    }
    return null;
}
