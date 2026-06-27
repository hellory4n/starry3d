package starrylib

import "core:fmt"
import "core:strings"
import "core:testing"

@(test)
test_string_ids :: proc(t: ^testing.T)
{
	// odin's test runner is multi-threaded, string IDs rely on global state
	// so this has to be all in one function otherwise everything will explode and die
	// TODO make it thread safe (writing needs a lock, reading can fuck off)
	testing.expect_value(t, init_string_ids(), nil)
	defer free_string_ids()

	id1 := strid("crapfrico")
	testing.expect(t, id1 > 0)

	id2 := strid("crapfrico")
	testing.expect_value(t, id2, id1)

	str := strings.clone("crapfrico")
	defer delete(str)
	id3 := strid(str)
	testing.expect_value(t, id3, id1)

	id4 := strid("crapflico")
	testing.expect(t, id4 != id1)

	id5 := strid("h")
	testing.expect(t, id5 != id1)

	id_occurrences: map[String_Id]int
	defer delete(id_occurrences)

	for i in 0 ..< 1000 {
		id := strid(fmt.tprintf("bloody %i", i))
		id_occurrences[id] += 1
	}

	for _, occurrences in id_occurrences {
		testing.expect_value(t, occurrences, 1)
	}

	id := strid("crapfrico")
	testing.expect_value(t, readable_strid(id), "crapfrico")
}
