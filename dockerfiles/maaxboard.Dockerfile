#
# SPDX-License-Identifier: BSD-2-Clause
#

ARG BASE_IMG
FROM --platform=linux/amd64 $BASE_IMG

ARG USERNAME
ENV USERNAME=$USERNAME

## Copy the install scripts into the image

COPY scripts /tmp/

## Set up the image

RUN echo ipv4 >> ~/.curlrc \ 
    ## Install sudo to support install scripts
    && apt-get update -q \
    && apt-get install -y --no-install-recommends sudo \
    ## Create the dev user
    && adduser --disabled-password --gecos "" --shell /bin/bash $USERNAME \
    && usermod -g sudo $USERNAME \
    && passwd -d $USERNAME \
    ## Make bash the default shell
    && ln -sf /bin/bash /bin/sh \
    ## Switch to the dev user
    && su - $USERNAME \
    ## Continue installation as the dev user
    && echo ipv4 >> ~/.curlrc \ 
    ## Set up environment variables to control the install scripts
    && export USE_DEBIAN_SNAPSHOT=no \
    && export REPO_DIR=/usr/bin \
    && export SCRIPTS_DIR=/home/$USERNAME/bin \
    ## Run the unmodified seL4 install scripts
    && /bin/bash "/tmp/base_tools.sh" \
    && /bin/bash "/tmp/sel4.sh" \
    ## Run the extras script specific to the MaaXBoard
    && /bin/bash "/tmp/maaxboard_extras.sh" \
    ## Clean up
    && sudo apt-get clean autoclean \
    && sudo apt-get autoremove --purge --yes \
    && sudo rm -rf /var/lib/apt/lists/*

## Set default user, working directory and command to run

USER $USERNAME
WORKDIR /host
CMD ["bash"]
