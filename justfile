# these are meant to be changed with --set VARIABLE VALUE
RELEASE := ""   # default: debug, can be 'minimal', 'size', or 'speed'
TARGET := ""    # default: native
SANITIZE := ""  # default: none

_RELEASE   := if RELEASE  == "" { "-debug -o:minimal" } else { f"-o:{{RELEASE}}" }
_SANITIZE  := if SANITIZE == "" { "" }                  else { f"-sanitize:{{SANITIZE}}" }
_TARGET    := if TARGET   == "" { "" }                  else { f"-target:{{TARGET}}" }

_BASE_CFLAGS := "-vet-cast -vet-shadowing -vet-using-stmt"

_EXE_NAME := if os() == "windows" { "./starry.exe" } else { "./starry.bin" }
_STUDIO_EXE := if os() == "windows" { "./studio.exe" } else { "./studio.bin" }

_CFLAGS := \
	f"{{_BASE_CFLAGS}} {{_TARGET}} {{_RELEASE}} {{_SANITIZE}}"

set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]

build-starry:
	odin build starry {{_CFLAGS}} -out:{{_EXE_NAME}}

test: build-starry
	{{_EXE_NAME}} -app-dir:test

@release:
	python misc/release.py

# but why would you do that
run-all-samples: build-starry \
	run-hello run-delta-time run-input-keys run-input-mouse \
	run-rectangles run-unicode run-text-layout run-scissor-test

run-hello: build-starry
	{{_EXE_NAME}} -app-dir:samples/hello

run-delta-time: build-starry
	{{_EXE_NAME}} -app-dir:samples/delta_time

run-rectangles: build-starry
	{{_EXE_NAME}} -app-dir:samples/rectangles

run-input-keys: build-starry
	{{_EXE_NAME}} -app-dir:samples/input_keys

run-input-mouse: build-starry
	{{_EXE_NAME}} -app-dir:samples/input_mouse

run-unicode: build-starry
	{{_EXE_NAME}} -app-dir:samples/unicode

run-text-layout: build-starry
	{{_EXE_NAME}} -app-dir:samples/text_layout

run-scissor-test: build-starry
	{{_EXE_NAME}} -app-dir:samples/scissor_test
