//
//  AnalogFaceView.swift


import SwiftUI

struct AnalogFaceView: View {
    let hourAngle: Double
    let minuteAngle: Double
    let secondAngle: Double

    private let clockSize: CGFloat = 280
    private let radius: CGFloat = 130

    var body: some View {
        ZStack {
            // 文字盤の背景
            Circle()
                .fill(Color(.systemBackground))
                .frame(width: clockSize, height: clockSize)
                .shadow(color: .gray.opacity(0.4), radius: 8, x: 0, y: 4)

            // 外周のベゼル
            Circle()
                .stroke(Color.primary.opacity(0.2), lineWidth: 4)
                .frame(width: clockSize, height: clockSize)

            // 分の目盛り（60本）
            ForEach(0..<60) { tick in
                let isHourMark = tick % 5 == 0
                Rectangle()
                    .fill(Color.primary.opacity(isHourMark ? 0.8 : 0.3))
                    .frame(width: isHourMark ? 2.5 : 1, height: isHourMark ? 14 : 8)
                    .offset(y: -(radius - 10))
                    .rotationEffect(.degrees(Double(tick) * 6))
            }

            // 時計の文字盤の数字（1〜12）
            ForEach(1...12, id: \.self) { number in
                Text("\(number)")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.primary)
                    .rotationEffect(.degrees(-Double(number) * 30))
                    .offset(y: -(radius - 32))
                    .rotationEffect(.degrees(Double(number) * 30))
            }

            // 時針
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.primary)
                .frame(width: 5, height: 60)
                .offset(y: -30)
                .rotationEffect(.degrees(hourAngle))
                .animation(.easeInOut(duration: 0.5), value: hourAngle)

            // 分針
            RoundedRectangle(cornerRadius: 1.5)
                .fill(Color.primary)
                .frame(width: 3.5, height: 85)
                .offset(y: -42.5)
                .rotationEffect(.degrees(minuteAngle))
                .animation(.easeInOut(duration: 0.3), value: minuteAngle)

            // 秒針
            Rectangle()
                .fill(Color.red)
                .frame(width: 1.5, height: 100)
                .offset(y: -40)
                .rotationEffect(.degrees(secondAngle))
                .animation(.linear(duration: 1), value: secondAngle)

            // 秒針のカウンターウェイト（反対側の短い部分）
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)

            // 中心のピン
            Circle()
                .fill(Color.primary)
                .frame(width: 12, height: 12)

            Circle()
                .fill(Color.red)
                .frame(width: 5, height: 5)
        }
        .frame(width: clockSize, height: clockSize)
    }
}

#Preview {
    AnalogFaceView(hourAngle: 60, minuteAngle: 30, secondAngle: 120)
}
