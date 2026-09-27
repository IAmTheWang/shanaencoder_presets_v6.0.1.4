# 字幕烧录不再强制覆盖 ASS 自带样式：移除 `-assforcestyle`

## 生效日期

- `2026-09-27`（第八轮）

## 背景

用户用 `nvQuality/26quality.xml` 烧了一份中日双语硬字幕，发现烧出来的字幕肉眼可见偏小，怀疑压制流程有问题，并给出截图对比：截图里的字幕明显比预期小很多。用户原话："这个烧字幕的 为啥把字幕变得这么小啊？直接使用ASS文件自己的样式就好了啊！重新改一下。"，随后进一步明确要求："所有文件夹XML都使用 ASS 自带的字体样式 不要使用样式去主动覆盖ASS的样式。"

## 根因分析

仓库里没有任何文档（`CLAUDE.md`/`PRESET_POLICY.md`/`skills/*`）解释过 `<substyle>` 到底是怎么生效的，只是笼统描述成"ASS subtitle style string"。通过对比全仓库 341 个 XML 文件的 `<encparamBox>` 尾部，发现规律：

- 部分文件夹的 `<encparamBox>` 结尾是 `... -map_chapters -1 -assforcestyle`，即在正常 FFmpeg 参数后面多了一个 `-assforcestyle` token。这不是真正的 FFmpeg 命令行参数，是 ShanaEncoder 自己的内部标记——它告诉程序"烧字幕时，把 `<substyle>` 里的 Format/Style 强制套用到字幕文件的每一个样式上"，效果类似 FFmpeg `subtitles=xxx.ass:force_style='...'`。
- 另一部分文件夹（`2压 H265 10bit NVENC`、`舟 滤镜参考`、多数 legacy/`2压`/`3压` 文件夹）的 `<encparamBox>` 没有这个 token，虽然 XML 里同样写着 `<substyle>`，但从未被实际应用——这些文件夹烧字幕时一直是原样使用 `.ass` 自己的 `[V4+ Styles]`。

也就是说，`<substyle>` 是否生效完全取决于同一个文件的 `<encparamBox>` 里有没有 `-assforcestyle`，而不是 `<substyle>` 本身的内容。

**带 `-assforcestyle` 的文件夹**（249 个文件）：`0cpuQuality*`（含 `Slow`/`SlowSameAudio`/`SameAudio`/`Medium`/`MediumSameAudio`）、`1cpuQuality*`（含 `Gpt5.3Codex`/`CodexFast`/`CodexFastSameAudio`/`CodexFastScene`）、`nvQuality`、`qualityQsv`、`qualitySameAudio`/`qualitySameAudioTransTo1080p`、`qualityTransTo720p`/`qualityTransTo1080p`、`qualityCpuTransTo720p`/`qualityCpuTransTo720pSameAudio`/`qualityCpuTransTo1080p`/`qualityCpuTransTo1080pSameAudio`、`00_TEMPLATE_MASTER` 的 4 个母版。这些文件夹的 `<substyle>` 全部是同一套 `Microsoft YaHei UI, 18pt` 的通用小字号定义。

用户实际使用的 `.ass` 文件（`H:\recodedVideos\9月27日(3).ass` 等）自己定义的字号是 86–128pt（Noto Sans CJK JP/SC Heavy），跟被强制套用的 18pt 相差 4–7 倍，这正是截图里字幕明显偏小的直接原因。

## 决策

移除全部 249 个文件 `<encparamBox>` 里的 `-assforcestyle`，`PRESET_POLICY.md` 新增全局规则第 7 条："字幕烧录不强制覆盖 ASS 自带样式"。`<substyle>` 标签本身不删除——反正不带 `-assforcestyle` 就不会被读取，留着不影响功能，也避免节外生枝改动 XML 结构。

这跟"每个文件夹自己维护差异化字号"是两回事：这次改动不是去调整 18pt 这个数值，而是让所有文件夹统一变回"完全不覆盖，字幕烧录效果 100% 取决于用户自己 `.ass` 文件里怎么定义"——用户自己的双语字幕流程会自己控制字号/字体/描边，预设不应该越俎代庖。

## 执行方式

先确认全部 249 个文件的模式完全一致（`-assforcestyle` 总是紧贴在 `</encparamBox>` 前面，前面必有一个空格，没有例外），然后一次性 sed：

```bash
grep -rlZ -- '-assforcestyle</encparamBox>' --include='*.xml' . \
  | tr '\0' '\n' | xargs -d '\n' sed -i 's/ -assforcestyle<\/encparamBox>/<\/encparamBox>/g'
```

执行后确认全仓库 `.xml` 里 `assforcestyle` 剩余匹配数为 0。

**意外但正确地一并处理了**：`generate_phase1.ps1`（仓库根目录的一次性生成脚本，用来批量生成 `0cpuQualityGpt5.3CodexFastSameAudio`/`qualityQsv`/`3压 快速H265 8bit x265` 三个文件夹最初那批文件）里硬编码的两个 XML 模板字符串本身也带着 `-assforcestyle`。执行 sed 时用了 `-rlZ`（`-Z` 空字符分隔输出）配合 `--include='*.xml'`，GNU grep 3.0 在这个组合下会静默忽略 `--include` 过滤（已用一个最小复现例验证是 grep 本身的行为，不是这个仓库特有的问题），导致 sed 实际上扫描了全仓库而不是只扫 `.xml`，顺带把这个脚本里同样的 `-assforcestyle` 也删掉了。核实后确认这其实是好事——这个脚本如果以后被重新跑一次，本来会重新生成带 `-assforcestyle` 强制覆盖的文件，跟这次改动的目标背道而驰；现在脚本模板和实际预设口径一致了，予以保留，不回退。`.claude/skills/audit-presets/SKILL.md` 的检查表没有涉及 `substyle`/`assforcestyle` 的规则，不需要更新。

**教训**：以后但凡用 `grep -rlZ ... --include=...` 配合 `xargs -d '\n'` 做批量替换，要么去掉 `-Z`（改用换行分隔 + 确认文件名不含换行符），要么先用 `--include` 单独跑一次不带 `-Z` 的 `grep -rl` 确认候选文件列表，再决定要不要用 `-Z` 管道，避免这个过滤被静默吃掉。

## 已知取舍

以后如果又想要"预设自己统一控制字幕大小/字体，不依赖用户 `.ass` 自己的样式"（比如批量处理一堆样式很乱的外部字幕源，想强制拉齐观感），可以参考这次的分析，在需要的预设副本里重新加回 `-assforcestyle`，并把 `<substyle>` 的 `Style:` 行改成想要的字号/字体——不建议直接改回全仓库现役预设，除非再次确认这是普遍需求。

## 配套文档更新

- `PRESET_POLICY.md`：新增全局规则第 7 条。
- `CLAUDE.md`：新增 round 8 changelog 段落；`substyle` 标签的 File Format 说明补充"只在 `-assforcestyle` 存在时才生效"的机制说明。

## 验证

- 全仓库 `grep -rl "assforcestyle" --include='*.xml' .` 结果为空。
- 抽查此前"带 `-assforcestyle`"分组里的几个文件夹（`1cpuQuality`/`nvQuality`/`qualityQsv`/`qualityCpuTransTo1080p`），确认 `-assforcestyle` 已从 `<encparamBox>` 末尾删除，`</encparamBox>` 前紧邻的是 `-map_chapters -1`，没有多余空格或标签错位。
- 端到端验证（烧出来的字幕是否真的变回 `.ass` 自己的大字号）依赖用户用同一份 `.ass` 文件重新跑一次压制手动确认——这一步作为可选的最终确认，不是本次改动落地的硬性前提。
