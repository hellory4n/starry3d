ifeq ($(build),debugasan)
    BUILDOPT = build=debugasan
else ifeq ($(build),debug)
    BUILDOPT = build=debug
else
    BUILDOPT =
endif

ifeq ($(crosscomp),windows)
    BUILDOPT += crosscomp=windows
endif

all: build-sandbox
clean: clean-sandbox

build-sandbox:
	cd sandbox && make $(BUILDOPT)

clean-sandbox:
	cd sandbox && make clean $(BUILDOPT)

help:
	@echo "Usage: make [clean] [build=release|debug|debugasan] [crosscomp=windows]"
