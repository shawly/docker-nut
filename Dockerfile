#
# nut Dockerfile
#
# https://github.com/shawly/docker-nut
#

# Base image prefix for automated dockerhub build
ARG BASE_IMAGE_PREFIX

# Set QEMU architecture
ARG QEMU_ARCH

# Set python image version
ARG PYTHON_VERSION=alpine

# Set vars for s6 overlay
ARG S6_OVERLAY_VERSION=v2.1.0.2
ARG S6_OVERLAY_ARCH=amd64
ARG S6_OVERLAY_RELEASE=https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCH}.tar.gz

# Set NUT vars
ARG NUT_REPO=https://github.com/blawar/nut.git
ARG NUT_BRANCH=master

# Provide QEMU files
FROM multiarch/qemu-user-static as qemu

# Build nut:master
FROM ${BASE_IMAGE_PREFIX}python:${PYTHON_VERSION}

ARG NUT_REPO
ARG NUT_BRANCH
ARG QEMU_ARCH
ARG BUILD_DATE
ARG S6_OVERLAY_RELEASE

ENV S6_OVERLAY_RELEASE=${S6_OVERLAY_RELEASE} \
    NUT_REPO=${NUT_REPO} \
    NUT_BRANCH=${NUT_BRANCH}

# Add qemu-arm-static binary (copying /register is a necessary hack for amd64 systems)
COPY --from=qemu /register /usr/bin/qemu-${QEMU_ARCH}-static* /usr/bin/

# Download S6 Overlay
ADD ${S6_OVERLAY_RELEASE} /tmp/s6overlay.tar.gz

# Change working dir.
WORKDIR /nut

# Install deps and build binary.
RUN \
  set -ex && \
  echo "Installing build dependencies..." && \
    apk add --no-cache --virtual build-dependencies \
      git \
      build-base \
      libusb-dev \
      libressl-dev \
      libffi-dev \
      curl-dev \
      jpeg-dev \
      zlib-dev && \
  echo "Installing runtime dependencies..." && \
    apk add --no-cache \
      curl \
      shadow \
      coreutils \
      libjpeg-turbo \
      tzdata && \
  echo "Extracting s6 overlay..." && \
    tar xzf /tmp/s6overlay.tar.gz -C / && \
  echo "Creating nut user..." && \
    useradd -u 1000 -U -M -s /bin/false nut && \
    usermod -G users nut && \
  echo "Cloning nut..." && \
    git clone --depth 1 ${NUT_REPO} /nut && \
    git checkout ${NUT_BRANCH} && \
    mkdir -p /nut/_NSPOUT /nut/titles && \
    chown -R nut:nut /nut && \
    mv -v /nut/conf /nut/conf_template && \
  echo "Removing pyqt5 from requirements.txt since we have no gui..." && \
    sed -i '/pyqt5/d' requirements.txt && \
  echo "Installing python packages..." && \
    pip3 install --no-cache -r requirements.txt && \
  echo "Removing unneeded build dependencies..." && \
    apk del build-dependencies && \
  echo "Cleaning up directories..." && \
    rm -f /usr/bin/register && \
    rm -rf .git .github windows_driver tests gui && \
    rm -f .coveragerc .editorconfig .gitignore .pep8 .pylintrc autoformat nut.pyproj nut.sln nut_gui.py tasks.py LICENSE requirements* *.md && \
    rm -rf /tmp/*

# Add files.
COPY rootfs/ /

# Define mountable directories.
VOLUME ["/nut/titles", "/nut/conf", "/nut/_NSPOUT"]

# Expose ports.
EXPOSE 9000

# Metadata.
LABEL \
      org.label-schema.name="nut" \
      org.label-schema.description="Docker container for nut" \
      org.label-schema.version="unknown" \
      org.label-schema.vcs-url="https://github.com/shawly/docker-nut" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vendor="shawly" \
      org.label-schema.docker.cmd="docker run -d --name=nut -p 9000:9000 -v $HOME/nut/titles:/nut/titles -v $HOME/nut/conf:/nut/conf shawly/nut"

# Start s6.
ENTRYPOINT ["/init"]
