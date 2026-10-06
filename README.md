# ffmpeg-wasm-audio-opus

AffdataNet 网站使用的精简版 [ffmpeg.wasm](https://github.com/ffmpegwasm/ffmpeg.wasm) core：**只把常见音频转码为 Opus**，不是通用的 ffmpeg.wasm。A trimmed [ffmpeg.wasm](https://github.com/ffmpegwasm/ffmpeg.wasm) core used by the AffdataNet website: it **only transcodes common audio formats to Opus** and is not a general-purpose ffmpeg.wasm.

单线程，可直接替换 `@ffmpeg/core` 0.12.x，配合 `@ffmpeg/ffmpeg` 0.12.15 使用。It is single-threaded and a drop-in replacement for `@ffmpeg/core` 0.12.x, used with `@ffmpeg/ffmpeg` 0.12.15.

## 支持的功能 Features

- 输入（解码）Input (decoding)：mp3、ogg/oga（Vorbis、FLAC、Opus）、opus、wav（PCM、ADPCM）、w64、flac、m4a（AAC、ALAC）、aac
- 滤镜 Filters：aresample、apad、silenceremove、atrim、asetpts、afade
- 输出（编码）Output (encoding)：仅 libopus，Ogg/Opus 封装 libopus only, in an Ogg/Opus container

FFmpeg n5.1.4 以 LGPL 构建（不启用 GPL 组件），libopus 1.3.1，emscripten 3.1.40，`-O3 -msimd128`，栈 5 MB（libopus 需要，同上游 [#824](https://github.com/ffmpegwasm/ffmpeg.wasm/pull/824)）。FFmpeg n5.1.4 is built under the LGPL (no GPL components), with libopus 1.3.1, emscripten 3.1.40, `-O3 -msimd128` and a 5 MB stack (required by libopus, as in upstream [#824](https://github.com/ffmpegwasm/ffmpeg.wasm/pull/824)).

wasm 约 2.2 MB（brotli 后约 0.8 MB），官方完整版约 32 MB。The wasm is about 2.2 MB (about 0.8 MB with brotli), compared with about 32 MB for the full official core.

## 构建 Building

每次 push 到 main，GitHub Actions 构建并发布 Release，历史版本都保留，使用方按标签和 SHA-256 固定版本；`ffmpeg-core.js`、`ffmpeg-core.wasm` 为 ESM 版本，tarball 内另含 UMD 版本。Every push to main is built by GitHub Actions and published as a release; past releases are kept so consumers can pin one by tag and SHA-256. `ffmpeg-core.js` and `ffmpeg-core.wasm` are the ESM build, and the tarball also contains the UMD build.

本地构建需要 Docker。Building locally requires Docker:

```bash
docker buildx build --build-arg EXTRA_CFLAGS="-O3 -msimd128" -o out .
```

增加支持的格式或滤镜时，修改 `build/ffmpeg.sh` 中的 `--enable-*`。To support more formats or filters, change the `--enable-*` options in `build/ffmpeg.sh`.

## 许可 License

本仓库以 LGPL 2.1 或更高版本发布（见 `LICENSE`）。This repository is released under the LGPL 2.1 or later (see `LICENSE`).

- `src/bind`、`src/fftools` 与构建脚本来自 ffmpeg.wasm（MIT，见 `LICENSE.ffmpeg.wasm`），其中 `src/fftools` 是修改过的 FFmpeg 源码（LGPL 2.1 或更高版本）。`src/bind`, `src/fftools` and the build scripts come from ffmpeg.wasm (MIT, see `LICENSE.ffmpeg.wasm`); `src/fftools` is modified FFmpeg source (LGPL 2.1 or later).
- 产物包含 FFmpeg（LGPL 2.1 或更高版本，源码为 FFmpeg `n5.1.4`）与 libopus（BSD，见 `LICENSE.opus`）。The build output contains FFmpeg (LGPL 2.1 or later, source at FFmpeg `n5.1.4`) and libopus (BSD, see `LICENSE.opus`).
