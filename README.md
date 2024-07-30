# Docker container for NUT

[![Docker Automated build](https://img.shields.io/badge/docker%20build-automated-brightgreen)](https://github.com/shawly/docker-nut/actions) [![GitHub Workflow Status](https://img.shields.io/github/workflow/status/shawly/docker-nut/Docker)](https://github.com/shawly/docker-nut/actions) [![Docker Pulls](https://img.shields.io/docker/pulls/shawly/nut)](https://hub.docker.com/r/shawly/nut) [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/shawly/nut/latest)](https://hub.docker.com/r/shawly/nut) [![GitHub Release](https://img.shields.io/github/release/shawly/docker-nut.svg)](https://github.com/shawly/docker-nut/releases/latest)

This is a Docker container for NUT. An app that acts as a USB and network server for use with [Tinfoil](https://tinfoil.io/Download)

---

[![nut](https://dummyimage.com/400x110/ffffff/575757&text=NUT)](https://github.com/blawar/nut)

NUT by [blawar](https://github.com/blawar/nut).

---

## Table of Content

- [Docker container for nut](#docker-container-for-nut)
  - [Table of Content](#table-of-content)
  - [Supported tags](#supported-tags)
  - [Image Variants](#image-variants)
  - [Supported Architectures](#supported-architectures)
  - [Quick Start](#quick-start)
  - [Usage](#usage)
    - [Environment Variables](#environment-variables)
    - [Data Volumes](#data-volumes)
    - [Ports](#ports)
    - [Changing Parameters of a Running Container](#changing-parameters-of-a-running-container)
  - [Docker Compose File](#docker-compose-file)
  - [Docker Image Update](#docker-image-update)
  - [User/Group IDs](#usergroup-ids)
  - [Using the NUT API](#using-the-nut-api)
  - [Troubleshooting](#troubleshooting)

## Supported tags

<!-- supported tags will be auto updated through workflows! -->

- `edge`, `edge-8a14810`, `edge-8a1481015b6c1ff5acc57c8cb9f0f325433c67d7` <!-- edge tag -->
- `latest`, `v3`, `v3.4`, `v3.4.0` <!-- latest tag -->

## Image Variants

This image comes in two different variants.

### `shawly/nut:<version>`

This image represents a stable or considered "working" build of NUT and should be preferred.
It will be built from a stable state of NUT, e.g. `tags/v3.3`.

### `shawly/nut:edge-<commitsha>`

This image represents a development state of this repo. It contains the latest features but is not considered stable, it can contain bugs and breaking changes.
If you are not sure what to choose, use the `latest` image or a version like `v3`.
It will be built from the latest `master` state of NUT.
`edge` will always be the latest development image. If NUT is updated, the `edge` image will be rebuilt and tagged with the latest commit shortref e.g. `edge-9c726a5`.

## Supported Architectures

The architectures supported by this image are:

| Architecture | Status                                                   |
| :----------: | -------------------------------------------------------- |
|    x86-64    | working                                                  |
|     x86      | untested                                                 |
|    arm64     | [working](https://github.com/shawly/docker-nut/issues/3) |
|    armv7     | untested                                                 |
|    armhf     | untested                                                 |
|   ppc64le    | dropped                                                  |

_I'm declaring the arm images as **untested** because I only own an older first generation RaspberryPi Model B+ I can't properly test the image on other devices, technically it should work on all RaspberryPi models and similar SoCs. While emulating the architecture with qemu works and can be used for testing, I can't guarantee that there will be no issues, just try it._

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
    -v $HOME/nut/titledb:/nut/titledb:rw \
    shawly/nut
```

Where:

- `$HOME/nut/titles`: This location contains nsp files.
- `$HOME/nut/conf`: This location contains the config files for NUT.
- `$HOME/nut/_NSPOUT`: This location contains the nsp files packed by NUT.
- `$HOME/nut/titledb`: This location contains the titledb.

## Usage

```
docker run [-d] \
    --name=nut \
    [-e <VARIABLE_NAME>=<VALUE>]... \
    [-v <HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]]... \
    [-p <HOST_PORT>:<CONTAINER_PORT>]... \
    shawly/nut
```

| Parameter | Description                                                                                                                                              |
| --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| -d        | Run the container in background. If not set, the container runs in foreground.                                                                           |
| -e        | Pass an environment variable to the container. See the [Environment Variables](#environment-variables) section for more details.                         |
| -v        | Set a volume mapping (allows to share a folder/file between the host and the container). See the [Data Volumes](#data-volumes) section for more details. |
| -p        | Set a network port mapping (exposes an internal container port to the host). See the [Ports](#ports) section for more details.                           |

### Environment Variables

To customize some properties of the container, the following environment
variables can be passed via the `-e` parameter (one for each variable). Value
of this parameter has the format `<VARIABLE_NAME>=<VALUE>`.

| Variable            | Description                                                                                                                                                                                                                                                        | Default                             |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------- |
| `USER_ID`           | ID of the user the application runs as. See [User/Group IDs](#usergroup-ids) to better understand when this should be set.                                                                                                                                         | `1000`                              |
| `GROUP_ID`          | ID of the group the application runs as. See [User/Group IDs](#usergroup-ids) to better understand when this should be set.                                                                                                                                        | `1000`                              |
| `TZ`                | [TimeZone] of the container. Timezone can also be set by mapping `/etc/localtime` between the host and the container.                                                                                                                                              | `Etc/UTC`                           |
| `UMASK`             | This sets the umask for the NUT process in the container.                                                                                                                                                                                                          | `022`                               |
| `FIX_OWNERSHIP`     | This executes a script which checks if the USER_ID & GROUP_ID changed from the default of 1000 and fixes the ownership of the /nut folder if necessary, otherwise nut wont't start. It's recommended to leave this enabled if you changed the USER_ID or GROUP_ID. | `true`                              |
| `TITLEDB_UPDATE`    | If the container should update the titledb when starting.                                                                                                                                                                                                          | `true`                              |
| `TITLEDB_URL`       | Git repository from which the titledb should be pulled. (If you change this URL you need to remove the /nut/titledb folder within your container!)                                                                                                                 | `https://github.com/blawar/titledb` |
| `TITLEDB_REGION`    | Region to be used when importing the titledb.                                                                                                                                                                                                                      | `true`                              |
| `TITLEDB_LANGUAGE`  | Language to be used when importing the titledb.                                                                                                                                                                                                                    | `true`                              |
| `NUT_API_SCHEDULES` | A json array with crontab schedules for calling api commands. The default value sets a cron schedule that runs a scan every 30 minutes. To disable scheduled api calls set this to `[]`. Check [Using the NUT API](#using-the-nut-api) down below for more info.   | `[{"scan": "0/30 * * * *"}]`        |

### Data Volumes

The following table describes data volumes used by the container. The mappings
are set via the `-v` parameter. Each mapping is specified with the following
format: `<HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]`.

| Container path | Permissions | Description                                             |
| -------------- | ----------- | ------------------------------------------------------- |
| `/nut/titles`  | rw          | This is the path NUT will use to scan for nsps.         |
| `/nut/conf`    | rw          | This is the path NUT will use to read its config files. |
| `/nut/_NSPOUT` | rw          | This is the path NUT uses for outputting nsp files.     |
| `/nut/titledb` | rw          | This is the path NUT stores the titledb.                |

**Note**: You can also use `/nut/titledb` within a separate bind mount or volume so your titledb is persisted between recreation of your container, this improves startup time.

### Ports

Here is the list of ports used by the container. They can be mapped to the host
via the `-p` parameter (one per port mapping). Each mapping is defined in the
following format: `<HOST_PORT>:<CONTAINER_PORT>`. The port number inside the
container cannot be changed, but you are free to use any port on the host side.

| Port | Mapping to host | Description                     |
| ---- | --------------- | ------------------------------- |
| 9000 | Mandatory       | Port used for NUT webinterface. |

### Changing Parameters of a Running Container

As seen, environment variables, volume mappings and port mappings are specified
while creating the container.

The following steps describe the method used to add, remove or update
parameter(s) of an existing container. The generic idea is to destroy and
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

Make sure to adjust according to your needs. Note that only mandatory network
ports are part of the example.

```yaml
version: "3"
services:
  nut:
    image: shawly/nut
    environment:
      - TZ: Europe/Berlin
      - USER_ID: 9000
      - GROUP_ID: 9000
      - TITLEDB_REGION: US
      - TITLEDB_LANGUAGE: en
      - NUT_API_SCHEDULES: "[{"scan":"0/30 * * * *}]"
    ports:
      - "9000:9000"
    volumes:
      - "$HOME/nut/titles:/nut/titles:rw"
      - "$HOME/nut/conf:/nut/conf:rw"
      - "$HOME/nut/_NSPOUT:/nut/_NSPOUT:rw"
      - "$HOME/nut/titledb:/nut/titledb:rw"
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
host and the container. For example, the user within the container may not
exists on the host. This could prevent the host from properly accessing files
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

## Using the NUT API

NUT provides an API for executing certain commands like scan and organize.

Replace http://localhost:9000 with the actual address to your NUT instance.

### Organize NSPs

Call [`http://localhost:9000/api/organize`](http://localhost:9000/api/organize)

### Scan for new NSPs

Call [`http://localhost:9000/api/scan`](http://localhost:9000/api/scan)

### Automated scans

With the latest `edge` image you can run automated schedules by configuring the `NUT_API_SCHEDULES` variable.

The default is set to `[{"scan": "0/30 * * * *"}]`, which calls `http://localhost:9000/api/scan` every full 30 minutes which will trigger a scan.

#### Format

The format is set up like this:

```json
[
  {
    "command": "min hour day month weekday"
  }
]
```

#### Example

If you wanted for example to scan and organize your NSPs automatically every 15 minutes, your configuration would look like this:

```json
[
  {
    "scan": "0/15 * * * *"
  },
  {
    "organize": "0/20 * * * *"
  }
]
```

So your `NUT_API_SCHEDULES` value would look like this `[{"scan":"0/15 * * * *"},{"organize":"0/20 * * * *"}]`. This would now run the scan every 15 minutes and the organize command every 20 minutes.

If you use Docker Compose and define your environment variables in yaml format, make sure to use the compact format so that there is no space after the colons (`:`)!

## Troubleshooting

### The log says `could not load keys.txt, all crypto operations will fail`

If you just want to serve titles for your Switch you don't need the keys.txt at all.
Otherwise you can extract the keys.txt via biskeydump and Lockpick or find them on the internet, I won't provide any links however, use Google.

### The log says `titledb/db.nza unknown extension titledb/db.nza`

You can ignore this.

### The log says something about "Permission denied" and/or NUT cant find any nsp files

This means your folder permissions are not correct or rather the folders are owned by a user that has a uid different from `1000`, see [User/Group IDs](#usergroup-ids).
Beware, if you have the environment variable `FIX_OWNERSHIP` set to `true` and change the `USER_ID` or `GROUP_ID` your volume's ownership will be changed!

### The log says `AttributeError: module 'collections' has no attribute 'Mapping'`

This is a bug that happens with NUT v3.3 when you use a `nut.conf` to store your settings, NUT seems to have an issue merging the `nut.default.conf` and your own `nut.conf`. The workaround for this is to remove the `nut.conf` file and make your changes in the `nut.default.conf`.
