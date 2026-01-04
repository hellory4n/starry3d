//! A bit like a pointer to a resource, except not garbage. Read this posthaste:
//! https://floooh.github.io/2018/06/17/handles-vs-pointers.html

/// Opaque handle to something (who knows)
pub const Opaque = packed struct(u32) {
    id: u24,
    gen: u8,
};

pub const Error = error{
    TooManyHandles,
    InvalidHandle,
    DanglingHandle,
};

pub fn Slot(comptime T: type) type {
    return struct {
        val: ?T = null,
        gen: u8 = 0,
    };
}

/// A big array where all handles of one type go.
pub fn Table(comptime T: type, comptime max_resources: u24) type {
    return struct {
        slots: [max_resources]Slot(T) = [_]Slot(T){.{}} ** max_resources,

        pub fn findFree(table: *const @This()) Error!Opaque {
            for (table.slots, 0..) |slot, i| {
                if (slot.val == null) {
                    return .{ .id = @intCast(i), .gen = slot.gen };
                }
            } else {
                return Error.TooManyHandles;
            }
        }

        pub fn getSlot(table: *const @This(), handle: Opaque) Error!T {
            if (handle.id > max_resources) {
                return Error.InvalidHandle;
            }
            if (table.slots[handle.id].gen != handle.gen) {
                return Error.DanglingHandle;
            }
            if (table.slots[handle.id].val == null) {
                return Error.InvalidHandle;
            }
            return table.slots[handle.id].val.?;
        }

        pub fn setSlot(table: *@This(), handle: Opaque, val: T) void {
            table.slots[handle.id].val = val;
        }

        pub fn freeSlot(table: *@This(), handle: Opaque) Error!void {
            if (table.slots[handle.id].gen != handle.gen) {
                return Error.DanglingHandle;
            }

            if (table.slots[handle.id].val != null) {
                table.slots[handle.id].val = null;
                table.slots[handle.id].gen +%= 1;
            }
        }
    };
}
