#
# nut Dockerfile
#
# https://github.com/shawly/docker-nut
#

# Set python image version
ARG PYTHON_VERSION=alpine

# Set vars for s6 overlay
ARG S6_OVERLAY_VERSION=v2.2.0.3
ARG S6_OVERLAY_BASE_URL=https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}

# Set NUT vars
ARG NUT_REPO=https://github.com/blawar/nut.git
ARG NUT_BRANCH=v3.3

# Set base images with s6 overlay download variable (necessary for multi-arch building via GitHub workflows)
FROM python:${PYTHON_VERSION} as python-amd64

ARG S6_OVERLAY_VERSION
ARG S6_OVERLAY_BASE_URL
ENV S6_OVERLAY_RELEASE="${S6_OVERLAY_BASE_URL}/s6-overlay-amd64.tar.gz"

FROM python:${PYTHON_VERSION} as python-386

ARG S6_OVERLAY_VERSION
ARG S6_OVERLAY_BASE_URL
ENV S6_OVERLAY_RELEASE="${S6_OVERLAY_BASE_URL}/s6-overlay-x86.tar.gz"

FROM python:${PYTHON_VERSION} as python-armv6

ARG S6_OVERLAY_VERSION
ARG S6_OVERLAY_BASE_URL
ENV S6_OVERLAY_RELEASE="${S6_OVERLAY_BASE_URL}/s6-overlay-armhf.tar.gz"

FROM python:${PYTHON_VERSION} as python-armv7

ARG S6_OVERLAY_VERSION
ARG S6_OVERLAY_BASE_URL
ENV S6_OVERLAY_RELEASE="${S6_OVERLAY_BASE_URL}/s6-overlay-arm.tar.gz"

FROM python:${PYTHON_VERSION} as python-arm64

ARG S6_OVERLAY_VERSION
ARG S6_OVERLAY_BASE_URL
ENV S6_OVERLAY_RELEASE="${S6_OVERLAY_BASE_URL}/s6-overlay-aarch64.tar.gz"

FROM python:${PYTHON_VERSION} as python-ppc64le

ARG S6_OVERLAY_VERSION
ARG S6_OVERLAY_BASE_URL
ENV S6_OVERLAY_RELEASE="${S6_OVERLAY_BASE_URL}/s6-overlay-ppc64le.tar.gz"

# Build nut:master
FROM python-${TARGETARCH:-amd64}${TARGETVARIANT}

ARG NUT_REPO
ARG NUT_BRANCH

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
      cargo \
      rust \
      zlib-dev && \
  echo "Installing runtime dependencies..." && \
    apk add --no-cache \
      bash \
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
    git clone --depth 1 --branch ${NUT_BRANCH} ${NUT_REPO} /nut && \
    mkdir -p /nut/_NSPOUT /nut/titles && \
    chown -R nut:nut /nut && \
    mv -v /nut/conf /nut/conf_template && \
  echo "Removing pyqt5 from requirements.txt since we have no gui..." && \
    sed -i '/pyqt5/d' requirements.txt && \
    sed -i '/qt-range-slider/d' requirements.txt && \
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

# Start s6.
ENTRYPOINT ["/init"]
