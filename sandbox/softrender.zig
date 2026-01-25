const std = @import("std");
const zglm = @import("zglm");

/// one thread per pixel is stupid, one thread per 16x16 pixels is less
const tile_size = 16;
const screen_width = 800;
const screen_height = 600;

// TODO it's Late as of writing so there may be overdraw

fn colorTile(start: @Vector(2, u32), end: @Vector(2, u32)) void {
    @setFloatMode(.optimized);
    var x: u32 = start[0];
    var y: u32 = start[1];
    while (y < end[1]) : (y += 1) while (x < end[0]) : (x += 1) {
        // const r = @as(f32, @floatFromInt(x)) / @as(f32, screen_width);
        // const g = @as(f32, @floatFromInt(y)) / @as(f32, screen_height);
        // backbuffer[x][y] = .{ @intFromFloat(r * 255), @intFromFloat(g * 255), 0, 1 };
        backbuffer[x][y] = .{ 255, 0, 0, 255 };
    };
}

pub fn render() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    // fancy threading shitfuckery
    // TODO this is completely different in v0.16 because of course it is
    var thread_pool: std.Thread.Pool = undefined;
    try thread_pool.init(.{
        .allocator = alloc,
    });
    defer thread_pool.deinit();

    const render_start = std.time.microTimestamp();
    var wg: std.Thread.WaitGroup = .{};

    var x: u32 = 0;
    var y: u32 = 0;
    while (y <= screen_height) : (y += tile_size) {
        // i may be stupid but good enough
        if (y >= screen_height) break;
        while (x <= screen_width) : (x += tile_size) {
            if (x >= screen_width) break;
            thread_pool.spawnWg(&wg, colorTile, .{
                @Vector(2, u32){ x, y },
                @Vector(2, u32){ x + tile_size, y + tile_size },
            });
        }
    }

    // the screen size won't always be divisible by the tile size
    // put the remainder in the last few tasks
    // this math is valid because it's integer division :)
    // const covered_x: u32 = (screen_width / tile_size) * tile_size;
    // const covered_y: u32 = (screen_height / tile_size) * tile_size;
    // if (covered_x != screen_width) {
    //     x = covered_x;
    //     y = 0;
    //     while (y <= screen_height) : (y = @min(y + tile_size, screen_height)) {
    //         thread_pool.spawnWg(&wg, colorTile, .{
    //             @Vector(2, u32){ x, y },
    //             @Vector(2, u32){ x + tile_size, y + tile_size },
    //         });
    //     }
    // }

    // if (covered_y != screen_height) {
    //     y = covered_y;
    //     x = 0;
    //     while (x <= screen_width) : (x = @min(x + tile_size, screen_width)) {
    //         thread_pool.spawnWg(&wg, colorTile, .{
    //             @Vector(2, u32){ x, y },
    //             @Vector(2, u32){ x + tile_size, y + tile_size },
    //         });
    //     }
    // }

    wg.wait();
    const render_end = std.time.microTimestamp();
    std.log.debug("rendering took {d} µs", .{render_end - render_start});

    const save_image_start = std.time.microTimestamp();
    try backbufferToPpm();
    const save_image_end = std.time.microTimestamp();
    std.log.debug("saving image took {d} µs", .{save_image_end - save_image_start});
}

var backbuffer: [screen_width][screen_height]@Vector(4, u8) =
    std.mem.zeroes([screen_width][screen_height]@Vector(4, u8));

pub fn backbufferToPpm() !void {
    const file = try std.fs.cwd().createFile("out.ppm", .{ .read = true });
    defer file.close();

    var buffer: [32 * 1024]u8 = undefined;
    var file_writer = file.writer(&buffer);
    const writer = &file_writer.interface;

    // ppm header
    try writer.writeAll("P6\n");
    try writer.print("{d} {d}\n", .{ screen_width, screen_height });
    try writer.writeAll("255\n");

    var pixels: [screen_width * screen_height * 3]u8 = undefined;
    for (0..screen_height) |y| {
        for (0..screen_width) |x| {
            const c = backbuffer[x][y];
            const idx = (y * screen_width + x) * 3;
            pixels[idx] = c[0];
            pixels[idx + 1] = c[1];
            pixels[idx + 2] = c[2];
        }
    }
    try writer.writeAll(&pixels);
    try writer.flush();
}
