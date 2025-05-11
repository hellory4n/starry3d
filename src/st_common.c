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

// yes this is intentional
// don't want to make users have to compile a lot of random crap
#include <whereami.c>

#include <math.h>
#include <string.h>
#include <stdio.h>
#include "st_common.h"
#include "st_window.h"
#include "st_render.h"
#include "st_voxel.h"

static TrArena st_arena;

static TrString st_app;
static TrString st_assets;
static TrString st_full_exe_dir;
static TrString st_full_user_dir;
static bool st_exe_dir_fetched;
static bool st_user_dir_fetched;

void st_init(StSettings settings)
{
	st_arena = tr_arena_new(TR_MB(1));

	st_full_exe_dir = tr_slice_new(&st_arena, ST_PATH_SIZE, sizeof(char));
	st_full_user_dir = tr_slice_new(&st_arena, ST_PATH_SIZE, sizeof(char));
	st_app = tr_slice_new(&st_arena, ST_PATH_SIZE, sizeof(char));
	st_assets = tr_slice_new(&st_arena, ST_PATH_SIZE, sizeof(char));
	strncpy(st_app.buffer, settings.app_name, ST_PATH_SIZE);
	strncpy(st_assets.buffer, settings.asset_dir, ST_PATH_SIZE);

	// man
	st_open_window(&st_arena, settings.app_name, settings.window_width, settings.window_height);
	st_render_init();
	st_vox_init();
}

void st_free(void)
{
	st_vox_free();
	st_render_free();
	st_close_window();

	tr_arena_free(&st_arena);
	tr_liblog("deinitialized starry3d");
}

void st_app_dir(TrString* out)
{
	// no need to get it twice
	if (st_exe_dir_fetched) {
		memcpy(out->buffer, st_full_exe_dir.buffer, (size_t)fmin(out->length, st_full_exe_dir.length));
		return;
	}

	// actually get the path :)
	// yes this is how you're supposed to use whereami
	int dirname_len;
	wai_getExecutablePath(st_full_exe_dir.buffer, st_full_exe_dir.length, &dirname_len);
	*TR_AT(st_full_exe_dir, char, dirname_len) = '\0';
	tr_liblog("executable directory: %s", (char*)st_full_exe_dir.buffer);

	memcpy(out->buffer, st_full_exe_dir.buffer, (size_t)fmin(out->length, st_full_exe_dir.length));
	st_exe_dir_fetched = true;
}

void st_user_dir(TrString* out)
{
	// no need to get it twice
	if (st_user_dir_fetched) {
		memcpy(out->buffer, st_full_user_dir.buffer, (size_t)fmin(out->length, st_full_user_dir.length));
		return;
	}

	// actually get the path :)
	// TODO will probably segfault if you have a really weird setup or smth
	#ifdef ST_WINDOWS
	char* sigma = getenv("APPDATA");
	snprintf(st_full_user_dir.buffer, st_full_user_dir.length, "%s/%s", sigma, (char*)st_app.buffer);
	#else
	char* sigma = getenv("HOME");
	snprintf(st_full_user_dir.buffer, st_full_user_dir.length, "%s/.local/share/%s", sigma,
		(char*)st_app.buffer);
	#endif
	tr_liblog("user directory: %s", (char*)st_full_user_dir.buffer);

	memcpy(out->buffer, st_full_user_dir.buffer, (size_t)fmin(out->length, st_full_user_dir.length));
	st_user_dir_fetched = true;
}

void st_path(const char* s, TrString* out)
{
	if (out->length < ST_PATH_SIZE) {
		tr_warn("buffer may not be large enough to store path");
	}

	if (strncmp(s, "app:", 4) == 0) {
		// remove the prefix
		const char* trimmed = s + 4;
		TrString stigma = tr_slice_new(&st_arena, ST_PATH_SIZE, sizeof(char));
		st_app_dir(&stigma);
		snprintf(out->buffer, out->length, "%s/%s/%s", (char*)stigma.buffer, (char*)st_assets.buffer, trimmed);
	}
	else if (strncmp(s, "usr:", 4) == 0) {
		// remove the prefix
		const char* trimmed = s + 4;
		TrString stigma = tr_slice_new(&st_arena, ST_PATH_SIZE, sizeof(char));
		st_user_dir(&stigma);
		snprintf(out->buffer, out->length, "%s/%s", (char*)stigma.buffer, trimmed);
	}
	else {
		tr_panic("you fucking legumes did you read the documentation for st_path");
	}
}

