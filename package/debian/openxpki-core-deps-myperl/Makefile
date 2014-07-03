# Makefile for OpenXPKI Perl Dependencies

PERL = /opt/myperl/bin/perl
COREDIR = ../../../core/server

# Usage: $(call perlcfg,KEY)
define perlcfg
$(shell $(PERL) "-V:$1" | awk -F\' '{print $$2}')
endef

SITELIB		= $(call perlcfg,sitelib)
SITEARCH	= $(call perlcfg,sitearch)
SITELIBEXP	= $(DESTDIR)$(call perlcfg,sitelibexp)
ARCHNAME	= $(call perlcfg,archname)
ARCHLIB		= $(call perlcfg,archlib)
SITEMAN1EXP	= $(call perlcfg,siteman1direxp)
SITEMAN3EXP	= $(call perlcfg,siteman3direxp)
SITESCRIPTEXP	= $(call perlcfg,sitescriptexp)

# The --reinstall flag ensures that the package is built even if cpanm finds
# the module already installed. I tried using this, but found that I ended
# up with Test::Harness in both myperl and this supplemental package
CPANM_OPTS = --notest --skip-satisfied --skip-installed --build-args="INSTALLPRIVLIB=$(SITELIB)"

-include ../cpanm.mk
-include ../../Makefile.local
-include Makefile.local

#MYPERL_PREFIX = /opt/myperl

# Environment vars needed for proper Perl module installation
# The PERL5LIB has the lib/perl5 in it to work around a bug in cpanm
export PERL5LIB		= $(DESTDIR)$(SITEARCH):$(DESTDIR)$(SITELIB):$(DESTDIR)/lib/perl5
export PERL_MB_OPT	= "--destdir '$(DESTDIR)' --installdirs site"
#export PERL_MB_OPT	= "--installdirs site"
#export PERL_MM_OPT	= "INSTALLDIRS=site INSTALL_BASE=$(DESTDIR)"
export PERL_MM_OPT	= "INSTALLDIRS=site INSTALLPRIVLIB=$(SITELIB)"

info:
	@echo "*** Makefile for openxpki-core-deps-myperl ***"
	@echo "PERL5LIB     = $(PERL5LIB)"
	@echo "PERL_MB_OPT  = $(PERL_MB_OPT)"
	@echo "PERL_MM_OPT  = $(PERL_MM_OPT)"
	@echo "ARCHNAME     = $(ARCHNAME)"
	@echo "DESTDIR      = $(DESTDIR)"
	@echo "COREDIR      = $(COREDIR)"
	@echo "PERL         = $(PERL)"
	@echo "CPANM        = $(CPANM)"
	@echo "CPANM_OPTS   = $(CPANM_OPTS)"

install: info cpanm
	PERL5LIB=$(PERL5LIB) PERL_MB_OPT=$(PERL_MB_OPT) DESTDIR=$(DESTDIR) PERL_MM_OPT=$(PERL_MM_OPT) \
		$(CPANM) $(CPANM_OPTS) Config::Std Class::Std
	cd $(COREDIR) && \
		PERL5LIB=$(PERL5LIB) \
		PERL_MB_OPT=$(PERL_MB_OPT) \
		DESTDIR=$(DESTDIR) \
		PERL_MM_OPT=$(PERL_MM_OPT) \
		$(CPANM) $(CPANM_OPTS) --installdeps .
#		$(CPANM) $(CPANM_OPTS) Class::Std Crypt::OpenSSL::AES
	# Cleanup for missing support in cpanm for DESTDIR with .meta files
	-mv $(DESTDIR)/lib/perl5/$(ARCHNAME)/.meta $(DESTDIR)$(SITEARCH)/
	# try to *safely* remove the unneeded directories
	-rmdir $(DESTDIR)/lib/perl5/$(ARCHNAME) $(DESTDIR)/lib/perl5 $(DESTDIR)/lib
	# remove perllocal.pod, if installed
	-rm $(DESTDIR)$(ARCHLIB)/perllocal.pod
	# Issue #2 - until I can get Pinto running, just remove the offending files
	# Note: since this is a nasty kludge, I'll leave the fail-on-error behavior
	# of make.
	rm -rf \
		$(DESTDIR)$(SITEMAN3EXP)/CGI.3 \
		$(DESTDIR)$(SITEMAN3EXP)/CGI::Apache.3 \
		$(DESTDIR)$(SITEMAN3EXP)/CGI::Carp.3 \
		$(DESTDIR)$(SITEMAN3EXP)/CGI::Cookie.3 \
		$(DESTDIR)$(SITEMAN3EXP)/CGI::Pretty.3 \
		$(DESTDIR)$(SITEMAN3EXP)/CGI::Push.3 \
		$(DESTDIR)$(SITEMAN3EXP)/CGI::Switch.3 \
		$(DESTDIR)$(SITEMAN3EXP)/CGI::Util.3 \
		$(DESTDIR)$(SITELIB)/CGI.pm \
		$(DESTDIR)$(SITELIB)/CGI/Apache.pm \
		$(DESTDIR)$(SITELIB)/CGI/Carp.pm \
		$(DESTDIR)$(SITELIB)/CGI/Cookie.pm \
		$(DESTDIR)$(SITELIB)/CGI/Pretty.pm \
		$(DESTDIR)$(SITELIB)/CGI/Push.pm \
		$(DESTDIR)$(SITELIB)/CGI/Switch.pm \
		$(DESTDIR)$(SITELIB)/CGI/Util.pm \
		$(DESTDIR)$(SITEMAN3EXP)/Module::Build* \
		$(DESTDIR)$(SITELIB)/Module/Build.pm \
		$(DESTDIR)$(SITELIB)/Module/Build \
		$(DESTDIR)$(ARCHLIB)/auto/Module/Build 
	# Issue #2 - let's just trash these for now
	rm -rf \
		$(DESTDIR)$(SITESCRIPTEXP)/config_data \
		$(DESTDIR)$(SITEMAN1EXP)/config_data.1 \
		$(DESTDIR)$(SITEMAN3EXP)/inc::latest.3 \
		$(DESTDIR)$(SITELIB)/inc

%:
	@echo "** DEBUG ** makefile target '$@' doesn't exist in openxpki-core-deps-myperl Makefile"

# This target writes the package and other debian files to the parent directory '..'
# It will cause the debian helper stuff to run all the above target(s).
package:
	dpkg-buildpackage -us -uc
