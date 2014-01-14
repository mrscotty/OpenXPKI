#!/bin/bash
#


if [[ $EUID -eq 0 ]]; then
    echo "This script must be run by a non-root user" 1>&2
    exit 1
fi

if [ -f /vagrant/env.profile ]; then
    . /vagrant/env.profile
fi

die () {
    echo $* 1>&2
    exit 1
}

: ${LOCAL_GIT_DIR:="$HOME/git"}
: ${LOCAL_GIT_REPO:="$LOCAL_GIT_DIR/openxpki"}

echo "    LOCAL_GIT_REPO = $LOCAL_GIT_REPO"
echo "    CPANM_OPTS = $CPANM_OPTS"


(cd "$LOCAL_GIT_REPO"/package/debian && make $TARGETS)
