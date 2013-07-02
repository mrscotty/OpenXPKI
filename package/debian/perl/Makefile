# trunk/package/debian/core
#
# This builds our own Perl binary and CPAN modules in /usr/share/openxpki
# for use by the OpenXPKI components. The Makefile is written to be
# run on a 'clean' system -- one where the /usr/share/openxpki-perldeps-<oxiversion>
# doesn't exist.
#
# To prevent clobbering an existing install or accidentally
# packaging things not installed by this script, the 'default' target
# checks that the above directory does NOT exist. To skip this check,
# use the target 'nocheck' instead.

TOPDIR=../..

SRCBASE=$(TOPDIR)/perl
PACKAGE=libopenxpki-perldeps
OXI_PERL_NAME := openxpki-perldeps-core
PERL_NAME=OpenXPKI-perldeps
PKGDIR=../deb/perl
#EXAMPLE=$(TOPDIR)/perl/config

include ../../common/perl-build.mk

# Makefile.inc contains common settings for all packages (checked in)
#include ../Makefile.inc
# Makefile.local may be used locally to override settings (not checked in)
-include ../Makefile.local

include $(TOPDIR)/package/common/Makefile.inc

#PERL_ROOT=/usr/share/openxpki
#PERL_VERSION=5.14.2
#PERL_5_BASEURL=http://ftp.gwdg.de/pub/languages/perl/CPAN/src/5.0
#PERL_SOURCE_TARBALL=perl-$(PERL_VERSION).tar.bz2
#PERL_SOURCE_TARBALL_LONG=$(PERL_SOURCE_PREFIX)/$(PERL_SOURCE_TARBALL)
#PERL_SOURCE_URL=$(PERL_5_BASEURL)/$(PERL_SOURCE_TARBALL)
#PERL_SOURCE_PREFIX=/tmp/$(PERLNAME)-$(PERL_VERSION)
#PERL_SOURCE_DIR=$(PERL_SOURCE_PREFIX)/perl-$(PERL_VERSION)
#PERL_OWNER_USER=$(shell id -un)
#PERL_OWNER_GROUP=$(shell id -gn)
#NEW_PERL_BIN=$(PERL_ROOT)/$(PERL_VERSION)/bin
#NEWPERL=$(NEW_PERL_BIN)/perl
#NEWCPANM=$(NEW_PERL_BIN)/cpanm

#.PHONY: info
#info:
#	@echo "Perl binary:  $(NEWPERL)"
#	@echo "cpanm file:   $(NEWCPANM)"
#	@echo "Tarball file: $(PERL_SOURCE_TARBALL_LONG)"

# Override 'default' from ../Makefile.inc
.PHONY: default
default: default-check default-nocheck

default-check:
	@test ! -d $(OXI_PERL) || (echo "$(OXI_PERL) already exists"; exit 1)

default-nocheck:
	$(MAKE) control
	$(MAKE) changelog
	$(MAKE) /tmp/$(PERLNAME)-$(PERL_VERSION).tar.gz
	$(MAKE) /tmp/openxpki-debian.tar.gz
	$(MAKE) source
	$(MAKE) package

control: control.template
