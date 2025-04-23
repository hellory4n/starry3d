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

// not static because nuklear wants this callback too so if nuklear is setup, we override this callback
// and then give the scroll state back to nuklear lmao
// this is from st3d.c
void __st3d_on_scroll(GLFWwindow* window, double x, double y);

struct nk_context* st3d_nkctx(void)
{
	return st3d_nk;
}

void st3d_ui_new(const char* font_path, int64_t font_size)
{
	// path.
	TrArena tmp = tr_arena_new(TR_KB(1));
	TrString sitrnmvhz = tr_slice_new(&tmp, ST3D_PATH_SIZE, sizeof(char));
	st3d_path(font_path, &sitrnmvhz);

	st3d_nk = nk_glfw3_init(&st3d_glfw, st3d_get_window_handle(), NK_GLFW3_INSTALL_CALLBACKS);
	// nuklear wants this callback too so if nuklear is setup, we override this callback
	// and then give the scroll state back to nuklear lmao
	glfwSetScrollCallback(st3d_get_window_handle(), __st3d_on_scroll);

	// font.
	struct nk_font_atlas* atlas;
	nk_glfw3_font_stash_begin(&st3d_glfw, &atlas);
	struct nk_font* font = nk_font_atlas_add_from_file(atlas, sitrnmvhz.buffer, font_size, NULL);
	nk_glfw3_font_stash_end(&st3d_glfw);
	// it look bad
	// nk_style_load_all_cursors(st3d_nk, atlas->cursors);
	nk_style_set_font(st3d_nk, &font->handle);

	tr_liblog("initialized nuklear");
	tr_arena_free(&tmp);
}

void st3d_ui_free(void)
{
	nk_glfw3_shutdown(&st3d_glfw);
}

void st3d_ui_begin(void)
{
	// starry3d and nuklear both try to set the scroll callback
	// so this is just passing the scroll shitfuck back to nuklear
	TrVec2f scroll = st3d_mouse_scroll();
	struct nk_glfw* glfw = (struct nk_glfw*)glfwGetWindowUserPointer(st3d_get_window_handle());
    glfw->scroll.x += (float)scroll.x;
    glfw->scroll.y += (float)scroll.y;

	nk_glfw3_new_frame(&st3d_glfw);
}

void st3d_ui_end(void)
{
	// pain.
	// note: this changes opengl's state and then resets everything to the default
	// so i'll probably have to do some tweaking for everything to work
	nk_glfw3_render(&st3d_glfw, NK_ANTI_ALIASING_OFF, ST3D_NK_MAX_VERTEX_BUFFER, ST3D_NK_MAX_ELEMENT_BUFFER);
}
