# Fast CPU Quality Presets with Audio Passthrough

## Overview

This folder contains fast-speed CPU-based H.265 encoding presets with GPT 5.3 Codex optimization that preserve the original audio stream without re-encoding. The symmetric counterpart of `0cpuQualityGpt5.3CodexMediumSameAudio` — use this when encoding speed matters more than maximum compression efficiency, but the source audio must not be re-encoded.

## Use Cases

- Content where audio must remain unchanged (AC3, DTS, FLAC, TrueHD source tracks)
- Fast batch processing where original audio integrity is required
- Archival with audio fidelity guarantee + fast turnaround
- Workflows downstream of an audio mixing step where re-encoding would degrade quality

## Encoding Characteristics

- **Codec**: H.265/HEVC (libx265)
- **Bit Depth**: 10-bit
- **CRF Range**: 20 (highest quality) – 32 (most compressed)
- **Preset Speed**: fast
- **Audio**: `-c:a copy` (stream passthrough — no re-encoding)
- **Container**: MP4 with faststart optimization

## File Naming

| Filename | CRF | Extension tag |
|----------|-----|---------------|
| `20qualityCpuFastSameAudio.xml` | 20 | `[se6originAudioQualityCpuFast20]` |
| `21qualityCpuFastSameAudio.xml` | 21 | `[se6originAudioQualityCpuFast21]` |
| … | … | … |
| `32qualityCpuFastSameAudio.xml` | 32 | `[se6originAudioQualityCpuFast32]` |

## Choosing CRF

- **CRF 20–22**: Near-lossless video, large files. For archival masters.
- **CRF 23–25**: High quality, typical for long-term storage.
- **CRF 26–28**: Good balance. Default for most SameAudio workflows.
- **CRF 29–32**: Smaller files, visible quality reduction. For low-storage scenarios.

## BigVoice Note

There is no BigVoice variant in this folder. BigVoice = `-b:a 256k` (re-encoded AAC for high-dynamic-range audio sources), which is incompatible with `-c:a copy`. Use `0cpuQualityGpt5.3CodexFast/21qualityCpuBigVoiceFast.xml` if you need both voice quality boost AND video encoding.

## Relationship to Other Folders

| Need | Folder |
|------|--------|
| Fast + re-encode audio | `0cpuQualityGpt5.3CodexFast` |
| Fast + copy audio | **This folder** |
| Medium + copy audio | `0cpuQualityGpt5.3CodexMediumSameAudio` |
| Any speed + copy audio | `0cpuQualitySameAudio` |
