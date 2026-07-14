# 00_TEMPLATE_MASTER

## Purpose

Golden Master XML templates for each encoding tier. **Do not load these directly in ShanaEncoder** — they are reference sources for the XML generation script and for global parameter changes.

## When to use this folder

- **Before changing a global parameter** (e.g., `-qmax`, `-shanakeyframe`, `shanapad` flag): edit the relevant master template here first, then propagate via the generation script. Do not hunt through 302+ files.
- **When writing the generation script** for new TransTo or SameAudio variants: use these as the encoding-block source of truth.
- **As a diff target** when auditing whether live presets have drifted from the master.

## Files

| File | Tier | Encoder | Key param |
|------|------|---------|-----------|
| `cpu_fast_crf21.xml` | x265-fast/Codex | libx265 | `-preset fast -crf 21.0 -qmin 17 -qmax 36` |
| `cpu_medium_crf21.xml` | x265-medium | libx265 | `-preset medium -crf 21.0 -qmin 17 -qmax 36` |
| `nvenc_cq23.xml` | NVENC H265 | hevc_nvenc | `-preset hq -tune:v hq -cq 23 -qmin 18 -qmax 35` |
| `qsv_cq23.xml` | QSV H265 | hevc_qsv | `-global_quality:v 23 -qmin 15 -qmax 35 -preset veryfast` |
| `filter_scale720p.xml` | Filter only | N/A | `scale=1280:720:flags=bicubic` + `scale_qsv` alternative |
| `filter_scale1080p.xml` | Filter only | N/A | `scale=1920:1080:flags=bicubic` + `scale_qsv` alternative |

## Adding a new master

When a new encoding tier is introduced (e.g., AV1), add its master template here **before** generating any presets for that tier. Follow the existing naming convention: `{encoder}_{quality_anchor}.xml`.

## BigVoice note

BigVoice presets use `-b:a 256k` (not the standard 192k). There is no separate BigVoice master template — derive it from the base master by changing the audio bitrate line.
