---
name: audit-presets
description: Audit all ShanaEncoder XML presets for consistency issues — missing movflags, wrong audio codec, naming convention violations, duplicate CRF values in the same folder, missing SameAudio counterparts, BigVoice bitrate violations. Also exports a coverage matrix of existing vs. missing variant combinations.
---

# audit-presets

Scans all `.xml` preset files in the repository and reports consistency issues. Optionally exports a coverage matrix.

## When to invoke
- User says "检查预设一致性", "审计预设", "哪些预设有问题", "找出不规范的预设" etc.
- User says "show coverage matrix", "生成覆盖矩阵", "哪些变体缺失" etc.
- Before a commit that touches many preset files.

## Workflow

### Step 0 — Generate Coverage Matrix

Walk all top-level folder names and classify each by encoder tier and variant type:

**Encoder tiers** (classify by folder name pattern):
- `x265-fast` — folders containing `CodexFast` or `0cpuQualitySameAudio`
- `x265-medium` — folders containing `CodexMedium`
- `x265-veryfast` — folders containing `1cpuQuality`, `qualityCpu`, `qualityTransTo`, `qualitySameAudio`
- `NVENC` — folders containing `nvQuality`
- `QSV` — folders containing `Qsv` or `QSV`
- `AV1-NVENC` — folders containing `AV1` and `nvenc` (case-insensitive)
- `AV1-CPU` — folders containing `AV1` and not `nvenc`

**Variant types** (classify by folder name suffix):
- `base` — no suffix
- `SameAudio` — contains `SameAudio`
- `TransTo720p` — contains `TransTo720p`
- `TransTo1080p` — contains `TransTo1080p`
- `TransTo720p+SameAudio` — contains both `TransTo720p` and `SameAudio`
- `TransTo1080p+SameAudio` — contains both `TransTo1080p` and `SameAudio`
- `Scene` — contains `Scene`

**BigVoice**: treat as a per-folder check, not a separate folder variant.

Output the matrix as a Markdown table with:
- Rows: variant types listed above
- Columns: encoder tiers listed above + `Hardware Req` column
- Cell values: `✅ EXISTS (N files)`, `❌ MISSING`, or `⚠️ PARTIAL (N files)` (partial = folder exists but has ≤3 files)
- `Hardware Req` column: `CPU`, `NVENC`, `Intel QSV`, `NVENC RTX 40xx` (for AV1-NVENC), `CPU + libsvtav1` (for AV1-CPU)

Tell the user: "Paste this into COVERAGE_MATRIX.md to update the index."

### Step 1 — Collect all XML files
Use Glob to find all `**/*.xml` files under the presets root, **excluding** `00_TEMPLATE_MASTER/` and legacy folders (`舟 5.X原预设/`, `舟 6.0原预设/`, `舟 滤镜参考/`).

### Step 2 — Run checks on each file
For each XML, check:

| Check | Rule | Severity |
|-------|------|----------|
| `movflags` | Must contain `-movflags faststart` in `<encparamBox>` | WARNING |
| `fps_mode` | If `-c:v` in `<encparamBox>` is a real encoder (not `copy`, and not absent/`none` — i.e. skip pure stream-copy and audio-only presets), it must contain `-fps_mode cfr` (substring match anywhere in `<encparamBox>`, don't rely on fixed whitespace/line-break position) | WARNING |
| Audio codec | Must be either `-c:a libfdk_aac -b:a 192k` or `-c:a copy` (not other values) | WARNING |
| Extension tag | `<extensiontextBox>` must not be empty | ERROR |
| SameAudio match | If a folder name contains `SameAudio`, audio must use `-c:a copy` | ERROR |
| Scale consistency | If folder name contains `TransTo720p`, must have `scale=1280:720`; `TransTo1080p` → `scale=1920:1080` | ERROR |
| Subtitle filter | `<filterparamBoxV>` should contain `shanasubtitle=1` for non-copy presets | INFO |
| BigVoice bitrate | If filename contains `BigVoice`, `<encparamBox>` must contain `-b:a 256k` (not `-b:a 192k`) | ERROR |

### Step 3 — Check folder-level consistency
For each folder:
- All files should use the same encoder (`libx265` / `hevc_nvenc` / `hevc_qsv` / etc.) — flag mixed encoders
- CRF/CQ values should be sequential and non-duplicate within the same folder
- If a `0cpuQuality*` or `nvQuality` folder exists without a matching `*SameAudio` sibling folder, report it as INFO
- If a BigVoice file exists in a folder, its audio bitrate must be `-b:a 256k` (caught by Step 2, but summarize at folder level)

### Step 4 — Report results
Group findings by severity:

```
❌ ERROR   (must fix — wrong behavior)
⚠️  WARNING (should fix — non-standard)
ℹ️  INFO    (optional — missing variants)
```

For each finding show: file path, the specific line/value that's wrong, and the expected value.

### Step 5 — Offer to fix
After reporting, ask: "要自动修复 WARNING 级别的问题吗？" If yes, apply fixes in batch.

After BigVoice ERROR findings, ask separately: "要将 BigVoice 文件的音频码率统一升级到 256k 吗？"

## Common Auto-fixable Issues
- Missing `-movflags faststart` → add after `-f mp4`
- Missing `-fps_mode cfr` (on non-copy, non-audio-only presets) → append to the end of the `-c:v` flag group
- Audio bitrate typo (e.g. `192`) → normalize to `192k`
- BigVoice files with `-b:a 192k` → upgrade to `-b:a 256k`
