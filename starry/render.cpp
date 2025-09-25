/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/render.cpp
 * The renderer's name is Kyler. Be nice to Kyler. Thanks.
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

#include "starry/render.h"

#include <glad/gl.h>

void st::_test_pipeline()
{
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	// glEnable(GL_CULL_FACE);
	// glCullFace(GL_BACK);
	// glFrontFace(GL_CCW);

	glEnable(GL_DEPTH_TEST);

	glLineWidth(2.5);
}

void st::set_wireframe_mode(bool val)
{
	glPolygonMode(GL_FRONT_AND_BACK, val ? GL_LINE : GL_FILL);
}

st::PackedModelVertex::PackedModelVertex(ModelVertex src)
{
	// TODO this probably (definitely) only works in little endian who gives a shit
	// the format is helpfully documented in the header (so read that if you're confused)
	uint64 bits = 0;

	bits |= uint64(src.position.x & 0xFF) << 0;
	bits |= uint64(src.position.y & 0xFF) << 8;
	bits |= uint64(src.position.z & 0xFF) << 16;

	bits |= uint64(int(src.normal) & 0xF) << 24;
	bits |= uint64(int(src.corner) & 0x3) << 28;
	bits |= uint64(int(src.shaded) & 0x1) << 30;
	bits |= uint64(int(src.using_texture) & 0x1) << 31;

	// unioning all over the plcae
	if (src.using_texture) {
		bits |= uint64(src.texture_id & 0x3FFF) << 32;
	}
	else {
		bits |= uint64(src.color.r & 0xFF) << 32;
		bits |= uint64(src.color.g & 0xFF) << 40;
		bits |= uint64(src.color.b & 0xFF) << 48;
		bits |= uint64(src.color.a & 0xFF) << 56;
	}

	x = uint32(bits & 0xFFFFFFFFu);
	y = uint32((bits >> 32) & 0xFFFFFFFFu);
}
