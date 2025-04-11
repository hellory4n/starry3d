CC = clang
CFLAGS = -std=c99 -Wall -Wextra -Wpedantic -Wshadow
LDFLAGS = -L. -Wl,-rpath=.

# you should probably edit this
PROGRAM = sandbox
# this is where you put starry3d
# for example `vendor/starry3d`
STARRY3D = ..

# i put starry3d things first
INCLUDE = \
    -I$(STARRY3D)/src \
    -I$(STARRY3D)/vendor \
    -I$(STARRY3D)/vendor/libtrippin \
    -I$(STARRY3D)/vendor/wgpu-native/include \
    -I$(STARRY3D)/vendor/glfw/include \
    -I$(STARRY3D)/vendor/glfw3webgpu \
    \
    -Isrc

# i put starry3d things first
SRCS = \
    $(STARRY3D)/vendor/libtrippin/libtrippin.c \
    $(STARRY3D)/vendor/glfw3webgpu/glfw3webgpu.c \
    $(STARRY3D)/src/st3d.c \
    \
	src/main.c

OBJS = $(SRCS:.c=.o)

# TODO more platforms also arm exists

PLATFORM := $(shell uname -s)
ifeq ($(PLATFORM),Linux)
    OS = linux
else ifeq ($(PLATFORM),Windows_NT)
    OS = windows
endif

# cross compiling lmao
ifeq ($(crosscomp),windows)
    CROSSCOMPILE = true
    OS = windows
endif

ifeq ($(OS),windows)
    TARGET := $(PROGRAM).exe
else
    TARGET := $(PROGRAM)
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

# make run :D
ifeq ($(CROSSCOMPILE),true)
    RUNCMD = wine $(TARGET)
else
    RUNCMD = ./$(TARGET)
endif

# we need to copy the wgpu-native and glfw .dll/.so :D
ifeq ($(OS),windows)
    WGPUCOPYCMD = cp $(STARRY3D)/vendor/wgpu-native/bin/windows-x86_64/wgpu_native.dll wgpu_native.dll
    GLFWCOPYCMD = cp $(STARRY3D)/vendor/glfw/bin/windows-x86_64/glfw3.dll glfw3.dll
else ifeq ($(OS),linux)
    WGPUCOPYCMD = cp $(STARRY3D)/vendor/wgpu-native/bin/linux-x86_64/libwgpu_native.so libwgpu_native.so
    GLFWCOPYCMD = cp $(STARRY3D)/vendor/glfw/bin/linux-x86_64/libglfw.so.3.4 libglfw.so.3.4
endif

ifeq ($(OS),windows)
    LDFLAGS += -lwgpu_native -lglfw3 -lopengl32 -lgdi32 -lwinmm -lcomdlg32 -lole32
else ifeq ($(OS),linux)
    LDFLAGS += -lwgpu_native -lglfw3 -lX11 -lXrandr -lGL -lXinerama -lm -lpthread -ldl -lrt
endif

# yeah
# the glfw defines are for glfw3webgpu to work
ifeq ($(OS),windows)
    CFLAGS += -DST3D_WINDOWS -D_GLFW_WIN32
else ifeq ($(OS),linux)
    CFLAGS += -DST3D_LINUX -D_GLFW_X11 -D_GLFW_WAYLAND
endif

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDE) -c $< -o $@ && $(WGPUCOPYCMD) && $(GLFWCOPYCMD)

clean:
	rm -f $(OBJS) $(TARGET) log.txt *wgpu* *glfw*

run: $(TARGET)
	$(RUNCMD)
