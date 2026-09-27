# 撤销合并安全策略：全仓库移除 `-fps_mode cfr`

## 生效日期

- `2026-09-27`（第七轮，撤销第六轮）

## 背景

第六轮（`design_documents/2026-09-21-merge-safety-fps-mode-cfr.md`）为解决一次真实的合并音画错位问题，把 `-fps_mode cfr` 加到了全仓库现役压制预设里。用了一段时间后，用户认为这个参数带来的补帧/体积代价在日常使用中不划算，要求撤销，把这个参数从所有预设里再次去掉。

## 决策

全仓库移除 `-fps_mode cfr`，`PRESET_POLICY.md` 全局策略第 1 条恢复为"不强制固定帧率"。第六轮的根因分析、决策理由本身没有错——只是用户在权衡"合并正确性 vs. 补帧/体积代价"后，选择接受偶发的合并音画错位风险，换取不给正常素材做不必要的补帧。

## 范围

移除全部当前带有 `-fps_mode cfr` 的 XML 文件里的这个 token，与第六轮加入时的范围一致（全部会重新编码视频的现役预设），另外还包含第六轮之后新增的、以及本仓库里 gitignore 的 ShanaEncoder 出厂预设文件夹（`Apple`/`Sony`/`Samsung`/`LG`/`Iriver`/`HTC`/`Cowon`/`(Convert)/*` 等）——这些文件夹不在 git 版本控制范围内，但物理上也被第六轮的批量修改覆盖过，本次一并清理，保持磁盘上的实际预设行为与仓库策略一致。

**不涉及**（沿用第六轮排除范围，因为这些文件本来就没有这个参数）：`0压 视频复制流`、`0压 音频复制流`、`2压 音频预设`、`舟 5.X原预设`、`舟 6.0原预设`。

## 执行方式

用一次性 `sed` 命令直接跑：

```bash
grep -rlZ -- '-fps_mode cfr' --include='*.xml' . 2>/dev/null \
  | tr '\0' '\n' | xargs -d '\n' sed -i 's/ -fps_mode cfr//g'
```

这条命令按字面 token 匹配（含前导空格），不依赖行内位置，因此不需要像第六轮那样对"无损 CQP"那 3 个单行 `<encparamBox>` 文件单独处理——它们的 `-fps_mode cfr` 后面还跟着 `-c:a copy` 等其他参数，普通的"删到行尾"策略在第六轮加入时是安全的，但反过来删除时如果只处理行尾模式会漏掉这 3 个文件；用 token 级替换一次性覆盖了所有形态。

执行后确认 `--include='*.xml'` 范围内 `-fps_mode cfr` 剩余匹配数为 0，仅文档文件（`CLAUDE.md`/`PRESET_POLICY.md`/两份设计文档/`parameter-notes.md`/`SCENE_PROFILES.md`/`audit-presets/SKILL.md`）里还保留字面提及，用于记录历史。

## 已知取舍

回到第六轮之前的状态：对于源文件本身视频轨/音频轨时长不一致的素材（例如录制时 CPU/GPU 被高负载进程抢占导致丢帧），合并多段这类素材时可能重新出现音画错位，且不会被这里的预设自动纠正。如果未来再次遇到类似问题，可以参考 `design_documents/2026-09-21-merge-safety-fps-mode-cfr.md` 的根因分析，在需要合并的那次操作前，给相关预设临时加回 `-fps_mode cfr`（不建议直接改回全仓库现役预设，除非再次确认这是普遍需求）。

## 配套文档更新

- `PRESET_POLICY.md`：全局策略第 1 条改回"不强制固定帧率"；"合并安全（CFR）策略"小节保留作为历史记录，末尾追加撤销说明。
- `CLAUDE.md`：在round 6 说明段落后追加 round 7 撤销说明。
- `skills/shanaencoder-preset-maintainer/references/parameter-notes.md`：`-fps_mode cfr` 条目更新为"曾默认开启，现已撤销"。
- `.claude/skills/audit-presets/SKILL.md`：Step 2 检查表移除 `fps_mode` 一行；Step 5"可自动修复问题"列表移除对应条目。
- `1cpuQualityGpt5.3CodexFast/SCENE_PROFILES.md`、`0cpuQualityGpt5.3CodexMedium/SCENE_PROFILES.md`、`0cpuQualityGpt5.3CodexMediumSameAudio/SCENE_PROFILES.md`：从每个场景变体的"关键滤镜/参数"列移除 `-fps_mode cfr`。

## 验证

- 全仓库 `grep -rl -- '-fps_mode cfr' --include='*.xml' .` 结果为空。
- 抽查此前第六轮特殊处理过的 3 个"无损 CQP"单行 `<encparamBox>` 文件，确认 `-fps_mode cfr` 已删除且相邻参数（如 `-c:a copy`）间距正常，没有残留双空格或参数错位。
- 抽查若干不同编码器（libx265 CPU / hevc_nvenc / hevc_qsv / libx264 / h264_nvenc）的 diff，确认只删除了 `-fps_mode cfr` 这一个 token，其他参数（`qmin`/`qmax`/AQ/CRF/faststart 等）未受影响。
