LIBDIR=/usr/local/lib
VERSION=1.0.2016
BB_TOOLBOX=bashbatch


GIT_TREE_STATE=$(shell (git status --porcelain | grep -q .) && echo dirty || echo clean)


BUILD_DATE=
BUILD_NUMBER=
GITHUB_ORIGIN=

.PHONY:


all: test
	@echo "If no error, you can now run make install"

help:
	@echo ""
	@echo "Usage: make [test|install|uninstall] [LIBDIR=path]"
	@echo "You can set LIBDIR to a valid directory. Default is $(LIBDIR)"
	@echo "You can remove installation using make uninstall as root or %wheel"
	@echo ""

install:
	@echo "Install"
	mkdir $(LIBDIR)/$(BB_TOOLBOX)/
	install -m655 ./lib/gen.inc $(LIBDIR)/$(BB_TOOLBOX)/gen.sh
	@echo "done"

uninstall:
	@echo "Removing libraries"
	rm -rf $(LIBDIR)/$(BB_TOOLBOX)
	@echo "done"

test:
	@echo "Checks UnitTests"
	@echo assert functions unit test
	cd ./src && ./assert.sh -ut
	@echo logger functions unit test
	cd ./src && ./logger.sh -ut
	@echo date functions unit test
	cd ./src && ./date.sh   -ut
	@echo string functions unit test
	cd ./src && ./str.sh    -ut
	@echo generic functions unit test
	cd ./src && ./gen.sh    -ut

dist:
	mkdir ./batchtools-$(VERSION)
	cp LICENSE README INSTALL Makefile 
	tar cvfz babatools-$(VERSION).tar.gz ./babatools-$(VERSION)
	rm -rf ./babatools-$(VERSION)
	@echo "babatools-$(VERSION).tar.gz done"
