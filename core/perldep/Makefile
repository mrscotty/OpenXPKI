# core/perldep/Makefile
#
# This builds our own Perl binary and CPAN modules in PERL_PREFIX
# for use by the OpenXPKI components.
#
# Note: write-permission will be needed for $(PERL_PREFIX)/
#
# NOTE: The target 'dist' only works from the git working repository
#

OXI_SOURCE = ../server
PERL_PREFIX = /opt/openxpki
PERL_VERSION = 5.18.2
PERL_SOURCE_TARBALL = perl-$(PERL_VERSION).tar.bz2
PERL_SOURCE_BASEURL = http://ftp.gwdg.de/pub/languages/perl/CPAN/src/5.0
PERL_SOURCE_URL = $(PERL_SOURCE_BASEURL)/$(PERL_SOURCE_TARBALL)
PERL_BUILD = /tmp/perldep-build
PERL_BIN = $(PERL_PREFIX)/bin
NEWPERL = $(PERL_BIN)/perl
NEWCPANM = $(PERL_BIN)/cpanm

TOPDIR := ../..
VERGEN := $(TOPDIR)/tools/vergen

# Allow local overrides
#-include ../Makefile.local
-include Makefile.local

ifndef OXI_PERL_NAME
	OXI_PERL_NAME := openxpki-perldep-core
endif
ifndef OXI_VERSION
	OXI_VERSION := $(shell $(VERGEN) --format version)
endif

DEB_BASENAME = $(OXI_PERL_NAME)-$(OXI_VERSION)
OXI_TARBALL = $(DEB_BASENAME).tar.gz

# Setting $(PERL_SKIP_TEST) will cause 'make test' to be
# skipped. This should only be used when running the
# build repeatedly to refine other components of the process.
ifdef PERL_SKIP_TEST
  PERL_MAKE_TARGETS = install
else
  PERL_MAKE_TARGETS = test install
  CPANM_OPT = --quiet
endif

# Setting $(CPAN_MIRROR_DIR) will cause cpanm to cache the
# tarballs fetched from CPAN.
ifdef CPAN_MIRROR_DIR
	CPANM_OPT += --cascade-search --save-dists=$(CPAN_MIRROR_DIR) --mirror $(CPAN_MIRROR_DIR) --mirror=http://search.cpan.org/CPAN
else
	CPANM_OPT +=
endif

MOCK_SERVER_FILES = $(patsubst %,$(DEB_BASENAME)/mock-server/%,Makefile.PL vergen.sh OpenXPKI)

############################################################
# 
# Primary Targets:
#
# 	fetch	Fetches the Perl tarball (default target)
#
# 	install	Installs Perl and CPAN to PERL_PREFIX/
#
############################################################

info:
	@echo "PERL_SKIP_TEST=$(PERL_SKIP_TEST)"
	@echo "CPAN_MIRROR_DIR=$(CPAN_MIRROR_DIR)"

.PHONY: dist fetch install

dist: $(OXI_TARBALL)

$(OXI_TARBALL): $(MOCK_SERVER_FILES) $(patsubst %,$(DEB_BASENAME)/%,Makefile .VERSION_DEFINITION .VERSION_MAJOR .VERSION_MINOR .VERSION_PKGREL)
	tar -czf $@ $(DEB_BASENAME)

fetch: $(PERL_SOURCE_TARBALL)

install: info $(NEWPERL) $(NEWCPANM) build-cpan

.PHONY: distclean
distclean:

############################################################
#
# Debug Targets (used during debugging for intermediate steps)
#
############################################################

.PHONY: install-perl install-cpanm install-cpan

install-perl: $(NEWPERL)

install-cpanm: $(NEWCPANM)

install-cpan: build-cpan


############################################################
# 
# Helper Targets:
#
############################################################

.PRECIOUS: $(PERL_BUILD)/perl-$(PERL_VERSION)
$(PERL_BUILD)/perl-$(PERL_VERSION): $(PERL_SOURCE_TARBALL)
	mkdir -p $(PERL_BUILD)
	tar -xjf $(PERL_SOURCE_TARBALL) -C $(PERL_BUILD)

.PRECIOUS: $(NEWPERL)
$(NEWPERL): $(PERL_BUILD)/perl-$(PERL_VERSION)
	cd $(PERL_BUILD)/perl-$(PERL_VERSION) \
		&& \
		sh Configure -des \
		-Dprefix=$(PERL_PREFIX) \
		&& \
		PERL5LIB= $(MAKE) $(PERL_MAKE_TARGETS) \

.PRECIOUS: $(NEWCPANM)
$(NEWCPANM): $(NEWPERL)
	curl -L http://cpanmin.us | PERL5LIB= $(NEWPERL) - --self-upgrade


# This is just a helper target for use during initial development work
.PHONY: mock-server
mock-server: $(MOCK_SERVER_FILES)

.PHONY: build-cpan
build-cpan: $(PERL_PREFIX)/.build-cpan
$(PERL_PREFIX)/.build-cpan: $(NEWCPANM) $(patsubst $(DEB_BASENAME)/%,%,$(MOCK_SERVER_FILES))
	PATH=$(PERL_BIN):$(PATH) $(NEWCPANM) $(CPANM_OPT) --notest Config::Std
	cd mock-server && PATH=$(PERL_BIN):$(PATH) $(NEWCPANM) $(CPANM_OPT) --installdeps --notest .
	touch $@

############################################################
#
# The following targets are used to create the dist tarball
#
############################################################

.PRECIOUS: $(PERL_SOURCE_TARBALL)
$(PERL_SOURCE_TARBALL):
	cp /vagrant/$@ $@ || echo "Need to fetch Perl tarball"
	test -f $@ || wget -O $@ $(PERL_SOURCE_URL)

$(DEB_BASENAME)/Makefile: Makefile
	mkdir -p $(shell dirname $@)
	cp $< $@.new
	perl -i -pe 's{VERGEN := .*}{VERGEN := mock-server/vergen.sh}' $@.new
	mv $@.new $@

$(DEB_BASENAME)/.VERSION_%: $(TOPDIR)/.VERSION_%
	mkdir -p $(shell dirname $@)
	cp $< $@

#$(DEB_BASENAME)/tools/vergen: $(TOPDIR)/tools/vergen
#	mkdir -p $(shell dirname $@)
#	cp $< $@

$(DEB_BASENAME)/mock-server/Makefile.PL:
	mkdir -p $(shell dirname $@)
	perl -pe 's{\.\./\.\./tools/vergen}{./vergen.sh};' < ../server/Makefile.PL > $@.new
	mv $@.new $@

$(DEB_BASENAME)/mock-server/vergen.sh:
	mkdir -p $(shell dirname $@)
	echo "#!/bin/sh" > $@
	echo "echo -n \\" >> $@
	../../tools/vergen --format version >> $@
	chmod +x $@

$(DEB_BASENAME)/mock-server/OpenXPKI:
	mkdir -p $@

