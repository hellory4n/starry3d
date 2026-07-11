-- preloaded code: gpu.lua
local ffi = require("ffi")

ffi.cdef [[
int32_t st_app_gpu(void);
void stgpu_begin_render_pass(int32_t dev, int32_t framebuffer, int32_t color_load_op, int32_t color_store_op, int32_t depth_load_op, int32_t depth_store_op, float clear_color_r, float clear_color_g, float clear_color_b, float clear_color_a, float clear_depth);
void stgpu_end_render_pass(int32_t dev);
int32_t stgpu_default_framebuffer(int32_t dev);
]]

st = st or {}
st.gpu = st.gpu or {}
st.app = st.app or {}

--- @class st.gpu.Device
--- @field v integer
st.gpu.Device = {}
st.gpu.Device.__index = st.gpu.Device

--- @class st.gpu.Pipeline
--- @field v integer
st.gpu.Pipeline = {}
st.gpu.Pipeline.__index = st.gpu.Pipeline

--- @class st.gpu.Shader
--- @field v integer
st.gpu.Shader = {}
st.gpu.Shader.__index = st.gpu.Shader

--- @class st.gpu.Buffer
--- @field v integer
st.gpu.Buffer = {}
st.gpu.Buffer.__index = st.gpu.Buffer

--- @class st.gpu.Texture
--- @field v integer
st.gpu.Texture = {}
st.gpu.Texture.__index = st.gpu.Texture

--- @class st.gpu.Sampler
--- @field v integer
st.gpu.Sampler = {}
st.gpu.Sampler.__index = st.gpu.Sampler

--- @class st.gpu.Framebuffer
--- @field v integer
st.gpu.Framebuffer = {}
st.gpu.Framebuffer.__index = st.gpu.Framebuffer

--- Returns the current GPU device
--- @return st.gpu.Device
function st.app.gpu()
	local self = {}
	self.v = ffi.C.st_app_gpu()
	return setmetatable(self, st.gpu.Device)
end

--- @enum (key) st.gpu.Load_Op
st.gpu.Load_Op = {
	dont_care = 0,
	load = 1,
	clear = 2,
}

--- @enum (key) st.gpu.Store_Op
st.gpu.Store_Op = {
	dont_care = 0,
	store = 1,
}

--- @class st.gpu.Render_Pass_Desc
--- @field framebuffer st.gpu.Framebuffer
--- @field color_load_op st.gpu.Load_Op
--- @field color_store_op st.gpu.Store_Op? Defaults to "store"
--- @field depth_load_op st.gpu.Load_Op? Defaults to "dont_care"
--- @field depth_store_op st.gpu.Store_Op? Defaults to "dont_care"
--- @field clear_color Vec4?
--- @field clear_depth number?

--- @param desc st.gpu.Render_Pass_Desc
function st.gpu.Device:begin_render_pass(desc)
	ffi.C.stgpu_begin_render_pass(
		self.v,                                -- dev
		desc.framebuffer.v,                    -- framebuffer
		st.gpu.Load_Op[desc.color_load_op],    -- color_load_op
		st.gpu.Store_Op[desc.color_store_op or "store"], -- color_store_op
		st.gpu.Load_Op[desc.depth_load_op or "dont_care"], -- depth_load_op
		st.gpu.Store_Op[desc.depth_store_op or "dont_care"], -- depth_store_op
		desc.clear_color.r or 0,               -- clear_color_r
		desc.clear_color.g or 0,               -- clear_color_g
		desc.clear_color.b or 0,               -- clear_color_b
		desc.clear_color.a or 0,               -- clear_color_a
		desc.clear_depth or 0                  -- clear_depth
	)
end

function st.gpu.Device:end_render_pass()
	ffi.C.stgpu_end_render_pass(self.v)
end

--- @return st.gpu.Framebuffer
function st.gpu.Device:default_framebuffer()
	local handle = ffi.C.stgpu_default_framebuffer(self.v)
	return setmetatable({ v = handle }, st.gpu.Framebuffer)
end
