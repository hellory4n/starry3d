-- preloaded code: builtin.lua
local ffi = require("ffi")

st = {}

ffi.cdef[[
void st_test(void);
]]

function st.test()
	ffi.C.st_test()
end
