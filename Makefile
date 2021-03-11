LIBDIR=/usr/local/lib
VERSION=1.0.2016
BB_TOOLBOX=bashbatch

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
    @echo "Checks libs UTests"
    assert.sh -ut
    logger.sh -ut
    date.sh   -ut
    str.sh    -ut
    gen.sh    -ut

dist:
    mkdir ./batchtools-$(VERSION)
    cp LICENSE README INSTALL Makefile 
    tar cvfz babatools-$(VERSION).tar.gz ./babatools-$(VERSION)
    rm -rf ./babatools-$(VERSION)
    @echo "babatools-$(VERSION).tar.gz done"
