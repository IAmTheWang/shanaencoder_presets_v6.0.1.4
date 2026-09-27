# Parameter Notes / 参数说明

## `-movflags faststart`

- English: Move MP4 metadata (`moov`) to the beginning of the file for faster online start and seeking.
- 中文: 将 MP4 的 `moov` 元数据前置，提升在线播放起播和拖动体验。

## `-fps_mode cfr`

- English: Force constant frame rate output. Use for editing workflows or compatibility with older players.
- 中文: 强制固定帧率。适用于剪辑流程或老旧播放器兼容。
- English: For variable-frame-rate sources, this may duplicate/drop frames and may increase size.
- 中文: 对可变帧率源，可能补帧/丢帧，并可能增大体积。
- English: Was enabled by default repo-wide from 2026-09-21 (round 6, merge-safety policy) through 2026-09-27, then reverted at the user's request — the size/frame-duplication cost was judged not worth it in practice. Removed from every preset again. See `PRESET_POLICY.md`.
- 中文: 2026-09-21（第六轮，合并安全策略）到 2026-09-27 期间曾在全仓库默认启用，之后应用户要求撤销——实际使用中认为补帧/体积代价不值得。已从全部预设中再次移除，详见 `PRESET_POLICY.md`。

## `-assforcestyle` / `<substyle>`

- English: `-assforcestyle` is a ShanaEncoder-internal token (not a real FFmpeg flag) appended to the end of `<encparamBox>`. When present, it forces the `<substyle>` tag's Format:/Style: line onto every style in the burned-in `.ass` subtitle (like FFmpeg's `subtitles=...:force_style=...`), overriding whatever font/size the `.ass` file itself defines. When absent, `<substyle>` is inert/decorative and the `.ass` file's own `[V4+ Styles]` is used untouched.
- 中文: `-assforcestyle` 是 ShanaEncoder 内部标记（不是真正的 FFmpeg 参数），追加在 `<encparamBox>` 末尾。存在时会把 `<substyle>` 里的 Format:/Style: 行强制套用到烧录的 `.ass` 字幕的每个样式上（类似 FFmpeg 的 `subtitles=...:force_style=...`），覆盖 `.ass` 文件自己定义的字体/字号。不存在时 `<substyle>` 是摆设，烧字幕效果完全取决于 `.ass` 自己的 `[V4+ Styles]`。
- English: As of 2026-09-27 (round 8) no active preset in this repo has `-assforcestyle` — it was removed from all 249 files that had it, after a real case where its generic 18pt override made a burned subtitle much smaller than the user's actual 86–128pt `.ass` styling. See `PRESET_POLICY.md` and `design_documents/2026-09-27-remove-assforcestyle.md`.
- 中文: 2026-09-27 起（第八轮）仓库里没有任何现役预设带 `-assforcestyle`——此前带着这个 token 的 249 个文件已全部移除，起因是一次真实案例：通用的 18pt 强制覆盖，让烧出来的字幕比用户实际 `.ass` 里定义的 86–128pt 小了好几倍。详见 `PRESET_POLICY.md` 与 `design_documents/2026-09-27-remove-assforcestyle.md`。

## `-preset veryfast` vs `-preset fast`

- English: `fast` spends more CPU time on better compression decisions; it is usually slower but can produce smaller files at similar visual quality.
- 中文: `fast` 会花更多 CPU 时间做更精细压缩决策；通常更慢，但同等观感下体积更小。
- English: Typical real-world range: slower by about 35% to 65%, size reduced by about 4% to 12%.
- 中文: 常见实测范围：速度慢约 35% 到 65%，体积小约 4% 到 12%。

