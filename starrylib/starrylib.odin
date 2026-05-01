/*
# The Starry general purpose libraries

This packages features components of Starry which may be put into any program, without depending on
the runtime. It includes:
- the reference BMV implementation
- voxel model API
- magicavoxel's .vox support
- other utilities
*/
package starrylib

import "base:intrinsics"

VERSION_NUM :: 2026_05_00 // v2026.5.0
VERSION_STR :: "v2026.5.0-dev"
VERSION_MAJOR :: 2026
VERSION_MINOR :: 5
VERSION_PATCH :: 0

// A short string used in many places to uniquely identify something.
//
// Note that if creating those things is fully automatic, it's usually better to use an incrementing
// 32-bit index. For example:
// - layers, model attributes, etc: uses human-assigned tags
// - handles: fully handled by the engine on its own, doesn't need to be human-readable
Tag :: distinct [4]byte

// `stlib.tag("crap")` looks nicer than `[4]stlib.Tag{'c', 'r', 'a', 'p'}`
tag :: #force_inline proc "contextless" (src: $T) -> Tag
	where intrinsics.type_is_string(T)
{
	return Tag{src[0], src[1], src[2], src[3]}
}
