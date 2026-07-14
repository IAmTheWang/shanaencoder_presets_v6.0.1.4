# Preset Coverage Matrix

Shows which encoder tier × variant combinations exist. Update this file whenever a new folder is added or removed.

**Legend**: ✅ EXISTS · ⚠️ PARTIAL (≤3 files) · ❌ MISSING

---

## H.265 / HEVC Presets

| Variant | x265-fast (Codex) | x265-medium (Codex) | x265-veryfast (1cpu/quality) | NVENC H265 | QSV H265 | Hardware Req |
|---------|:-----------------:|:-------------------:|:----------------------------:|:----------:|:--------:|-------------|
| **base** | ✅ `0cpuQualityGpt5.3CodexFast` (13) | ✅ `0cpuQualityGpt5.3CodexMedium` (14) | ✅ `1cpuQuality` (14) + `1cpuQualityGpt5.3Codex` (14) | ✅ `nvQuality` (13) | ✅ `qualityQsv` (11) | CPU / NVENC / Intel QSV |
| **SameAudio** | ✅ `0cpuQualityGpt5.3CodexFastSameAudio` (13) | ✅ `0cpuQualityGpt5.3CodexMediumSameAudio` (14) | ✅ `0cpuQualitySameAudio` (13) + `qualitySameAudio` (11) | ❌ MISSING | ❌ MISSING | CPU / NVENC / Intel QSV |
| **TransTo720p** | ❌ MISSING | ❌ MISSING | ✅ `qualityCpuTransTo720p` (12) + `qualityTransTo720p` (11) | ❌ MISSING | ❌ MISSING | CPU / NVENC / Intel QSV |
| **TransTo1080p** | ❌ MISSING | ❌ MISSING | ✅ `qualityCpuTransTo1080p` (12) + `qualityTransTo1080p` (11) | ❌ MISSING | ❌ MISSING | CPU / NVENC / Intel QSV |
| **TransTo720p + SameAudio** | ❌ MISSING | ❌ MISSING | ✅ `qualityCpuTransTo720pSameAudio` (12) | ❌ MISSING | ❌ MISSING | CPU / NVENC / Intel QSV |
| **TransTo1080p + SameAudio** | ❌ MISSING | ❌ MISSING | ✅ `qualityCpuTransTo1080pSameAudio` (12) + `qualitySameAudioTransTo1080p` (11) | ❌ MISSING | ❌ MISSING | CPU / NVENC / Intel QSV |
| **Scene** | ✅ `0cpuQualityGpt5.3CodexFastScene` (5) | ❌ MISSING | ❌ MISSING | ❌ MISSING | ❌ MISSING | CPU |
| **BigVoice** | ⚠️ 1 file at CRF21 only | ⚠️ 1 file at CRF21 only | ⚠️ 1 file at CRF21 in each of `1cpuQuality`, `1cpuQualityGpt5.3Codex` | ❌ MISSING | ❌ MISSING | CPU / NVENC |

---

## H.264 Presets

| Variant | x264 (CPU) | NVENC H264 | Hardware Req |
|---------|:----------:|:----------:|-------------|
| **base** | ✅ `2压 H264 8bit x264` | ✅ `2压 H264 8bit NVENC` | CPU / NVENC |
| **SameAudio** | ❌ MISSING | ❌ MISSING | CPU / NVENC |

---

## AV1 Presets

| Variant | AV1-NVENC | AV1-CPU (SVT-AV1) | Hardware Req |
|---------|:---------:|:-----------------:|-------------|
| **base** | ❌ MISSING | ❌ MISSING | NVENC RTX 40xx / CPU + libsvtav1 |
| **SameAudio** | ❌ MISSING | ❌ MISSING | NVENC RTX 40xx / CPU + libsvtav1 |

> **AV1 pre-check**: Before creating AV1 presets, verify: `ffmpeg -encoders | grep av1_nvenc` and `ffmpeg -encoders | grep svtav1`

---

## Lossless / Passthrough

| Variant | Video copy | Audio copy |
|---------|:----------:|:----------:|
| **base** | ✅ `0压 视频复制流` (7) | ✅ `0压 音频复制流` |

---

## High-Compression Presets (2压 / 3压)

| Variant | H265 10bit x265 | H265 8bit x265 (fast) | H265 10bit NVENC | H265 10bit QSV |
|---------|:---------------:|:---------------------:|:----------------:|:--------------:|
| **2压 base** | ✅ `2压 H265 10bit x265` (12) | ✅ `2压 快速H265 8bit x265` | ✅ `2压 H265 10bit NVENC` (8) | ⚠️ `2压 H265 10bit QSV` (2) |
| **3压 base** | ✅ `3压 H265 10bit x265` (6) | ✅ `3压 快速H265 8bit x265` (6) | ❌ MISSING | ❌ MISSING |

---

## Audio-Only Presets

| Codec | Status |
|-------|--------|
| Various (AAC, AC3, etc.) | ✅ `2压 音频预设` (10 files) |

---

## Maintenance Rule

**Every time a new folder is added**: update the relevant row and column in this matrix. Run `/audit-presets` to regenerate the matrix automatically from the current folder state.
