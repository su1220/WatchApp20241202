//
//  ClockManager.swift
//
//  時刻の更新と音声再生（予報音・時報音・読み上げ）を担う常駐マネージャ。
//  View に紐づく Timer はバックグラウンドで止まるため、アプリ起動時に
//  生成されるシングルトン側で Timer を回し、常駐中は背面でも鳴らし続ける。
//

import Foundation
import AudioToolbox
import AVFoundation

final class ClockManager: ObservableObject {

    // アプリ全体で1つだけ使うシングルトン
    static let shared = ClockManager()

    // View が表示に使う現在時刻（更新されると画面も再描画される）
    @Published private(set) var currentTime = Date()

    // 読み上げ用シンセサイザ（マネージャが保持し続ける）
    private let synthesizer = AVSpeechSynthesizer()

    // 毎秒のタイマー
    private var timer: Timer?

    private init() {
        // アプリのオーディオセッションを使って発話する
        // （AudioSessionManager の .duckOthers が効き、他アプリ音を下げる）
        synthesizer.usesApplicationAudioSession = true
    }

    // 毎秒タイマーを開始。アプリ常駐中はバックグラウンドでも動き続ける
    func start() {
        guard timer == nil else { return }   // 二重起動を防ぐ
        let t = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        // .common モードで登録し、画面スクロール等の操作中も止まらないようにする
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    // 1秒ごとの処理：時刻更新と音声再生
    private func tick() {
        currentTime = Date()
        playScheduledSound()
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
            AudioServicesPlaySystemSoundWithCompletion(SoundConfig.timeSoundID) { [weak self] in
                // 完了ハンドラは別スレッドで呼ばれるため、発話はメインスレッドで行う
                DispatchQueue.main.async {
                    let utterance = AVSpeechUtterance(string: text)
                    self?.synthesizer.speak(utterance)
                }
            }
        } else if second >= leadStart {
            // 予報音（57・58・59秒）
            AudioServicesPlaySystemSound(SoundConfig.forecastSoundID)
        }
    }
}
