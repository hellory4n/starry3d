/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/internal.cpp
 * Internal parts of the library :)
 *
 * Copyright (c) 2025 hellory4n <hellory4n@gmail.com>
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 *
 */

#include "starry/internal.h"

#include <trippin/common.h>
#include <trippin/iofs.h>
#include <trippin/log.h>
#include <trippin/memory.h>

#include "starry/app.h"

namespace st {

// it has to live somewhere
Starry* _st = nullptr;

}

void st::_preinit()
{
	// TODO this could be a thing in libtrippin
	for (auto [_, path] : _st->settings.logfiles) {
		tr::use_log_file(path);
	}
	tr::init();

	if (_st->settings.user_dir == "") {
		_st->settings.user_dir = _st->settings.name;
	}
	tr::set_paths(_st->settings.app_dir, _st->settings.user_dir);

	tr::info("starry3d %s", st::VERSION);
	tr::info("app:// pointing to %s", *tr::path(tr::scratchpad(), "app://"));
	tr::info("user:// pointing to %s", *tr::path(tr::scratchpad(), "user://"));

	// make sure user:// and app:// exists
	tr::String userdir = tr::path(tr::scratchpad(), "user://");
	tr::create_dir(userdir).unwrap();
	TR_ASSERT_MSG(tr::path_exists(userdir), "couldn't create user://");
	TR_ASSERT_MSG(
		tr::path_exists(tr::path(tr::scratchpad(), "app://")),
		"app:// is pointing to an invalid directory, are you sure this is the right path?"
	);

	tr::info("preinitialized successfully");
}

void st::_postfree()
{
	_st->asset_arena.free();
	// _st itself is on that arena
	// TODO this WILL break
	_st->arena.free();
	_st = nullptr;
}
