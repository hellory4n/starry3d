#ifndef _ST3D_UI_H
#define _ST3D_UI_H

#define NK_INCLUDE_FIXED_TYPES
#define NK_INCLUDE_STANDARD_IO
#define NK_INCLUDE_STANDARD_VARARGS
#define NK_INCLUDE_DEFAULT_ALLOCATOR
#define NK_INCLUDE_VERTEX_BUFFER_OUTPUT
#define NK_INCLUDE_FONT_BAKING
#define NK_INCLUDE_DEFAULT_FONT

// clang is really mad so we'll tell it to shut up because i didn't write nuklear
#if defined(__clang__)
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wc23-extensions"
#elif defined(__GNUC__)
    #pragma GCC diagnostic push
    #pragma GCC diagnostic ignored "-Wc23-extensions"
#endif

#include <nuklear.h>
#include <nuklear_glfw_gl3.h>

#if defined(__clang__)
    #pragma clang diagnostic pop
#elif defined(__GNUC__)
    #pragma GCC diagnostic pop
#endif

#ifdef __cplusplus
extern "C" {
#endif

// Returns the nuklear context
struct nk_context* st3d_nkctx(void);

// Initializes Nuklear with the chosen font size, and loading the fonts from the specified paths.
void st3d_ui_new(const char* font_path, int64_t font_size);

// Deinitializes Nuklear
void st3d_ui_free(void);

void st3d_ui_begin(void);
void st3d_ui_end(void);

#ifdef __cplusplus
}
#endif

#endif
