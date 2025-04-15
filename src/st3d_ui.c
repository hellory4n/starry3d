#include <glad/gl.h>
#define NK_IMPLEMENTATION
#define NK_GLFW_GL3_IMPLEMENTATION
// nuklear is included here
// it's 30k lines, i assume including that twice would be a bit much
#include "st3d_ui.h"
#include "st3d.h"

// stolen from the nuklear glfw example
#define ST3D_NK_MAX_VERTEX_BUFFER 512 * 1024
#define ST3D_NK_MAX_ELEMENT_BUFFER 128 * 1024

static struct nk_glfw st3d_glfw = {0};
static struct nk_context* st3d_nk;

struct nk_context* st3d_nkctx(void)
{
	return st3d_nk;
}

void st3d_ui_new(const char* font_path, int64_t font_size)
{
	st3d_nk = nk_glfw3_init(&st3d_glfw, st3d_get_window_handle(), NK_GLFW3_DEFAULT);

	// font.
	struct nk_font_atlas* atlas;
	nk_glfw3_font_stash_begin(&st3d_glfw, &atlas);
	struct nk_font* font = nk_font_atlas_add_from_file(atlas, font_path, font_size, NULL);
	nk_glfw3_font_stash_end(&st3d_glfw);
	// it look bad
	// nk_style_load_all_cursors(st3d_nk, atlas->cursors);
	nk_style_set_font(st3d_nk, &font->handle);

	tr_liblog("initialized nuklear");
}

void st3d_ui_free(void)
{
	nk_glfw3_shutdown(&st3d_glfw);
}

void st3d_ui_begin(void)
{
	nk_glfw3_new_frame(&st3d_glfw);
}

void st3d_ui_end(void)
{
	// pain.
	// note: this changes opengl's state and then resets everything to the default
	// so i'll probably have to do some tweaking for everything to work
	nk_glfw3_render(&st3d_glfw, NK_ANTI_ALIASING_OFF, ST3D_NK_MAX_VERTEX_BUFFER, ST3D_NK_MAX_ELEMENT_BUFFER);
}
