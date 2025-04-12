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
    -I$(STARRY3D)/vendor/glfw/include \
    \
    -Isrc

# i put starry3d things first
SRCS = \
    $(STARRY3D)/vendor/libtrippin/libtrippin.c \
    $(STARRY3D)/src/st3d.c \
    $(STARRY3D)/src/st3d_render.c \
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

# i would put glfw as a submodule and then compile from source but
# it uses cmake and cmake fucking sucks
ifeq ($(OS),windows)
    GLFWCOPYCMD = cp $(STARRY3D)/vendor/glfw/bin/windows-x86_64/glfw3.dll glfw3.dll
else ifeq ($(OS),linux)
    GLFWCOPYCMD = cp $(STARRY3D)/vendor/glfw/bin/linux-x86_64/libglfw.so.3.4 libglfw.so.3.4
endif

ifeq ($(OS),windows)
    LDFLAGS += -lglfw3 -lopengl32 -lgdi32 -lwinmm -lcomdlg32 -lole32
else ifeq ($(OS),linux)
    LDFLAGS += -lglfw3 -lX11 -lXrandr -lGL -lXinerama -lm -lpthread -ldl -lrt
endif

# yeah
ifeq ($(OS),windows)
    CFLAGS += -DST3D_WINDOWS
else ifeq ($(OS),linux)
    CFLAGS += -DST3D_LINUX
endif

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDE) -c $< -o $@ && $(GLFWCOPYCMD)

clean:
	rm -f $(OBJS) $(TARGET) log.txt *glfw*

run: $(TARGET)
	$(RUNCMD)
