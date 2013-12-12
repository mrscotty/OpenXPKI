# perl-build.mk - helper targets for building our own local perl and cpan
#
# The targets and variables here should be compatible with both debian and
# suse build routines. Also, independent packages may be created for separate
# applications. For example, the OpenXPKI service and clients require the
# full perl/cpan installation. The enrollment UI, on the other hand, only
# needs a few dependencies from cpan.
#
# USAGE:
#
# 	OXI_PERL_NAME := openxpki-perldeps-core
#
# 	include ../common/perl-build.mk
#
# 	# distro-specific targets
# 	...
#
#

TOPDIR := ../../..
VERGEN := $(TOPDIR)/tools/vergen

ifndef OXI_PERL_NAME
	OXI_PERL_NAME := openxpki-perldep
endif
ifndef OXI_VERSION
	OXI_VERSION := $(shell $(VERGEN) --format version)
endif
ifndef PKGREL
	OXI_PKGREL  := $(shell $(VERGEN) --format PKGREL)
endif

OXI_SOURCE := $(TOPDIR)/core/server
OXI_PERL_OWNER := $(shell id -un)
OXI_PERL_GROUP := $(shell id -gn)
OXI_PERL_VERSION := 5.14.2
OXI_PERL_PREFIX := /usr/share/$(OXI_PERL_NAME)
OXI_PERL_BINDIR := $(OXI_PERL_PREFIX)/$(OXI_PERL_VERSION)/bin
OXI_PERL := $(OXI_PERL_BINDIR)/perl
OXI_CPANM := $(OXI_PERL_BINDIR)/cpanm

RPMBUILD_DIR := $(HOME)/rpmbuild
SOURCE_PREFIX := $(RPMBUILD_DIR)/SOURCES
BUILD_PREFIX := /tmp/$(OXI_PERL_NAME)-$(OXI_PERL_VERSION)
BUILD_PERL := $(BUILD_PREFIX)/perl-$(OXI_PERL_VERSION)
PERL_SOURCE_TARBALL := perl-$(OXI_PERL_VERSION).tar.bz2
PERL_5_BASEURL := http://ftp.gwdg.de/pub/languages/perl/CPAN/src/5.0
PERL_SOURCE_URL := $(PERL_5_BASEURL)/$(PERL_SOURCE_TARBALL)


.PHONY: all
all: check build-cpan default

.PHONY: info
info:
	@echo "      SOURCE_PREFIX:  $(SOURCE_PREFIX)"
	@echo "PERL_SOURCE_TARBALL:  $(PERL_SOURCE_TARBALL)"
	@echo "    OXI_PERL_PREFIX:  $(OXI_PERL_PREFIX)"
	@echo "   OXI_PERL_VERSION:  $(OXI_PERL_VERSION)"
	@echo "          OXI_CPANM:  $(OXI_CPANM)"

.PHONY: nocheck
nocheck:

# Helper Targets
.PHONY: fetch-perl
fetch-perl: $(SOURCE_PREFIX)/$(PERL_SOURCE_TARBALL)

# Sanity checks for this tree
# 1. check for required command line tools
.PHONY: check
check:
	@for cmd in $(VERGEN) tpage ; do \
		if ! $$cmd </dev/null >/dev/null 2>&1 ; then \
			echo "ERROR: executable '$$cmd' does not work properly." ;\
			exit 1 ;\
		fi ;\
	 done

# Fetch tarball from perl.org
.SECONDARY: $(SOURCE_PREFIX)/$(PERL_SOURCE_TARBALL)
$(SOURCE_PREFIX)/$(PERL_SOURCE_TARBALL):
	test -d $(SOURCE_PREFIX) || mkdir -p $(SOURCE_PREFIX)
	cp /vagrant/$(PERL_SOURCE_TARBALL) $(SOURCE_PREFIX)/ || echo "Need to fetch tarball"
	test -f $@ || (cd $(SOURCE_PREFIX) && wget $(PERL_SOURCE_URL))

# Install new oxi perl
$(OXI_PERL): $(SOURCE_PREFIX)/$(PERL_SOURCE_TARBALL)
	sudo mkdir -p $(BUILD_PREFIX)
	sudo chown $(OXI_PERL_OWNER):$(OXI_PERL_GROUP) $(BUILD_PREFIX)
	sudo mkdir -p $(OXI_PERL_PREFIX)
	sudo chown $(OXI_PERL_OWNER):$(OXI_PERL_GROUP) $(OXI_PERL_PREFIX)
	(cd $(BUILD_PREFIX) && tar -xjf $(SOURCE_PREFIX)/$(PERL_SOURCE_TARBALL))
	(cd $(BUILD_PERL) && \
		PERL5LIB= sh Configure -des \
		-Dprefix=$(OXI_PERL_PREFIX)/$(OXI_PERL_VERSION) \
		-Dscriptdir=$(OXI_PERL_BINDIR))
	(cd $(BUILD_PERL) && PERL5LIB= make)
	(cd $(BUILD_PERL) && PERL5LIB= make test)
	(cd $(BUILD_PERL) && PERL5LIB= make install)
	(cd $(OXI_PERL_PREFIX) && ln -s $(OXI_PERL_VERSION) CURRENT)

# Install 'cpanm' using new oxi perl
$(OXI_CPANM): $(OXI_PERL)
	curl -L http://cpanmin.us | PERL5LIB= $(OXI_PERL) - --self-upgrade

# Install CPAN modoules in three steps:
# 1. take care of dependencies needed to run Makefile.PL
# 2. manually install any dependencies not resolved automatically in step 3
# 3. install remaining deps for oxi
.PHONY: build-cpan
build-cpan: $(OXI_PERL_PREFIX)/.build-cpan
$(OXI_PERL_PREFIX)/.build-cpan: $(OXI_CPANM)
	PERL5LIB= PATH=$(OXI_PERL_BINDIR):$(PATH) $(OXI_CPANM) $(CPANM_OPTS) --quiet --notest Config::Std YAML::XS
	PERL5LIB= PATH=$(OXI_PERL_BINDIR):$(PATH) $(OXI_CPANM) $(CPANM_OPTS) --quiet --installdeps --notest Workflow
	(cd $(OXI_SOURCE) && PERL5LIB= PATH=$(OXI_PERL_BINDIR):$(PATH) $(OXI_CPANM) $(CPANM_OPTS) --quiet --installdeps --notest .)
	touch $@
