//! A shader is a GPU program that runs on the GPU
const vk = @import("vulkan");
const impl = @import("internal.zig");

pub const ShaderStage = enum {
    vertex,
    fragment,
    // TODO the rest of the stages
};

pub const ShaderSettings = struct {
    stage: ShaderStage,
    entrypoint: []const u8 = "main",
    /// Used for configuring shaders in a way more efficient than setting uniforms at runtime.
    specialization_constants: ?SpecializationConstants = null,
};

/// Used for configuring shaders in a way more efficient than setting uniforms at runtime.
pub const SpecializationConstants = struct {
    /// Only has to live while the pipeline is being created
    data: *const anyopaque,
    /// The fucking size of the fucking data (just use `@sizeOf`)
    size: usize,
    constants: []SpecializationConstant,
};

pub const SpecializationConstant = struct {
    constant_id: u32,
    /// Usually from `@offsetOf`
    offset: usize,
    /// Usually from `@sizeOf`
    size: usize,
};

/// A shader is a GPU program that runs on the GPU
pub const ShaderModule = struct {
    module: vk.ShaderModule,
    settings: ShaderSettings,

    /// The manual and slightly torturous way of making a shader
    pub fn fromMemory(spirv: []const u8, settings: ShaderSettings) !ShaderModule {
        const create_info = vk.ShaderModuleCreateInfo{
            .code_size = spirv.len,
            .p_code = @ptrCast(@alignCast(spirv)),
        };

        return ShaderModule{
            .module = try impl.vkd.createShaderModule(impl.device, &create_info, null),
            .settings = settings,
        };
    }

    /// Uses comptime magic to make shaders from imports
    pub fn fromImport(comptime import: anytype) !ShaderModule {}

    /// Frees the shader. This is safe to do immediately after the shader is linked (which happens when
    /// the pipeline is created)
    pub fn free(shader: *ShaderModule) void {
        if (shader.module != .null_handle) {
            impl.vkd.destroyShaderModule(impl.device, shader.module, null);
        }
        shader.module = .null_handle;
    }
};
