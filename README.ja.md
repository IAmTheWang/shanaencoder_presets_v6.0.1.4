[简体中文](README.md) | [English](README.en.md) | **日本語**

# ShanaEncoder プリセット集

[ShanaEncoder](https://shana.pe.kr/shanaencoder) 用の動画エンコード XML プリセット設定集です。

## プロジェクトスキル（Claude Code Skills）

このプロジェクトにはプリセット管理用の Claude Code スキルが組み込まれています。Claude Code セッション内でスラッシュコマンドを入力するだけで呼び出せます。

### `/new-preset` — 新しいプリセットを作成

既存の `.xml` プリセットファイルをテンプレートにして、新しいプリセットファイルを生成します。

**対応内容：**
- `SameAudio` バリアント — 音声の再エンコードを `-c:a copy` に置き換え
- `Scene` バリアント — シーン調整済みの x265 パラメータを追加
- `TransTo720p` / `TransTo1080p` — スケールフィルタを追加
- カスタム — 指定した任意のパラメータ変更

**プロンプト例：**
- 「0cpuQualityGpt5.3CodexMedium の 20 番プリセットの SameAudio 版を作成して」
- 「CRF 22 の Medium プリセットを新規作成して」

---

### `/audit-presets` — 全プリセットの整合性を監査

すべての `.xml` ファイルをスキャンし、重大度別に問題を報告します。

| レベル | 例 |
|-------|---------|
| ❌ ERROR | `SameAudio` フォルダなのに音声が `-c:a copy` になっていない |
| ⚠️ WARNING | `-movflags faststart` が付いていない |
| ℹ️ INFO | `0cpuQuality*` はあるのに対応する `*SameAudio` フォルダがない |

報告後、WARNING レベルの問題を一括自動修正するか確認します。

**プロンプト例：**
- 「すべてのプリセットの整合性をチェックして」
- 「プリセットを監査して、規約に合わないファイルを見つけて」

---

## フォルダ構成

フォルダ構成の全体像と命名規則は [CLAUDE.md](CLAUDE.md) を参照してください。
