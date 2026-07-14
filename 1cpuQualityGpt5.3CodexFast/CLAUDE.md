# Fast CPU Quality Presets with GPT 5.3 Codex

## Overview

This folder contains fast CPU-based H.265 encoding presets optimized with GPT 5.3 Codex parameter tuning. Designed for scenarios where encoding speed is prioritized while maintaining good quality.

## Use Cases

- Quick batch processing of video files
- Real-time or near-real-time encoding workflows
- Content requiring fast turnaround with acceptable quality trade-offs
- Archive/storage scenarios with moderate quality requirements

## Encoding Characteristics

- **Codec**: H.265/HEVC (libx265)
- **Bit Depth**: 10-bit
- **Quality Level**: CRF 20.0 (high quality)
- **Preset Speed**: fast
- **Audio Codec**: libfdk_aac at 192k
- **Container Format**: MP4 with faststart optimization

## Special Features

- **GPT 5.3 Codex Optimization**: Intelligent parameter tuning for optimal quality-to-speed ratio
- **Fast Encoding**: Targets quick processing without sacrificing perceptual quality
- **Subtitle Support**: Built-in subtitle handling capabilities
- **Optimized Container**: faststart enabled for improved streaming performance

## Recommended For

- Quick video conversions and re-encoding tasks
- Batch processing with time constraints
- Content where encoding speed is a priority
- Streaming-optimized distribution files

## Notes

- CRF 20.0 provides better quality than standard presets while maintaining reasonable encoding speed
- Audio is re-encoded to AAC at 192k bitrate for compatibility and quality balance
- 10-bit encoding ensures good color depth without excessive file size
