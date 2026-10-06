#!/bin/bash
# Configures and builds the FFmpeg libraries with only the components AffdataNet needs:
# demuxing/decoding of common audio uploads, the audio filters it uses, and Opus in Ogg output.

set -euo pipefail

CONF_FLAGS=(
  --target-os=none              # disable target specific configs
  --arch=x86_32                 # use x86_32 arch
  --enable-cross-compile        # use cross compile configs
  --disable-asm                 # disable asm
  --disable-stripping           # disable stripping as it won't work
  --disable-programs            # disable ffmpeg, ffprobe and ffplay build
  --disable-doc                 # disable doc build
  --disable-debug               # disable debug mode
  --disable-runtime-cpudetect   # disable cpu detection
  --disable-autodetect          # disable env auto detect
  --disable-pthreads --disable-w32threads --disable-os2threads
  --disable-network
  --disable-postproc            # GPL only, and video only

  # assign toolchains and extra flags
  --nm=emnm
  --ar=emar
  --ranlib=emranlib
  --cc=emcc
  --cxx=em++
  --objcc=emcc
  --dep-cc=emcc
  --extra-cflags="$CFLAGS"
  --extra-cxxflags="$CXXFLAGS"

  --disable-everything
  --enable-protocol=file

  # Inputs: .mp3 .ogg/.oga/.opus .wav .flac .m4a .aac
  --enable-demuxer=mp3,ogg,wav,w64,flac,mov,aac
  --enable-parser=mpegaudio,vorbis,opus,flac,aac
  --enable-decoder=mp3,mp3float,mp2,mp2float,vorbis,opus,flac,aac,aac_fixed,alac
  --enable-decoder=pcm_u8,pcm_s16le,pcm_s16be,pcm_s24le,pcm_s24be,pcm_s32le,pcm_f32le,pcm_f64le,pcm_alaw,pcm_mulaw
  --enable-decoder=adpcm_ms,adpcm_ima_wav

  # Output: Opus in Ogg (.opus)
  --enable-libopus
  --enable-encoder=libopus
  --enable-muxer=ogg,opus

  # Filters used by AffdataNet, plus those the ffmpeg tool inserts itself
  --enable-filter=aresample,apad,silenceremove,atrim,asetpts,afade
  --enable-filter=aformat,anull,abuffer,abuffersink,null,format,buffer,buffersink
)

emconfigure ./configure "${CONF_FLAGS[@]}" "$@"
emmake make -j
