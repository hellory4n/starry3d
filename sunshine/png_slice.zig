//! Writer for PNG slices. This is intended as only an easy way to visualize
//! voxel data (as saving to .vox is a lossy conversion)

const std = @import("std");
const testing = std.testing;
const zglm = @import("zglm");
const sunshine = @import("root.zig");
const world = @import("world.zig");
const c = @cImport({
    @cInclude("stb_image_write.h");
});

/// tag is most likely the color unless you're doing something peculiar
pub fn write(
    alloc: std.mem.Allocator,
    file: std.fs.File,
    model: *const world.World,
    tag: world.Tag,
) !void {
    const area = model.area();
    const dimensions = zglm.Vec2iu{ @intCast(area[0] * area[1]), @intCast(area[2]) };

    const img = try Image.create(alloc, @intCast(dimensions[0]), @intCast(dimensions[1]), .rgba32);
    defer img.deinit(alloc);

    var i: usize = 0;
    var x: i32 = model.start[0];
    var y: i32 = model.start[1];
    var z: i32 = model.start[2];
    while (z < model.end[2]) {
        while (y < model.end[1]) {
            while (x < model.end[0]) {
                const val = model.getVoxelProp(.{ x, y, z }, tag).orElse(0);
                const r = (val >> 24) & 0xFF;
                const g = (val >> 16) & 0xFF;
                const b = (val >> 8) & 0xFF;
                const a = val & 0xFF;

                img.pixels.rgba32[i] = .{ .r = r, .g = g, .b = b, .a = a };

                i += 1;
                x += 1;
            }
            y += 1;
        }
        z += 1;
    }

    var buffer: [4096]u8 = undefined;
    try img.writeToFile(alloc, file, &buffer, .{ .png = .{} });
}

test write {
    const testout = try sunshine.testOut();
    defer testout.close();

    const w = try world.World.init(testing.allocator, .{ -8, -8, -8 }, .{ 8, 8, 8 });
    defer w.deinit();

    try w.setVoxelProp(.{ 0, 0, 0 }, world.tag_color, 0xff0000ff);
    try w.setVoxelProp(.{ 1, 0, 0 }, world.tag_color, 0xff0000ff);
    try w.setVoxelProp(.{ 2, 0, 0 }, world.tag_color, 0xff0000ff);
    try w.setVoxelProp(.{ 0, 0, 0 }, world.tag_color, 0xff0000ff);
    try w.setVoxelProp(.{ 0, 0, 1 }, world.tag_color, 0xff0000ff);
    try w.setVoxelProp(.{ 0, 0, 2 }, world.tag_color, 0xff0000ff);
    try w.setVoxelProp(.{ 2, 0, 1 }, world.tag_color, 0xff0000ff);
    try w.setVoxelProp(.{ 2, 0, 2 }, world.tag_color, 0xff0000ff);
    try w.setVoxelProp(.{ 1, 0, 2 }, world.tag_color, 0xff0000ff);
    try w.setVoxelProp(.{ 1, 5, 2 }, world.tag_color, 0xffff00ff);

    const file = try testout.createFile("slice.png", .{ .read = true });
    defer file.close();

    try write(testing.allocator, file, w, world.tag_color);
}
