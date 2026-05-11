# these are meant to be changed with --set VARIABLE VALUE
RELEASE := ""   # default: debug, can be 'minimal', 'size', or 'speed'
TARGET := ""    # default: native
SANITIZE := ""  # default: none

_RELEASE     := if RELEASE  == "" { "-debug" } else { f"-o:{{RELEASE}}" }
_SANITIZE    := if SANITIZE == "" { "" }       else { f"-sanitize:{{SANITIZE}}" }
_TARGET      := if TARGET   == "" { "" }       else { f"-target:{{TARGET}}" }

_BASE_CFLAGS := "-vet-cast -vet-shadowing -vet-unused-variables"
_CFLAGS      := f"{{_BASE_CFLAGS}} {{_TARGET}} {{_RELEASE}} {{_SANITIZE}}"

@test:
	@# test starrylib
	odin test starrylib {{_CFLAGS}}
	@# test starrylib/model
	odin test starrylib/model {{_CFLAGS}}
	@# test starrylib/model/bmv
	odin test starrylib/model/bmv {{_CFLAGS}}
	@# test starrylib/model/pngslice
	odin test starrylib/model/pngslice {{_CFLAGS}}
	@# test starrylib/model/vox
	odin test starrylib/model/vox {{_CFLAGS}}

# but why would you do that
run-all-examples: \
	run-hello run-gpu-triangle run-gpu-bufferless run-gpu-textures run-gpu-uniforms

@run-hello:
	@# run hello
	odin run examples/hello {{_CFLAGS}}

@run-gpu-triangle:
	@# run gpu triangle
	odin run examples/gpu_triangle {{_CFLAGS}}

@run-gpu-bufferless:
	@# run gpu bufferless
	odin run examples/gpu_bufferless {{_CFLAGS}}

@run-gpu-textures:
	@# run gpu textures
	odin run examples/gpu_textures {{_CFLAGS}}

@run-gpu-uniforms:
	@# run gpu uniforms
	odin run examples/gpu_uniforms {{_CFLAGS}}
