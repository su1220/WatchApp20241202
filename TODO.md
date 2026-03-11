# TODO - 今回の作業

## Phase 1: AnalogFaceView.swift の削除
- [x] `WatchApp20241202/AnalogFaceView.swift` を削除
- [x] `project.pbxproj` から参照を4箇所除去
  - PBXBuildFile セクション
  - PBXFileReference セクション
  - PBXGroup セクション
  - PBXSourcesBuildPhase セクション

## Phase 2: ContentView.swift の改修
- [x] `AnalogClockView` → `DigitalClockView` にリネーム
- [x] アナログ時計関連コードを削除
- [x] `AudioToolbox` + `AVFoundation` をインポート
- [x] `SoundConfig` enum を追加（forecastSoundID: 1340、timeSoundID: 1167）
- [x] `DisplayConfig` enum と `ClockStyle` enum を追加
- [x] 音声再生ロジックを実装
  - 57・58・59秒：予報音（ID: 1340）
  - 00秒：時報音（ID: 1167）
  - 時報音終了後：`AVSpeechSynthesizer` で「〇時〇〇分です」を読み上げ
- [x] デジタル時計の表示を `DisplayConfig` を使って実装

## Phase 3: ファイル分割リファクタリング
- [x] `SoundConfig.swift` を新規作成（UserDefaults 対応）
- [x] `DisplayConfig.swift` を新規作成（UserDefaults 対応 + ClockStyle）
- [x] `DigitalClockView.swift` を新規作成
- [x] `ContentView.swift` をルートのみに簡略化
- [x] `project.pbxproj` に新ファイルの参照を追加（4箇所）
- [x] `CLAUDE.md`・`TODO.md` を更新
