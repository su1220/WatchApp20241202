//
//  DigitalClockView.swift

import SwiftUI
import AudioToolbox
import AVFoundation

struct DigitalClockView: View {
    @State private var currentTime = Date()
    // AVSpeechSynthesizer は @State で保持し、ビュー再生成時も同一インスタンスを維持する
    @State private var synthesizer = AVSpeechSynthesizer()

    // デジタル時計用のフォーマット（時：分：秒）
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: currentTime)
    }

    // 読み上げ用テキスト（例：「7時58分です」「9時ちょうどです」）
    private var speakText: String {
        let hour   = Calendar.current.component(.hour,   from: currentTime)
        let minute = Calendar.current.component(.minute, from: currentTime)
        return minute == 0 ? "\(hour)時ちょうどです" : "\(hour)時\(minute)分です"
    }

    // 秒に応じて予報音・時報音・読み上げを実行
    private func playScheduledSound() {
        let second    = Calendar.current.component(.second, from: currentTime)
        let leadStart = 60 - SoundConfig.forecastLeadSeconds  // デフォルト = 57

        if second == 0 {
            // 時報音を再生し、鳴り終わってから時刻を読み上げ
            let text = speakText
            AudioServicesPlaySystemSoundWithCompletion(SoundConfig.timeSoundID) {
                let utterance = AVSpeechUtterance(string: text)
                self.synthesizer.speak(utterance)
            }
        } else if second >= leadStart {
            // 予報音（57・58・59秒）
            AudioServicesPlaySystemSound(SoundConfig.forecastSoundID)
        }
    }

    var body: some View {
        Text(formattedTime)
            .font(.system(size: DisplayConfig.fontSize,
                          weight: DisplayConfig.defaultFontWeight,
                          design: .monospaced))
            .foregroundColor(DisplayConfig.defaultColor)
            .onAppear {
                // タイマーで秒単位の更新と音声再生
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    self.currentTime = Date()
                    self.playScheduledSound()
                }
            }
    }
}

#Preview {
    DigitalClockView()
}
