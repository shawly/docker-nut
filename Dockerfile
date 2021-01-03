#
# nut Dockerfile
#
# https://github.com/shawly/docker-nut
#

# Base image prefix for automated dockerhub build
ARG BASE_IMAGE_PREFIX

# Set QEMU architecture
ARG QEMU_ARCH

# Set python version
ARG PYTHON_VERSION=slim

# Set vars for s6 overlay
ARG S6_OVERLAY_VERSION=v2.1.0.2
ARG S6_OVERLAY_ARCH=amd64
ARG S6_OVERLAY_RELEASE=https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCH}.tar.gz

# Set NUT vars
ARG NUT_REPO=https://github.com/blawar/nut.git
ARG NUT_BRANCH=master

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

# Add qemu-arm-static binary
COPY .gitignore qemu-${QEMU_ARCH}-static* /usr/bin/

# Download S6 Overlay
ADD ${S6_OVERLAY_RELEASE} /tmp/s6overlay.tar.gz

# Change working dir.
WORKDIR /nut

# Install deps and build binary.
RUN \
  set -ex && \
  echo "Installing build dependencies..." && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      git \
      gcc \
      curl \
      libusb-dev \
      libssl-dev \
      libcurl4-openssl-dev \
      tzdata && \
  echo "Extracting s6 overlay..." && \
    tar xzf /tmp/s6overlay.tar.gz -C / && \
  echo "Creating nut user..." && \
    useradd -u 1000 -U -M -s /bin/false nut && \
    usermod -G users nut && \
    mkdir -p /var/log/nut && \
    chown -R nobody:nogroup /var/log/nut && \
  echo "Cloning nut..." && \
    git clone --depth 1 ${NUT_REPO} /nut && \
    git checkout ${NUT_BRANCH} && \
    chown -R nut:nut /nut && \
  echo "Installing python packages..." && \
    pip3 install --no-cache -r requirements.txt && \
  echo "Removing build dependencies..." && \
    apt-get autoremove -y --purge \
      git \
      libusb-dev \
      libssl-dev \
      libcurl4-openssl-dev \
      gcc && \
    apt-get -y autoclean && \
  echo "Cleaning up temp directory..." && \
    rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/*

# Add files.
COPY rootfs/ /

# Define mountable directories.
VOLUME ["/games", "/nut/conf"]

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
      org.label-schema.docker.cmd="docker run -d --name=nut -p 9000:9000 -v $HOME/games:/games:rw shawly/nut"

# Start s6.
ENTRYPOINT ["/init"]
