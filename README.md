<!--
     SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Dockerfiles for seL4 development with the Avnet MaaXBoard

## Background

This repository holds tooling required to generate and manage the Docker image used by the [seL4 developer kit](https://github.com/sel4devkit) for the Avnet MaaXBoard.

This is a fork of the tooling created by the [seL4 Foundation](https://github.com/seL4) for the generation of Docker images (see [here](https://github.com/seL4/seL4-CAmkES-L4v-dockerfiles)). The changes within this fork:

1. Do not change any of the files from the source repository, thereby allowing updates from the source repository to be incorporated with minimal effort.
2. Add MaaXBoard specific configuration in the form a new Makefile, a new Dockerfile for the MaaXBoard image and a script to customise the tooling available within the image.

## Requirements

* docker (See [here](https://get.docker.com) or [here](https://docs.docker.com/engine/installation) for instructions)
* make

It is recommended you add yourself to the docker group, so you can run docker commands without using sudo.

## Quick start

To create a build environment for seL4 development targeting the Avnet MaaXBoard, run:


```bash
git clone https://github.com/sel4devkit/maaxboard-dockerfiles
cd maaxboard-dockerfiles
make -f MaaXBoard_Makefile build
```

To run the generated build environment mapping a particular directory to the /host dir in the container:

```
make -f MaaXBoard_Makefile run HOST_DIR=/scratch/sel4_stuff  # as an example
```

To push the generated build environment to the seL4 developer kit Github area (note, requires this elevated privileges):

```
make -f MaaXBoard_Makefile push
```

## Released images on Github

"Known working" images are pushed to the seL4 developer kit Github organisation, see [here](https://github.com/orgs/sel4devkit/packages/container/package/maaxboard). Images with the `:latest` tag are considered to be "known working".