package starrylib

import "core:testing"

@(test)
test_tag_map32_basic :: proc(t: ^testing.T)
{
	m: Tag_Map(16, Tag32, int)

	// set
	testing.expect(t, tag_map_set(&m, tag32("helo"), 42))
	testing.expect(t, tag_map_set(&m, tag32("wrld"), 123))
	testing.expect(t, tag_map_set(&m, tag32("haha"), 999))

	// get
	v, ok := tag_map_get(&m, tag32("helo"))
	testing.expect(t, ok)
	testing.expect(t, v == 42)

	v, ok = tag_map_get(&m, tag32("wrld"))
	testing.expect(t, ok && v == 123)

	v, ok = tag_map_get(&m, tag32("haha"))
	testing.expect(t, ok && v == 999)

	// missing key
	_, ok = tag_map_get(&m, tag32("nope"))
	testing.expect(t, !ok)
}

@(test)
test_tag_map64_basic :: proc(t: ^testing.T)
{
	m: Tag_Map(16, Tag64, int)

	// set
	testing.expect(t, tag_map_set(&m, tag64("hello   "), 42))
	testing.expect(t, tag_map_set(&m, tag64("world   "), 123))
	testing.expect(t, tag_map_set(&m, tag64("hahahaha"), 999))

	// get
	v, ok := tag_map_get(&m, tag64("hello   "))
	testing.expect(t, ok)
	testing.expect(t, v == 42)

	v, ok = tag_map_get(&m, tag64("world   "))
	testing.expect(t, ok && v == 123)

	v, ok = tag_map_get(&m, tag64("hahahaha"))
	testing.expect(t, ok && v == 999)

	// missing key
	_, ok = tag_map_get(&m, tag64(" nuh uh "))
	testing.expect(t, !ok)
}

@(test)
test_tag_map_overwrite :: proc(t: ^testing.T)
{
	m: Tag_Map(8, Tag32, int)

	tag_map_set(&m, "test", 100)
	tag_map_set(&m, "test", 999) // overwrite

	v, ok := tag_map_get(&m, "test")
	testing.expect(t, ok && v == 999)
}

@(test)
test_tag_map_delete :: proc(t: ^testing.T)
{
	m: Tag_Map(16, Tag32, int)

	tag_map_set(&m, tag32("aaaa"), 1)
	tag_map_set(&m, tag32("bbbb"), 2)
	tag_map_set(&m, tag32("cccc"), 3)

	// delete middle key
	tag_map_delete_key(&m, tag32("bbbb"))

	// "b" should be gone
	v, ok := tag_map_get(&m, tag32("bbbb"))
	testing.expect(t, !ok)

	// others should still work
	v, ok = tag_map_get(&m, tag32("aaaa"))
	testing.expect(t, ok && v == 1)

	v, ok = tag_map_get(&m, tag32("cccc"))
	testing.expect(t, ok && v == 3)

	// re-insert deleted key
	testing.expect(t, tag_map_set(&m, tag32("bbbb"), 42))
	v, ok = tag_map_get(&m, tag32("bbbb"))
	testing.expect(t, ok && v == 42)
}

@(test)
test_tag_map_tombstone_probing :: proc(t: ^testing.T)
{
	m: Tag_Map(32, Tag32, int)

	// insert keys that collide
	for i: u8 = 0; i < 15; i += 1 {
		tag_map_set(&m, Tag32{i, 0, 0, 0}, int(i) * 10)
	}

	// delete some in the middle of probe sequences
	tag_map_delete_key(&m, Tag32{5, 0, 0, 0})
	tag_map_delete_key(&m, Tag32{6, 0, 0, 0})

	// insert new keys that would have collided with deleted ones
	testing.expect(t, tag_map_set(&m, Tag32{100, 0, 0, 0}, 999))
	testing.expect(t, tag_map_set(&m, Tag32{101, 0, 0, 0}, 888))

	// verify everything still works
	for i: u8 = 0; i < 15; i += 1 {
		if i == 5 || i == 6 do continue
		v, ok := tag_map_get(&m, Tag32{i, 0, 0, 0})
		testing.expectf(t, ok && v == int(i) * 10, "key %d failed", i)
	}

	v, ok := tag_map_get(&m, Tag32{100, 0, 0, 0})
	testing.expect(t, ok && v == 999)
}

@(test)
test_tag_map_full :: proc(t: ^testing.T)
{
	m: Tag_Map(8, Tag32, int)

	for i: u8 = 0; i < 8; i += 1 {
		ok := tag_map_set(&m, Tag32{i, 0, 0, 0}, int(i))
		testing.expectf(t, ok, "failed to insert key %d", i)
	}

	ok := tag_map_set(&m, Tag32{255, 0, 0, 0}, 999)
	testing.expect(t, !ok, "should not insert when full")
}
