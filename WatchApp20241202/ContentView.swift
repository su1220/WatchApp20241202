//
//  ContentView.swift


import SwiftUI

struct AnalogClockView: View {
    @State private var currentTime = Date()
    @State private var totalSeconds: Int = 0
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    // 時間に基づいて角度を計算
    private var hourAngle: Double {
        let hours = Double(calendar.component(.hour, from: currentTime) % 12)
        let minutes = Double(calendar.component(.minute, from: currentTime))
        return (hours * 30) + (minutes / 60 * 30) // 1時間30度 + 分に応じた補正
    }
    
    private var minuteAngle: Double {
        let minutes = Double(calendar.component(.minute, from: currentTime))
        let seconds = Double(calendar.component(.second, from: currentTime))
        return (minutes * 6) + (seconds / 60 * 6) // 1分6度 + 秒に応じた補正
    }
    
    private var secondAngle: Double {
        return Double(totalSeconds) * 6 // 累積秒数に基づいて計算
    }
    
    var body: some View {
            ZStack {
                // 時計の文字盤
                ForEach(0..<12) { tick in
                    Rectangle()
                        .fill(Color.primary)
                        .frame(width: 2, height: 10)
                        .offset(y: -90)
                        .rotationEffect(.degrees(Double(tick) * 30))
                }
                
                // 時針
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: 4, height: 50)
                    .offset(y: -25)
                    .rotationEffect(.degrees(hourAngle))
                    .animation(.easeInOut(duration: 0.5), value: hourAngle)
                
                // 分針
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: 3, height: 70)
                    .offset(y: -35)
                    .rotationEffect(.degrees(minuteAngle))
                    .animation(.easeInOut(duration: 0.5), value: minuteAngle)
                
                // 秒針
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 2, height: 90)
                    .offset(y: -45)
                    .rotationEffect(.degrees(secondAngle))
                    .animation(.linear(duration: 1), value: secondAngle)
                
                // 中心の円
                Circle()
                    .fill(Color.primary)
                    .frame(width: 10, height: 10)
            }
            .frame(width: 200, height: 200)
            .onAppear {
                // 初期化
                let initialSeconds = calendar.component(.hour, from: currentTime) * 3600 +
                                     calendar.component(.minute, from: currentTime) * 60 +
                                     calendar.component(.second, from: currentTime)
                totalSeconds = initialSeconds
                
                // タイマーで秒単位の更新
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    self.currentTime = Date()
                    self.totalSeconds += 1 // 秒を累積
                    
                    //安全のため、1日の秒数を超えた場合に値をリセット
                    if self.totalSeconds >= 86400 {
                        self.totalSeconds = 0
                    }
                }
        }
    }
}

struct ContentView: View {
    var body: some View {
        AnalogClockView()
            .padding()
    }
}

#Preview {
    ContentView()
}
