#!/bin/sh
gcc -std=c11 -Wall -Wextra -shared -fPIC -o libapp.so example/main.c
