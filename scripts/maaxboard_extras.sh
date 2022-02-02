#!/bin/bash
#
# This script adds and removes packages to control those required
# for building for the Avnet MaaxBoard. 
#
# SPDX-License-Identifier: BSD-2-Clause
#

set -exuo pipefail

# Source common functions
DIR="${BASH_SOURCE%/*}"
test -d "$DIR" || DIR=$PWD
# shellcheck source=utils/common.sh
. "$DIR/utils/common.sh"

# Extras for the MaaXBoard build environment, e.g. to build u-boot
as_root apt-get install -y --no-install-recommends \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    gcc-arm-linux-gnueabihf \
    g++-arm-linux-gnueabihf \
    gcc-arm-linux-gnueabi \
    g++-arm-linux-gnueabi \
    sudo \
    cowsay \
    bison \
    flex \
    python-dev \
    # end of list

# Remove tools and architectures not required by the MaaXBoard. This
# reduces the size of the resulting Docker image.
as_root apt-get remove -y \
    gcc-riscv64-unknown-elf \
    # end of list

# Install required python2 dependencies.
as_root wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
as_root python2 get-pip.py 
as_root rm get-pip.py
as_root python2 -m pip install --no-cache-dir \
    setuptools \
    pylint \
    sel4-deps \
    camkes-deps \
    # end of list

# Set up locales. en_GB chosen because we're in the UK.
echo 'en_GB.UTF-8 UTF-8' | as_root tee /etc/locale.gen > /dev/null
as_root dpkg-reconfigure --frontend=noninteractive locales
echo "LANG=en_GB.UTF-8" | as_root tee -a /etc/default/locale > /dev/null
echo "export LANG=en_GB.UTF-8" >> "$HOME_DIR/.bashrc"
