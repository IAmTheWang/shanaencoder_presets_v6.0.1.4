# PRESET POLICY

## 生效日期

- `2026-04-13`（建立统一策略）
- `2026-04-19`（新增 场景分支预设与技能化维护说明）
- `2026-06-28`（新增 CodexFastSameAudio 目录定义；定义 BigVoice 为技术参数 -b:a 256k；新增审计规则）
- `2026-09-20`（新增 CodexSlow / CodexSlowSameAudio 目录定义：真 10bit、去 qmin/qmax、放开 GOP 限制，详见 `design_documents/2026-09-20-codexSlow-quality-tuning.md`）
- `2026-09-21`（推广真10bit + `aq-mode=3:aq-strength=0.8` + `qmin 12`/无qmax 统一量化策略到全部 0/1 开头纯英文 CPU 预设文件夹；同时修正本文件此前把 `1cpuQuality` 系列文件夹错误标注为 `0cpuQuality` 前缀的问题）

## 全局统一策略（适用于全仓 XML）

1. 不强制固定帧率：移除 `-fps_mode cfr`。
2. 不做音量放大：移除 `volume=...`。
3. 不使用 limiter：移除 `alimiter=...`。
4. MP4 统一前置索引：保留/添加 `-movflags faststart`。
5. HEVC 兼容标记：对 HEVC 编码（如 `libx265` / `hevc_*`）添加 `-tag:v hvc1`。
6. 音频复制不加滤镜：`-c:a copy` 的预设不新增音频处理链。

## CPU 量化策略统一说明（2026-09-21 起）

**适用范围**：所有文件夹名以 `0` 或 `1` 开头、不含中文字符的 libx265 CPU 预设文件夹（含 `00_TEMPLATE_MASTER` 里的 `cpu_fast_crf21.xml`/`cpu_medium_crf21.xml` 两个母版）。`00_TEMPLATE_MASTER` 里另外的 NVENC/QSV/纯滤镜模板不适用（不是 x265）。

**统一参数**（下面各文件夹小节的"质量约束"均指向这里，不再逐条重复）：
- 真 10bit：`-pix_fmt yuv420p10le`（而不是仅命名为"10bit"、实际隐式 8bit）。
- `-qmin 12`，不设 `-qmax`（交给 x265 默认上限 69）。
- `-x265-params aq-mode=3:aq-strength=0.8`（x265 官方定义 `aq-mode 3` 为"偏向暗部场景防色带"模式，调低 `aq-strength` 避免过度花码率）。
- 不强制 `-shanakeyframe`，交给 x265 默认 GOP（最大 250 帧）+ 场景切换自动插入关键帧。

**不受此统一策略约束、各文件夹继续保留自己差异化定位的部分**：`-preset` 速度档位（veryfast/fast/medium/slow）、每个文件的 CRF 数值、音频编码方式（copy/libfdk_aac/BigVoice 256k）、文件命名规则。

依据与决策过程（含 x265 官方文档验证、真实 A/B 体积对比数据）详见 `design_documents/2026-09-20-codexSlow-quality-tuning.md`。

## 主要目录的定位与差异

### `1cpuQuality`

- 角色：基线方案（更快）。
- 视频参数：`-preset veryfast`。
- 质量约束：见上方"CPU 量化策略统一说明"（此前是 `-qmin 15 -qmax 35`，2026-09-21 起统一为 `qmin12`/无qmax/aq-mode3）。
- 文件命名：原始命名（如 `24qualityCpu.xml`）。

### `1cpuQualityGpt5.3Codex`

- 角色：优化方案（更省体积倾向）。
- 视频参数：`-preset fast`。
- 质量约束：见上方"CPU 量化策略统一说明"（此前完全不设 qmin/qmax，2026-09-21 起改为 `qmin12`/无qmax/aq-mode3）。
- 文件命名：`*Optimized.xml`（如 `24qualityCpuOptimized.xml`）。

### `1cpuQualityGpt5.3CodexFast`

- 角色：优化方案 + 文件名显式区分。
- 参数：与 `1cpuQualityGpt5.3Codex` 一致（`-preset fast`）；质量约束见上方"CPU 量化策略统一说明"。
- 文件命名：`*Fast.xml`（如 `24qualityCpuFast.xml`）。
- 输出后缀：`[se6qualityCpuFastXX].mp4` 规则（如 `[se6qualityCpuFast24].mp4`）。

### `1cpuQualityGpt5.3CodexFastScene`

- 角色：场景化实验组（A/B 对比用），保留基线 `1cpuQualityGpt5.3CodexFast` 文件不动。
- 质量约束：见上方"CPU 量化策略统一说明"（2026-09-21 起 5 个场景变体的 qmin/qmax 已统一收敛为 `qmin12`/无qmax/aq-mode3，不再保留各变体原本不同的 qmin/qmax 数值——保持全仓库量化口径一致优先于保留这个文件夹内部的差异化实验；各变体的 CRF 数值、命名、音频策略差异照常保留）。
- 文件命名：`*Scene_*.xml`（如 `24qualityCpuFastScene_BalancedGuard.xml`）。
- 记录要求：每个新增场景预设须注明"适用素材、目标分辨率、质量档位、关键滤镜开关"。

### `1cpuQualityGpt5.3CodexFastSameAudio`

- 角色：Fast 优化方案 + 保留原音轨。`1cpuQualityGpt5.3CodexFast` 的音轨直通对应版本。
- 视频参数：`-preset fast`，与 CodexFast 完全一致。
- 质量约束：见上方"CPU 量化策略统一说明"（此前保留 `-qmin 17 -qmax 36`，2026-09-21 起统一为 `qmin12`/无qmax/aq-mode3）。
- 音频策略：`-c:a copy`，不重编码音频。
- 播放兼容：保留 `-tag:v hvc1` + `-movflags faststart`。
- 适用场景：音轨格式需保留（AC3/DTS/FLAC）且编码速度优先。

### `0cpuQualityGpt5.3CodexMedium`

- 角色：中速方案，速度/体积介于 Fast 和 Slow 之间。
- 视频参数：`-preset medium`。
- 质量约束：见上方"CPU 量化策略统一说明"。
- 文件命名：`*Medium.xml`（如 `24qualityCpuMedium.xml`）。

### `0cpuQualityGpt5.3CodexMediumSameAudio`

- 角色：`CodexMedium` 的音轨直通对应版本。
- 视频参数：与 `CodexMedium` 完全一致（`-preset medium`）。
- 质量约束：见上方"CPU 量化策略统一说明"。
- 音频策略：`-c:a copy`，不重编码音频。

### `0cpuQualityGpt5.3CodexSlow`

- 角色：慢速高质量方案（体积/画质优先于速度）。
- 视频参数：`-preset slow`。
- 质量约束：见上方"CPU 量化策略统一说明"。
- 代价与权衡：详见 `design_documents/2026-09-20-codexSlow-quality-tuning.md`——真10bit+`aq-mode3`比纯 8bit 编码更慢；相比"完全不设qmin/qmax"的第一轮版本，`qmin12` 是折中的安全网，不是完全放开。
- 文件命名：原始命名（如 `25qualityCpuSlow.xml`），CRF 数值直接体现在文件名与 `<extensiontextBox>` 后缀中，同一文件夹内各档位独立维护，不互相覆盖。

### `0cpuQualityGpt5.3CodexSlowSameAudio`

- 角色：`CodexSlow` 的音轨直通对应版本。
- 视频参数：与 `CodexSlow` 完全一致（`-preset slow`）；质量约束见上方"CPU 量化策略统一说明"。
- 音频策略：`-c:a copy`，不重编码音频。
- 适用场景：音轨格式需保留且愿意接受慢速编码换取体积/画质收益。

### `0cpuQualitySameAudio`

- 角色：保留原音轨（`-c:a copy`）的优化方案。
- 视频参数：`-preset fast`。
- 质量约束：见上方"CPU 量化策略统一说明"。
- 播放兼容：保留 `-tag:v hvc1`（HEVC）。
- MP4 体验：保留/添加 `-movflags faststart`。
- 音频策略：不重编码音频，不新增音频放大与 limiter。

### `00_TEMPLATE_MASTER`

- 角色：黄金母版模板，不会被 ShanaEncoder 直接加载，是生成其他预设的源头。
- `cpu_fast_crf21.xml` / `cpu_medium_crf21.xml`：libx265 母版，质量约束见上方"CPU 量化策略统一说明"，2026-09-21 起已同步更新，保持和实际使用中的预设文件夹口径一致。
- `nvenc_cq23.xml` / `qsv_cq23.xml` / 两个 `filter_scale*.xml`：分别是 NVENC/QSV/纯滤镜模板，不受本次 x265 专属的量化策略约束。

## BigVoice 技术定义

- **BigVoice = `-b:a 256k`**（而非标准 192k）。
- 适用场景：高动态范围音频源（演讲、人声为主的内容），需在保持高音频码率的同时压缩视频。
- **与 SameAudio 不兼容**：BigVoice 需要重编码音频（`-c:a libfdk_aac -b:a 256k`），因此不存在于任何 SameAudio 文件夹。
- **审计规则**：`/audit-presets` 会对文件名含 `BigVoice` 但 `<encparamBox>` 中不含 `-b:a 256k` 的文件报 ERROR。

## 使用建议

1. 日常大量压制优先用 `1cpuQuality`（更快）。
2. 收藏/长期存储优先用 `1cpuQualityGpt5.3Codex` 或 `1cpuQualityGpt5.3CodexFast`（更偏压缩效率）；追求极致画质/体积可用 `0cpuQualityGpt5.3CodexSlow`（更慢）。
3. 场景类素材优先从 `1cpuQualityGpt5.3CodexFastScene` 小样本 A/B 后再批量。
4. 涉及大范围参数调整时，先复制新目录做 A/B，对比后再推广。

## 变更纪律

1. 修改策略时，先更新本文件，再批量改 XML。
2. 每次大改至少抽测一条动漫、一条真人、一条高运动素材。
3. 若发现兼容问题，优先新增分支预设，不直接覆盖稳定预设。

