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
