--- @meta

--- magical internal library, please don't use
--- @class __stlib
__st = {}

--- @param x number
--- @return number
function __st.round(x) end

--- @param x number
--- @param y number
--- @param z number
--- @return number imag
--- @return number jmag
--- @return number kmag
--- @return number real
function __st.euler_to_quat(x, y, z) end

--- @param imag number
--- @param jmag number
--- @param kmag number
--- @param real number
--- @return number x
--- @return number y
--- @return number z
function __st.quat_to_euler(imag, jmag, kmag, real) end
