# CodexSlow 预设调优（去 qmin/qmax、真 10bit、放开 GOP 限制）

## 生效日期

- `2026-09-20`

## 背景

用户拿到 Gemini 对 `0cpuQualityGpt5.3CodexSlow/25qualityCpuSlow.xml` 的一份优化建议，原始建议共 4 点：

1. 删除 `-shanakeyframe 10`，理由：Gemini 认为这会导致"每 10 帧（约0.3秒）强制插入关键帧"，造成体积虚胖 15%~30%。
2. 新增 `-pix_fmt yuv420p10le`，理由：解决 8bit 压制在皮肤渐变、暗部灯光处的色带（banding）问题。
3. 将 CRF 从 25.0 调整为 23.0，并删除 `-qmin 17 -qmax 36`，理由：CRF 25 压缩过猛导致暗部噪点，qmin/qmax 会干扰 x265 的码率分配。
4. 字幕处理方式（硬字幕 vs 软字幕），二选一，纯个人播放习惯。

在逐条讨论中，没有直接采信 Gemini 的说法，而是做了实际验证：

- **反编译 `ShanaEncoder.exe` 二进制**（UTF-16LE 字符串搜索），在 `shanakeyframe` 附近找到：
  ```
  -shanakeyframe ... -c:v libx265 ...:keyint= ...:min-keyint= ... -g ... -keyint_min ...
  ```
  证实 `shanakeyframe` 宏最终会展开为 x265 的 `keyint`/`min-keyint`（对应通用 ffmpeg 的 `-g`/`-keyint_min`），**单位是帧数，不是秒数**。同一段字符串里软件自身给出的默认建议值是 `25`（对应 25fps 下约 1 秒一个关键帧）。仓库里统一用的 `10` 比软件自己的默认建议还小一倍多。

- **查证 x265 官方 CLI 文档**（<https://x265.readthedocs.io/en/master/cli.html>）：
  - `--qpmin`："sets a hard lower limit on QP allowed to ratecontrol. Default 0"
  - `--qpmax`："sets a hard upper limit on QP allowed to ratecontrol. Default 69"
  - `--keyint`："Max intra period in frames...Default 250"
  - `--min-keyint`：场景切换间隔小于此值时编码为 I/P 帧而非强制关键帧

  确认仓库当前的 `qmin 17 / qmax 36` 是人为收紧过的 QP 范围（默认是 0~69），`shanakeyframe 10` 远小于官方默认的 250 帧。

- **查证社区资料**（Doom9 论坛、forasoft 技术文章等）：x265 对 8bit 片源做 10bit 编码，能**减少但不能消除**色带；编码速度确实会变慢（不同来源给出 5%~接近 50% 不等，取决于版本/CPU/tune）；文件体积**不保证变小**，低码率区间可能持平甚至略增。

- **确认仓库现状**：`0cpuQualityGpt5.3CodexSlow/23qualityCpuSlow.xml` 已经是 CRF 23.0，所以"CRF 25→23"这条不需要新建或覆写文件——如果想要 CRF 23，直接用现有的 23 号文件即可。真正需要跨文件统一调整的是 qmin/qmax 和 keyframe 两项策略。

## 逐条有效性判断（含代价，不是"纯收益"）

| 建议 | 是否有效 | 代价 |
|---|---|---|
| 删除 `-shanakeyframe 10` | 有效，原理成立（关键帧比预测帧贵，GOP 越短码率开销越大） | PotPlayer/播放器拖动进度条时是"跳到最近关键帧"来实时刷新预览画面的；关键帧越密集，拖动手感越流畅精细。删除后关键帧间隔从固定 10 帧变成 x265 默认最大 250 帧（+场景切换自动插入），拖动查找片段会变得更"粗糙"。 |
| 新增 `-pix_fmt yuv420p10le` | 有效，是业界公认技巧 | 编码速度变慢（这批文件已经是 `-preset slow`，会更慢）；输出变为 HEVC Main10 profile，老旧/低端硬件解码器可能不支持，需要软解，弱设备可能卡顿——仓库里存在专门的 `2压 H265 10bit NVENCfor720pXiaoMiTv` 预设，说明弱设备兼容性是被认真考虑过的点。 |
| 删除 `qmin 17` / `qmax 36`，交给 CRF 自适应 | 有效，x265/x264 社区主流建议就是不手动设这两个值，让 CRF 自己判断 | 去掉 `qmin` 后，编码器在需要极高精度的画面（渐变/暗部）可以用更低 QP，那部分片段体积可能略增；去掉 `qmax` 后，失去了"复杂/高动态画面画质不低于某个底线"的保险，最难压的画面（高速运动、强噪点）可能被压得更狠、画质更差。 |
| 字幕硬烧/软字幕 | 不涉及有效性，纯个人播放习惯 | 无 |

## 最终决策

**采用 1、2、3；4 维持现状不改。**

理由：这三项改动的收益（更小体积/更好画质/更符合 x265 社区最佳实践）对当前使用场景是划算的取舍，用户已知晓并接受对应代价（拖动进度条手感变粗糙、编码变慢、弱设备兼容性风险、极端画面画质下限保护移除）。

## 修改范围

`0cpuQualityGpt5.3CodexSlow` + `0cpuQualityGpt5.3CodexSlowSameAudio` 两个文件夹，共 28 个 XML 文件（每个文件夹 14 个，含各自的 BigVoice 变体）。**每个文件保留自己原有的 CRF 数值**（20.0~32.0），不改文件名、不改 CRF 数字，只统一调整编码参数策略。

未选择"只改一个文件"，是因为这两个文件夹里所有 CRF 档位共享同一套底层策略（preset slow、qmin/qmax、shanakeyframe），只改一个文件会导致同一文件夹内策略不一致；也未选择"推广到全仓库所有 10bit 预设"，因为改动面太大、风险太高，遵循仓库自身在 `PRESET_POLICY.md` 里的纪律——"涉及大范围参数调整时，先小范围验证再推广"。

## 具体参数 diff

对 `<encparamBox>` 做以下 2 处改动，其余参数（CRF 数值、`-preset slow`、音频编码、`faststart`、字幕滤镜、`assforcestyle` 等）保持不变：

```diff
- -c:v libx265 -tag:v hvc1 -crf XX.0 -qmin 17 -qmax 36 -preset slow -tune:v none
+ -c:v libx265 -tag:v hvc1 -pix_fmt yuv420p10le -crf XX.0 -preset slow -tune:v none
```
```diff
- -sn -map_metadata -1 -map_chapters -1 -shanakeyframe 10 -assforcestyle
+ -sn -map_metadata -1 -map_chapters -1 -assforcestyle
```

（`XX.0` = 每个文件各自原有的 CRF 值，不改动）

### `yuv420p10le` 参数拆解（容易误解的点，需要说明）

`-pix_fmt yuv420p10le` 这个值本身由 4 部分拼成：

| 片段 | 含义 |
|---|---|
| `yuv420` | 色度采样比例（YUV 4:2:0）——亮度(Y)每像素都精细记录，色度(UV)每 2×2 像素共用一组数据，是视频行业的通用默认标准 |
| `p` | planar，Y/U/V 三个分量分开存储 |
| `10` | **位深**，每个分量 1024 级精度（8bit 只有 256 级），是这次改动唯一实质变化的部分 |
| `le` | little-endian，多字节数据的存储字节序，纯技术实现细节，不影响画质 |

**关键澄清：这次改动"新增了 `-pix_fmt yuv420p10le` 这一串参数"，但并不等于"新增了 YUV420 这个色度采样方案"。**

ffmpeg 在没有显式指定 `-pix_fmt` 时，libx265 的默认值本身就是 `yuv420p`（8bit 版本的 YUV420）。也就是说：

- **改动前**：色度采样已经是 4:2:0（隐式默认，8bit）——这 28 个文件此前完全没写 `-pix_fmt`，一直是靠 ffmpeg 的隐式默认在跑。
- **改动后**：色度采样仍然是 4:2:0（这次显式写出来了，10bit）。

这次改动唯一真正生效的部分是**位深从隐式 8bit 变成显式 10bit**；`420` 这个色度采样比例从头到尾没有变化，只是这次跟着 `10` 一起被显式写进了配置文件。之所以在这里特别写明，是因为字符串里同时出现 `yuv420` 和 `10`，很容易被误读成"这次同时新增了 YUV420 和 10bit 两件事"，实际只新增了后者。

## 验证方法

1. 挑 2~3 个不同 CRF 档位的文件（如 20、25、32）在 ShanaEncoder 里实际压制一次，用以下命令确认真 10bit 生效：
   ```bash
   ffprobe -v error -select_streams v:0 -show_entries stream=pix_fmt,profile -of default=noprint_wrappers=1 output.mp4
   ```
   预期输出：`pix_fmt=yuv420p10le`、`profile=Main 10`。
   用 `ffprobe -show_frames -select_streams v:0 -show_entries frame=pict_type` 粗查关键帧间隔不再固定为 10 帧。
2. 对比同一素材新旧参数压出的文件体积，留痕对比（不设硬性体积指标）。
3. 用 PotPlayer 打开新压制的文件，实际拖动进度条，确认拖动查找片段的体验变化是否可接受（主观判断，需要用户自己确认）。
4. 检查 `substyle` / 字幕滤镜等未被误改。

## 遗留问题 / 后续

是否要把同样的策略（真 10bit、去 qmin/qmax、放开 GOP）推广到仓库里其他标"10bit"的 CPU 预设文件夹（如 `0cpuQualityGpt5.3CodexMedium`、`1cpuQuality` 等），本次不做，留待这批 CodexSlow 文件在实际使用中验证效果后再决定。

---

## 第二轮调整（2026-09-21）：用 AQ 模式调优替代粗暴去 qmin

### 触发原因：真实 A/B 测试结果

用户用同一份素材（NEO-781...）分别跑了旧 Medium 预设和第一轮改完的 Slow 预设，CRF 都是 25：

| 预设 | 参数 | 体积 |
|---|---|---|
| `0cpuQualityGpt5.3CodexMedium` (25) | preset medium、8bit（隐式）、qmin17/qmax36、keyframe10 | 1.79GB |
| `0cpuQualityGpt5.3CodexSlow` (25，第一轮改后) | preset slow、真10bit、无qmin/qmax、无强制keyframe | 2.1GB（+17%） |

注意这不是单变量对比，preset 本身也不同（medium vs slow），但排查后判断：体积上涨主要来自"真10bit"+"去掉 qmin17"两项**同方向叠加**——都会让编码器在这批素材典型的暗部/皮肤渐变画面上多花精度防色带，抵消了"去 shanakeyframe"和"preset slow"本该省下的体积。

### Gemini 第二轮建议

不用 `qmin` 硬阈值控制体积，改用 x265 的自适应量化机制本身：`--aq-mode 3`（暗部防色带专用模式）+ `--aq-strength 0.8`（降低 AQ 强度，避免把 H.264 源文件的压缩瑕疵当作"高价值细节"过度花码率）+ 保留 `qmin 10~12` 作为极少数极端画面的兜底，而非主力调节手段。预期能把 17% 的涨幅压到 3%~6%。

### 技术验证（x265 官方文档）

查证 <https://x265.readthedocs.io/en/master/cli.html>：

- `--aq-mode 3` 官方原文：*"AQ enabled with auto-variance and bias to dark scenes. This is recommended for 8-bit encodes or low-bitrate 10-bit encodes, to prevent color banding/blocking."* —— 确认这个模式就是官方设计来解决色带问题的，跟 Gemini 的说法一致。（x265 默认是 `aq-mode 2`，不是 1；Gemini 原话"默认1或2"不够精确，但不影响结论。）
- `--aq-strength` 默认 1.0，范围 0~3，官方注明在 aq-mode 2/3 下该值越高、QP 偏移和码率差异越大——确认调低到 0.8 确实能减少 AQ 在暗部区域多花的码率。

结论：这条建议比第一轮"完全去掉 qmin"更精准——用内容感知的机制解决问题，而不是全局硬阈值。

### 最终决策

采用 `aq-mode=3`、`aq-strength=0.8`、`qmin=12`。`qmax`（原36）继续保持完全去掉，不重新加回——`qmax` 解决的是复杂/高动态画面的画质下限保护，跟 `aq-mode 3` 针对的暗部防色带是两个不同问题，这轮 Gemini 建议也没提议改动 `qmax`。

### 计划中的 XML 改动（尚未执行，待本设计文档经 Gemini 审阅后再落地）

范围与第一轮相同：`0cpuQualityGpt5.3CodexSlow` + `0cpuQualityGpt5.3CodexSlowSameAudio` 共 28 个文件，各自 CRF 数值不变。

```diff
- -c:v libx265 -tag:v hvc1 -pix_fmt yuv420p10le -crf XX.0 -preset slow -tune:v none
+ -c:v libx265 -tag:v hvc1 -pix_fmt yuv420p10le -crf XX.0 -qmin 12 -preset slow -tune:v none -x265-params aq-mode=3:aq-strength=0.8
```

注意：`aq-mode`/`aq-strength` 不是 ffmpeg 通用参数，必须通过 `-x265-params aq-mode=3:aq-strength=0.8` 传给 x265，不能写成独立的 `-aq-mode`/`-aq-strength` 标志；`qmin` 仍用 ffmpeg 原生 `-qmin` 写法，两种语法不要混用。

### 后续步骤（第二轮设计时的计划，已在第三轮中执行完毕，见下）

1. ~~把这份设计文档拿给 Gemini 审阅。~~ 已完成，Gemini 审阅通过。
2. ~~审阅通过后：同步更新 `PRESET_POLICY.md` 和 `CLAUDE.md`~~ 已在第三轮一并完成（见下）。
3. ~~批量修改 28 个 XML 文件~~ 已在第三轮的批量修改中一并完成。
4. 用同一份素材重新压制 CRF25，对比体积是否回落到预期的 +3%~+6% 区间，并检查暗部/皮肤渐变画面的色带情况——**待用户实测**。
5. Git 提交粒度改为按文件夹拆分，详见第三轮章节。

---

## 第三轮调整（2026-09-21）：推广到全部 0/1 开头纯英文 CPU 预设文件夹

### 触发原因

Gemini 审阅第二轮设计文档通过后，用户要求：把第二轮定下的最终方案（真10bit + `qmin12` + 无`qmax` + `aq-mode=3:aq-strength=0.8` + 无强制 `shanakeyframe`）推广到仓库里**所有文件夹名以 0 或 1 开头、且不含中文字符**的 libx265 CPU 预设文件夹，而不只是 `CodexSlow` 这两个文件夹。这也正好回答了第一轮文档"遗留问题"里挂起的那个问题。

### 范围盘点

实际用 Bash/Grep 核对目录（不依赖 `CLAUDE.md` 的旧描述——过去出现过文档和实际目录不一致的情况），确认满足条件的文件夹及其当时的 `<encparamBox>` 状态：

| 文件夹 | 文件数 | preset | 改动前 qmin/qmax | 音频 |
|---|---|---|---|---|
| `0cpuQualityGpt5.3CodexMedium` | 14 | medium | 17/36 | libfdk_aac 192k（含BigVoice 256k） |
| `0cpuQualityGpt5.3CodexMediumSameAudio` | 14 | medium | 17/36 | copy |
| `0cpuQualityGpt5.3CodexSlow` | 14 | slow | 第一轮已去掉，本轮补 aq-mode | libfdk_aac 192k（含BigVoice） |
| `0cpuQualityGpt5.3CodexSlowSameAudio` | 14 | slow | 第一轮已去掉，本轮补 aq-mode | copy |
| `0cpuQualitySameAudio` | 13 | fast | 17/36 | copy |
| `1cpuQuality` | 14 | veryfast | 15/35（跟其他文件夹不同） | libfdk_aac 192k（含BigVoice） |
| `1cpuQualityGpt5.3Codex` | 14 | fast | 本来就没设 qmin/qmax | libfdk_aac 192k（含BigVoice） |
| `1cpuQualityGpt5.3CodexFast` | 14 | fast | 17/36 | libfdk_aac 192k（含BigVoice） |
| `1cpuQualityGpt5.3CodexFastSameAudio` | 13 | fast | 17/36 | copy |
| `1cpuQualityGpt5.3CodexFastScene` | 5 | fast | 每个文件不同（16/34、17/36×2、18/40，刻意做A/B差异化） | 混合 |
| `00_TEMPLATE_MASTER`（仅 `cpu_fast_crf21.xml`/`cpu_medium_crf21.xml`，libx265 母版） | 2 | fast/medium | 17/36 | libfdk_aac 192k |

共 **131 个文件**。`00_TEMPLATE_MASTER` 里另外 4 个模板（`nvenc_cq23.xml`/`qsv_cq23.xml`/两个 filter 模板）是 NVENC/QSV/纯滤镜，不是 x265，本次 x265 专属的 aq-mode/pix_fmt 方案不适用，未改动。

**关键决策（已和用户确认）：**
- `1cpuQualityGpt5.3CodexFastScene` 虽然是刻意做差异化 A/B 测试用的文件夹（各文件 qmin/qmax 本来不同），仍然统一改成新方案，不保留原有的 qmin/qmax 差异——保持全仓库底层量化策略口径一致优先于保留这个文件夹内部的差异化实验。
- `00_TEMPLATE_MASTER` 的 2 个 libx265 母版一并更新，保持"母版是生成其他预设的源头"这个设计不失效。
- 每个文件夹的 `-preset` 速度档位（medium/fast/veryfast/slow）、每个文件的 CRF 数值、音频编码方式（copy/libfdk_aac/BigVoice 256k）、文件名，全部保持不变——这次只统一底层量化/防色带策略，不动"这个文件夹是什么定位"的核心身份。

### 执行结果

用一条 `sed -E` 正则（能同时处理"原来有 qmin/qmax"和"原来没有 qmin/qmax"两种情况）对 129 个"全新应用"文件 + `00_TEMPLATE_MASTER` 的 2 个母版做了替换，另用单独一条正则对已经完成第一轮的 `CodexSlow`/`SlowSameAudio` 28 个文件补上第二轮的 aq-mode 增量。执行后验证：
- 全范围 131 个文件确认都含 `pix_fmt yuv420p10le`、`qmin 12`、`aq-mode=3:aq-strength=0.8`。
- 反向扫描确认没有任何残留的非 12 qmin 数值、没有任何残留的 qmax、没有任何残留的 `shanakeyframe`。
- 抽查了 BigVoice（256k音频）、SameAudio（copy音频）、FastScene 变体、母版模板等代表性文件，确认 CRF 值、音频编码、文件名后缀、`<encparamBox>` 首尾空格均未被误改。
- 确认 `nvenc_cq23.xml`/`qsv_cq23.xml`/两个 filter 模板完全未被触碰。

### 待用户验证

跟第一、二轮一样，实际压制效果需要用户自己验证：
1. 挑 1~2 个非 Slow 文件夹（如 Medium、`1cpuQualityGpt5.3CodexFast`）实际压一版，跟旧版本做体积/画质对比。
2. `ffprobe` 检查 `pix_fmt=yuv420p10le`、`profile=Main 10`。
3. 暗部/皮肤渐变画面色带的肉眼对比。
4. **`1cpuQuality`（veryfast 档位）的预期校正**：veryfast 本身算法较简化，配合 `aq-mode 3` 后暗部色带能明显改善，但整体压缩率天然低于 slow/medium 档位——测试时不要拿它跟 slow 档位的绝对体积做横向比较，只跟它自己"改前的 veryfast 版本"比。

---

## 第四轮调整（2026-09-21）：推广到 NVENC（NVIDIA 显卡）文件夹

### 触发原因

用户要求把前三轮定下的量化策略也用到用 NVIDIA 显卡压制的文件夹。但 NVENC（`hevc_nvenc`/`h264_nvenc`）和 libx265 是完全不同的编码器实现，`-x265-params aq-mode=3:aq-strength=0.8` 这种 libx265 专属语法 NVENC 根本不认，不能照搬——这一轮做的是"把策略的目标翻译成 NVENC 自己的参数"，不是复制语法。

### 技术差异核实

- **10bit**：NVENC 真 10bit 要用 `-pix_fmt p010le`（不是 x265 的 `yuv420p10le`），配合已有的 `-profile:v main10`。查证社区反馈，这个参数在部分驱动/滤镜链组合下可能报错——风险比 libx265 那边高，已告知用户需要自己实测。
- **AQ/防色带**：NVENC 没有 x265 的"aq-mode 3 暗部防色带"专用模式，只有通用的 `-spatial-aq 1 -aq-strength N`（1~15，默认8）+ `-temporal-aq`，NVIDIA 官方文档只说这是通用感知质量优化（"low complexity flat regions...extra bits are allocated"），不是官方认证的防色带方案。已和用户确认仍然开启，作为最接近的类比方案：`-spatial-aq 1 -aq-strength 8`（用 NVIDIA 官方默认强度）。
- **`2压 H264 8bit NVENC`**：文件夹名字明确写着"8bit"，且 H.264 的 10bit(High10) 硬件解码支持很差，已和用户确认本轮**排除**，完全不动。

### 范围与文件类型分类

7 个 `hevc_nvenc` 文件夹 + `00_TEMPLATE_MASTER` 的 `nvenc_cq23.xml` 母版，共 74 个文件。其中 `2压 H265 10bit NVENC` / `2压 H265 10bit NVENCfor720pXiaoMiTv` 两个文件夹内部混合了 4 种不同的码率控制模式，不能用同一个正则统一处理，按类型分开：

| 类型 | 文件数 | 特征 | 处理方式 |
|---|---|---|---|
| A：标准 CQ 档位 | 68 | `-cq NN -qmin X -qmax Y` | 加 `pix_fmt p010le`；qmin统一收敛为12，去掉qmax；加 `spatial-aq 1 -aq-strength 8` |
| B：CQP 固定QP | 2 | `-qp 25`，无qmin/qmax | 只加 `pix_fmt p010le` + AQ，不碰qmin/qmax（固定QP下qmin/qmax不生效） |
| C：无损CQP | 2 | `-qp 0` | 只加 `pix_fmt p010le`，不加AQ/qmin/qmax（无损没有"重新分配码率"的概念） |
| D：VBR码率模式 | 2 | `-b:v 3800k -shanarcmode variable -qmin 17` | 加 `pix_fmt p010le`；qmin收敛为12；加AQ |

全部类型统一去掉 `-shanakeyframe 10`（类型C本来就没有，不用处理）。

### 执行结果

用分类型的 `sed -E` 正则完成替换，验证：
- 74/74 文件含 `pix_fmt p010le`。
- 72/74 文件含 `spatial-aq 1 -aq-strength 8`（正确排除了2个无损CQP文件）。
- 70/74 文件含 `qmin 12`（68个类型A + 2个类型D，正确排除了2个CQP固定QP文件和2个无损CQP文件）。
- 全范围无残留 `shanakeyframe`。
- `2压 H264 8bit NVENC` 确认 0 处改动。
- 两个"2压"文件夹的全部 8 个文件逐一核对（不是抽样），确认类型分类和改法一一对应正确。

### 待用户验证

1. **`-pix_fmt p010le` 兼容性必须用户自己实测**：在 ShanaEncoder 里实际跑 1~2 个典型文件（含 `2压` 系列的缩放/去隔行滤镜链），确认不报错。如果某个文件夹报错，把该文件夹的 `-pix_fmt p010le` 撤回即可，`spatial-aq`/`qmin`/去keyframe 部分不受影响。
2. 暗部/皮肤渐变画面的 `spatial-aq` 效果肉眼对比（预期效果弱于 CPU 那边的 `aq-mode 3`，因为 NVENC 没有官方认证的暗部偏置机制）。
3. `ffprobe` 检查 `pix_fmt=p010le`、`profile=Main 10`。

---

## 综合总结（2026-09-21）：这套配置适合什么场景 + 关键知识点回顾

### 为什么这套参数适合"把已压缩过的 H.264 源转成 H.265 10bit"这类场景

用户后续把整个方案转给 Gemini 做了一轮总结评价，评价本身有参考价值，但其中几处表述偏夸大或有一个具体数值需要核实，这里给出核实后的版本，不直接照抄原文：

1. **暗部/皮肤渐变的色带控制**：真 10bit（1024级灰阶，是8bit的4倍精度）+ `aq-mode 3`（x265 官方文档明确定义为"偏向暗部场景防色带"），两者共同作用，确实是当前 x265 生态下针对这类内容（暗光、皮肤渐变）最对症的组合，不是过度设计。
2. **`aq-strength 0.8` 控制体积**：调低 aq-strength 能降低"把 H.264 源里残留的噪点/压缩瑕疵误判为高价值细节"的倾向，这个机制是真实的，但**不是"完美拦截"**——AQ 本身是一种统计意义上的启发式调整，不是针对性的瑕疵检测算法，效果因素材而异。
3. **`qmin 12` 防止体积失控**：这确实是为了避免重蹈第一轮"完全不设qmin/qmax"导致体积暴涨17%的覆辙，但**目前这个新方案（qmin12+aq-mode3）本身还没有经过用户实际重新压制验证**——它是基于 x265 官方文档和 Gemini 两轮建议推导出的方案，"体积涨幅能压到3%~6%"是 Gemini 的预期，不是已验证的结果。压制测试仍然是待办事项（见上方"待用户验证"）。
4. **CRF 25.0 大约相当于 x264 CRF 21~22 的画质** ——这个具体数值**查证后基本站得住脚，但不是精确换算，是一个粗略经验法则**：社区里比较主流的说法是"x265 的 CRF 数值，要比达到同等画质所需的 x264 CRF 数值大约高 4~6"（因为 x265 压缩效率更高，用一个"数字上更松"的CRF依然能省出体积）。反过来算，x265 CRF 25 对应的 x264 画质水平大概在 CRF 19~21 附近，用户引用的"21~22"落在这个区间的边缘，方向是对的，但不同资料给出的具体偏移量差异不小（4~6分不等），不建议当成精确换算公式使用，只能当粗略参考。
5. **`-c:a libfdk_aac -b:a 192k` 音质** ——libfdk_aac 是公认音质最好的开源 AAC 编码器之一，192kbps 双声道对大多数人来说**接近无损、难以分辨**，但严格来说 AAC 本身是有损编码，**不是字面意义上的"无损"**，这里措辞需要更准确一些。
6. **`-tune:v none` 是正确选择**：这条评价是准确的、无需修正——`--tune grain` 会大幅堆码率保留噪点颗粒，`--tune ssim`/`--tune psnr` 会为了刷高某个客观指标分数而牺牲主观观感，两者都不适合这个场景；配合 AQ 调优、保持 `tune none`（不做额外倾向性优化）确实是主流做法。
7. **`-tag:v hvc1` + `-movflags faststart` 兼容性**：这两条也是准确的、无需修正——`hvc1` 标记是 Apple 生态硬解 HEVC MP4 的硬性要求，`faststart` 把索引信息前置能让局域网/NAS播放时不用等下载完就能拖进度条。

### 关键知识点回顾（对话中讲解过的概念，方便以后翻查）

- **色带（Banding）**：本质是连续渐变被迫用太少的量化级数去逼近，导致肉眼能分辨出台阶状边界，不是画面"坏了"，是精度不够的伪影。10bit（1024级）比8bit（256级）能提供细4倍的台阶，是解决色带最根本的手段。
- **YUV420 色度采样**：亮度(Y)信息逐像素精细记录，色度(UV)信息每2×2像素共用一组，因为人眼对亮度变化远比对色彩变化敏感，这样能省大量数据又不明显掉画质。这次改动没有动这部分，一直都是420，只是新加了显式声明位深（10 vs 隐式8）。
- **qmin/qmax**：编码器允许使用的量化精度（QP）范围的下限/上限。qmin=下限=最多能花多少精度（防止某些画面被过度雕琢）；qmax=上限=最少要保留多少精度（防止某些画面被压得太烂）。x265/x264 社区主流建议是不手动锁死这两个值，交给 CRF/AQ 自己判断，除非有具体数据支撑。
- **AQ（自适应量化，Adaptive Quantization）**：让编码器不再对整帧用同一个QP，而是按内容分区调整——`aq-mode` 决定"哪些区域该多给/少给码率"的判断逻辑（x265 的 `aq-mode 3` 专门偏向暗部防色带；NVENC 只有通用的 spatial-aq，没有暗部专属逻辑），`aq-strength` 决定"差异化的幅度有多大"。
- **关键帧/GOP（shanakeyframe）**：控制视频里每隔多少帧强制插入一张完整画面。间隔越密，拖动播放进度条越流畅精细，但文件越大；间隔越松（x265/NVENC 默认最多250帧+场景切换自动插入），文件越小但拖动手感越粗糙。这次改动统一去掉了原来"每10帧强制一个关键帧"的激进设置。
- **硬字幕 vs 软字幕**：硬字幕是把文字烧录进画面像素里，没法关闭/切换；软字幕是把文字当成独立的一条"字幕流"跟画面分开存放，播放器能开关/切换语言。MP4 只能通过 `mov_text` 存非常简陋的软字幕（不支持 ASS 复杂样式），要保留这批预设 `<substyle>` 定义的完整字体/颜色/描边样式当软字幕，必须用 MKV 容器。这批预设目前统一用硬字幕（`-vf "shanasubtitle=1"` + `-sn` 禁用字幕流）。
- **NVENC vs libx265 的参数不通用**：两者是完全不同的编码器实现。x265 的 `-x265-params aq-mode=3:aq-strength=0.8`、真10bit的 `yuv420p10le` 这些语法，在 NVENC 上要分别翻译成 `-spatial-aq 1 -aq-strength 8`、`p010le`——同样的设计目标，不同的具体实现，不能跨编码器照抄参数。

### 仍然悬而未决、需要用户自己验证的事项（汇总自前四轮）

1. CPU（libx265）批量改动后的真实压制效果——体积/画质对比、暗部色带肉眼对比、PotPlayer 拖动手感。
2. NVENC 批量改动后 `-pix_fmt p010le` 的驱动/滤镜链兼容性——有报错风险，需要实测确认。
3. 第二/三轮的 `qmin12 + aq-mode3` 方案，是否真的能把第一轮"完全不设qmin/qmax"导致的 +17% 体积涨幅压回预期的 +3%~+6% 区间——这是 Gemini 的预期，还没有实测数据验证。
