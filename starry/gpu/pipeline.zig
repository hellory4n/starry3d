//! beware of the render pipeline
const std = @import("std");
const vk = @import("vulkan");
const shader = @import("shader.zig");
const util = @import("../util.zig");
const math = @import("../math.zig");
const ScratchAllocator = @import("../scratch.zig").ScratchAllocator;

/// A bunch of crap to configure. Fascinating.
pub const PipelineSettings = struct {
    /// Shaders are pretty important innit mate..
    shaders: []shader.ShaderModule,

    /// Specifies if the vertex data is triangles or something else
    primitive_topology: PrimitiveTopology = .triangle_list,
    // If true and if the primitive topology is set to a strip type, you can use a special index of
    // `gpu.primitive_restart` so that it discards previous vertices and starts from scratch.
    enable_primitive_restart: bool = false,

    /// Crops shit. Null makes it only crop shit outside of the screen. You can set this at render
    /// time.
    initial_scissor: ?math.Rect2D(u32) = null,
};

pub const PrimitiveTopology = enum {
    /// Points from vertices
    point_list,
    /// Line from every 2 vertices without reuse
    line_list,
    /// The end vertex of every line is used as start vertex for the next line
    line_strip,
    /// Triangle from every 3 vertices without reuse
    triangle_list,
    /// The second and third vertex of every triangle are used as first two vertices of the next
    /// triangle
    triangle_strip,
};

// See `gpu.PipelineSettings.enable_primitive_restart`
pub const primitive_restart: u32 = 0xFFFFFFFF;

/// beware of the render pipeline
pub const Pipeline = struct {
    /// Creates a new render pipeline. Amazing.
    pub fn new(settings: PipelineSettings) !Pipeline {
        var scratch = ScratchAllocator.init();
        defer scratch.deinit();
        const alloc = scratch.allocator();

        var shader_create_infos = std.ArrayList(vk.PipelineShaderStageCreateInfo).empty;
        defer shader_create_infos.deinit(alloc);

        for (settings.shaders) |shader_module| {
            var specialization_info: ?vk.SpecializationInfo = null;
            if (shader_module.settings.specialization_constants) |specialization_constants| {
                specialization_info = .{};
                specialization_info.?.p_map_entries = alloc.alloc(
                    vk.SpecializationInfo,
                    specialization_constants.len,
                );
                specialization_info.?.p_data = specialization_constants.data;
                specialization_info.?.data_size = specialization_constants.size;
                specialization_info.?.map_entry_count = specialization_constants.constants.len;
                specialization_info.?.p_map_entries = alloc.alloc(
                    vk.SpecializationMapEntry,
                    specialization_constants.constants.len,
                );

                var i: usize = 0;
                while (i < specialization_constants.len) : (i += 1) {
                    specialization_info.?.p_map_entries[i] = .{
                        .constant_id = specialization_constants.constants[i].constant_id,
                        .offset = specialization_constants.constants[i].offset,
                        .size = specialization_constants.constants[i].size,
                    };
                }
            }

            shader_create_infos.append(alloc, vk.PipelineShaderStageCreateInfo{
                .module = shader_module.module,
                .stage = switch (shader_module.settings.stage) {
                    .vertex => .{ .vertex_bit = true },
                    .fragment => .{ .fragment_bit = true },
                },
                .p_name = util.zigstrToCstr(alloc, shader_module.settings.entrypoint),
                .p_specialization_info = &specialization_info,
            });
        }

        // big starry knows what's best to be dynamic
        const dynamic_states = [_]vk.DynamicState{
            .viewport,
            .scissor,
        };
        const dynamic_state = vk.PipelineDynamicStateCreateInfo{
            .p_dynamic_states = &dynamic_states,
            .dynamic_state_count = dynamic_states.len,
        };

        const vertex_input_info = vk.PipelineVertexInputStateCreateInfo{}; // TODO

        const input_assembly = vk.PipelineInputAssemblyStateCreateInfo{
            .topology = switch (settings.primitive_topology) {
                .point_list => .point_list,
                .line_list => .line_list,
                .line_strip => .line_strip,
                .triangle_list => .triangle_list,
                .triangle_strip => .triangle_strip,
            },
            .primitive_restart_enable = @enumFromInt(@intFromBool(settings.enable_primitive_restart)),
        };

        const viewport_state = vk.PipelineViewportStateCreateInfo{
            .viewport_count = 1,
            .scissor_count = 1,
        };
    }
};
