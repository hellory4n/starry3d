# these are meant to be changed with --set VARIABLE VALUE
RELEASE := ""   # default: debug, can be 'minimal', 'size', or 'speed'
TARGET := ""    # default: native
SANITIZE := ""  # default: none

default: build-all

_RELEASE     := if RELEASE  == "" { "-debug" } else { f"-o:{{RELEASE}}" }
_SANITIZE    := if SANITIZE == "" { "" }       else { f"-sanitize:{{SANITIZE}}" }
_TARGET      := if TARGET   == "" { "" }       else { f"-target:{{TARGET}}" }

_BASE_CFLAGS := "-vet"
_CFLAGS      := f"{{_BASE_CFLAGS}} {{_TARGET}} {{_RELEASE}} {{_SANITIZE}}"

build-all: build-sandbox

@build-sandbox:
	@# build sandbox
	odin build sandbox {{_CFLAGS}}

@run-sandbox:
	@# run sandbox
	odin run sandbox {{_CFLAGS}}

@test:
	@# test starrylib
	odin test starrylib {{_CFLAGS}}
	@# test starrylib/model
	odin test starrylib/model
	@# test starrylib/model/bmv
	odin test starrylib/model/bmv
	@# test starrylib/model/pngslice
	odin test starrylib/model/pngslice
	@# test starrylib/model/vox
	odin test starrylib/model/vox
