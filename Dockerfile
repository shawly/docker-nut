#
# nut Dockerfile
#
# https://github.com/shawly/docker-nut
#

# Set python image version
ARG PYTHON_VERSION=3.10-alpine3.15

# Set vars for s6 overlay
ARG S6_OVERLAY_VERSION=v2.2.0.3
ARG S6_OVERLAY_BASE_URL=https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}

# Set NUT vars
ARG NUT_BRANCH=tags/v3.3
ARG NUT_RELEASE=https://github.com/blawar/nut/archive/refs/${NUT_BRANCH}.tar.gz
ARG TITLEDB_URL=https://github.com/blawar/titledb

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

# Build nut
FROM python-${TARGETARCH:-amd64}${TARGETVARIANT} as builder

ARG NUT_RELEASE

# Change working dir
WORKDIR /nut

# Install build deps and install python dependencies
RUN \
  set -ex && \
  echo "Installing build dependencies..." && \
    apk add --no-cache \
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
    echo "Fixing armv6 and armv7 build by cloning cargo index manually" && \
      git clone --bare https://github.com/rust-lang/crates.io-index.git ~/.cargo/registry/index/github.com-1285ae84e5963aae

# Download NUT
ADD ${NUT_RELEASE} /tmp/nut.tar.gz

# Build venv
RUN \
  set -ex && \
  echo "Extracting nut..." && \
    tar xzf /tmp/nut.tar.gz --strip-components=1 -C /nut && \
  echo "Upgrading pip..." && \
    pip3 install --upgrade pip && \
  echo "Removing pyqt5 from requirements.txt since we have no gui..." && \
    sed -i '/pyqt5/d' requirements.txt && \
    sed -i '/qt-range-slider/d' requirements.txt && \
  echo "Fixing markupsafe issue..." && \
    echo "markupsafe==2.0.1" >> requirements.txt && \
  echo "Upgrading pip..." && \
    pip3 install --upgrade pip && \
  echo "Setup venv..." && \
    pip3 install virtualenv && \
    python3 -m venv venv && \
    source venv/bin/activate && \
  echo "Building wheels for requirements..." && \
    pip3 install --only-binary :all: -r requirements.txt && \
  echo "Creating volume directories..." && \
    mv -v conf conf_template && \
    mkdir -p conf _NSPOUT titles && \
  echo "Cleaning up directories..." && \
    rm -rf .github windows_driver gui tests tests-gui images && \
    rm -f .coveragerc .editorconfig .gitignore .pep8 .pylintrc .pre-commit-config.yaml \
          autoformat nut.pyproj nut.sln nut_gui.py tasks.py requirements_dev.txt setup.cfg pytest.ini *.md

# Setup nut image
FROM python-${TARGETARCH:-amd64}${TARGETVARIANT}

ARG TITLEDB_URL

ENV UMASK=022 \
    FIX_OWNERSHIP=true \
    TITLEDB_UPDATE=true \
    TITLEDB_URL=${TITLEDB_URL} \
    TITLEDB_REGION=US \
    TITLEDB_LANGUAGE=en \
    PATH="/nut/venv/bin:$PATH" \
    NUT_API_SCHEDULES='[{"scan": "0/30 * * * *"}]'

# Download S6 Overlay
ADD ${S6_OVERLAY_RELEASE} /tmp/s6overlay.tar.gz

# Copy wheels & crafty-web
COPY --chown=1000 --from=builder /nut /nut

# Change working dir
WORKDIR /nut

# Install deps and build binary
RUN \
  set -ex && \
  echo "Installing runtime dependencies..." && \
    apk add --no-cache \
      bash \
      curl \
      shadow \
      coreutils \
      libjpeg-turbo \
      tzdata \
      diffutils \
      sed \
      jq \
      git && \
  echo "Extracting s6 overlay..." && \
    tar xzf /tmp/s6overlay.tar.gz -C / && \
  echo "Creating nut user..." && \
    useradd -u 1000 -U -M -s /bin/false nut && \
    usermod -G users nut && \
  echo "Cleaning up directories..." && \
    rm -f /usr/bin/register && \
    rm -rf /tmp/*

# Add files
COPY rootfs/ /

# Define mountable directories
VOLUME ["/nut/titles", "/nut/conf", "/nut/_NSPOUT", "/nut/titledb"]

# Expose ports
EXPOSE 9000

# Start s6
ENTRYPOINT ["/init"]
