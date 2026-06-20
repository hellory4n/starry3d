# these are meant to be changed with --set VARIABLE VALUE
RELEASE := ""   # default: debug, can be 'minimal', 'size', or 'speed'
TARGET := ""    # default: native
SANITIZE := ""  # default: none

_RELEASE     := if RELEASE  == "" { "-debug -o:minimal" } else { f"-o:{{RELEASE}}" }
_SANITIZE    := if SANITIZE == "" { "" }       else { f"-sanitize:{{SANITIZE}}" }
_TARGET      := if TARGET   == "" { "" }       else { f"-target:{{TARGET}}" }

_BASE_CFLAGS := "-vet-cast -vet-shadowing -vet-unused-variables"
_CFLAGS      := f"{{_BASE_CFLAGS}} {{_TARGET}} {{_RELEASE}} {{_SANITIZE}}"

@test:
	@# test starrylib
	odin test starrylib {{_CFLAGS}}

# but why would you do that
run-all-samples: \
	run-hello run-custom-asset-loaders \
	run-gpu-triangle run-gpu-bufferless run-gpu-uniform-buffers run-gpu-textures \
	run-gpu-framebuffers run-gpu-storage-buffers \
	run-3d-scene

@run-hello:
	@# run hello
	odin run samples/hello {{_CFLAGS}}

@run-custom-asset-loaders:
	@# run custom asset loaders
	odin run samples/custom_asset_loaders {{_CFLAGS}}

@run-gpu-triangle:
	@# run gpu triangle
	odin run samples/gpu_triangle {{_CFLAGS}}

@run-gpu-bufferless:
	@# run gpu bufferless
	odin run samples/gpu_bufferless {{_CFLAGS}}

@run-gpu-uniform-buffers:
	@# run gpu uniform buffers
	odin run samples/gpu_uniform_buffers {{_CFLAGS}}

@run-gpu-textures:
	@# run gpu textures
	odin run samples/gpu_textures {{_CFLAGS}}

@run-gpu-framebuffers:
	@# run gpu framebuffers
	odin run samples/gpu_framebuffers {{_CFLAGS}}

@run-gpu-storage-buffers:
	@# run gpu storage buffers
	odin run samples/gpu_storage_buffers {{_CFLAGS}}

@run-3d-scene:
	@# run 3D scene
	odin run samples/3d_scene {{_CFLAGS}}

@run-lua-hello:
	@# run hello (lua)
	odin run starryluarunner -- samples/lua/hello/config.lua
