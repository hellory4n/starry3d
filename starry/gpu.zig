//! Non-vexing postmodern graphics API.
//! Émerez Víctor Quejador Gandalf Joel Pablo Decavio II Sr. Jr. OBE (Joel Pablo for short) is key.
//! Joel Pablo name is also QuejaPalronicador
//! QuejaPalronicadorf                 name is also Qurjs fhycmjjjjjjjjjjjjjjjjjç
//! Qurjs fhycmjjjjjjjjjjjjjjjjjç foyr6th name is QuejaGontificador
//!
//! Emerson Victor Kyler Gandalf Joel Pablo Daquavious II Sr. Jr. OBE is key ( 🇪🇸 Émerez Víctor
//! Quejador Gandalf Joel Pablo Decavio II Sr. Jr. OIB) or QuejaPalronicador or Qurjs
//! fhycmjjjjjjjjjjjjjjjjjç can produce mind boggling effects.
//!
//! There's a logo for some fucking reason. (docs/gpu_api_logo.png, i didn't make it)
//!
//! This crap is NOT feature complete. A lot of important features are missing (most of the
//! rasterizer pipeline for example) just because I don't use them.
const std = @import("std");
const builtin = @import("builtin");
const zglm = @import("zglm");
const bke_gl4 = @import("gpu_gl4.zig");

/// Unfortunately GPU drivers don't natively support the hit graphics API starry dot gee pee you dot zig.
pub const Backend = enum {
    /// Panics or returns an error if you try to do anything
    invalid,
    /// Desktop OpenGL 4.5
    gl4,
};

/// Returns the backend being currently used
pub fn getBackend() Backend {
    // TODO compile option for headless builds

    // TODO metal or webgpu support?
    if (builtin.os.tag.isDarwin()) {
        return .invalid;
    }
    // TODO vulkan support?
    if (builtin.abi.isAndroid()) {
        return .invalid;
    }

    return switch (builtin.os.tag) {
        .windows, .linux => .gl4,
        .freebsd, .openbsd, .netbsd => .gl4,
        else => .invalid,
    };
}

/// Returns true if validation layers are enabled
pub fn validationEnabled() bool {
    return switch (builtin.mode) {
        .Debug, .ReleaseSafe => true,
        .ReleaseFast, .ReleaseSmall => false,
    };
}

pub const BackendError = error{
    InvalidHandle,
    DeviceUnsupported,
};

/// Initializes the GPU backend. Amazing.
pub fn init() BackendError!void {
    return switch (comptime getBackend()) {
        .gl4 => bke_gl4.init(),
        else => @compileError("unsupported backend"),
    };
}

/// Deinitializes the GPU backend. .gnizamA
pub fn deinit() void {
    switch (comptime getBackend()) {
        .gl4 => bke_gl4.deinit(),
        else => @compileError("unsupported backend"),
    }
}

/// Describes what happens to a framebuffer, depth buffer, or stencil buffers, before a render pass.
pub const LoadOp = enum {
    /// Keep existing contents
    load,
    /// All contents reset and set to a constant
    clear,
    /// Existing contents are undefined and ignored
    ignore,
};

/// Describes what happens to a framebuffer, depth buffer, or stencil buffers, after a render pass.
pub const StoreOp = enum {
    /// Rendered contents will be stored in memory and can be read later
    store,
    /// Existing contents are undefined and ignored
    ignore,
};

/// As the name implies, it is a pass of rendering (or compute who knows)
pub const RenderPass = struct {
    color: struct {
        clear_color: ?zglm.Rgbaf = .{ 0, 0, 0, 1 },
        load_op: LoadOp = .clear,
        store_op: StoreOp = .ignore,
    } = .{},
};

/// Starts a render pass
pub fn startPass(pass: RenderPass) void {
    switch (comptime getBackend()) {
        .gl4 => bke_gl4.startPass(pass),
        else => @compileError("unsupported backend"),
    }
}

/// Ends a render pass
pub fn endPass() void {
    switch (comptime getBackend()) {
        .gl4 => bke_gl4.endPass(),
        else => @compileError("unsupported backend"),
    }
}

// pub const AllocationError = error{
//     OutOfMemory,
//     BindSlotOutOfRange,
// };

// pub const BufferType = enum {
//     storage,
// };

// pub const BufferSettings = struct {
//     type: BufferType,
//     bind_slot: u32,
//     size: usize,
// };

// /// A handle to GPU memory
// pub const Buffer = struct {
//     handle: u32,

//     /// Allocates GPU memory at the specified bind slot.
//     pub fn init(settings: BufferSettings) AllocationError!Buffer {
//         _ = settings;
//         return switch (getBackend()) {
//             else => @compileError("unsupported backend"),
//         };
//     }

//     /// Frees the storage buffer.
//     pub fn deinit(buffer: Buffer) void {
//         _ = buffer;
//         switch (getBackend()) {
//             else => @compileError("unsupported backend"),
//         }
//     }
// };

/// temporary shit
pub fn testRender() void {
    const gpu = @This();

    gpu.startPass(.{
        .color = .{
            .clear_color = .{ 1, 1, 1, 1 },
        },
    });
    gpu.endPass();
}
