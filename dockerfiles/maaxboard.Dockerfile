#
# SPDX-License-Identifier: BSD-2-Clause
#

ARG BASE_IMG
FROM --platform=linux/amd64 $BASE_IMG

ARG USERNAME
ENV USERNAME=$USERNAME

## Copy the install scripts into the image

COPY scripts /tmp/

## Set up the image. Commands that require root access first

RUN echo ipv4 >> ~/.curlrc \ 
    ## Create the dev user with sudo permissions
    && adduser --disabled-password --gecos "" --shell /bin/bash $USERNAME \
    && usermod -g sudo $USERNAME \
    && passwd -d $USERNAME \
    ## Make bash the default shell
    && ln -sf /bin/bash /bin/sh \
    ## Set up environment variables to control the install scripts
    && export USE_DEBIAN_SNAPSHOT=no \
    && export REPO_DIR=/usr/bin \
    && export SCRIPTS_DIR=/home/$USERNAME/bin \
    && export HOME_DIR=/home/$USERNAME \
    && export USERNAME=$USERNAME \
    ## Run the unmodified seL4 install scripts
    && /bin/bash "/tmp/base_tools.sh" \
    && /bin/bash "/tmp/sel4.sh" \
    && /bin/bash "/tmp/camkes.sh" \
    ## Run the extras script specific to the MaaXBoard
    && /bin/bash "/tmp/maaxboard_extras.sh" \
    ## Clean up
    && apt-get clean autoclean \
    && apt-get autoremove --purge --yes \
    && rm -rf /var/lib/apt/lists/*

## Complete installation with basic setup as the dev user

USER $USERNAME

RUN echo ipv4 >> ~/.curlrc \ 
    ## Set up some defaults for Git
    && git config --global user.email "dev-user@maaxboard" \
    && git config --global user.name "Dev User"

## Set default working directory and command to run

WORKDIR /host
CMD ["bash"]
