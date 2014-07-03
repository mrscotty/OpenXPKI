# Makefile for libdbd-mysql-myperl

PERL = /opt/myperl/bin/perl

# Usage: $(call perlcfg,KEY)
define perlcfg
$(shell $(PERL) "-V:$1" | awk -F\' '{print $$2}')
endef

SITELIB		= $(call perlcfg,sitelib)
SITEARCH	= $(call perlcfg,sitearch)
SITELIBEXP	= $(DESTDIR)$(call perlcfg,sitelibexp)
ARCHNAME	= $(call perlcfg,archname)
ARCHLIB		= $(call perlcfg,archlib)
PRIVLIB		= $(call perlcfg,privlib)


#MYPERL_PREFIX = /opt/myperl

# Environment vars needed for proper Perl module installation
export PERL5LIB		= $(DESTDIR)$(SITEARCH):$(DESTDIR)$(SITELIB)
export PERL_MB_OPT	= "--destdir '$(DESTDIR)' --installdirs site"
export PERL_MM_OPT	= "INSTALLDIRS=site DESTDIR=$(DESTDIR)"
# INSTALLPRIVLIB=$(SITEARCH)"

include ../cpanm.mk

CPANM_OPTS = --notest --verbose --skip-satisfied --skip-installed

info:
	@echo "*** DEBUG ***"
	@echo "PERL5LIB     = $(PERL5LIB)"
	@echo "PERL_MB_OPT  = $(PERL_MB_OPT)"
	@echo "PERL_MM_OPT  = $(PERL_MM_OPT)"
	@echo "*** DEBUG ***"

install: cpanm info
	PERL5LIB=$(PERL5LIB) PERL_MB_OPT=$(PERL_MB_OPT) PERL_MM_OPT=$(PERL_MM_OPT) DESTDIR=$(DESTDIR) \
		$(CPANM) $(CPANM_OPTS) \
		Test::NoWarnings
	PERL5LIB=$(PERL5LIB) PERL_MB_OPT=$(PERL_MB_OPT) PERL_MM_OPT=$(PERL_MM_OPT) DESTDIR=$(DESTDIR) \
		$(CPANM) $(CPANM_OPTS) \
		Test::Tester Test::Deep DBD::mysql
	# remove perllocal.pod, if installed
	-rm $(DESTDIR)$(ARCHLIB)/perllocal.pod
	-rmdir $(DESTDIR)$(ARCHLIB) $(DESTDIR)$(PRIVLIB)
	# Cleanup for missing support in cpanm for DESTDIR with .meta files
	#mv $(DESTDIR)/lib/perl5/$(ARCHNAME)/.meta $(DESTDIR)$(SITEARCH)/
	# try to *safely* remove the unneeded directories
	#rmdir $(DESTDIR)/lib/perl5/$(ARCHNAME) $(DESTDIR)/lib/perl5 $(DESTDIR)/lib

%:
	@echo "WARNING ** Target '$@' doesn't exist"
	@echo "        ** Current directory: $(PWD)"
	@echo "        ** Makefiles: $(MAKEFILE_LIST)"

clean:
	rm -rf $(DESTDIR) debian/libdbd-mysql-myperl

# This target writes the package and other debian files to the parent directory '..'
# It will cause the debian helper stuff to run all the above target(s).
package:
	DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -us -uc
