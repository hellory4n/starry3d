//! sunshine-specific benchmarks

const std = @import("std");
const testing = std.testing;
const world = @import("world.zig");

// this isnt ffmpeg so i think this is more than enough for most simulation stuff
// noinline so the optimizer doesn't do smth too goofy, idk
const BadApple = struct {
    pub noinline fn width() u32 {
        return 480;
    }

    pub noinline fn height() u32 {
        return 360;
    }

    pub noinline fn timeRequiredMicro() i64 {
        const nvnfjbn: f32 = (1 / 30) * 1000 * 1000;
        return @intFromFloat(nvnfjbn);
    }

    pub noinline fn getPixel(x: u32, y: u32) u32 {
        _ = x;
        _ = y;
        return 0x000000ff;
    }
};

test "realtime bad apple (brushless)" {
    testing.log_level = .debug;

    var w = try world.World.init(
        testing.allocator,
        .{ 0, 0, 0 },
        .{ @intCast(BadApple.width()), @intCast(BadApple.height()), 1 },
    );
    defer w.deinit();

    const set_all_black_start = std.time.microTimestamp();
    for (0..BadApple.height()) |y| for (0..BadApple.width()) |x| {
        try w.setVoxelProp(
            .{ @intCast(x), @intCast(y), 0 },
            world.tag_color,
            BadApple.getPixel(@intCast(x), @intCast(y)),
        );
    };
    const set_all_black_end = std.time.microTimestamp();
    const set_all_black_time = set_all_black_end - set_all_black_start;
    std.log.info("setting all black took {d} µs", .{set_all_black_time});

    const invert_all_start = std.time.microTimestamp();
    for (0..BadApple.height()) |y| for (0..BadApple.width()) |x| {
        const prev_color = w.getVoxelProp(
            .{ @intCast(x), @intCast(y), 0 },
            world.tag_color,
        ).orElse(0);

        var rgb = prev_color & 0xffffff00;
        const a = prev_color & 0x000000ff;
        rgb ^= 0xffffff00;
        const new_color = rgb | a;

        try w.setVoxelProp(.{ @intCast(x), @intCast(y), 0 }, world.tag_color, new_color);
    };
    const invert_all_end = std.time.microTimestamp();
    const invert_all_time = invert_all_end - invert_all_start;
    std.log.info("inverting all took {d} µs", .{invert_all_time});

    // probably inaccurate idk idc
    const avg_time = @divFloor(set_all_black_time + invert_all_time, 2);
    std.log.info("average time: {d} µs", .{avg_time});
    std.log.info("can this run bad apple in realtime? {s}", .{
        if (avg_time <= BadApple.timeRequiredMicro()) "maybe" else "no",
    });
}
