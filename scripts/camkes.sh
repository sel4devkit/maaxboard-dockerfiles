#!/bin/bash

set -exuo pipefail

# Source common functions
DIR="${BASH_SOURCE%/*}"
test -d "$DIR" || DIR=$PWD
# shellcheck source=utils/common.sh
. "$DIR/utils/common.sh"

# Don't make caches by default. Docker will set this to be 'yes'
: "${MAKE_CACHES:=no}"

# By default, assume we are on a desktop (usually less destructive)
: "${DESKTOP_MACHINE:=yes}"

# Docker may set this variable - fill if not set
: "${SCM:=https://github.com}"

# tmp space for building 
: "${TEMP_DIR:=/tmp}"

# At the end of each Docker image, we switch back to normal Debian
# apt repos, so we need to switch back to the Snapshot repos now
possibly_toggle_apt_snapshot

# Get dependencies
as_root dpkg --add-architecture i386
as_root apt-get update -q
as_root apt-get install -y --no-install-recommends \
    fakeroot \
    linux-libc-dev-i386-cross \
    linux-libc-dev:i386 \
    pkg-config \
    spin \
    # end of list

as_root apt-get install -y --no-install-recommends -t bullseye \
    lib32stdc++-8-dev \
    # end of list

# Required for testing
as_root apt-get install -y --no-install-recommends \
    gdb \
    libssl-dev \
    libcunit1-dev \
    libglib2.0-dev \
    libsqlite3-dev \
    libgmp3-dev \
    # end of list

# Required for stack to use tcp properly
as_root apt-get install -y --no-install-recommends \
    netbase \
    # end of list 
        
# Required for rumprun
as_root apt-get install -y --no-install-recommends \
    dh-autoreconf \
    genisoimage \
    gettext \
    rsync \
    xxd \
    # end of list 

# Required for cakeml
as_root apt-get install -y --no-install-recommends \
    polyml \
    libpolyml-dev \
    # end of list 


# Get python deps for CAmkES
for pip in "pip2" "pip3"; do
    as_root ${pip} install --no-cache-dir \
        camkes-deps \
        jinja2 \
        # end of list 
done

# Get stack
wget -O - https://get.haskellstack.org/ | sh
echo "export PATH=\"\$PATH:\$HOME/.local/bin\"" >> "$HOME/.bashrc"

as_root groupadd stack

echo "allow-different-user: true" >> "$HOME/.stack/config.yaml"
chmod a+x "$HOME" && chgrp -R stack "$HOME/.stack"
chmod -R g=u "$HOME/.stack"

# CAmkES is hard coded to look for clang in /opt/clang/
as_root ln -s /usr/lib/llvm-3.8 /opt/clang

if [ "$MAKE_CACHES" = "yes" ] ; then
    # Get a project that relys on stack, and use it to init the capDL-tool cache \
    # then delete the repo, because we don't need it.
    try_nonroot_first mkdir -p "$TEMP_DIR/camkes" || chown_dir_to_user "$TEMP_DIR/camkes" 
    pushd "$TEMP_DIR/camkes"
        repo init -u "${SCM}/seL4/camkes-manifest.git" --depth=1
        repo sync -j 4
        mkdir build
        pushd build
            ../init-build.sh
            ninja
        popd
    popd
    rm -rf camkes
fi

possibly_toggle_apt_snapshot
