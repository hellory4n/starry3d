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
const bke_wgpu = @import("gpu_wgpu.zig");

/// Unfortunately GPU drivers don't natively support the hit graphics API starry dot gee pee you dot zig.
pub const Backend = enum {
    /// Panics or returns an error if you try to do anything
    invalid,
    /// WebGPU through Dawn
    wgpu_dawn,
};

/// Returns the backend being currently used
pub fn getBackend() Backend {
    // TODO compile option for headless builds

    // TODO metal support?
    if (builtin.os.tag.isDarwin() and builtin.os.tag != .macos) {
        return .invalid;
    }
    // TODO vulkan support?
    if (builtin.abi.isAndroid()) {
        return .invalid;
    }

    return switch (builtin.os.tag) {
        .windows, .linux, .macos => .wgpu_dawn,
        .freebsd, .openbsd, .netbsd => .wgpu_dawn,
        else => .invalid,
    };
}

pub const BackendError = error{
    InvalidHandle,
    NoBackendAvailable,
};

/// Initializes the GPU backend. Amazing.
pub fn init() BackendError!void {
    return switch (getBackend()) {
        .wgpu_dawn => bke_wgpu.init(),
        else => @compileError("unsupported backend"),
    };
}

/// Deinitializes the GPU backend. .gnizamA
pub fn deinit() void {
    switch (getBackend()) {
        .wgpu_dawn => bke_wgpu.deinit(),
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
