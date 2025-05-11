/*
 * Starry3D: C voxel game engine
 * More information at https://github.com/hellory4n/starry3d
 *
 * Copyright (C) 2025 by hellory4n <hellory4n@gmail.com>
 *
 * Permission to use, copy, modify, and/or distribute this
 * software for any purpose with or without fee is hereby
 * granted.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS
 * ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
 * WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
 * TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE
 * USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

#include <glad/gl.h>
#define NK_IMPLEMENTATION
#define NK_GLFW_GL3_IMPLEMENTATION
// nuklear is included here
// it's 30k lines, i assume including that twice would be a bit much
#include "st_ui.h"
#include "st_window.h"
#include "st_common.h"

// stolen from the nuklear glfw example
#define ST_NK_MAX_VERTEX_BUFFER 512 * 1024
#define ST_NK_MAX_ELEMENT_BUFFER 128 * 1024

static struct nk_glfw st_glfw = {0};
static struct nk_context* st_nk;

// not static because nuklear wants this callback too so if nuklear is setup, we override this callback
// and then give the scroll state back to nuklear lmao
// this is from st_window.c
void __st_on_scroll(GLFWwindow* window, double x, double y);

struct nk_context* st_nkctx(void)
{
	return st_nk;
}

void st_ui_new(const char* font_path, int64_t font_size)
{
	// path.
	TrArena tmp = tr_arena_new(TR_KB(1));
	TrString sitrnmvhz = tr_slice_new(&tmp, ST_PATH_SIZE, sizeof(char));
	st_path(font_path, &sitrnmvhz);

	st_nk = nk_glfw3_init(&st_glfw, st_get_window_handle(), NK_GLFW3_INSTALL_CALLBACKS);
	// nuklear wants this callback too so if nuklear is setup, we override this callback
	// and then give the scroll state back to nuklear lmao
	glfwSetScrollCallback(st_get_window_handle(), __st_on_scroll);

	// font.
	struct nk_font_atlas* atlas;
	nk_glfw3_font_stash_begin(&st_glfw, &atlas);
	struct nk_font* font = nk_font_atlas_add_from_file(atlas, sitrnmvhz.buffer, font_size, NULL);
	nk_glfw3_font_stash_end(&st_glfw);
	// it look bad
	// nk_style_load_all_cursors(st_nk, atlas->cursors);
	nk_style_set_font(st_nk, &font->handle);

	tr_liblog("initialized nuklear");
	tr_arena_free(&tmp);
}

void st_ui_free(void)
{
	nk_glfw3_shutdown(&st_glfw);
}

void st_ui_begin(void)
{
	// starry3d and nuklear both try to set the scroll callback
	// so this is just passing the scroll shitfuck back to nuklear
	TrVec2f scroll = st_mouse_scroll();
	struct nk_glfw* glfw = (struct nk_glfw*)glfwGetWindowUserPointer(st_get_window_handle());
    glfw->scroll.x += (float)scroll.x;
    glfw->scroll.y += (float)scroll.y;

	nk_glfw3_new_frame(&st_glfw);
}

void st_ui_end(void)
{
	// pain.
	// note: this changes opengl's state and then resets everything to the default
	// so i'll probably have to do some tweaking for everything to work
	nk_glfw3_render(&st_glfw, NK_ANTI_ALIASING_OFF, ST_NK_MAX_VERTEX_BUFFER, ST_NK_MAX_ELEMENT_BUFFER);
}
