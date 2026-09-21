[简体中文](README.md) | **English** | [日本語](README.ja.md)

# ShanaEncoder Presets

XML preset configurations for [ShanaEncoder](https://shana.pe.kr/shanaencoder) video encoding.

## Project Skills

This project includes Claude Code skills for managing presets. Invoke them by typing the slash command in a Claude Code session.

### `/new-preset` — Scaffold a new preset

Creates a new `.xml` preset file from an existing one as a template.

**Supports:**
- `SameAudio` variant — replaces re-encoded audio with `-c:a copy`
- `Scene` variant — adds scene-tuned x265 parameters
- `TransTo720p` / `TransTo1080p` — adds scale filter
- Custom — any parameter change you specify

**Example prompts:**
- "Create a SameAudio version of the 20 preset in 0cpuQualityGpt5.3CodexMedium"
- "Create a new Medium preset at CRF 22"

---

### `/audit-presets` — Audit all presets for consistency

Scans every `.xml` file and reports issues grouped by severity.

| Level | Example |
|-------|---------|
| ❌ ERROR | Audio in a `SameAudio` folder isn't using `-c:a copy` |
| ⚠️ WARNING | Missing `-movflags faststart` |
| ℹ️ INFO | `0cpuQuality*` exists but has no matching `*SameAudio` folder |

After reporting, offers to auto-fix WARNING-level issues in batch.

**Example prompts:**
- "Check all presets for consistency"
- "Audit the presets and find non-compliant files"

---

## Folder Structure

See [CLAUDE.md](CLAUDE.md) for the full folder reference and naming conventions.
