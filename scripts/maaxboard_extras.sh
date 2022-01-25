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
    sudo \
    cowsay \
    bison \
    flex \
    # end of list

# Remove tools and architectures not required by the MaaXBoard. This
# significantly reduces the size of the resulting Docker image.
as_root apt-get remove -y \
    g++-10-arm-linux-gnueabi \
    g++-10-arm-linux-gnueabihf \
    gcc-10-arm-linux-gnueabi \
    gcc-10-arm-linux-gnueabihf \
    gcc-riscv64-unknown-elf \
    # end of list
as_root dpkg --remove-architecture armhf
as_root dpkg --remove-architecture armel
