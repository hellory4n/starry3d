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

# evil luajit ffi fuckery requires us to exports symbols to ourselves
_LDFLAGS := if os() == "windows" { "" } else { "-extra-linker-flags:\"-rdynamic\"" }

_CFLAGS := \
	f"{{_BASE_CFLAGS}} {{_LDFLAGS}} {{_TARGET}} {{_RELEASE}} {{_SANITIZE}}"

set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]

build-starry:
	odin build starry {{_CFLAGS}} -out:{{_EXE_NAME}}

studio:
	odin run studio {{_CFLAGS}} -- -app-dir:studio

build-studio:
	odin build studio {{_CFLAGS}} -out:{{_STUDIO_EXE}}

@release:
	python misc/release.py

# but why would you do that
@run-all-samples: build-starry
	@# building starry
	run-hello

@run-hello: build-starry
	@# samples: hello
	{{_EXE_NAME}} -app-dir:samples/hello
