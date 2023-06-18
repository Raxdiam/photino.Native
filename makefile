PROJ = Photino.Native
PROJ_TEST = Photino.Test
PROJ_TEST_SDK = net6.0

UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
    OS := Darwin
else ifeq ($(UNAME_S),Linux)
    OS := Linux
else
    OS := Windows_NT
endif

# x64, x86, ARM64
ifeq ($(arch),)
	ifeq ($(OS),Windows_NT)
		ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
    	arch := x64
  	else ifeq ($(PROCESSOR_ARCHITECTURE),x86)
  	  arch := x86
  	else ifeq ($(PROCESSOR_ARCHITECTURE),ARM64)
  	  arch := ARM64
  	endif
	else
		UNIX_ARCH := $(shell uname -m)
		ifeq ($(UNIX_ARCH),x86_64)
    	arch := x64
		else ifeq ($(UNIX_ARCH),arm64)
		  arch := ARM64
		endif
	endif
endif
ARCH ?= $(arch)

build:
	@echo "Building $(PROJ) for $(OS) $(ARCH)"

build: clean build-release
dev: build-debug copy
gen: build-gen

ifeq ($(OS),Windows_NT)
### Windows ###

build-release: install
	msbuild $(PROJ).sln /p:Configuration=Release /p:Platform=$(ARCH)

build-debug: install
	msbuild $(PROJ).sln /p:Configuration=Debug /p:Platform=$(ARCH)

install: ; if not exist packages nuget restore

PLATFORM?=$(ARCH)
ifeq ($(ARCH),x86)
	PLATFORM=Win32
endif

copy:
	xcopy /y /q "$(PROJ)\bin\Debug\$(PLATFORM)\$(PROJ).dll" "$(PROJ_TEST)\bin\$(ARCH)\Debug\$(PROJ_TEST_SDK)\" > nul
	xcopy /y /q "$(PROJ)\bin\Debug\$(PLATFORM)\$(PROJ).pdb" "$(PROJ_TEST)\bin\$(ARCH)\Debug\$(PROJ_TEST_SDK)\" > nul
	xcopy /y /q "$(PROJ)\bin\Debug\$(PLATFORM)\WebView2Loader.dll" "$(PROJ_TEST)\bin\$(ARCH)\Debug\$(PROJ_TEST_SDK)\" > nul

clean:
	if exist $(PROJ)\bin rmdir /s /q $(PROJ)\bin
	if exist $(PROJ)\obj rmdir /s /q $(PROJ)\obj
	if exist packages rmdir /s /q packages
######
else ifeq ($(OS),Darwin)
### macOS ###
OS_ARCH=x86_64
ifeq ($(ARCH),x64)
	OS_ARCH=x86_64
else ifeq ($(ARCH),ARM64)
	OS_ARCH=arm64
endif

build-gen:
	cmake \
	--no-warn-unused-cli \
	-DCMAKE_OSX_ARCHITECTURES=$(OS_ARCH) \
	-DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE \
	-DCMAKE_BUILD_TYPE:STRING=Debug \
	-S$(shell pwd) -B$(shell pwd)/build -G "Unix Makefiles"

build-release: build-gen	
	cd build && make
	rm -f $(PROJ)/src/shared/Exports.mm

build-debug: build-release

install:

copy:
	cp build/$(PROJ).dylib $(PROJ_TEST)/bin/Debug/$(PROJ_TEST_SDK)/$(PROJ).dylib

clean:
	rm -rf build
	rm -f $(PROJ)/src/shared/Exports.mm
######
else ifeq ($(OS),Linux)
### Linux ###
build-gen:
	mkdir -p build && cd build && cmake ..

build-release: build-gen
	cd build && make

build-debug: build-release

install:
	sudo apt-get update
	sudo apt-get install -y libgtk-3-dev libwebkit2gtk-4.0-dev libnotify4 libnotify-dev

copy:
	cp build/$(PROJ).so $(PROJ_TEST)/bin/Debug/$(PROJ_TEST_SDK)/$(PROJ).so

clean:
	rm -rf build

######
endif
