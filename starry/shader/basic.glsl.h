#pragma once
/*
    #version:1# (machine generated, don't edit!)

    Generated by sokol-shdc (https://github.com/floooh/sokol-tools)

    Cmdline:
        sokol-shdc -i starry/shader/basic.glsl -o starry/shader/basic.glsl.h -l glsl430

    Overview:
    =========
    Shader program: 'basic':
        Get shader desc: basic_shader_desc(sg_query_backend());
        Vertex Shader: vs
        Fragment Shader: fs
        Attributes:
            ATTR_basic_position => 0
    Bindings:
*/
#if !defined(SOKOL_GFX_INCLUDED)
#error "Please include sokol_gfx.h before basic.glsl.h"
#endif
#if !defined(SOKOL_SHDC_ALIGN)
#if defined(_MSC_VER)
#define SOKOL_SHDC_ALIGN(a) __declspec(align(a))
#else
#define SOKOL_SHDC_ALIGN(a) __attribute__((aligned(a)))
#endif
#endif
#define ATTR_basic_position (0)
/*
    #version 430

    layout(location = 0) in vec3 position;

    void main()
    {
        gl_Position = vec4(position, 1.0);
    }

*/
static const uint8_t vs_source_glsl430[111] = {
    0x23,0x76,0x65,0x72,0x73,0x69,0x6f,0x6e,0x20,0x34,0x33,0x30,0x0a,0x0a,0x6c,0x61,
    0x79,0x6f,0x75,0x74,0x28,0x6c,0x6f,0x63,0x61,0x74,0x69,0x6f,0x6e,0x20,0x3d,0x20,
    0x30,0x29,0x20,0x69,0x6e,0x20,0x76,0x65,0x63,0x33,0x20,0x70,0x6f,0x73,0x69,0x74,
    0x69,0x6f,0x6e,0x3b,0x0a,0x0a,0x76,0x6f,0x69,0x64,0x20,0x6d,0x61,0x69,0x6e,0x28,
    0x29,0x0a,0x7b,0x0a,0x20,0x20,0x20,0x20,0x67,0x6c,0x5f,0x50,0x6f,0x73,0x69,0x74,
    0x69,0x6f,0x6e,0x20,0x3d,0x20,0x76,0x65,0x63,0x34,0x28,0x70,0x6f,0x73,0x69,0x74,
    0x69,0x6f,0x6e,0x2c,0x20,0x31,0x2e,0x30,0x29,0x3b,0x0a,0x7d,0x0a,0x0a,0x00,
};
/*
    #version 430

    layout(location = 0) out vec4 FragColor;

    void main()
    {
        FragColor = vec4(1.0, 0.0, 0.0, 1.0);
    }

*/
static const uint8_t fs_source_glsl430[116] = {
    0x23,0x76,0x65,0x72,0x73,0x69,0x6f,0x6e,0x20,0x34,0x33,0x30,0x0a,0x0a,0x6c,0x61,
    0x79,0x6f,0x75,0x74,0x28,0x6c,0x6f,0x63,0x61,0x74,0x69,0x6f,0x6e,0x20,0x3d,0x20,
    0x30,0x29,0x20,0x6f,0x75,0x74,0x20,0x76,0x65,0x63,0x34,0x20,0x46,0x72,0x61,0x67,
    0x43,0x6f,0x6c,0x6f,0x72,0x3b,0x0a,0x0a,0x76,0x6f,0x69,0x64,0x20,0x6d,0x61,0x69,
    0x6e,0x28,0x29,0x0a,0x7b,0x0a,0x20,0x20,0x20,0x20,0x46,0x72,0x61,0x67,0x43,0x6f,
    0x6c,0x6f,0x72,0x20,0x3d,0x20,0x76,0x65,0x63,0x34,0x28,0x31,0x2e,0x30,0x2c,0x20,
    0x30,0x2e,0x30,0x2c,0x20,0x30,0x2e,0x30,0x2c,0x20,0x31,0x2e,0x30,0x29,0x3b,0x0a,
    0x7d,0x0a,0x0a,0x00,
};
static inline const sg_shader_desc* basic_shader_desc(sg_backend backend) {
    if (backend == SG_BACKEND_GLCORE) {
        static sg_shader_desc desc;
        static bool valid;
        if (!valid) {
            valid = true;
            desc.vertex_func.source = (const char*)vs_source_glsl430;
            desc.vertex_func.entry = "main";
            desc.fragment_func.source = (const char*)fs_source_glsl430;
            desc.fragment_func.entry = "main";
            desc.attrs[0].base_type = SG_SHADERATTRBASETYPE_FLOAT;
            desc.attrs[0].glsl_name = "position";
            desc.label = "basic_shader";
        }
        return &desc;
    }
    return 0;
}
