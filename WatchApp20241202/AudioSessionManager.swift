//
//  AudioSessionManager.swift
//
//  バックグラウンドでも音声を鳴らすための基盤。
//  ・オーディオセッションを .playback / .duckOthers で構成
//    （読み上げ時に他アプリの音を一瞬下げる＝ナビと同じダッキング）
//  ・無音を極小ループ再生してアプリを凍結（suspend）させない
//    → これにより Timer がバックグラウンドでも動き続ける
//

import AVFoundation

final class AudioSessionManager {

    // アプリ全体で1つだけ使うシングルトン
    static let shared = AudioSessionManager()

    // 無音をループ再生するプレイヤー（常駐の要）
    private var silencePlayer: AVAudioPlayer?

    private init() {}

    // 起動時に1回呼ぶ。セッション開始＋無音ループ再生を始める
    func start() {
        configureSession()
        startSilenceLoop()
    }

    // オーディオセッションを再生用に構成して有効化
    private func configureSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            // .playback        … 消音スイッチを無視し、バックグラウンドでも鳴らせる
            // .duckOthers      … 自分が鳴る間、他アプリの音量を下げる（ナビ的挙動）
            // .mixWithOthers   … 他アプリの再生を止めず共存させる
            try session.setCategory(.playback,
                                    options: [.duckOthers, .mixWithOthers])
            try session.setActive(true)
        } catch {
            print("オーディオセッションの設定に失敗: \(error)")
        }
    }

    // 無音WAVを実行時に生成し、無限ループで再生してアプリを常駐させる
    private func startSilenceLoop() {
        guard let url = makeSilentWavFile() else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1   // -1 で無限ループ
            player.volume = 0           // 完全な無音
            player.play()
            silencePlayer = player
        } catch {
            print("無音ループの再生に失敗: \(error)")
        }
    }

    // 0.5秒ぶんの無音WAVをテンポラリ領域に書き出して、そのURLを返す。
    // バンドルへ音声ファイルを追加せずに済むよう、実行時に生成する。
    private func makeSilentWavFile() -> URL? {
        let sampleRate = 8000              // サンプリングレート（無音なので低くてよい）
        let durationSeconds = 0.5
        let sampleCount = Int(Double(sampleRate) * durationSeconds)
        let bitsPerSample = 16
        let channels = 1
        let byteRate = sampleRate * channels * bitsPerSample / 8
        let blockAlign = channels * bitsPerSample / 8
        let dataSize = sampleCount * blockAlign

        var data = Data()

        // --- WAVヘッダ（RIFFチャンク）---
        data.append(contentsOf: Array("RIFF".utf8))
        data.append(uint32: UInt32(36 + dataSize))   // 以降のファイルサイズ
        data.append(contentsOf: Array("WAVE".utf8))

        // --- fmt サブチャンク ---
        data.append(contentsOf: Array("fmt ".utf8))
        data.append(uint32: 16)                       // fmtチャンクのサイズ
        data.append(uint16: 1)                        // フォーマット = PCM
        data.append(uint16: UInt16(channels))
        data.append(uint32: UInt32(sampleRate))
        data.append(uint32: UInt32(byteRate))
        data.append(uint16: UInt16(blockAlign))
        data.append(uint16: UInt16(bitsPerSample))

        // --- data サブチャンク（中身はすべて0＝無音）---
        data.append(contentsOf: Array("data".utf8))
        data.append(uint32: UInt32(dataSize))
        data.append(Data(repeating: 0, count: dataSize))

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("silence.wav")
        do {
            try data.write(to: url)
            return url
        } catch {
            print("無音WAVの書き出しに失敗: \(error)")
            return nil
        }
    }
}

// リトルエンディアンで数値を Data に追記するための補助
private extension Data {
    mutating func append(uint32 value: UInt32) {
        var v = value.littleEndian
        Swift.withUnsafeBytes(of: &v) { append(contentsOf: $0) }
    }
    mutating func append(uint16 value: UInt16) {
        var v = value.littleEndian
        Swift.withUnsafeBytes(of: &v) { append(contentsOf: $0) }
    }
}
