//! Shared with the build system and compiler
const std = @import("std");
pub const Stage = enum { vertex, fragment, compute };
pub const Output = enum { hlsl5, spirv };

pub const SourceFile = struct {
    path: []const u8,
    stage: Stage,
    output: Output,
    /// note ReleaseSafe is the same as ReleaseFast here
    mode: std.builtin.OptimizeMode = .Debug,
    include_paths: []const []const u8 = &.{},
};

/// Struct used for .zon files
pub const ShaderImport = struct {
    entry_point: []const u8,
    hlsl_code: []const u8,
    spirv_code: []const u8,
    stage: Stage,
};
