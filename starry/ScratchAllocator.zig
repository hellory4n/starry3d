//! Temporary allocator type shit. It works a lot like a stack, where there's a fixed size buffer
//! shared by the entire program, and each function can make a new instance of `ScratchAlloc`,
//! which is then freed at the end, leaving more space for the rest of the program to use. If the
//! underlying buffer is full, it'll use a backup allocator so that the program doesn't just die.
//! Probably thread-safe, idk lol.
const std = @import("std");
const mem = std.mem;
const heap = std.heap;
const testing = std.testing;

pub const ScratchAllocator = @This();

start_pos: isize = -1,
fallback_alloc: heap.ArenaAllocator = undefined,
fallback_backing_alloc: heap.GeneralPurposeAllocator(.{}) = undefined, // catchy
created_fallback: bool = false,

pub fn init() ScratchAllocator {
    globalInit();
    return ScratchAllocator{
        .start_pos = @intCast(scratch_alloc.end_index),
    };
}

pub fn deinit(scratch: *ScratchAllocator) void {
    if (scratch.start_pos == -1) {
        return;
    }

    // TODO there must be a better way to do this
    @memset(scratch_buffer[@intCast(scratch.start_pos)..], 0xaa);
    scratch_alloc.end_index = @intCast(scratch.start_pos);
    scratch.start_pos = -1;

    if (scratch.created_fallback) {
        scratch.fallback_alloc.deinit();
        _ = scratch.fallback_backing_alloc.deinit();
    }
}

/// allocating it rn
pub fn allocator(scratch: *ScratchAllocator) mem.Allocator {
    // making it idiot proof
    if (scratch.start_pos == -1) {
        @panic("idiot you didn't initialize with ScratchAllocator.init()");
    }

    return .{
        .ptr = scratch,
        .vtable = &.{
            .alloc = implAlloc,
            .resize = implResize,
            .remap = implRemap,
            .free = implFree,
        },
    };
}

fn implAlloc(ctx: *anyopaque, len: usize, alignment: mem.Alignment, ret_addr: usize) ?[*]u8 {
    const scratch: *ScratchAllocator = @ptrCast(@alignCast(ctx));
    const try_ptr = scratch_alloc.threadSafeAllocator().vtable.alloc(
        &scratch_alloc,
        len,
        alignment,
        ret_addr,
    );

    // null = failed = out of memory, use the fallback in that case
    if (try_ptr) |ptr| {
        return ptr;
    } else {
        if (!scratch.created_fallback) {
            scratch.fallback_backing_alloc = heap.GeneralPurposeAllocator(.{}).init;
            scratch.fallback_alloc = heap.ArenaAllocator.init(
                scratch.fallback_backing_alloc.allocator(),
            );
            scratch.created_fallback = true;
        }
        return scratch.fallback_alloc.allocator().vtable.alloc(
            &scratch.fallback_alloc,
            len,
            alignment,
            ret_addr,
        );
    }
}

fn implFree(_: *anyopaque, memory: []u8, _: mem.Alignment, _: usize) void {
    @memset(memory, 0xaa);
}

/// `resize()` is unsupported, this is just for compatibility with the `Allocator` interface
fn implResize(_: *anyopaque, _: []u8, _: mem.Alignment, _: usize, _: usize) bool {
    return false;
}

/// `remap()` could probably be supported but i can't be bothered rn
fn implRemap(_: *anyopaque, _: []u8, _: mem.Alignment, _: usize, _: usize) ?[*]u8 {
    return null;
}

// TODO 256 kb might be too few
const scratch_size: usize = 256 * 1024;
threadlocal var scratch_buffer: [scratch_size]u8 = .{0} ** scratch_size;
threadlocal var scratch_alloc: heap.FixedBufferAllocator = undefined;
threadlocal var scratch_alloc_initialized = false;

fn globalInit() void {
    if (!scratch_alloc_initialized) {
        scratch_alloc = heap.FixedBufferAllocator.init(&scratch_buffer);
        scratch_alloc_initialized = true;
    }
}

test "scratch allocator" {
    var scratch = ScratchAllocator.init();
    defer scratch.deinit();
    const alloc = scratch.allocator();

    var array = try alloc.alloc(i32, 4);
    array[0] = 1;
    array[1] = 2;
    array[2] = 3;
    array[3] = 4;
    try testing.expect(array[0] == 1);
    try testing.expect(array[1] == 2);
    try testing.expect(array[2] == 3);
    try testing.expect(array[3] == 4);
}

test "multiple scratch allocators" {
    // simulates function calls each making their own scratchpad
    var scratch1 = ScratchAllocator.init();
    defer scratch1.deinit();
    const alloc1 = scratch1.allocator();

    var a: *i32 = undefined;
    var b: *i32 = undefined;
    var c: *i32 = undefined;

    a = try alloc1.create(i32);
    a.* = 38;

    {
        var scratch2 = ScratchAllocator.init();
        defer scratch2.deinit();
        const alloc2 = scratch2.allocator();

        b = try alloc2.create(i32);
        b.* = 61;

        {
            var scratch3 = ScratchAllocator.init();
            defer scratch3.deinit();
            const alloc3 = scratch3.allocator();

            c = try alloc3.create(i32);
            c.* = -67;
        }

        try testing.expect(c.* != -67);
    }

    try testing.expect(b.* != 61);
    try testing.expect(a.* == 38);
}

test "scratch fallback" {
    var scratch = ScratchAllocator.init();
    defer scratch.deinit();
    const alloc = scratch.allocator();

    // these should be allocated as usual
    const a = try alloc.create(i32);
    a.* = 123;
    const b = try alloc.create(i32);
    b.* = 456;
    const c = try alloc.create(i32);
    c.* = 789;

    // massive allocation, won't fit
    const massive = try alloc.alloc(i32, 100_000);
    massive[35_621] = 8752752;

    // should still fit since they're separate
    const d = try alloc.create(i32);
    d.* = 1234;

    try testing.expect(a.* == 123);
    try testing.expect(b.* == 456);
    try testing.expect(c.* == 789);
    try testing.expect(d.* == 1234);
    try testing.expect(massive[35_621] == 8752752);
}
