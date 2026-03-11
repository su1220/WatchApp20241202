# WatchApp20241202 - 仕様書

## アプリ概要
デジタル時計表示と音声機能（予報音・時報音・時刻読み上げ）のシンプルなiOSアプリ。

## 画面構成
- アナログ時計なし
- デジタル時計のみ表示

## 音声仕様
| タイミング | 種別 | SystemSoundID |
|-----------|------|--------------|
| 毎分57・58・59秒 | 予報音 | 1340 |
| 毎分00秒 | 時報音 | 1167 |
| 時報音終了後 | 時刻読み上げ | AVSpeechSynthesizer |

### 読み上げ形式
- 例：「7時58分です」
- `AVSpeechSynthesizer` を使用

## 表示仕様
`DisplayConfig` enum で一元管理（将来の UserDefaults 化・設定画面対応を前提とした設計）

```swift
enum DisplayConfig {
    static let fontSize: CGFloat = 40
    static let fontWeight: Font.Weight = .bold
    static let color: Color = .primary
    static let style: ClockStyle = .standard
}

enum ClockStyle {
    case standard       // 標準
    case sevenSegment   // 7セグ風
    case nixieTube      // ニキシー管風
}
```
- 現時点では `standard` のみ実装
- スタイル追加時は `switch` で分岐するだけで対応可能

## 音声設定
`SoundConfig` enum で一元管理（将来の UserDefaults 化・設定画面対応を前提とした設計）

```swift
enum SoundConfig {
    static let forecastLeadSeconds = 3
    static let forecastSoundID: SystemSoundID = 1340
    static let timeSoundID: SystemSoundID = 1167
}
```

## 将来の拡張予定
- 設定画面からの表示スタイル変更（色・サイズ・7セグ・ニキシー管風など）
- 設定画面からの音声ON/OFF・音量調整
- バックグラウンド対応（UNUserNotificationCenter を使用予定）
