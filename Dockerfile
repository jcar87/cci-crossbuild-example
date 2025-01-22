# Ubuntu noble 24.04 LTS
FROM ubuntu:noble

# Set up dpkg architectures, amd64 (native) and arm64 (cross)
RUN dpkg --add-architecture arm64
COPY amd64_sources /etc/apt/sources.list.d/ubuntu.sources
COPY arm64_sources /etc/apt/sources.list.d/ubuntu_arm64.sources

RUN apt-get update \
    && DEBIAN_FRONTEND=noniteractive apt-get install -y --no-install-recommends \
    build-essential \
    crossbuild-essential-arm64 \
    ca-certificates \
    cmake \
    nano \
    ninja-build \
    pkg-config \
    pkgconf:arm64 \
    pkgconf-bin:arm64 \ 
    python3-venv \
    tree \
    wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /root
RUN python3 -m venv venv \
    && ./venv/bin/pip install conan \
    && ./venv/bin/conan profile detect \
    && ln -s /root/venv/bin/conan /usr/bin/conan

COPY arm64_profile /root/.conan2/profiles/arm64
