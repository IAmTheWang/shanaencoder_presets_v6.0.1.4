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
- "给 0cpuQualityGpt5.3CodexMedium 里的 20 预设创建一个 SameAudio 版本"
- "新建一个 CRF 22 的 Medium 预设"

---

### `/audit-presets` — Audit all presets for consistency

Scans every `.xml` file and reports issues grouped by severity.

| Level | Example |
|-------|---------|
| ❌ ERROR | SameAudio 文件夹里音频没用 `-c:a copy` |
| ⚠️ WARNING | 缺少 `-movflags faststart` |
| ℹ️ INFO | 存在 `0cpuQuality*` 但没有对应的 `*SameAudio` 文件夹 |

After reporting, offers to auto-fix WARNING-level issues in batch.

**Example prompts:**
- "检查所有预设的一致性"
- "审计预设，找出不规范的文件"

---

## Folder Structure

See [CLAUDE.md](CLAUDE.md) for the full folder reference and naming conventions.
