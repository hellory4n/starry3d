package starrylib

import "core:fmt"
import "core:hash"

// A fixed-size hashmap that uses tags as keys and performs no heap allocations for ultimate
// speedmaxxing at the club.
Tag_Map :: struct($N: int, $K: typeid, $V: typeid) where N > 0 && (K == Tag32 || K == Tag64) {
	buckets: [N]Tag_Map_Bucket(K, V),
	len:     int,
}

Tag_Map_Bucket :: struct($K: typeid, $V: typeid) {
	key:   K,
	value: V,
	full:  bool,
	dead:  bool,
}

_tag_map_find :: proc(
	m: ^$T/Tag_Map($N, $K, $V),
	key: K,
	return_if_dead := false,
) -> (
	bucket: ^Tag_Map_Bucket(K, V),
	full: bool,
)
{
	key := key
	start := hash.fnv32a(key[:]) % u32(N)
	i := start

	for {
		bucket = &m.buckets[i]
		if !bucket.full {
			return bucket, false
		}

		if return_if_dead {
			if bucket.key == key || bucket.dead {
				return bucket, false
			}
		} else if bucket.key == key && !bucket.dead {
			return bucket, false
		}

		i = (i + 1) % u32(N)
		if i == start {
			full = true
			return
		}
	}
}

// Sets or adds a key in the tag map.
tag_map_set :: proc(m: ^$T/Tag_Map($N, $K, $V), key: K, val: V) -> (ok: bool)
{
	bucket, full := _tag_map_find(m, key, return_if_dead = true)
	if full {
		return false
	}

	if bucket.dead || !bucket.full {
		bucket.full = true
		bucket.dead = false
		bucket.key = key
	}
	bucket.value = val
	m.len += 1
	return true
}

// Returns the value with that key, if available.
tag_map_get :: proc(m: ^$T/Tag_Map($N, $K, $V), key: K) -> (val: V, ok: bool) #optional_ok
{
	bucket, _ := _tag_map_find(m, key)
	if bucket.full && !bucket.dead {
		return bucket.value, true
	}

	ok = false
	return
}

// Removes the key wow amazing.
tag_map_delete_key :: proc(m: ^$T/Tag_Map($N, $K, $V), key: K)
{
	bucket, _ := _tag_map_find(m, key)
	if bucket.full && !bucket.dead {
		bucket.dead = true
		m.len -= 1
	}
}

// TODO iterator
