# WatchApp20241202 - 仕様書

## アプリ概要
デジタル時計表示と音声機能（予報音・時報音・時刻読み上げ）のシンプルなiOSアプリ。

## ファイル構成

| ファイル | 役割 |
|---------|------|
| `ContentView.swift` | 画面のルート（DigitalClockView を呼び出すのみ） |
| `DigitalClockView.swift` | デジタル時計の表示・タイマー・音声再生ロジック |
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
- バックグラウンド対応（UNUserNotificationCenter を使用予定）
