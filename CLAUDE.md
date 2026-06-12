# WatchApp20241202 - 仕様書

## アプリ概要
デジタル時計表示と音声機能（予報音・時報音・時刻読み上げ）のシンプルなiOSアプリ。

## ファイル構成

| ファイル | 役割 |
|---------|------|
| `ContentView.swift` | 画面のルート（DigitalClockView を呼び出すのみ） |
| `DigitalClockView.swift` | デジタル時計の表示のみ（ClockManager を監視して時刻を表示） |
| `ClockManager.swift` | 常駐シングルトン。タイマー・音声再生（予報音・時報音・読み上げ）・ダッキング制御を担う |
| `AudioSessionManager.swift` | 常駐シングルトン。オーディオセッション設定・無音常駐・ダッキングの開始/終了を担う |
| `SoundConfig.swift` | 音声設定の定義（UserDefaults 対応済み） |
| `DisplayConfig.swift` | 表示設定・ClockStyle の定義（UserDefaults 対応済み） |

## 音声仕様

| タイミング | 種別 | SystemSoundID |
|-----------|------|--------------|
| 毎分57・58・59秒 | 予報音 | 1340（デフォルト） |
| 毎分00秒 | 時報音 | 1167（デフォルト） |
| 時報音終了後 | 時刻読み上げ | AVSpeechSynthesizer |

### 読み上げ形式
- 例：「7時58分です」／正時は「9時ちょうどです」

### SoundConfig（UserDefaults キー）
| 設定項目 | キー | デフォルト値 |
|---------|------|------------|
| 予報音 ID | `forecastSoundID` | 1340 |
| 時報音 ID | `timeSoundID` | 1167 |
| 予報開始秒数 | `forecastLeadSeconds` | 3（57秒から） |

## バックグラウンド仕様

他アプリ使用中・画面ロック中でも、予報音・時報音・時刻読み上げを鳴らす（ナビ音声のような挙動）。

### 仕組み
- `Info.plist` の `UIBackgroundModes` に `audio` を設定（バックグラウンドオーディオ権限）
- `AudioSessionManager` が**人にはほぼ聞こえない極小トーン（20Hz）をループ再生**し、アプリの凍結を防いで常駐させる（→ タイマーが背面でも動き続ける）
- オーディオセッションは `.playback` / `.mixWithOthers`（他アプリと共存）
- `ClockManager` のタイマー（`RunLoop.common`）が背面でも毎秒動作し、音声を再生

### 注意点（既知の仕様）
- 読み上げ用 `AVSpeechSynthesizer` は **`usesApplicationAudioSession = false`** にする（常駐プレイヤーと同じセッションを共有すると背面で発話が固まるため）
- アプリを**完全終了（アプリスイッチャーでスワイプ）**すると鳴らない（バックグラウンド＝ホームに戻る/ロックは可）

### ダッキング（他アプリ音量を下げる）
- アナウンス中だけ `.duckOthers` を `setActive(true)` で発動し、読み上げ完了（`AVSpeechSynthesizerDelegate` の `didFinish`）で解除
- 発動中は常駐トーンの音量を上げ、予報音の合間も下げ続けてゆらぎを抑える
- ダッキング開始は予報音の1秒前に前倒し（重い `setActive` で予報音の間隔がズレるのを防ぐ）

## 表示仕様

### ClockStyle
| 値 | 説明 |
|----|------|
| `standard` | 標準（現在実装済み） |
| `sevenSegment` | 7セグ風（将来実装） |
| `nixieTube` | ニキシー管風（将来実装） |

### DisplayConfig（UserDefaults キー）
| 設定項目 | キー | デフォルト値 |
|---------|------|------------|
| フォントサイズ | `clockFontSize` | 40 |
| 表示スタイル | `clockStyle` | `standard` |
| 文字色 | ※UserDefaults非対応 | `.primary`（固定） |

## 将来の拡張予定
- 設定画面からの音声ID・予報秒数の変更
- 設定画面からの表示スタイル変更（色・サイズ・7セグ・ニキシー管風など）
- Color の UserDefaults 対応（hex 文字列での保存）

※ バックグラウンド対応は実装済み（「バックグラウンド仕様」を参照）。当初の通知方式（UNUserNotificationCenter）ではなく、常時オーディオ方式を採用。
