# Parameter Notes / 参数说明

## `-movflags faststart`

- English: Move MP4 metadata (`moov`) to the beginning of the file for faster online start and seeking.
- 中文: 将 MP4 的 `moov` 元数据前置，提升在线播放起播和拖动体验。

## `-fps_mode cfr`

- English: Force constant frame rate output. Use for editing workflows or compatibility with older players.
- 中文: 强制固定帧率。适用于剪辑流程或老旧播放器兼容。
- English: For variable-frame-rate sources, this may duplicate/drop frames and may increase size.
- 中文: 对可变帧率源，可能补帧/丢帧，并可能增大体积。
- English: As of 2026-09-21 this is enabled by default across most active re-encode presets in this repo (merge-safety policy — prevents audio/video drift from accumulating when concatenating multiple source files). See `PRESET_POLICY.md`. Treat it as opt-out, not opt-in.
- 中文: 2026-09-21 起该参数已在仓库大部分现役压制预设中默认启用（合并安全策略——防止多段素材拼接时音画偏差累积），详见 `PRESET_POLICY.md`。现在是默认开启、非默认关闭。

## `-preset veryfast` vs `-preset fast`

- English: `fast` spends more CPU time on better compression decisions; it is usually slower but can produce smaller files at similar visual quality.
- 中文: `fast` 会花更多 CPU 时间做更精细压缩决策；通常更慢，但同等观感下体积更小。
- English: Typical real-world range: slower by about 35% to 65%, size reduced by about 4% to 12%.
- 中文: 常见实测范围：速度慢约 35% 到 65%，体积小约 4% 到 12%。

