# This tries to set up a couple of prereqs for you

TOPDIR=../..

PACKAGE_TARGETS = core i18n mason-html-client

include $(TOPDIR)/vagrant/etc/Makefile-git.incl
include $(TOPDIR)/vagrant/etc/Makefile-debian.incl
include $(TOPDIR)/vagrant/etc/Makefile-project.incl
include $(TOPDIR)/vagrant/etc/Makefile-vagrant.incl

#core.deb: $(call get-core-manifest)


.PHONY: info
info:
	@echo
	@echo "Supported targets:"
	@echo
	@echo "  build		build packages"
	@echo "  preinstall	copy packages and config to test instance"
	@echo "  install	install RPM packages on test instance"
	@echo "  clean      destroy all existing VM instances"
	@echo

debug2:
	@echo "Core Manifest: $(call get-core-manifest)"

#include: core.d

# $(call make-depend,MANIFEST,DEBPKG,depend-file)
#define make-depend
#  perl -n \
#     -e 'next if m/^#/ or m/^\s*$$/;' \
#     -e 'print "$2 $3: $(TOPDIR)/core/server/" . $$_;' $1 > $3.tmp
#  mv $3.tmp $3
#endef

define pkg-git-hash
$(shell if [ -f $1 ]; then \
	grep git-hash $1 | awk '{print $$2}'; \
	else \
	echo "0"; \
	fi)
endef

core.d:
	if [ "$(call curr-git-hash)" != "$(call pkg-git-hash,core.deb)" ]; then \
		touch $@; \
	fi


core.deb: core.d
	echo "git-hash $(call curr-git-hash)" > $@

	
#%.d: $(call get-$(%)-manifest)
#core.d: $(call get-core-manifest)

#core.deb core.d: $(call get-core-manifest)
#	touch $@


#include $(TOPDIR)/vagrant/etc/Makefile.incl

#VAGRANT_PREREQS += perl-5.14.2.tar.bz2

#perl-5.14.2.tar.bz2:
#	cp -p /junk/scotty/mirrors/perl/$@ $@

#CONF_PKG_VERSION = 1.1-0
CODE_PKG_VERSION = 0.11.3-1

.vagrant/machines/%/virtualbox/id: $(VAGRANT_PREREQS)
	vagrant up `echo $@ | awk -F/ '{print $$3}'`

#RPM_FILES = \
#	perl-openxpki-client-enrollment-$(CODE_PKG_VERSION).x86_64.rpm \
#	openxpki-perldeps-enrollment-$(CODE_PKG_VERSION).x86_64.rpm

#RPM_DIR = packages/Linux/DBpki/enroll-ui/1.0.0.0
#RPMS_TO_INSTALL = $(patsubst %,$(RPM_DIR)/%,$(RPM_FILES))
#RCM_HELPER_FILES = $(filter-out .%.swp,$(shell find rcm-helper -type f))

debug:
	echo "RPMS_TO_INSTALL = $(RPMS_TO_INSTALL)"
	echo "RCM_HELPER_FILES = $(RCM_HELPER_FILES)"

#.PHONY: pull
#pull: .vagrant/machines/build/virtualbox/id
#	vagrant ssh build --command "(test -d ~/git/openxpki || mkdir -p ~/git && cd ~/git && git clone /git-repo openxpki)"
#	vagrant ssh build --command "(cd ~/git/openxpki && git pull)"

.mk-state.git-refresh: .vagrant/machines/build/virtualbox/id
	vagrant ssh build --command "TARGETS='perl' /vagrant/etc/run-git-refresh.sh"

build: .mk-state.git-refresh
	vagrant ssh build --command "TARGETS='perl' /vagrant/etc/run-build.sh"

#.PHONY: packages
#packages: .vagrant/machines/build/virtualbox/id
#	vagrant ssh build --command "/vagrant/guest-bin/build-oxi.sh"

#.PHONY: preinstall
#preinstall: .mk-state.preinstall
#	
#.mk-state.preinstall: .vagrant/machines/test/virtualbox/id $(RPMS_TO_INSTALL) $(RCM_HELPER_FILES)
#	rsync -av --exclude '.*.swp' -e "vagrant ssh test --" packages/ :~pkiadm/inst.images/
#	rsync -av --exclude '.*.swp' -e "vagrant ssh test --" rcm-helper/ :~pkiadm/rcm-helper/
#	touch $@

#.PHONY: install
#install: .vagrant/machines/test/virtualbox/id .mk-state.preinstall
#	vagrant ssh test --command "sudo ~pkiadm/rcm-helper/bin/rcm-helper.sh"

#.PHONY: test-local
#test-local: .vagrant/machines/test/virtualbox/id install
#	vagrant ssh test --command "/vagrant/guest-bin/test-oxi.sh"

.PHONY: clean
clean:
	vagrant destroy -f
	rm -f .mk-state.* depend

.PHONY: clean-packages
clean-packages:
	rm -rf packages/Linux

.PHONY: realclean
realclean: clean clean-packages

