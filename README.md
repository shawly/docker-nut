# Docker container for NUT
[![Docker Automated build](https://img.shields.io/docker/automated/shawly/nut.svg)](https://hub.docker.com/r/shawly/nut/) [![Docker Image](https://images.microbadger.com/badges/image/shawly/nut.svg)](http://microbadger.com/#/images/shawly/nut) ![Docker Pulls](https://img.shields.io/docker/pulls/shawly/nut) [![Build Status](https://travis-ci.org/shawly/docker-nut.svg?branch=master)](https://travis-ci.org/shawly/docker-nut) [![GitHub Release](https://img.shields.io/github/release/shawly/docker-nut.svg)](https://github.com/shawly/docker-nut/releases/latest)

This is a Docker container for NUT. An app that acts as a USB and network server for use with [Tinfoil](https://tinfoil.io/Download)

---

[![nut](https://dummyimage.com/400x110/ffffff/575757&text=NUT)](https://gitlab.com/crafty-controller/nut)

NUT by [blawar](https://gitlab.com/blawar/nut).

---
## Table of Content

   * [Docker container for nut](#docker-container-for-nut)
      * [Table of Content](#table-of-content)
      * [Supported Architectures](#supported-architectures)
      * [Quick Start](#quick-start)
      * [Usage](#usage)
         * [Environment Variables](#environment-variables)
         * [Data Volumes](#data-volumes)
         * [Ports](#ports)
         * [Changing Parameters of a Running Container](#changing-parameters-of-a-running-container)
      * [Docker Compose File](#docker-compose-file)
      * [Docker Image Update](#docker-image-update)
      * [User/Group IDs](#usergroup-ids)
      * [Support or Contact](#support-or-contact)

## Supported Architectures

The architectures supported by this image are:

| Architecture | Tag | Status |
| :----: | --- | ------ |
| x86-64 | amd64-latest | working |
| x86 | i386-latest | experimental |
| arm64 | arm64v8-latest | experimental |
| armv7 | arm32v7-latest | experimental |
| armhf | arm32v6-latest | experimental |

*I'm declaring the arm images as **experimental** because I only own an older first generation RaspberryPi Model B+ I can't properly test the image on other devices, technically it should work on all RaspberryPi models and similar SoCs. While emulating the architecture with qemu works and can be used for testing, I can't guarantee that there will be no issues, just try it.*

## Quick Start

**NOTE**: The Docker command provided in this quick start is given as an example
and parameters should be adjusted to your need.

Launch the nut docker container with the following command:
```
docker run -d \
    --name=nut \
    -p 9000:9000 \
    -v $HOME/nut/titles:/nut/titles:rw \
    -v $HOME/nut/conf:/nut/conf:rw \
    -v $HOME/nut/_NSPOUT:/nut/_NSPOUT:rw \
    shawly/nut
```

Where:
  - `$HOME/nut/titles`: This location contains nsp files.
  - `$HOME/nut/conf`: This location contains the config files for NUT.
  - `$HOME/nut/_NSPOUT`: This location contains the nps files packed by NUT.

## Usage

```
docker run [-d] \
    --name=nut \
    [-e <VARIABLE_NAME>=<VALUE>]... \
    [-v <HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]]... \
    [-p <HOST_PORT>:<CONTAINER_PORT>]... \
    shawly/nut
```
| Parameter | Description |
|-----------|-------------|
| -d        | Run the container in background.  If not set, the container runs in foreground. |
| -e        | Pass an environment variable to the container.  See the [Environment Variables](#environment-variables) section for more details. |
| -v        | Set a volume mapping (allows to share a folder/file between the host and the container).  See the [Data Volumes](#data-volumes) section for more details. |
| -p        | Set a network port mapping (exposes an internal container port to the host).  See the [Ports](#ports) section for more details. |

### Environment Variables

To customize some properties of the container, the following environment
variables can be passed via the `-e` parameter (one for each variable).  Value
of this parameter has the format `<VARIABLE_NAME>=<VALUE>`.

| Variable       | Description                                  | Default |
|----------------|----------------------------------------------|---------|
|`USER_ID`| ID of the user the application runs as.  See [User/Group IDs](#usergroup-ids) to better understand when this should be set. | `1000` |
|`GROUP_ID`| ID of the group the application runs as.  See [User/Group IDs](#usergroup-ids) to better understand when this should be set. | `1000` |
|`TZ`| [TimeZone] of the container.  Timezone can also be set by mapping `/etc/localtime` between the host and the container. | `Etc/UTC` |

### Data Volumes

The following table describes data volumes used by the container.  The mappings
are set via the `-v` parameter.  Each mapping is specified with the following
format: `<HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]`.

| Container path  | Permissions | Description |
|-----------------|-------------|-------------|
|`/nut/titles`| rw | This is the path NUT will use to scan for nsps. |
|`/nut/conf`| rw | This is the path NUT will use to read its config files. |
|`/nut/_NSPOUT`| rw | This is the path NUT use for outputting nsp files. |

### Ports

Here is the list of ports used by the container.  They can be mapped to the host
via the `-p` parameter (one per port mapping).  Each mapping is defined in the
following format: `<HOST_PORT>:<CONTAINER_PORT>`.  The port number inside the
container cannot be changed, but you are free to use any port on the host side.

| Port | Mapping to host | Description |
|------|-----------------|-------------|
| 9000 | Mandatory | Port used for NUT webinterface. |

### Changing Parameters of a Running Container

As seen, environment variables, volume mappings and port mappings are specified
while creating the container.

The following steps describe the method used to add, remove or update
parameter(s) of an existing container.  The generic idea is to destroy and
re-create the container:

  1. Stop the container (if it is running):
```
docker stop nut
```
  2. Remove the container:
```
docker rm nut
```
  3. Create/start the container using the `docker run` command, by adjusting
     parameters as needed.

## Docker Compose File

Here is an example of a `docker-compose.yml` file that can be used with
[Docker Compose](https://docs.docker.com/compose/overview/).

Make sure to adjust according to your needs.  Note that only mandatory network
ports are part of the example.

```yaml
version: '3'
services:
  nut:
    image: shawly/nut
    environment:
      - TZ: Europe/Berlin
      - USER_ID: 9000
      - GROUP_ID: 9000
    ports:
      - "9000:9000"
    volumes:
      - "$HOME/nut/titles:/nut/titles:rw"
      - "$HOME/nut/conf:/nut/conf:rw"
      - "$HOME/nut/_NSPOUT:/nut/_NSPOUT:rw"
```

## Docker Image Update

If the system on which the container runs doesn't provide a way to easily update
the Docker image, the following steps can be followed:

  1. Fetch the latest image:
```
docker pull shawly/nut
```
  2. Stop the container:
```
docker stop nut
```
  3. Remove the container:
```
docker rm nut
```
  4. Start the container using the `docker run` command.

## User/Group IDs

When using data volumes (`-v` flags), permissions issues can occur between the
host and the container.  For example, the user within the container may not
exists on the host.  This could prevent the host from properly accessing files
and folders on the shared volume.

To avoid any problem, you can specify the user the application should run as.

This is done by passing the user ID and group ID to the container via the
`USER_ID` and `GROUP_ID` environment variables.

To find the right IDs to use, issue the following command on the host, with the
user owning the data volume on the host:

    id <username>

Which gives an output like this one:
```
uid=1000(myuser) gid=1000(myuser) groups=1000(myuser),4(adm),24(cdrom),27(sudo),46(plugdev),113(lpadmin)
```

The value of `uid` (user ID) and `gid` (group ID) are the ones that you should
be given the container.
