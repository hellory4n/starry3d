#ifndef _ST3D_IMGUI_H
#define _ST3D_IMGUI_H

#define NK_INCLUDE_FIXED_TYPES
#define NK_INCLUDE_STANDARD_IO
#define NK_INCLUDE_STANDARD_VARARGS
#define NK_INCLUDE_DEFAULT_ALLOCATOR
#define NK_INCLUDE_VERTEX_BUFFER_OUTPUT
#define NK_INCLUDE_FONT_BAKING
#define NK_INCLUDE_DEFAULT_FONT
#include <nuklear.h>
#include <nuklear_glfw_gl3.h>

void st3d_ui_new(void);
void st3d_ui_free(void);

void st3d_ui_begin(void);
void st3d_ui_end(void);

#endif
