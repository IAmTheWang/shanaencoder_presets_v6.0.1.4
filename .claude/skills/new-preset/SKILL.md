---
name: new-preset
description: Scaffold a new ShanaEncoder XML preset or preset variant from an existing one. Use when creating SameAudio variants, Scene variants, TransTo720p/1080p variants, or a fresh preset with adjusted quality parameters.
---

# new-preset

Creates a new ShanaEncoder XML preset based on an existing preset as template.

## When to invoke
- User says "新建预设", "创建预设变体", "加个 SameAudio 版本", "复制预设改 CRF" etc.
- Any request to scaffold a new `.xml` preset file.

## Workflow

### Step 1 — Understand what the user wants
Ask (or infer from context):
1. **Source preset**: which existing `.xml` to use as template (read it with Read tool)
2. **Variant type** — one of:
   - `SameAudio` → replace `-c:a libfdk_aac -b:a 192k` with `-c:a copy`
   - `Scene` → add `-x265-params scenecut=40:bframes=8` to encparamBox
   - `TransTo720p` → add `-vf scale=-2:720` to filterparamBoxV
   - `TransTo1080p` → add `-vf scale=-2:1080` to filterparamBoxV
   - `Custom` → user specifies exact parameter changes
3. **Target folder**: which folder to place the new file in
4. **CRF value**: if changing quality (default: keep source value)

### Step 2 — Derive the filename
Follow the existing naming convention in the target folder:
- Read the folder to find the highest existing numeric prefix (e.g. `28xxx.xml` → next is `29xxx.xml`)
- Append the base name from the source but updated for the variant
- SameAudio variants append `_SameAudio` before `.xml`

### Step 3 — Generate the XML
- Copy source XML structure exactly
- Apply only the targeted parameter changes
- Update `<extensiontextBox>` tag name to reflect the new preset name
- For SameAudio: also update `filterparamBoxA` if needed

### Step 4 — Write and confirm
- Write the file using the Write tool
- Show the user a diff summary of what changed vs. the source preset

## XML Parameter Reference

```
Audio copy (SameAudio):      -c:a copy
Audio re-encode (default):   -c:a libfdk_aac -b:a 192k
Scale to 720p:               scale=-2:720  (add to -vf in filterparamBoxV)
Scale to 1080p:              scale=-2:1080
movflags (always include):   -movflags faststart
Scene tuning:                -x265-params scenecut=40:bframes=8
```

## Naming Conventions
- `[se6qualityCpuMedium20].mp4` style tag in `<extensiontextBox>` — update the number to match new CRF
- SameAudio folder names end with `SameAudio`
- Scene folder names end with `Scene`
- File suffix: `_SameAudio.xml`, `_Scene.xml`, no suffix for standard variants
