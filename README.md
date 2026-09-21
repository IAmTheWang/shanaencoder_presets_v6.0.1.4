**简体中文** | [English](README.en.md) | [日本語](README.ja.md)

# ShanaEncoder 预设仓库

[ShanaEncoder](https://shana.pe.kr/shanaencoder) 视频编码用的 XML 预设配置集合。

## 项目技能（Claude Code Skills）

这个项目内置了几个 Claude Code 技能，用于管理预设。在 Claude Code 会话里直接输入斜杠命令即可调用。

### `/new-preset` — 从现有预设创建新预设

以现有的 `.xml` 预设文件为模板，生成一个新的预设文件。

**支持：**
- `SameAudio` 变体 —— 把重新编码音频换成 `-c:a copy`
- `Scene` 变体 —— 添加场景调优的 x265 参数
- `TransTo720p` / `TransTo1080p` —— 添加缩放滤镜
- 自定义 —— 任意你指定的参数改动

**示例 prompt：**
- "给 0cpuQualityGpt5.3CodexMedium 里的 20 预设创建一个 SameAudio 版本"
- "新建一个 CRF 22 的 Medium 预设"

---

### `/audit-presets` — 审计所有预设的一致性

扫描每一个 `.xml` 文件，按严重程度分级报告问题。

| 级别 | 示例 |
|-------|---------|
| ❌ ERROR | SameAudio 文件夹里音频没用 `-c:a copy` |
| ⚠️ WARNING | 缺少 `-movflags faststart` |
| ℹ️ INFO | 存在 `0cpuQuality*` 但没有对应的 `*SameAudio` 文件夹 |

报告完成后，会提示是否要批量自动修复 WARNING 级别的问题。

**示例 prompt：**
- "检查所有预设的一致性"
- "审计预设，找出不规范的文件"

---

## 文件夹结构

完整的文件夹参考和命名规范见 [CLAUDE.md](CLAUDE.md)。
