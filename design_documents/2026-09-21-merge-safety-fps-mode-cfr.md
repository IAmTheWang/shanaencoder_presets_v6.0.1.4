# 合并安全策略：全仓库压制类预设加 `-fps_mode cfr`

## 生效日期

- `2026-09-21`（第六轮）

## 背景

用户用 `2压 H265 10bit NVENCfor720pXiaoMiTv/210S_NVHVC_30_FMP4.xml` 把 4 段视频合并压制成一个文件，发现最后一段音频已经切到了 `...ethermine.mp4` 的内容，但画面还停在上一段 `Rec 0014.mp4`。

## 根因分析

这个预设本身只是单文件转码参数（缩放/编码/音频），不包含任何"合并时间轴对齐"逻辑——真正的合并是 ShanaEncoder 自己按每段文件各自记录的视频轨总时长、音频轨总时长分别首尾拼接。

如果某一段源文件内部的视频轨和音频轨时长本来就不一致（本例大概率是 `Rec 0014.mp4`——录制时电脑同时在跑 ETH 挖矿，CPU/GPU 被挖矿进程抢占，录屏软件视频帧丢帧/编码跟不上，但音频采集走独立时钟没跟着掉），拼接后从这一段开始就会出现一个时间差，且这个差值会累加到后面的片段——这正是"音频已经进入下一段内容、画面还停在上一段"的现象，也解释了为什么问题出现在第 4 段而不是更早。

这种源文件内部丢帧本应能被标准 ffmpeg 手段纠正：`-fps_mode cfr`（原 `-vsync cfr`）会按帧的实际时间戳把输出重采样到恒定帧率，在源文件因丢帧而在时间轴上出现"空洞"的地方补帧，使输出视频轨的真实时长贴合按恒定采样率记录的音频轨时长。但仓库当时的全局策略（`PRESET_POLICY.md` 原第 1 条）明确"不强制固定帧率：移除 `-fps_mode cfr`"——目的是避免对正常可变帧率素材做不必要的补帧/丢帧、增大体积，副作用是这种源文件级别的音画偏差从未被纠正，合并时被原样放大暴露。

## 决策

反转 `PRESET_POLICY.md` 全局策略第 1 条：除纯 `-c:v copy`（无重新编码）与纯音频输出（无视频轨）预设外，所有会重新编码视频的现役预设默认加 `-fps_mode cfr`。理由：这个仓库里没有任何预设文件在结构上区分"会被用来合并"和"只会单文件使用"——ShanaEncoder 的合并是使用者在 GUI 里勾选多文件时套用的，同一份预设两种用法都可能遇到，所以没办法只对"合并场景"生效，只能对所有重新编码视频的预设生效。

## 范围

**加（337 个文件）**：
- 编码器：`libx265`(234) / `hevc_nvenc`(73) / `hevc_qsv`(14) / `libx264`(8) / `h264_nvenc`(8)。
- 覆盖全部现役文件夹（`0cpuQuality*`、`1cpuQuality*`、`2压 H264/H265*`、`3压 *`、`nvQuality`、`quality*` 系列）+ `00_TEMPLATE_MASTER` 的 4 个母版（`cpu_fast_crf21.xml`/`cpu_medium_crf21.xml`/`nvenc_cq23.xml`/`qsv_cq23.xml`）+ `舟 滤镜参考`（15 个文件）。
- `舟 滤镜参考` 纳入范围的依据：round 5 faststart 审计已经把它当"现役参考预设"处理过（拿到过 faststart），不是当成历史存档，本次沿用同样对待方式。
- `SameAudio` 系列（`-c:a copy`）依然纳入——`-fps_mode cfr` 只作用于视频轨的重新编码，跟音频是否 copy 无关。

**不加**：
- `0压 视频复制流`（7 个，`-c:v copy`，没有重新编码，参数用不上）。
- `0压 音频复制流`（4 个）+ `2压 音频预设`（10 个）——纯音频输出，没有视频轨。
- `舟 5.X原预设`（86 个）、`舟 6.0原预设`（91 个）——项目一贯把这两个当历史版本快照，不随现行规范变动（round 5 faststart 审计已确立的先例）。
- `00_TEMPLATE_MASTER` 的 `filter_scale720p.xml`/`filter_scale1080p.xml`——纯滤镜片段，没有 `<encparamBox>`。

## 执行方式

用一次性 `sed -E` 命令在 shell 里直接跑（沿用前两轮大改的做法，仓库里没有、也不打算新增一个专门的传播脚本）：

```bash
find . -name '*.xml' \
  -not -path './.git/*' \
  -not -path './舟 5.X原预设/*' \
  -not -path './舟 6.0原预设/*' \
  -print0 | xargs -0 sed -i -E '/-fps_mode/!s/^(\s*-c:v (libx265|libx264|hevc_nvenc|hevc_qsv|h264_nvenc)\b.*)$/\1 -fps_mode cfr/'
```

`/-fps_mode/!` 是幂等性保护——即使命令中途失败重跑，已经带 `-fps_mode` 的行不会被二次追加（执行前已核实全仓库 537 个已跟踪 xml 里没有一个包含 `fps_mode`/`vsync`，这条保护纯粹是防御性的）。

这条命令按行匹配 `-c:v <编码器>` 开头的行、在行尾追加，覆盖了绝大多数文件（它们的 `<encparamBox>` 里 `-c:v` 那组参数总是单独一行）。但有 3 个"无损 CQP"文件（`2压 H264 8bit NVENC/208S_NVAVC_无损CQP_FMP4.xml`、`2压 H265 10bit NVENC/210S_NVHVC_无损CQP_FMP4.xml`、`2压 H265 10bit NVENCfor720pXiaoMiTv/210S_NVHVC_无损CQP_FMP4.xml`）的整个 `<encparamBox>` 是单行写法、`-c:v` 不在行首，sed 命令没匹配上，改用 Edit 工具手动在这 3 个文件里把 `-fps_mode cfr` 插到视频参数组末尾（`-pix_fmt`/`-c:v` 之后、`-c:a` 之前）。

执行后用 `git diff --stat` 确认恰好 337 个文件变化，且排除目录（含两个"舟"历史文件夹、`0压 视频复制流`、`0压 音频复制流`、`2压 音频预设`、两个纯滤镜母版）一个字节都没变。

## 已知取舍

对于真正按设计使用可变帧率、且确定不会被拿去和其他素材合并的源（比如某些游戏录制/自适应刷新率内容），`-fps_mode cfr` 可能导致补帧/丢帧、体积略增。这次决策认为"合并时不再音画错位"这个正确性收益优先于这点体积代价——如果以后遇到明确不需要合并、且素材已知是合法可变帧率的场景，可以在预设副本里自行去掉这个参数（不建议直接改现役预设，遵循 `PRESET_POLICY.md`"变更纪律"里"优先新增分支预设，不直接覆盖稳定预设"的原则）。

## 配套文档更新

- `PRESET_POLICY.md`：反转全局策略第 1 条，新增"合并安全（CFR）策略"小节。
- `CLAUDE.md`：在"Per-Folder Encoding Parameters"小节开头追加 round 6 说明段落。
- `skills/shanaencoder-preset-maintainer/references/parameter-notes.md`：`-fps_mode cfr` 条目补充"现在默认开启"的说明。
- `.claude/skills/audit-presets/SKILL.md`：Step 2 检查表新增 `fps_mode` 一行（WARNING 级别，对齐 `movflags` 检查），明确排除纯 copy 与纯音频预设。
- `1cpuQualityGpt5.3CodexFast/SCENE_PROFILES.md`、`0cpuQualityGpt5.3CodexMedium/SCENE_PROFILES.md`、`0cpuQualityGpt5.3CodexMediumSameAudio/SCENE_PROFILES.md`：给每个场景变体的"关键滤镜/参数"列追加 `-fps_mode cfr`。

顺带发现但本次不修：后两份 `SCENE_PROFILES.md`（CodexMedium 系列）里列的 `-qmin`/`-qmax` 数值是 2026-09-21 统一量化策略生效前的旧值，跟实际 XML（已是 `qmin 12`、无 `qmax`）不一致，是那次改动漏更新文档留下的既有问题，跟本次合并安全改动无关，已通过 `spawn_task` 单独提出。

## 验证

- `git diff --stat`：337 个文件变化，均在预期范围内。
- 抽查 5 种编码器（libx265 CPU / hevc_nvenc / hevc_qsv / libx264 / h264_nvenc）+ 1 个 SameAudio 变体 + 3 个母版 + `舟 滤镜参考` 的 diff，确认 `-fps_mode cfr` 插入位置正确、格式不重复、没有破坏 XML。
- 端到端验证（音画是否真的不再错位）依赖用户提供当时那 4 段素材的实际路径手动跑一次合并——这一步作为可选的最终确认，不是本次改动落地的硬性前提。
