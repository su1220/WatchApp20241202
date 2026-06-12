//
//  DigitalClockView.swift

import SwiftUI

struct DigitalClockView: View {
    // 時刻と音声は ClockManager が一括管理する。View は表示に専念する
    @ObservedObject private var clock = ClockManager.shared

    // デジタル時計用のフォーマット（時：分：秒）
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: clock.currentTime)
    }

    var body: some View {
        Text(formattedTime)
            .font(.system(size: DisplayConfig.fontSize,
                          weight: DisplayConfig.defaultFontWeight,
                          design: .monospaced))
            .foregroundColor(DisplayConfig.defaultColor)
    }
}

#Preview {
    DigitalClockView()
}
