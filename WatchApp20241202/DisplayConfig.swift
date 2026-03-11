//
//  DisplayConfig.swift

import SwiftUI

// 時計の表示スタイル（将来の設定画面から選択可能にする）
enum ClockStyle: String {
    case standard     = "standard"      // 標準
    case sevenSegment = "sevenSegment"  // 7セグ風
    case nixieTube    = "nixieTube"     // ニキシー管風
}

// 表示設定（UserDefaults から読み込み、設定画面からの変更に対応）
// 注意: Color は UserDefaults に直接保存できないため、現時点ではデフォルト値固定
enum DisplayConfig {

    // UserDefaults のキー
    private static let fontSizeKey = "clockFontSize"
    private static let styleKey    = "clockStyle"

    // デフォルト値
    static let defaultFontSize: CGFloat      = 40
    static let defaultFontWeight: Font.Weight = .bold
    static let defaultColor: Color            = .primary
    static let defaultStyle: ClockStyle       = .standard

    // フォントサイズ（UserDefaults に保存値があればそれを使用）
    static var fontSize: CGFloat {
        let saved = UserDefaults.standard.double(forKey: fontSizeKey)
        return saved != 0 ? CGFloat(saved) : defaultFontSize
    }

    // 表示スタイル（UserDefaults に保存値があればそれを使用）
    static var style: ClockStyle {
        let saved = UserDefaults.standard.string(forKey: styleKey)
        return ClockStyle(rawValue: saved ?? "") ?? defaultStyle
    }
}
