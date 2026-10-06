# syntax=docker/dockerfile-upstream:master-labs

# Audio-only ffmpeg.wasm core: decodes common audio formats and encodes Opus only.
# Based on https://github.com/ffmpegwasm/ffmpeg.wasm (MIT); only libopus is linked, and
# FFmpeg is built under the LGPL without GPL components.

FROM emscripten/emsdk:3.1.40 AS emsdk-base
ARG EXTRA_CFLAGS
ARG EXTRA_LDFLAGS
ENV INSTALL_DIR=/opt
# The single-thread ffmpeg tool of ffmpeg.wasm targets FFmpeg 5.1.
ENV FFMPEG_VERSION=n5.1.4
ENV CFLAGS="-I$INSTALL_DIR/include $CFLAGS $EXTRA_CFLAGS"
ENV CXXFLAGS="$CFLAGS"
ENV LDFLAGS="-L$INSTALL_DIR/lib $LDFLAGS $CFLAGS $EXTRA_LDFLAGS"
ENV EM_PKG_CONFIG_PATH=$EM_PKG_CONFIG_PATH:$INSTALL_DIR/lib/pkgconfig:/emsdk/upstream/emscripten/system/lib/pkgconfig
ENV PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$EM_PKG_CONFIG_PATH
ENV FFMPEG_ST=yes
RUN apt-get update && apt-get install -y pkg-config autoconf automake libtool

FROM emsdk-base AS opus-builder
ENV OPUS_BRANCH=v1.3.1
ADD https://github.com/ffmpegwasm/opus.git#$OPUS_BRANCH /src
COPY build/opus.sh /src/build.sh
RUN bash -x /src/build.sh

FROM emsdk-base AS ffmpeg-builder
ADD https://github.com/FFmpeg/FFmpeg.git#$FFMPEG_VERSION /src
COPY --from=opus-builder $INSTALL_DIR $INSTALL_DIR
COPY build/ffmpeg.sh /src/build.sh
RUN bash -x /src/build.sh

FROM ffmpeg-builder AS ffmpeg-wasm-builder
COPY src/bind /src/src/bind
COPY src/fftools /src/src/fftools
COPY build/ffmpeg-wasm.sh build.sh
RUN mkdir -p /src/dist/umd && bash -x /src/build.sh -lopus -o dist/umd/ffmpeg-core.js
RUN mkdir -p /src/dist/esm && bash -x /src/build.sh -lopus -sEXPORT_ES6 -o dist/esm/ffmpeg-core.js

# `docker buildx build -o out .` writes out/dist.
FROM scratch AS exporter
COPY --from=ffmpeg-wasm-builder /src/dist /dist
