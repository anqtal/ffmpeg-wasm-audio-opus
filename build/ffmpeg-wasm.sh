#!/bin/bash
# Links the ffmpeg tool and the ffmpeg.wasm bindings into ffmpeg-core.js/.wasm.
# `-o <OUTPUT_FILE_NAME>` must be provided, e.g. bash ffmpeg-wasm.sh -lopus -o ffmpeg-core.js
# Same as upstream's single-thread build, without libpostproc (not built) and SDL (unused).

set -euo pipefail

EXPORT_NAME="createFFmpegCore"

CONF_FLAGS=(
  -I.
  -I./src/fftools
  -I$INSTALL_DIR/include
  -L$INSTALL_DIR/lib
  -Llibavcodec
  -Llibavdevice
  -Llibavfilter
  -Llibavformat
  -Llibavutil
  -Llibswresample
  -Llibswscale
  -lavcodec
  -lavdevice
  -lavfilter
  -lavformat
  -lavutil
  -lswresample
  -lswscale
  -Wno-deprecated-declarations
  $LDFLAGS
  -sENVIRONMENT=worker
  -sWASM_BIGINT                            # enable big int support
  -sSTACK_SIZE=5MB                         # libopus needs more than the default stack
  -sMODULARIZE                             # modularized to use as a library
  -sINITIAL_MEMORY=32MB -sALLOW_MEMORY_GROWTH # just enough memory, growing as needed
  -sEXPORT_NAME="$EXPORT_NAME"             # required in browser env, so that user can access this module from window object
  -sEXPORTED_FUNCTIONS=$(node src/bind/ffmpeg/export.js) # exported functions
  -sEXPORTED_RUNTIME_METHODS=$(node src/bind/ffmpeg/export-runtime.js) # exported built-in functions
  -lworkerfs.js
  --pre-js src/bind/ffmpeg/bind.js        # extra bindings, contains most of the ffmpeg.wasm javascript code
  # ffmpeg source code
  src/fftools/cmdutils.c
  src/fftools/ffmpeg.c
  src/fftools/ffmpeg_filter.c
  src/fftools/ffmpeg_hw.c
  src/fftools/ffmpeg_mux.c
  src/fftools/ffmpeg_opt.c
  src/fftools/opt_common.c
  src/fftools/ffprobe.c
)

emcc "${CONF_FLAGS[@]}" "$@"
