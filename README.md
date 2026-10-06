# ffmpeg-wasm-audio

AffdataNet 网站使用的精简版 [ffmpeg.wasm](https://github.com/ffmpegwasm/ffmpeg.wasm) core，
单线程，可直接替换 `@ffmpeg/core` 0.12.x，配合 `@ffmpeg/ffmpeg` 0.12.15 使用。

只保留网站转码需要的部分：

- 输入：mp3、ogg/oga、opus、wav（PCM、ADPCM）、w64、flac、m4a（AAC、ALAC）、aac
- 滤镜：aresample、apad、silenceremove、atrim、asetpts、afade
- 输出：libopus 编码，Ogg/Opus 封装

FFmpeg n5.1.4 以 LGPL 构建（不启用 GPL 组件），libopus 1.3.1，emscripten 3.1.40，
`-O3 -msimd128`，栈 5 MB（libopus 需要，同上游
[#824](https://github.com/ffmpegwasm/ffmpeg.wasm/pull/824)）。

## 构建

每次 push 到 main，GitHub Actions 构建并发布 Release（`ffmpeg-core.js`、`ffmpeg-core.wasm`
为 ESM 版本，tarball 内另含 UMD 版本），只保留最新一版。本地构建需要 Docker：

```bash
docker buildx build --build-arg EXTRA_CFLAGS="-O3 -msimd128" -o out .
```

增加支持的格式或滤镜时，修改 `build/ffmpeg.sh` 中的 `--enable-*`。

## 许可

- `src/bind`、`src/fftools` 与构建脚本来自 ffmpeg.wasm（MIT，见 `LICENSE.ffmpeg.wasm`），
  其中 `src/fftools` 是修改过的 FFmpeg 源码（LGPL 2.1 或更高版本）。
- 产物包含 FFmpeg（LGPL 2.1 或更高版本，源码为 FFmpeg `n5.1.4`）与 libopus（BSD）。
