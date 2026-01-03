//! A bit like a pointer to a resource, except not garbage. Read this posthaste:
//! https://floooh.github.io/2018/06/17/handles-vs-pointers.html

pub const Any = packed struct(u32) {
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

        pub fn findFree(table: @This()) Error!Any {
            for (table.slots, 0..) |slot, i| {
                if (slot.val == null) {
                    return .{ .id = @intCast(i), .gen = slot.gen };
                }
            } else {
                return Error.TooManyHandles;
            }
        }

        pub fn getSlot(table: @This(), handle: Any) Error!*T {
            if (handle.id > max_resources) {
                return Error.InvalidHandle;
            }
            if (table.slots[handle.id].gen != handle.gen) {
                return Error.DanglingHandle;
            }
            if (table.slots[handle.id].val == null) {
                return Error.InvalidHandle;
            }
            return &table.slots[handle.id].val.?;
        }

        pub fn freeSlot(table: @This(), handle: Any) Error!void {
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

// TODO hash the settings struct so that resources can be cached

/// Wraps handles to be type safe.
/// - `Settings` is the type to the init function so that it knows what to initialize.
/// - `InitError` is the error type that the init function returns. You should probably make
///   it include `HandleError`
/// - `Value` is the concrete type that handles point to.
/// - `initFn` and `deinitFn` modify the handle table and do fancy faffery so that the handle
///   points to something useful.
/// - `handle_table`, as the name implies, is a `HandleTable()`
pub fn Handle(
    comptime Settings: type,
    comptime InitError: type,
    comptime Value: type,
    comptime initFn: *const fn (settings: Settings) anyerror!Any,
    comptime deinitFn: *const fn (handle: Any) void,
    handle_table: anytype,
) type {
    return struct {
        h: Any,
        const LoadError = InitError;

        /// Loads the thingy.
        pub fn init(settings: Settings) LoadError!@This() {
            return initFn(settings) catch |err| {
                return @errorCast(err);
            };
        }

        /// Frees the thingy.
        pub fn deinit(handle: @This()) void {
            deinitFn(handle.h);
        }

        /// Returns the concrete type that the handle points to.
        pub fn get(handle: @This()) !*Value {
            return handle_table.getSlot(handle.h);
        }
    };
}
