#!/bin/bash
#
# prov-build.sh - Provision build VM

. /vagrant/etc/helper

fail_if_not_root

if ! is_done prov-build.sh; then
    # Update package list
    package_update
    
    # For rebuilding debian packages
    package 'devscripts build-essential fakeroot'
    # Dependencies for building perl
    #package 'libdb-dev libgdm-dev libbz2-dev'
    package 'libdb-dev libbz2-dev'
    # Install packages needed for building
    package 'debhelper git-core openssl libssl-dev openssl gettext curl'
    package 'expat libexpat-dev'
    package 'libconfig-std-perl libyaml-perl libtemplate-perl'


    set_done prov-build.sh
fi

finished
