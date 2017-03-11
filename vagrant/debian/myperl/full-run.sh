#!/bin/bash
#
# full-run.sh - start vagrant instances, build packages, test 'em
#
# NOTE: This assumes that it starts with a clean slate, so it's best
# to just destroy any current instances. You'll have to do that 
# yourself--I'm too paranoid.

set -e -x

dist="$1"

case $dist in
    xenial)
        vagid=build-xenial
        ;;
    debian)
        vagid=build-myperl
        ;;
    *)
        echo "Unsupported distribution '$dist'" 1>&2
        exit 1
        ;;
esac

if [ ! -f .vagrant/machines/$vagid/virtualbox/id ]; then
    vagrant up --no-provision $vagid
    vagrant ssh $vagid --command 'sudo /vagrant/myperl/provision-build.sh'
fi

if [ -f local.rc ]; then
    vagrant ssh $vagid --command 'cp /vagrant/local.rc ~/'
fi

vagrant ssh $vagid --command '/vagrant/myperl/build.sh all'
vagrant ssh $vagid --command '/vagrant/myperl/build.sh collect'

if [ "$dist" = 'debian' ]; then
    vagrant up test-myperl
    vagrant ssh test-myperl --command 'sudo /vagrant/myperl/install-oxi.sh'
    vagrant ssh test-myperl --command 'sudo /vagrant/myperl/run-tests.sh'
fi

