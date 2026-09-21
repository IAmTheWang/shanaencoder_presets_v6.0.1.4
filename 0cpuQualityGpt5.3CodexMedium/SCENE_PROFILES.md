# Scene Profiles (x265 CPU Medium)

这是一组基于 `24qualityCpuMedium.xml` 衍生的 场景化分支预设，遵循“不覆盖旧预设”的原则，仅新增文件用于 A/B。

## 设计目标

- 体积优先：尽量减少码率峰值与输出体积
- 均衡优先：在体积与观感之间做温和折中
- 细节优先：提升复杂场景保留，接受更大体积
- 原音优先：保持音频不重编码

## 预设说明

| 文件名 | 适用素材 | 目标分辨率 | 质量档位 | 关键滤镜/参数 |
|---|---|---|---|---|
| `24qualityCpuMediumScene_FreeCRF.xml` | 常规场景 | 720p/1080p | CRF 24 | `-vf "shanasubtitle=1"`，`-qmin 17 -qmax 36`，`-fps_mode cfr` |
| `24qualityCpuMediumScene_BalancedGuard.xml` | 常规场景（主推） | 720p/1080p | CRF 24（均衡） | `-vf "shanasubtitle=1"`，`-qmin 17 -qmax 36`，`-fps_mode cfr` |
| `26qualityCpuMediumScene_SizeFirstGuard.xml` | 高噪点/长时长场景 | 720p/1080p | CRF 26（体积优先） | `-vf "shanasubtitle=1"`，`-qmin 18 -qmax 40`，`-fps_mode cfr` |
| `23qualityCpuMediumScene_DetailGuard.xml` | 高运动/暗部细节场景 | 1080p | CRF 23（细节优先） | `-vf "shanasubtitle=1"`，`-qmin 16 -qmax 34`，`-fps_mode cfr` |
| `24qualityCpuMediumScene_BalancedGuardSameAudio.xml` | 音频已可用场景 | 720p/1080p | CRF 24（均衡） | `-vf "shanasubtitle=1"`，`-qmin 17 -qmax 36`，`-c:a copy`，`-fps_mode cfr` |

> 注：本表 `-qmin`/`-qmax` 列的数值是历史值，未跟上 2026-09-21 生效的统一量化策略（`qmin 12`、无 `qmax`）；这是本次合并安全改动之外的既有文档遗留问题，未在本次一并修正。

## 使用建议

1. 先做 3~5 分钟样本 A/B，再批量应用。
2. 如果输出大于输入，优先从 `24` 升到 `26`，再观察观感。
3. 如果暗部出现明显块感，先从 `26` 回到 `24`，或把 `qmax` 从 `40` 收紧到 `36`。

