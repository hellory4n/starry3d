const std = @import("std");
const builtin = @import("builtin");
const zglm = @import("zglm");
const sunshine = @import("sunshine");

/// one thread per pixel is stupid, one thread per a few pixels is less
const tile_size = 16;
const image_width = 1366;
const image_height = 768;
const image_size = @Vector(2, u32){ image_width, image_height };

var backbuffer: [image_width][image_height]@Vector(4, u8) =
    std.mem.zeroes([image_width][image_height]@Vector(4, u8));

// TODO it's Late as of writing so there may be overdraw

fn colorTile(pos: @Vector(2, u32), size: @Vector(2, u32)) void {
    @setFloatMode(.optimized);
    var x: u32 = pos[0];
    var y: u32 = pos[1];

    while (y < y + size[1] and y < image_height) : (y += 1) {
        x = pos[0];
        while (x < x + size[0] and x < image_width) : (x += 1) {
            // useful for hypermegaultramega optimization
            if (builtin.mode == .Debug or builtin.mode == .ReleaseSafe) {
                if (zglm.all(backbuffer[x][y] != @Vector(4, u8){ 0, 0, 0, 0 })) {
                    std.log.warn("overdrawing {d}x{d}", .{ x, y });
                }
            }

            const r = @as(f32, @floatFromInt(x)) / @as(f32, image_width);
            const g = @as(f32, @floatFromInt(y)) / @as(f32, image_height);
            backbuffer[x][y] = .{ @intFromFloat(r * 255), @intFromFloat(g * 255), 0, 1 };
        }
    }
}

pub fn render() !void {
    var scratch = sunshine.ScratchAllocator.init();
    defer scratch.deinit();
    const alloc = scratch.allocator();

    // fancy threading shitfuckery
    // TODO this is completely different in v0.16 because of course it is
    var thread_pool: std.Thread.Pool = undefined;
    try thread_pool.init(.{
        .allocator = alloc,
        // rendering is expensive!
        // max number of os threads != number of cpu cores so this is probably fine
        // note this has to be balanced with the tile size to work properly
        .n_jobs = (std.Thread.getCpuCount() catch 1) * 2,
    });
    defer thread_pool.deinit();
    std.log.debug("using {d}* threads", .{thread_pool.getIdCount()});

    const render_start = std.time.microTimestamp();
    var wg: std.Thread.WaitGroup = .{};

    var x: u32 = 0;
    var y: u32 = 0;
    while (y + tile_size < image_height) : (y += tile_size) {
        x = 0;
        while (x + tile_size < image_width) : (x += tile_size) {
            thread_pool.spawnWg(&wg, colorTile, .{
                @Vector(2, u32){ x, y },
                @min(
                    @Vector(2, u32){ tile_size, tile_size },
                    image_size - @Vector(2, u32){ x, y },
                ),
            });
        }
    }

    wg.wait();
    const render_end = std.time.microTimestamp();
    std.log.debug("rendering took {d} µs ({d} FPS)", .{
        render_end - render_start,
        1 / (@as(f32, @floatFromInt(render_end - render_start)) / 1000 / 1000),
    });

    const save_image_start = std.time.microTimestamp();
    try backbufferToPpm();
    const save_image_end = std.time.microTimestamp();
    std.log.debug("saving image took {d} µs", .{save_image_end - save_image_start});
}

pub fn backbufferToPpm() !void {
    const file = try std.fs.cwd().createFile("out.ppm", .{ .read = true });
    defer file.close();

    var buffer: [32 * 1024]u8 = undefined;
    var file_writer = file.writer(&buffer);
    const writer = &file_writer.interface;

    // ppm header
    try writer.writeAll("P6\n");
    try writer.print("{d} {d}\n", .{ image_width, image_height });
    try writer.writeAll("255\n");

    var pixels: [image_width * image_height * 3]u8 = undefined;
    for (0..image_height) |y| {
        for (0..image_width) |x| {
            const c = backbuffer[x][y];
            const idx = (y * image_width + x) * 3;
            pixels[idx] = c[0];
            pixels[idx + 1] = c[1];
            pixels[idx + 2] = c[2];
        }
    }
    try writer.writeAll(&pixels);
    try writer.flush();
}
