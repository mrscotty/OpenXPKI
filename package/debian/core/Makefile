# trunk/package/debian/core
#

TOPDIR=../../..
SRCBASE=$(TOPDIR)/core/server
PACKAGE=libopenxpki-perl
PERLNAME=OpenXPKI
PKGDIR=../deb/core
EXAMPLE=$(TOPDIR)/config

# common includes for package builds
include $(TOPDIR)/package/common/Makefile.inc

TT_EXTRA_SYMBOLS = --define BUILD_DATE="$(shell date --rfc-2822)"

# Makefile.local may be used locally to override settings (not checked in)
-include ../Makefile.local

VERGEN = $(TOPDIR)/tools/vergen
OUR_BASENAME = $(PACKAGE)
OUR_VERSION = $(shell $(VERGEN) --format version)
OUR_SOURCE_TARBALL = $(OUR_BASENAME)_$(OUR_VERSION).orig.tar.bz2
OUR_SOURCE_DIR = $(OUR_BASENAME)-$(OUR_VERSION)
DEBIAN_PKG = $(OUR_BASENAME)_$(OUR_VERSION)_amd64.deb

all: $(DEBIAN_PKG)

doit: info $(OUR_SOURCE_TARBALL)

info:
	@echo "OUR_SOURCE_TARBALL = $(OUR_SOURCE_TARBALL)"

$(OUR_SOURCE_TARBALL):
	(cd $(TOPDIR) && git archive --format=tar \
		--prefix=$(OUR_SOURCE_DIR)/ HEAD ) \
		 | bzip2 > $@


.PHONY: unpack-tarball

unpack-tarball: $(OUR_SOURCE_TARBALL) control changelog
	# unpack the oxi tarball
	tar xjf $<
	# copy over the debian/ stuff
	mkdir $(OUR_SOURCE_DIR)/debian
	tar cf - changelog compat control copyright $(PACKAGE).openxpkid.init \
		$(PACKAGE).preinst $(PACKAGE).postinst $(PACKAGE).examples $(PACKAGE).dirs \
		rules \
		| tar xf - -C $(OUR_SOURCE_DIR)/debian

$(DEBIAN_PKG): unpack-tarball examples
	cd $(OUR_SOURCE_DIR) && \
		DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -us -uc

clean:
	rm -rf $(OUR_SOURCE_DIR)

examples-DEPRECATED:
	cd $(EXAMPLE); \
	tar -czf /tmp/openxpki-examples.tar.gz .; \
	cd /tmp/$(PERLNAME)-*; \
	mkdir -p examples; \
	tar -xzf /tmp/openxpki-examples.tar.gz  -C examples; \
	cd examples; \
	tar -zcf openxpki-etc.tgz openxpki; \
	tar -zcf profiles.tgz profiles; \
	cd feature; \
	tar -zcf ../openxpki-feature.tgz *; \
	cd ..

examples:
	mkdir $(OUR_SOURCE_DIR)/examples
	tar -cf - -C $(EXAMPLE) sampleconfig.sh sampledbuser.sql apache/openxpki-scep.conf README.md | \
		tar xf - -C $(OUR_SOURCE_DIR)/examples
	tar -czf $(OUR_SOURCE_DIR)/examples/openxpki-etc.tgz -C $(EXAMPLE) openxpki
	tar -czf $(OUR_SOURCE_DIR)/examples/profiles.tgz -C $(EXAMPLE) profiles
	tar -czf $(OUR_SOURCE_DIR)/examples/openxpki-feature.tgz -C $(EXAMPLE) feature

