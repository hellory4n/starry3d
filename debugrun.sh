#!/bin/sh
set -e
ninja
gdb -q -ex run -ex "quit" --args ./build/bin/sandbox $@
