#include <stdbool.h>
#include <string.h>
#include <libtrippin.h>
#include "st3d_core.h"
#include "st3d_render.h"
#include "st3d_window.h"

St3dCtx st3d_init(const char* app, const char* assets, int32_t width, int32_t height)
{
	tr_init("log.txt");

	St3dCtx ctx = {0};
	ctx.arena = tr_arena_new(TR_MB(1));
	memcpy(ctx.app_dir, assets, 64);
	memcpy(ctx.user_dir, app, 64);
	st3di_window_new(&ctx, width, height, app);
	st3di_gl_new(&ctx);

	tr_log(TR_LOG_LIB_INFO, "initialized starry3d");
	return ctx;
}

void st3d_free(St3dCtx* ctx)
{
	// this should go in the order in which st3d_init initializes things, but backwards

	st3di_gl_free(ctx);
	st3di_window_free(ctx);
	tr_arena_free(ctx->arena);

	tr_log(TR_LOG_LIB_INFO, "deinitialized starry3d");
	tr_free();
}
