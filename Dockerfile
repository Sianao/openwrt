# syntax=docker/dockerfile:1

# Local OpenWrt build container for mediatek/filogic (Cudy TR3600 v1).
# The OpenWrt source tree is mounted at /src, not baked into the image.
#
# Build (match your host UID/GID so build_dir/staging_dir are owned by you):
#   docker build \
#     --build-arg USER_ID="$(id -u)" \
#     --build-arg GROUP_ID="$(id -g)" \
#     -t openwrt-build .
#
# Run an interactive shell in the source tree:
#   docker run --rm -it \
#     -v "$PWD":/src \
#     -v openwrt-ccache:/ccache \
#     openwrt-build bash

FROM ubuntu:24.04

ARG TARGETARCH
ARG USER_ID=1000
ARG GROUP_ID=1000

ENV DEBIAN_FRONTEND=noninteractive \
    CCACHE_DIR=/ccache \
    FORCE_UNSAFE_CONFIGURE=1

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential clang flex bison g++ gawk \
        $(if [ "$TARGETARCH" = "amd64" ]; then echo gcc-multilib g++-multilib; fi) \
        gettext git libncurses-dev libssl-dev perl rsync unzip \
        zlib1g-dev file wget quilt ccache python3 python3-setuptools \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -o -g "$GROUP_ID" build \
    && useradd -m -u "$USER_ID" -g "$GROUP_ID" -o -s /bin/bash build \
    && mkdir -p /src /ccache \
    && chown -R build:build /src /ccache

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /src
VOLUME ["/src", "/ccache"]

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/bin/bash", "-lc", "make -j$(nproc)"]
