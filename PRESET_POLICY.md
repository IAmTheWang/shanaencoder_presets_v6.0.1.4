# PRESET POLICY

## 生效日期

- `2026-04-13`（建立统一策略）
- `2026-04-19`（新增 场景分支预设与技能化维护说明）
- `2026-06-28`（新增 CodexFastSameAudio 目录定义；定义 BigVoice 为技术参数 -b:a 256k；新增审计规则）
- `2026-09-20`（新增 CodexSlow / CodexSlowSameAudio 目录定义：真 10bit、去 qmin/qmax、放开 GOP 限制，详见 `design_documents/2026-09-20-codexSlow-quality-tuning.md`）

## 全局统一策略（适用于全仓 XML）

1. 不强制固定帧率：移除 `-fps_mode cfr`。
2. 不做音量放大：移除 `volume=...`。
3. 不使用 limiter：移除 `alimiter=...`。
4. MP4 统一前置索引：保留/添加 `-movflags faststart`。
5. HEVC 兼容标记：对 HEVC 编码（如 `libx265` / `hevc_*`）添加 `-tag:v hvc1`。
6. 音频复制不加滤镜：`-c:a copy` 的预设不新增音频处理链。

## 主要目录的定位与差异

### `0cpuQuality`

- 角色：基线方案（更快）。
- 视频参数：`-preset veryfast`。
- 质量约束：保留 `-qmin/-qmax`。
- 文件命名：原始命名（如 `24qualityCpu.xml`）。

### `0cpuQualityGpt5.3Codex`

- 角色：优化方案（更省体积倾向）。
- 视频参数：`-preset fast`。
- 质量约束：移除 `-qmin/-qmax`，让 CRF 自适应。
- 文件命名：`*Optimized.xml`（如 `24qualityCpuOptimized.xml`）。

### `0cpuQualityGpt5.3CodexFast`

- 角色：优化方案 + 文件名显式区分。
- 参数：与 `0cpuQualityGpt5.3Codex` 一致（`-preset fast`、无 `qmin/qmax`）。
- 文件命名：`*Fast.xml`（如 `24qualityCpuFast.xml`）。
- 输出后缀：`[se6qualityCpuFastXX].mp4` 规则（如 `[se6qualityCpuFast24].mp4`）。
- 场景分支：允许在本目录新增 `*Scene_*.xml` 作为场景化策略，不覆盖原 `*Fast.xml`。

### `0cpuQualityGpt5.3CodexFast`（场景分支）

- 角色：场景化实验组（A/B 对比用），保留基线文件不动。
- 质量约束：按目标拆分为“自由 CRF / 均衡护栏 / 体积优先 / 细节优先 / 原音保留”。
- 文件命名：`*Scene_*.xml`（如 `24qualityCpuFastScene_BalancedGuard.xml`）。
- 记录要求：每个新增场景预设须注明“适用素材、目标分辨率、质量档位、关键滤镜开关”。

### `0cpuQualityGpt5.3CodexFastSameAudio`

- 角色：Fast 优化方案 + 保留原音轨。`0cpuQualityGpt5.3CodexFast` 的音轨直通对应版本。
- 视频参数：`-preset fast`，与 CodexFast 完全一致。
- 质量约束：保留 `-qmin 17 -qmax 36`。
- 音频策略：`-c:a copy`，不重编码音频。
- 播放兼容：保留 `-tag:v hvc1` + `-movflags faststart`。
- 适用场景：音轨格式需保留（AC3/DTS/FLAC）且编码速度优先。

### `0cpuQualityGpt5.3CodexSlow`

- 角色：慢速高质量方案（体积/画质优先于速度）。
- 视频参数：`-preset slow`，真 10bit（`-pix_fmt yuv420p10le`，与 `CodexFast`/`CodexMedium` 不同，这两个仅命名为10bit但未实际写 `pix_fmt`）。
- 质量约束：不设 `-qmin/-qmax`，完全交给 CRF 自适应；不强制 `-shanakeyframe`，交给 x265 默认 GOP（最大 250 帧）+ 场景切换自动插入关键帧。
- 代价与权衡：详见 `design_documents/2026-09-20-codexSlow-quality-tuning.md`——编码更慢、拖动进度条查找片段的精细度下降、复杂画面失去 QP 上限保护。
- 文件命名：原始命名（如 `25qualityCpuSlow.xml`），CRF 数值直接体现在文件名与 `<extensiontextBox>` 后缀中，同一文件夹内各档位独立维护，不互相覆盖。

### `0cpuQualityGpt5.3CodexSlowSameAudio`

- 角色：`CodexSlow` 的音轨直通对应版本。
- 视频参数：与 `CodexSlow` 完全一致（`-preset slow`、真 10bit、无 qmin/qmax、无强制 keyframe）。
- 音频策略：`-c:a copy`，不重编码音频。
- 适用场景：音轨格式需保留且愿意接受慢速编码换取体积/画质收益。

### `0cpuQualitySameAudio`

- 角色：保留原音轨（`-c:a copy`）的优化方案。
- 视频参数：`-preset fast`。
- 质量约束：移除 `-qmin/-qmax`，让 CRF 自适应。
- 播放兼容：保留 `-tag:v hvc1`（HEVC）。
- MP4 体验：保留/添加 `-movflags faststart`。
- 音频策略：不重编码音频，不新增音频放大与 limiter。

## BigVoice 技术定义

- **BigVoice = `-b:a 256k`**（而非标准 192k）。
- 适用场景：高动态范围音频源（演讲、人声为主的内容），需在保持高音频码率的同时压缩视频。
- **与 SameAudio 不兼容**：BigVoice 需要重编码音频（`-c:a libfdk_aac -b:a 256k`），因此不存在于任何 SameAudio 文件夹。
- **审计规则**：`/audit-presets` 会对文件名含 `BigVoice` 但 `<encparamBox>` 中不含 `-b:a 256k` 的文件报 ERROR。

## 使用建议

1. 日常大量压制优先用 `0cpuQuality`（更快）。
2. 收藏/长期存储优先用 `0cpuQualityGpt5.3Codex` 或 `0cpuQualityGpt5.3CodexFast`（更偏压缩效率）。
3. 场景类素材优先从 `0cpuQualityGpt5.3CodexFast` 的 `*Scene_*.xml` 小样本 A/B 后再批量。
4. 涉及大范围参数调整时，先复制新目录做 A/B，对比后再推广。

## 变更纪律

1. 修改策略时，先更新本文件，再批量改 XML。
2. 每次大改至少抽测一条动漫、一条真人、一条高运动素材。
3. 若发现兼容问题，优先新增分支预设，不直接覆盖稳定预设。

