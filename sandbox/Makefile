CC = clang
CFLAGS = -std=c99 -Wall -Wextra -Wpedantic -Wshadow -fno-strict-aliasing
LDFLAGS = -L.

# you should probably edit these
PROGRAM = sandbox
STARRY3D = ..

# i put starry3d things first
INCLUDE = \
    -I${STARRY3D}/src \
    -I${STARRY3D}/vendor \
    -I${STARRY3D}/vendor/libtrippin \
    -I${STARRY3D}/vendor/rgfw \
    \
    -Isrc

# i put starry3d things first
SRCS = \
    ${STARRY3D}/vendor/libtrippin/libtrippin.c \
    ${STARRY3D}/src/st3d_core.c \
    \
	src/main.c

OBJS = $(SRCS:.c=.o)

PLATFORM := $(shell uname -s)
ifeq ($(PLATFORM),Linux)
    OS = linux
else ifeq ($(PLATFORM),Windows_NT)
    OS = windows
endif

# cross compiling lmao
ifeq ($(platform),windows)
    CROSSCOMPILE = true
    OS = windows
endif

ifeq ($(OS),windows)
    TARGET := ${PROGRAM}.exe
else
    TARGET := ${PROGRAM}
endif

# mingw doesn't always have clang
ifeq ($(OS),windows)
    ifeq ($(CROSSCOMPILE),true)
        CC = x86_64-w64-mingw32-gcc
    else
        CC = gcc
    endif
endif

# lmao
ifeq ($(build),debugasan)
    CFLAGS += -O0 -g -DDEBUG -fsanitize=address
else ifeq ($(build),debug)
    CFLAGS += -O0 -g -DDEBUG
else
    CFLAGS += -O2 -DRELEASE
endif

ifeq ($(OS),windows)
    # -Wl,--subsystem,windows hides the console window
    LDFLAGS += -lopengl32 -lgdi32 -lwinmm -lcomdlg32 -lole32
else ifeq ($(OS),linux)
    LDFLAGS += -lGL -lXrandr -lX11 -lXinerama -lm -lpthread -ldl -lrt
endif

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDE) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET) log.txt

run: $(TARGET)
	./$(TARGET)
