# syntax=docker/dockerfile:1-labs

ARG OS_BASE=debian:bookworm

FROM scratch AS git-gstreamer

ARG GSTREAMER_MINOR_VERSION=22
ARG GSTREAMER_PATCH_VERSION=0
ADD --keep-git-dir=true https://gitlab.freedesktop.org/gstreamer/gstreamer.git#1.${GSTREAMER_MINOR_VERSION}.${GSTREAMER_PATCH_VERSION} /

FROM scratch AS git-gstreamer-patches

ADD https://github.com/JeffyCN/meta-rockchip.git#master:recipes-multimedia/gstreamer /

FROM scratch AS git-rockchip-gstreamer

ADD https://github.com/JeffyCN/mirrors.git#gstreamer-rockchip /

# --------------------------------------------------------------------------- #

FROM scratch AS git-rockchip-mpp

ADD --keep-git-dir=true https://github.com/rockchip-linux/mpp.git#develop /

# --------------------------------------------------------------------------- #

FROM scratch AS git-rockchip-rga

ADD https://github.com/JeffyCN/mirrors.git#linux-rga /

# --------------------------------------------------------------------------- #

FROM ${OS_BASE} AS build-base

RUN --mount=type=cache,sharing=locked,id=apt-base,target=/var/lib/apt \
    --mount=type=cache,sharing=locked,id=apt-base,target=/var/cache/apt \
    apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      cmake \
      g++ \
      gcc \
      git \
      make \
      wget \
    && rm -rf /var/lib/apt/lists/* \
    ;

# --------------------------------------------------------------------------- #

FROM build-base AS build-rockchip-mpp

COPY --link --from=git-rockchip-mpp / /src/rockchip-mpp

RUN cd /src/rockchip-mpp/build/linux/aarch64 \
    && ./make-Makefiles.bash \
    && DESTDIR=/out/rockchip-mpp make install -j$(nproc)

# --------------------------------------------------------------------------- #

FROM scratch AS rockchip-mpp

COPY --link --from=build-rockchip-mpp /out/rockchip-mpp /

# --------------------------------------------------------------------------- #

FROM build-base AS build-rockchip-rga

COPY --link --from=git-rockchip-rga / /src/rockchip-rga
WORKDIR /src/rockchip-rga

RUN --mount=type=cache,sharing=locked,id=apt-rkrga,target=/var/lib/apt \
    --mount=type=cache,sharing=locked,id=apt-rkrga,target=/var/cache/apt \
    apt-get update \
    && DEBIAN_FRONTEND=noninterface apt-get install -y --no-install-recommends \
      libdrm-dev \
      meson \
      pkg-config \
    && rm -rf /var/lib/apt/lists/* \
    ;

RUN cd /src/rockchip-rga \
    && meson build \
    && cd build \
    && DESTDIR=/out/rockchip-rga ninja install \
    ;

# --------------------------------------------------------------------------- #

FROM scratch AS rockchip-rga

COPY --link --from=build-rockchip-rga /out/rockchip-rga /

# --------------------------------------------------------------------------- #

FROM build-base AS build-gstreamer

# we don't need non-free-firmware
# https://www.debian.org/releases/bookworm/arm64/release-notes/ch-information.html#non-free-split
RUN sed -i 's/Components: main/Components: main contrib non-free/' /etc/apt/sources.list.d/debian.sources \
    && sed -i 's/Types: deb/Types: deb deb-src/' /etc/apt/sources.list.d/debian.sources \
    && echo 'APT::Get::Update::SourceListWarnings::NonFreeFirmware "false";' > /etc/apt/apt.conf.d/no-bookworm-firmware.conf \
    ;

RUN --mount=type=cache,sharing=locked,id=apt-gstreamer,target=/var/lib/apt \
    --mount=type=cache,sharing=locked,id=apt-gstreamer,target=/var/cache/apt \
    apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      bison \
      bubblewrap \
      ca-certificates \
      cmake \
      flex \
      flite1-dev \
      gcc \
      gettext \
      git \
      gperf \
      iso-codes \
      liba52-0.7.4-dev \
      libaa1-dev \
      libaom-dev \
      libass-dev \
      libatk-bridge2.0-dev \
      libatk1.0-dev \
      libatspi2.0-dev \
      libavcodec-dev \
      libavfilter-dev \
      libavformat-dev \
      libavutil-dev \
      libbs2b-dev \
      libbz2-dev \
      libcaca-dev \
      libcap-dev \
      libchromaprint-dev \
      libcups2-dev \
      libcurl4-gnutls-dev \
      libdca-dev \
      libde265-dev \
      libdrm-dev \
      libdv4-dev \
      libdvdnav-dev \
      libdvdread-dev \
      libdw-dev \
      libepoxy-dev \
      libfaac-dev \
      libfaad-dev \
      libfdk-aac-dev \
      libfluidsynth-dev \
      libgbm-dev \
      libgcrypt20-dev \
      libgirepository1.0-dev \
      libgl-dev \
      libgles-dev \
      libglib2.0-dev \
      libgme-dev \
      libgmp-dev \
      libgraphene-1.0-dev \
      libgsl-dev \
      libgsm1-dev \
      libgudev-1.0-dev \
      libjpeg-dev \
      libjson-glib-dev \
      libkate-dev \
      liblcms2-dev \
      liblilv-dev \
      libmjpegtools-dev \
      libmodplug-dev \
      libmp3lame-dev \
      libmpcdec-dev \
      libmpeg2-4-dev \
      libmpg123-dev \
      libofa0-dev \
      libogg-dev \
      libopencore-amrnb-dev \
      libopencore-amrwb-dev \
      libopenexr-dev \
      libopenjp2-7-dev \
      libopus-dev \
      liborc-0.4-dev \
      libpango1.0-dev \
      libpng-dev \
      libqrencode-dev \
      librsvg2-dev \
      librtmp-dev \
      libsbc-dev \
      libseccomp-dev \
      libshout3-dev \
      libsndfile1-dev \
      libsoundtouch-dev \
      libsoup2.4-dev \
      libspandsp-dev \
      libspeex-dev \
      libsrt-gnutls-dev \
      libsrtp2-dev \
      libssl-dev \
      libtag1-dev \
      libtheora-dev \
      libtwolame-dev \
      libudev-dev \
      libunwind-dev \
      libva-dev \
      libvisual-0.4-dev \
      libvo-aacenc-dev \
      libvo-amrwbenc-dev \
      libvorbis-dev \
      libvpx-dev \
      libvulkan-dev \
      libwavpack-dev \
      libwayland-dev \
      libwebp-dev \
      libwebrtc-audio-processing-dev \
      libwildmidi-dev \
      libwoff-dev \
      libx264-dev \
      libx265-dev \
      libxcomposite-dev \
      libxdamage-dev \
      libxkbcommon-dev \
      libxslt1-dev \
      libzbar-dev \
      libzvbi-dev \
      meson \
      python3 \
      python3-dev \
      python3-pip \
      ruby \
      wayland-protocols \
      wget \
      xdg-dbus-proxy \
    && rm -rf /var/lib/apt/lists/* \
    ;

COPY --link --from=rockchip-mpp / /
COPY --link --from=rockchip-rga / /
RUN ldconfig

COPY --link --from=git-gstreamer / /src/gstreamer
COPY --link --from=git-gstreamer-patches / /src/patches

ARG GSTREAMER_MINOR_VERSION=22
WORKDIR /src/gstreamer
RUN git config --global user.email "ci-noreply@milas.dev" \
    && git config --global user.name "Build User" \
    && find /src/patches/gstreamer1.0_1.${GSTREAMER_MINOR_VERSION} \
        -name '*.patch' \
        -type f \
        -print0 \
      | sort -z \
      | xargs -r0 git am --directory=subprojects/gstreamer --reject --whitespace=fix \
    && find /src/patches/gstreamer1.0-plugins-base_1.${GSTREAMER_MINOR_VERSION} \
        -name '*.patch' \
        -type f \
        -print0 \
      | sort -z \
      | xargs -r0 git am --directory=subprojects/gst-plugins-base --reject --whitespace=fix \
    && find /src/patches/gstreamer1.0-plugins-good_1.${GSTREAMER_MINOR_VERSION} \
        -name '*.patch' \
        -type f \
        -print0 \
      | sort -z \
      | xargs -r0 git am --directory=subprojects/gst-plugins-good --reject --whitespace=fix \
    && find /src/patches/gstreamer1.0-plugins-bad_1.${GSTREAMER_MINOR_VERSION} \
        -name '*.patch' \
        -type f \
        -print0 \
      | sort -z \
      | xargs -r0 git am --directory=subprojects/gst-plugins-bad --reject --whitespace=fix \
    ;

RUN meson setup build
RUN cd build && DESTDIR=/out/gstreamer ninja install

FROM scratch AS gstreamer

COPY --link --from=build-gstreamer /out/gstreamer /

FROM build-gstreamer AS build-rockchip-gstreamer

# TODO(milas): this is lazy, should just point the build at the headers in /src/gstreamer directly
RUN cd /src/gstreamer/build \
    && ninja install \
    && ldconfig \
    ;

COPY --link --from=git-rockchip-gstreamer / /src/rockchip-gstreamer

RUN cd /src/rockchip-gstreamer \
    && meson setup build \
    && cd build \
    && DESTDIR=/out/rockchip-gstreamer ninja install \
    ;

# --------------------------------------------------------------------------- #

FROM scratch AS rockchip-gstreamer-plugin

COPY --link --from=build-rockchip-gstreamer /out/rockchip-gstreamer/ /

# --------------------------------------------------------------------------- #

FROM ${OS_BASE} AS os-gstreamer

ENV GST_PLUGIN_PATH=/usr/local/lib/gstreamer-1.0

# we don't need non-free-firmware
# https://www.debian.org/releases/bookworm/arm64/release-notes/ch-information.html#non-free-split
RUN sed -i 's/Components: main/Components: main contrib non-free/' /etc/apt/sources.list.d/debian.sources \
    && echo 'APT::Get::Update::SourceListWarnings::NonFreeFirmware "false";' > /etc/apt/apt.conf.d/no-bookworm-firmware.conf \
    ;

FROM os-gstreamer AS os

RUN --mount=type=cache,sharing=locked,id=apt-os,target=/var/lib/apt \
    --mount=type=cache,sharing=locked,id=apt-os,target=/var/cache/apt \
    apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        libatk1.0-0 \
        libatk-bridge2.0-0 \
        libatk-adaptor \
        libatspi2.0-0 \
        libunwind8 \
        libdw1 \
        libgmp10 \
        libgsl27 \
        libglib2.0-0 \
        libcap2 \
        libcups2 \
        liborc-0.4-0 \
        iso-codes \
        libgl1 \
        libgles1 \
        libgles2 \
        libgudev-1.0-0 \
        libgbm1 \
        libgraphene-1.0-dev \
        libpng16-16 \
        libjpeg62-turbo \
        libogg0 \
        libopus0 \
        libpango-1.0-0 \
        libvisual-0.4-0 \
        libtheora0 \
        libvorbis0a \
        libxkbcommon0 \
        libxcomposite1 \
        libxdamage1 \
        libwayland-client0 \
        libwayland-cursor0 \
        libwayland-egl1 \
        libwayland-server0 \
        libharfbuzz-icu0 \
        libegl1 \
        libepoxy0 \
        libgcrypt20 \
        libwebp7 \
        libwebpdemux2 \
        libwebpmux3 \
        libopenjp2-7 \
        libwoff1 \
        libxslt1.1 \
        bubblewrap \
        libseccomp2 \
        xdg-dbus-proxy \
        libsoup2.4-1 \
        libvulkan1 \
        libass9 \
        libchromaprint1 \
        libcurl3-gnutls \
        libaom3 \
        libbz2-1.0 \
        liblcms2-2 \
        libbs2b0 \
        libdca0 \
        libfaac0 \
        libfaad2 \
        libflite1 \
        libssl3 \
        ladspa-sdk \
        libfdk-aac2 \
        libgsm1 \
        libkate1 \
        libgme0 \
        libde265-0 \
        liblilv-0-0 \
        libmodplug1 \
        mjpegtools \
        libmjpegutils-2.1-0 \
        libmpcdec6 \
        libdvdnav4 \
        libdvdread8 \
        librsvg2-2 \
        librtmp1 \
        libsbc1 \
        libsndfile1 \
        libsoundtouch1 \
        libspandsp2 \
        libsrt1.5-openssl \
        libsrtp2-1 \
        libvo-aacenc0 \
        libvo-amrwbenc0 \
        libwebrtc-audio-processing1 \
        libofa0 \
        libzvbi0 \
        libopenexr-3-1-30 \
        libwildmidi2 \
        libx265-199 \
        libzbar0 \
        wayland-protocols \
        libaa1 \
        libmp3lame0 \
        libcaca0 \
        libdv4 \
        libmpg123-0 \
        libvpx7 \
        libshout3 \
        libspeex1 \
        libtag1v5 \
        libtwolame0 \
        libwavpack1 \
        liba52-0.7.4 \
        libx264-164 \
        libopencore-amrnb0 \
        libopencore-amrwb0 \
        libmpeg2-4 \
        libavcodec59 \
        libavfilter8 \
        libavformat59 \
        libavutil57 \
        libva2 \
        libva-wayland2 \
        xvfb \
        libxrandr-dev \
    && rm -rf /var/lib/apt/lists/* \
    ;

COPY --link --from=rockchip-mpp / /
COPY --link --from=rockchip-rga / /

COPY --link --from=gstreamer / /
COPY --link --from=rockchip-gstreamer-plugin / /

RUN ldconfig

# --------------------------------------------------------------------------- #

FROM os AS os-debug

ENV mpi_debug=1
ENV mpp_debug=1
ENV h264d_debug=1
ENV mpp_syslog_perror=1

ADD https://dl.radxa.com/media/video/1080p.264 /media/1080p.264

CMD mpi_dec_test -i /media/1080p.264 -t 7 -h 1080 -w 1920
