# ShanaEncoder Presets Repository

## Overview

This repository contains XML preset configurations for **ShanaEncoder**, a video encoding tool. Each folder groups related encoding presets by quality level, codec, and use case.

## Repository Structure

### Core Preset Categories

#### CPU-based Quality Presets
- **`0cpuQualityGpt5.3CodexMedium`** - Medium-preset CPU x265 encoding with GPT 5.3 Codex optimization
- **`0cpuQualityGpt5.3CodexMediumSameAudio`** - `CodexMedium` variant with audio stream copy
- **`0cpuQualityGpt5.3CodexSlow`** - Slow-preset CPU x265 encoding, true 10-bit (`-pix_fmt yuv420p10le`)
- **`0cpuQualityGpt5.3CodexSlowSameAudio`** - `CodexSlow` variant with audio stream copy
- **`0cpuQualitySameAudio`** - Fast-preset CPU x265 encoding with audio stream copy
- **`1cpuQuality`** - Standard/baseline quality CPU-based encoding presets (`-preset veryfast`)
- **`1cpuQualityGpt5.3Codex`** - CPU quality presets with GPT 5.3 Codex optimization
- **`1cpuQualityGpt5.3CodexFast`** - Fast CPU-based x265 encoding with GPT 5.3 Codex optimization
- **`1cpuQualityGpt5.3CodexFastSameAudio`** - `CodexFast` variant with audio stream copy
- **`1cpuQualityGpt5.3CodexFastScene`** - Scene-focused fast CPU x265 encoding, hand-tuned A/B variants

As of 2026-09-21, all folders above (libx265 CPU presets) share one unified quantization policy: true 10-bit, `-qmin 12` with no `-qmax`, `aq-mode=3:aq-strength=0.8`, no forced keyframe interval. See the Per-Folder Encoding Parameters table below and `design_documents/2026-09-20-codexSlow-quality-tuning.md` for details.

#### Lossless/Passthrough Presets
- **`0压 视频复制流`** - Video stream copy (no re-encoding)
- **`0压 音频复制流`** - Audio stream copy (no re-encoding)

#### H.264 Compression Presets
- **`2压 H264 8bit NVENC`** - H.264 8-bit compression using NVIDIA NVENC GPU acceleration
- **`2压 H264 8bit x264`** - H.264 8-bit compression using x264 CPU encoder

#### H.265/HEVC Compression Presets
- **`2压 H265 10bit NVENC`** - H.265 10-bit compression using NVIDIA NVENC
- **`2压 H265 10bit NVENCfor720pXiaoMiTv`** - H.265 10-bit NVENC optimized for 720p playback on Xiaomi TVs
- **`2压 H265 10bit QSV`** - H.265 10-bit compression using Intel Quick Sync Video
- **`2压 H265 10bit x265`** - H.265 10-bit compression using x265 CPU encoder
- **`2压 快速H265 8bit x265`** - Fast H.265 8-bit compression using x265
- **`2压 高码H265 10bit x265`** - High bitrate H.265 10-bit compression using x265

#### Advanced H.265 Presets
- **`3压 H265 10bit x265`** - Advanced H.265 10-bit x265 presets
- **`3压 快速H265 8bit x265`** - Advanced fast H.265 8-bit x265 presets

#### Audio Presets
- **`2压 音频预设`** - Audio-only compression presets

#### Quality Transformation Presets
- **`qualityCpuTransTo1080p`** - CPU-based transcoding to 1080p resolution
- **`qualityCpuTransTo1080pSameAudio`** - CPU transcoding to 1080p with audio stream copy
- **`qualityCpuTransTo720p`** - CPU-based transcoding to 720p resolution
- **`qualityCpuTransTo720pSameAudio`** - CPU transcoding to 720p with audio stream copy
- **`qualityTransTo1080p`** - Standard transcoding to 1080p resolution
- **`qualityTransTo720p`** - Standard transcoding to 720p resolution

#### GPU-accelerated Presets
- **`nvQuality`** - NVIDIA GPU-accelerated quality presets

#### Special Purpose Presets
- **`qualitySameAudio`** - Quality presets with audio stream copy
- **`qualitySameAudioTransTo1080p`** - Quality + audio copy + 1080p transcoding
- **`qualityQsv`** - Intel Quick Sync Video (QSV) quality presets

#### Legacy/Reference Presets
- **`舟 5.X原预设`** - Original presets from ShanaEncoder 5.X version
- **`舟 6.0原预设`** - Original presets from ShanaEncoder 6.0 version
- **`舟 滤镜参考`** - Filter reference and documentation presets

#### Skills/Tools
- **`skills`** - Utility scripts and tools for the preset system

## Per-Folder Encoding Parameters

Codec / bit depth / quality / preset speed / audio / notes for every preset folder (merged from former per-folder CLAUDE.md files, now removed to reduce context overhead).

**2026-09-21 update**: all `0`/`1`-prefixed pure-ASCII libx265 CPU folders below (plus `00_TEMPLATE_MASTER`'s two libx265 masters) now share one unified quantization policy: true 10-bit (`-pix_fmt yuv420p10le`), `-qmin 12` with no `-qmax`, `-x265-params aq-mode=3:aq-strength=0.8` (x265's dark-scene banding-prevention AQ mode), and no forced `-shanakeyframe` (x265 default GOP ≤250 frames + scenecut). Full rationale, x265 doc citations, and A/B test data: `design_documents/2026-09-20-codexSlow-quality-tuning.md`. Per-folder rows below only note what's *distinct* to that folder (preset speed, CRF range, audio).

| Folder | Codec | Bit | Quality | Preset | Audio | Notes |
|---|---|---|---|---|---|---|
| `00_TEMPLATE_MASTER` | (n/a) | — | — | — | — | Golden-master XML templates, NOT loaded directly in ShanaEncoder. Edit these first for global param changes, then propagate via generation script. Masters: `cpu_fast_crf21.xml` / `cpu_medium_crf21.xml` (libx265 fast/medium, CRF21, follow the unified quantization policy above as of 2026-09-21), `nvenc_cq23.xml` (hevc_nvenc hq, CQ23, qmin18/qmax35 — NVENC, not subject to the x265 AQ policy), `qsv_cq23.xml` (hevc_qsv veryfast, global_quality 23, qmin15/qmax35 — QSV, not subject to the x265 AQ policy), `filter_scale720p.xml`/`filter_scale1080p.xml` (scale filters + scale_qsv alt). BigVoice = `-b:a 256k`, derived from base master (no separate master file). |
| `0cpuQualityGpt5.3CodexMedium` | libx265 | **true 10-bit** | CRF 20.0–32.0 (per-file, `NNqualityCpuMedium.xml`) | medium | libfdk_aac 192k | faststart; unified quantization policy (see above). |
| `0cpuQualityGpt5.3CodexMediumSameAudio` | libx265 | **true 10-bit** | CRF 20.0–32.0 (per-file) | medium | copy | faststart; unified quantization policy (see above). |
| `0cpuQualityGpt5.3CodexSlow` | libx265 | **true 10-bit** (`-pix_fmt yuv420p10le`) | CRF 20.0–32.0 (per-file, `NNqualityCpuSlow.xml`) | slow | libfdk_aac 192k | faststart; unified quantization policy (see above) — `-qmin 12`, no qmax, `aq-mode=3:aq-strength=0.8` as of 2026-09-21 (round 1 had gone qmin/qmax-free entirely; round 2 added the AQ-based approach after real A/B testing showed the fully-free version cost +17% size). See `design_documents/2026-09-20-codexSlow-quality-tuning.md`. BigVoice variant = `-b:a 256k`. |
| `0cpuQualityGpt5.3CodexSlowSameAudio` | libx265 | **true 10-bit** (`-pix_fmt yuv420p10le`) | CRF 20.0–32.0 (per-file, `NNqualityCpuSlowSameAudio.xml`) | slow | copy | faststart; same as `CodexSlow`. No BigVoice variant here (same incompatibility with `-c:a copy` as other SameAudio folders). |
| `0cpuQualitySameAudio` | libx265 | **true 10-bit** | CRF 20.0–32.0 (per-file) | fast | copy | faststart; unified quantization policy (see above). |
| `0压 视频复制流` | copy (video) | — | lossless | — | copy | Container remux only, FLV output |
| `0压 音频复制流` | copy (audio) | — | lossless | — | copy | Audio-only extraction, M4A output |
| `1cpuQuality` | libx265 | **true 10-bit** | CRF 20.0–32.0 (per-file) | veryfast | libfdk_aac 192k | faststart; unified quantization policy (see above). Note: `veryfast` is inherently a simpler/faster algorithm than `medium`/`slow`, so its overall compression ratio stays naturally lower than those tiers even with the same AQ tuning — don't compare its absolute output size against `CodexSlow`, only against its own pre-2026-09-21 output. |
| `1cpuQualityGpt5.3Codex` | libx265 | **true 10-bit** | CRF 20.0–32.0 (per-file) | fast | libfdk_aac 192k | faststart; unified quantization policy (see above). Previously had no qmin/qmax at all; now uses the shared `qmin 12`/no-qmax/aq-mode3 scheme. |
| `1cpuQualityGpt5.3CodexFast` | libx265 | **true 10-bit** | CRF 20.0–32.0 (per-file) | fast | libfdk_aac 192k | faststart; subtitle support; unified quantization policy (see above). |
| `1cpuQualityGpt5.3CodexFastSameAudio` | libx265 | **true 10-bit** | CRF 20–32 (per-file, `NNqualityCpuFastSameAudio.xml`) | fast | copy | faststart; unified quantization policy (see above). No BigVoice variant here (BigVoice=`-b:a 256k` re-encode is incompatible with `-c:a copy`); use `1cpuQualityGpt5.3CodexFast/21qualityCpuBigVoiceFast.xml` instead. CRF guide: 20-22 near-lossless/archival, 23-25 high quality storage, 26-28 default balance, 29-32 small/low-storage. |
| `1cpuQualityGpt5.3CodexFastScene` | libx265 | **true 10-bit** | CRF 23.0–26.0 (5 hand-tuned A/B variants) | fast | libfdk_aac 192k (one variant uses copy) | faststart; scene-detection/detail-guard filenames kept, but as of 2026-09-21 all 5 variants' qmin/qmax were converged onto the unified quantization policy above (previously each variant intentionally used a different qmin/qmax spread — that differentiation was dropped in favor of repo-wide consistency; CRF and filenames still differ per variant). |
| `2压 H264 8bit NVENC` | h264_nvenc | 8-bit | CQ 23 | hq | copy | faststart; unsharp+deblock filters; requires NVENC GPU (GTX 950+/RTX) |
| `2压 H264 8bit x264` | libx264 | 8-bit | CRF 19.0 | veryfast | copy | faststart; SSIM-tuned; unsharp+deblock filters |
| `2压 H265 10bit NVENC` | hevc_nvenc | 10-bit | CQ 23 | hq | copy | faststart; profile main10; requires HEVC NVENC GPU (GTX 950+/RTX) |
| `2压 H265 10bit NVENCfor720pXiaoMiTv` | hevc_nvenc | 10-bit | CQ 23 | hq | libmp3lame 128k, 2ch | faststart; scaled to 1280x720 w/ bicubic scale+pad for Xiaomi TV compatibility |
| `2压 H265 10bit QSV` | hevc_qsv | 10-bit | VBR 1064k target / 2240k max | veryfast | copy | faststart; profile main; requires Intel QSV (6th-gen Core+) |
| `2压 H265 10bit x265` | libx265 | 10-bit | CRF 10.0 (very high quality) | veryfast | copy | faststart; SSIM-tuned; unsharp+deblock filters |
| `2压 快速H265 8bit x265` | libx265 | 8-bit | CRF 19.0 | veryfast | copy | faststart; PSNR-tuned; deblock filter |
| `2压 音频预设` | AC3 + other audio codecs | — | — | — | — | Audio-only, format/codec conversion |
| `2压 高码H265 10bit x265` | libx265 | 10-bit | CQP 15 | medium | copy | faststart; bitrate 1064k target/2240k max/4480k buffer; unsharp filter |
| `3压 H265 10bit x265` | libx265 | 10-bit | VBR 1064k target/2240k max | veryfast | copy | faststart; unsharp filter |
| `3压 快速H265 8bit x265` | libx265 | 8-bit | VBR 500k target/1000k max/2000k buffer | veryfast | copy | faststart; PSNR-tuned; deblock filter |
| `nvQuality` | hevc_nvenc | 10-bit | CQ 23 | hq | libfdk_aac 192k | profile main10 |
| `qualityCpuTransTo1080p` | libx265 | 10-bit | CRF 21.0 | veryfast | libfdk_aac 192k | scale to 1920x1080 bicubic + auto pad |
| `qualityCpuTransTo1080pSameAudio` | libx265 | 10-bit | CRF 21.0 | veryfast | copy | scale to 1920x1080 bicubic + auto pad |
| `qualityCpuTransTo720p` | libx265 | 10-bit | CRF 21.0 | veryfast | libfdk_aac 192k | scale to 1280x720 bicubic + auto pad |
| `qualityCpuTransTo720pSameAudio` | libx265 | 10-bit | CRF 21.0 | veryfast | copy | scale to 1280x720 bicubic + auto pad |
| `qualityQsv` | hevc_qsv | 10-bit | quality 23 | veryfast | libfdk_aac 192k | profile main; requires Intel QSV (6th-gen Core+) |
| `qualitySameAudio` | hevc_nvenc | 10-bit | CQ 23 | hq | copy | profile main10 (NVENC despite generic folder name) |
| `qualitySameAudioTransTo1080p` | hevc_nvenc | 10-bit | CQ 23 | hq | copy | profile main10; scale/pad to 1920x1080 |
| `qualityTransTo1080p` | hevc_nvenc | 10-bit | CQ 23 | hq | libfdk_aac 192k | profile main10; scale to 1920x1080 bicubic + pad |
| `qualityTransTo720p` | hevc_nvenc | 10-bit | CQ 23 | hq | libfdk_aac 192k | profile main10; scale to 1280x720 |
| `skills` | — | — | — | — | — | Reserved/empty; placeholder for future automation scripts |
| `舟 5.X原预设` | — | — | — | — | — | Legacy ShanaEncoder 5.X presets, reference-only |
| `舟 6.0原预设` | — | — | — | — | — | Legacy ShanaEncoder 6.0 initial-release presets, reference-only |
| `舟 滤镜参考` | libx265 | 10-bit | CRF 21.0 | veryfast | copy | faststart; profile main, level 5.1; HDR: BT.2020 color space + SMPTE 2084 (PQ) transfer + master-display/MaxCLL/MaxFALL metadata (Dolby Vision-compatible); unsharp 0.02 + deblock filters; subtitle support |

## File Format

Each preset is stored as an XML file with the following structure:

```xml
<?xml version="1.0" encoding="utf-8"?>
<Settings>
  <extensiontextBox>Output file extension</extensiontextBox>
  <filterparamBoxV>Video filters (FFmpeg format)</filterparamBoxV>
  <filterparamBoxA>Audio filters (FFmpeg format)</filterparamBoxA>
  <encparamBox>Encoding parameters (FFmpeg format)</encparamBox>
  <Logo>Logo overlay configuration</Logo>
</Settings>
```

## Key Encoding Encoders

- **x264** - H.264 software encoder (CPU-based)
- **x265** - H.265/HEVC software encoder (CPU-based)
- **NVENC** - NVIDIA GPU-accelerated encoder
- **QSV** - Intel Quick Sync Video (GPU-accelerated on Intel)
- **libfdk_aac** - AAC audio codec

## Quality Levels

Presets are organized by quality and compression ratio:
- **0压** (0 compression) - Lossless, copy streams without re-encoding
- **1压** (1 compression) - High quality, preserves details
- **2压** (2 compression) - Standard quality, good balance
- **3压** (3 compression) - Lower quality, higher compression

## Naming Conventions

- Files ending in `Same_Audio` preserve original audio (copy stream instead of re-encoding)
- Files ending in `TransTo720p/1080p` resample to specific resolutions
- NVENC variants use NVIDIA GPU acceleration
- QSV variants use Intel GPU acceleration
- x265/x264 variants use CPU-based software encoding

## Usage

Load these presets in ShanaEncoder to apply predefined encoding configurations for batch video processing with consistent quality and performance characteristics.

## Recent Updates

- Scene-focused presets for optimized x265 encoding
- Xiaomi TV compatibility optimization for 720p playback
- GPT 5.3 Codex optimization variants
- Quality/performance tuning across multiple encoder backends
