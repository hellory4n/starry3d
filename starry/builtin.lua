--[[ preloaded Starry code ]]
local ffi = require("ffi")

ffi.cdef[[
void stlua_test(void);
]]

st = {}

function st.test()
	ffi.C.stlua_test()
end
