//
//  ContentView.swift

import SwiftUI
import AudioToolbox
import AVFoundation

// 音声設定（将来の UserDefaults 化・設定画面対応を前提とした設計）
enum SoundConfig {
    static let forecastLeadSeconds = 3                    // 時報の何秒前から予報音を鳴らすか
    static let forecastSoundID: SystemSoundID = 1340      // 予報音
    static let timeSoundID: SystemSoundID = 1167          // 時報音
}

// 表示スタイル（将来の設定画面から選択可能にする）
enum ClockStyle {
    case standard       // 標準
    case sevenSegment   // 7セグ風
    case nixieTube      // ニキシー管風
}

// 表示設定（将来の UserDefaults 化・設定画面対応を前提とした設計）
enum DisplayConfig {
    static let fontSize: CGFloat = 40
    static let fontWeight: Font.Weight = .bold
    static let color: Color = .primary
    static let style: ClockStyle = .standard
}

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
        let hour = Calendar.current.component(.hour, from: currentTime)
        let minute = Calendar.current.component(.minute, from: currentTime)
        if minute == 0 {
            return "\(hour)時ちょうどです"
        } else {
            return "\(hour)時\(minute)分です"
        }
    }

    // 秒に応じて予報音・時報音・読み上げを実行
    private func playScheduledSound() {
        let second = Calendar.current.component(.second, from: currentTime)
        let leadStart = 60 - SoundConfig.forecastLeadSeconds  // = 57

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
                          weight: DisplayConfig.fontWeight,
                          design: .monospaced))
            .foregroundColor(DisplayConfig.color)
            .onAppear {
                // タイマーで秒単位の更新と音声再生
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    self.currentTime = Date()
                    self.playScheduledSound()
                }
            }
    }
}

struct ContentView: View {
    var body: some View {
        DigitalClockView()
    }
}

#Preview {
    ContentView()
}
