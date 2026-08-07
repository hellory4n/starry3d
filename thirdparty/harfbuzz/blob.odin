/*
H a r f b u z z  b i n d i n g s  - An Odin package with bindings to Harfbuzz.

blob.odin - Types and functions for managing binary blobs.

The HarfBuzz API itself is copyright of HarfBuzz copyright holders
Copyright for binding coding of (c) 2024, Maurizio M. Gavioli and contributors

LICENSING ("2-Clause BSD License a.k.a. Simplified BSD License a.k.a. FreeBSD License")

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1) Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
2) Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

(c) 2024, Maurizio M. Gavioli and contributors
author: Maurizio M. Gavioli, 2024-07-24

HARFBUZZ LICENSE

HarfBuzz itself is licensed under the so-called "Old MIT" license.
For up-to-date details, see https://github.com/harfbuzz/harfbuzz?tab=License-1-ov-file

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-blob.h
		https://harfbuzz.github.io/harfbuzz-hb-blob.html
*/

/* hb-blob — Binary data containers
Blobs wrap a chunk of binary data to handle lifecycle management of data
while it is passed between client and HarfBuzz. Blobs are primarily used to
to create font faces, but also to access font face tables, as well as pass
around other binary data.
*/

package	harfbuzz

import "core:c"

// TODO : check Windows library name
when ODIN_OS == .Windows	{	foreign import hb "windows/harfbuzz.lib"	}
else when ODIN_OS == .Linux	{	foreign import hb "system:harfbuzz"	}

//******************
// TYPES
//******************

//	typedef struct hb_blob_t hb_blob_t;
blob_t	::	struct {}						// opaque struture

/*Data type holding the memory modes available to client programs.

Regarding these various memory-modes:
- In no case shall the HarfBuzz client modify memory that is passed to HarfBuzz in a blob. If there is any such possibility, HB_MEMORY_MODE_DUPLICATE should be used such that HarfBuzz makes a copy immediately,
- Use HB_MEMORY_MODE_READONLY otherwise, unless you really really really know what you are doing,
- HB_MEMORY_MODE_WRITABLE is appropriate if you really made a copy of data solely for the purpose of passing to HarfBuzz and doing that just once (no reuse!),
- If the font is mmap()ed, it's okay to use HB_MEMORY_MODE_READONLY_MAY_MAKE_WRITABLE , however, using that mode correctly is very tricky. Use HB_MEMORY_MODE_READONLY instead.
*/
memory_mode_t :: enum c.int
{
	MEMORY_MODE_DUPLICATE,		// HarfBuzz immediately makes a copy of the data.
	MEMORY_MODE_READONLY,		// HarfBuzz client will never modify the data, and HarfBuzz will never modify the data.
	MEMORY_MODE_WRITABLE,		// HarfBuzz client made a copy of the data solely for HarfBuzz, so HarfBuzz may modify the data.
	MEMORY_MODE_READONLY_MAY_MAKE_WRITABLE,
}

//******************
// FUNCTIONS */
//******************

@(default_calling_convention = "c", link_prefix = "hb_") foreign hb
{

/* hb_blob_t * hb_blob_create (const char *data, unsigned int length, hb_memory_mode_t mode, void *user_data, hb_destroy_func_t destroy);

Creates a new "blob" object wrapping data . The mode parameter is used to negotiate ownership and lifecycle of data .
- data		Pointer to blob data.
- length	Length of data in bytes.
- mode		Memory mode for data.
- user_data	Data parameter to pass to destroy .
- destroy	Callback to call when data is not needed anymore.
- Returns	New blob, or the empty blob if something failed or if length is zero. Destroy with hb_blob_destroy().
* */
blob_create	:: proc(data: [^]byte, length: c.uint, mode: memory_mode_t, user_data: rawptr, destroy: destroy_func_t)	-> ^blob_t ---

/*
hb_blob_t * hb_blob_create_or_fail (const char *data, unsigned int length, hb_memory_mode_t mode, void *user_data, hb_destroy_func_t destroy);

Creates a new "blob" object wrapping data . The mode parameter is used to negotiate ownership and lifecycle of data .
Note that this function returns a freshly-allocated empty blob even if length is
zero. This is in contrast to hb_blob_create(), which returns the singleton empty
blob (as returned by hb_blob_get_empty()) if length is zero.

Returns	New blob, or NULL if failed. Destroy with hb_blob_destroy().
*/
//blob_create_or_fail (data: [^]byte, length: c.uint, mode: memory_mode_t, user_data: rawptr, destroy: destroy_func_t)	-> ^blob_t ---	// since: 2.8.2

/*
hb_blob_t * hb_blob_create_from_file (const char *file_name);

Creates a new blob containing the data from the specified binary font file.
The filename is passed directly to the system on all platforms, except on Windows, where the filename is interpreted as UTF-8. Only if the filename is not valid UTF-8, it will be interpreted according to the system codepage.
Returns	An hb_blob_t pointer with the content of the file, or hb_blob_get_empty() if failed.
*/
blob_create_from_file	:: proc(file_name: cstring)	-> ^blob_t ---

/*
hb_blob_t * hb_blob_create_from_file_or_fail (const char *file_name);

Creates a new blob containing the data from the specified binary font file.
The filename is passed directly to the system on all platforms, except on Windows, where the filename is interpreted as UTF-8. Only if the filename is not valid UTF-8, it will be interpreted according to the system codepage.
Returns	An hb_blob_t pointer with the content of the file, or NULL if failed.
*/
//blob_create_from_file_or_fail (const char *file_name)	-> ^blob_t ---	// since: 2.8.2

/*
hb_blob_t * hb_blob_create_sub_blob (hb_blob_t *parent, unsigned int offset, unsigned int length);

Returns a blob that represents a range of bytes in parent . The new blob is always created
with HB_MEMORY_MODE_READONLY, meaning that it will never modify data in the parent blob.
The parent data is not expected to be modified, and will result in undefined behavior if it is.
Makes parent immutable.
- parent	Parent blob.
- offset	Start offset of sub-blob within parent , in bytes.
- length	Length of sub-blob.
Returns		New blob, or the empty blob if something failed or if length is zero or offset
			is beyond the end of parent 's data. Destroy with hb_blob_destroy().
*/
blob_create_sub_blob	:: proc(parent: ^blob_t, offset: c.uint, length: c.uint)	-> ^blob_t ---

/*
hb_blob_t * hb_blob_copy_writable_or_fail (hb_blob_t *blob);

Makes a writable copy of blob.
Returns		The new blob, or nullptr if allocation failed
*/
blob_copy_writable_or_fail	:: proc(blob: ^blob_t)	-> ^blob_t ---

/*
hb_blob_t * hb_blob_get_empty (void);

Returns the singleton empty blob.
*/
blob_get_empty	:: proc()	-> ^blob_t ---

/*
hb_blob_t * hb_blob_reference (hb_blob_t *blob);

Increases the reference count on blob .
Returns		the blob
*/
blob_reference	:: proc(blob: ^blob_t)	-> ^blob_t ---

/*
void hb_blob_destroy (hb_blob_t *blob);

Decreases the reference count on blob , and if it reaches zero, destroys blob , freeing all memory,
possibly calling the destroy-callback the blob was created for if it has not been called already.
*/
blob_destroy	:: proc(blob: ^blob_t)	---

/*
hb_bool_t hb_blob_set_user_data (hb_blob_t *blob, hb_user_data_key_t *key, void *data, hb_destroy_func_t destroy, hb_bool_t replace);

Attaches a user-data key/data pair to the specified blob.
- blob		An hb_blob_t
- key		The user-data key to set
- data		A pointer to the user data to set
- destroy	A callback to call when data is not needed anymore [nullable].
- replace	Whether to replace an existing data with the same key
Returns		true if success, false otherwise
*/
blob_set_user_data	:: proc(blob: ^blob_t, key: ^user_data_key_t, data: rawptr, destroy: destroy_func_t, replace: bool_t)	-> bool_t ---

/*
void * hb_blob_get_user_data (const hb_blob_t *blob, hb_user_data_key_t *key);

Fetches the user data associated with the specified key, attached to the specified font-functions structure.
- blob		a blob
- key		The user-data key to query
Returns		A pointer to the user data. [transfer none]
*/
blob_get_user_data	:: proc(blob: /*const*/ ^blob_t, key: ^user_data_key_t)	-> rawptr ---

/*
void hb_blob_make_immutable (hb_blob_t *blob);

Makes a blob immutable.
*/

blob_make_immutable	:: proc(blob: ^blob_t)	---

/*
hb_bool_t hb_blob_is_immutable (hb_blob_t *blob);

Tests whether a blob is immutable.
Returns		true if blob is immutable, false otherwise
*/
blob_is_immutable	:: proc(blob: ^blob_t)	-> bool_t ---

/*
const char * hb_blob_get_data (hb_blob_t *blob, unsigned int *length);

Fetches the data from a blob.
- blob		a blob.
- length	The length in bytes of the data retrieved. [out]
Returns		the byte data of blob. [nullable][transfer none][array length=length]
*/
blob_get_data	:: proc(blob: ^blob_t, length: ^c.uint)	-> /*const*/ [^]byte ---

/*
char * hb_blob_get_data_writable (hb_blob_t *blob, unsigned int *length);

Tries to make blob data writable (possibly copying it) and return pointer to data.

Fails if blob has been made immutable, or if memory allocation fails.
- blob		a blob.
- length	output length of the writable data. [out]
Returns		Writable blob data, or NULL if failed. [transfer none][array length=length]
*/
blob_get_data_writable	:: proc(blob: ^blob_t, length: ^c.uint)	-> [^]byte ---

/*
unsigned int hb_blob_get_length (hb_blob_t *blob);

Fetches the length of a blob's data.
*/
blob_get_length	::proc (blob: ^blob_t)	-> c.uint ---

}
