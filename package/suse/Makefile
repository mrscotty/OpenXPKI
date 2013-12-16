## Written 2006 by Martin Bartosch for the OpenXPKI project
## Copyright (C) 2005-2011 by The OpenXPKI Project
##
## Prereq: cpanspec.sourceforge.net

TOPDIR=../..

PACKAGES=\
	perl-openxpki-core \
	perl-openxpki-client-html-mason \
	openxpki-i18n
#	perl-openxpki-client-html-sc 

OPT_PACKAGES=\
    openxpki-perldeps-core \
	openxpki-perldeps-enrollment

ifdef PREFIX
PERL_MAKEPL_ARGS="PREFIX=$(PREFIX)"
endif

# Disable implicit rules to make debugging easier. We're using our own rules, anyway.

.SUFFIXES:

.PHONY : $(PACKAGES) $(OPT_PACKAGES) cpan fetchcpan

# Makefile.inc contains common settings for all packages (checked in)
include Makefile.inc

# optional: Makefile.local may be used locally to override 
# settings (should not be checked in)
-include Makefile.local

.PHONY : $(PACKAGES) all builddep public cust

all:
	@echo "Deprecated - use one of the following"
	@echo " "
	@echo " make builddep     - build the build dependencies (DEPRECATED)"
	@echo " make perldeps      - create CPAN dependency package"
	@echo " make public       - build the public code packages"
	@echo " make cust         - build the custom code package"

# builddep basically gets any CPAN stuff needed for the build process. First,
# it tries to use zypper to install those provided by SuSE. Then, it fetches
# the cpan2dist stuff to automate the process of installing the remaining 
# packages. (we'll use cpan2dist later when packaging the openxpki prereqs
# from cpan.

builddep-DEPRECATED:
	@echo "build dependencies"
	@test -f /usr/bin/zypper || (echo "Error: /usr/bin/zypper not found" && exit 1)
	@test -f builddep-`./susesux`.lst || (echo "Error: builddep-`./susesux`.lst not found" && exit 1)
	@xargs zypper install -y < builddep-`./susesux`.lst
	@perl -MCPANPLUS::Dist::SUSE -e 1 || (echo -e "\nError: CPANPLUS::Dist::SUSE not installed\n\n\trun 'cpan CPANPLUS::Dist::SUSE' to install\n" && exit 1)
#	@cpan2dist --format CPANPLUS::Dist::SUSE --install Config::Std

cpandep: openxpki-perldeps-core

public: clean $(PACKAGES) collect

cust:
	@echo "Sorry - not implemented yet"

$(EXTERNAL):
	@test -d rpm || mkdir rpm
	@test -d rpm/cpan || mkdir rpm/cpan
	@cd rpm/cpan && cpan2dist --format CPANPLUS::Dist::SUSE --force --install $(subst __,::,$@)

cpan:
	make --directory=cpan TARGET=cpan

cleancpan:
	make --directory=cpan TARGET=clean

$(PACKAGES):
	cd $@ && PATH=$(PATH):/usr/sbin make $(SUBTARGET) $(PERL_MAKEPL_ARGS)

$(OPT_PACKAGES):
	cd $@ && PATH=$(PATH):/usr/sbin make $(SUBTARGET) $(PERL_MAKEPL_ARGS)

collect:
	@mv */*.rpm .     || echo No suse package file found.

clean:
	rm -f *.rpm
	make $(PACKAGES) $(OPT_PACKAGES) SUBTARGET=clean

distclean: clean
