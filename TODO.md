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
  - `totalSeconds`、`calendar`、各角度計算プロパティ
  - `AnalogFaceView()` の呼び出し
- [x] `AudioToolbox` + `AVFoundation` をインポート
- [x] `SoundConfig` enum を追加（forecastSoundID: 1340、timeSoundID: 1167）
- [x] `DisplayConfig` enum と `ClockStyle` enum を追加
- [x] 音声再生ロジックを実装
  - 57・58・59秒：予報音（ID: 1340）
  - 00秒：時報音（ID: 1167）
  - 時報音終了後：`AVSpeechSynthesizer` で「〇時〇〇分です」を読み上げ
- [x] デジタル時計の表示を `DisplayConfig` を使って実装
