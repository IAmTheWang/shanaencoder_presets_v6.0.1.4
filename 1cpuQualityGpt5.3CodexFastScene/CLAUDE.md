# Fast CPU Scene-Focused Presets with GPT 5.3 Codex

## Overview

This folder contains fast CPU-based H.265 encoding presets with scene detection and detail preservation. Optimized with GPT 5.3 Codex tuning for scene-aware encoding that adapts quality to content complexity.

## Use Cases

- Video processing with varying scene complexity
- Content with both static and dynamic scenes
- Archival of footage with mixed content types
- Adaptive quality encoding based on scene characteristics

## Encoding Characteristics

- **Codec**: H.265/HEVC (libx265)
- **Bit Depth**: 10-bit
- **Quality Level**: CRF 23.0
- **Preset Speed**: fast
- **Audio Codec**: libfdk_aac at 192k
- **Container Format**: MP4 with faststart optimization

## Special Features

- **Scene Detection**: Analyzes scenes and applies guardrails to preserve details
- **Detail Preservation**: Prevents over-compression artifacts in complex scenes
- **Adaptive Quality**: Adjusts encoding parameters based on scene complexity
- **GPT 5.3 Codex Tuning**: Intelligent parameter optimization for scene-aware encoding

## Recommended For

- Documentary and interview footage with static backgrounds
- Content with mixed static and dynamic scenes
- Encoding scenarios where detail preservation is important for specific scenes
- Archival with varying content complexity

## Notes

- CRF 23.0 with scene-aware guardrails provides good quality for variable content
- Detail guard parameters prevent quality loss in complex scenes while maintaining bitrate efficiency
- Audio is re-encoded to AAC at 192k for consistent audio quality
