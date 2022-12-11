CC=c++
CFLAGS=-std=c++2a -Wall -O2 -shared -fPIC
# CFLAGS=-std=c++2a -Wall -O0 -g -shared -fPIC

SRC=./Photino.Native
SRC_SHARED=$(SRC)/Shared
SRC_WIN=$(SRC)/Platform/Windows
SRC_MAC=$(SRC)/Platform/macOS
SRC_LIN=$(SRC)/Platform/Linux

DEST_PATH=./lib

DEST_PATH_PROD=$(DEST_PATH)/prod
DEST_PATH_DEV=$(DEST_PATH)/dev
DEST_FILE=Photino.Native

all:
	# "make all is unavailable, use [windows|mac|linux](-dev)."

windows: clean build-photino-windows
mac: clean build-photino-mac
linux: clean build-photino-linux

windows-dev: clean-dev build-photino-windows
mac-dev: clean-dev build-photino-mac-dev
linux-dev: clean-dev install-linux-dependencies build-photino-linux-dev

build-photino-windows:
	# "build-photino-windows is not defined"

build-photino-windows-dev:
	# "build-photino-windows-dev is not defined"

build-photino-mac:
	# "build-photino-mac is not defined"

build-photino-mac-dev:
	cp $(SRC_SHARED)/Exports.cpp $(SRC_SHARED)/Exports.mm &&\
	$(CC) -o $(DEST_PATH_DEV)/$(DEST_FILE).dylib\
		  $(CFLAGS)\
		  -framework Cocoa\
		  -framework WebKit\
		  -framework UserNotifications\
		  $(SRC_MAC)/Photino.AppDelegate.mm\
		  $(SRC_MAC)/Photino.UiDelegate.mm\
		  $(SRC_MAC)/Photino.UrlSchemeHandler.mm\
		  $(SRC_MAC)/Photino.NSWindowBorderless.mm\
		  $(SRC_MAC)/Photino.mm\
		  $(SRC_SHARED)/Exports.mm &&\
	rm $(SRC_SHARED)/Exports.mm &&\
	cp $(DEST_PATH_DEV)/$(DEST_FILE).dylib ./Photino.Test/bin/Debug/net6.0/

install-linux-dependencies:
	sudo apt-get update\
	&& sudo apt-get install libgtk-3-dev libwebkit2gtk-4.0-dev libnotify4 libnotify-dev

build-photino-linux:
	# "build-photino-linux is not defined"

build-photino-linux-dev:
	$(CC) -o $(DEST_PATH_DEV)/$(DEST_FILE).so\
		  $(CFLAGS)\
		  $(SRC_LIN)/Photino.cpp\
		  $(SRC_SHARED)/Exports.cpp\
		  `pkg-config --cflags --libs gtk+-3.0 webkit2gtk-4.0 libnotify` &&\
	cp $(DEST_PATH_DEV)/$(DEST_FILE).so ./Photino.Test/bin/Debug/net6.0/

clean:
	rm -rf $(DEST_PATH_PROD)/* & mkdir -p $(DEST_PATH_PROD)

clean-dev:
	rm -rf $(DEST_PATH_DEV)/* & mkdir -p $(DEST_PATH_DEV)