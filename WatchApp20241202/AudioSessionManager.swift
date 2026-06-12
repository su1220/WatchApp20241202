//
//  AudioSessionManager.swift
//
//  バックグラウンドでも音声を鳴らすための基盤。
//  ・オーディオセッションを .playback / .mixWithOthers で構成し他アプリと共存
//  ・人にはほぼ聞こえない極小トーンをループ再生して、
//    アプリの凍結（suspend）を防ぎ、かつオーディオ経路を起こし続ける
//    → これにより Timer が背面で動き続け、読み上げ(TTS)も背面で鳴らせる
//

import AVFoundation

final class AudioSessionManager {

    // アプリ全体で1つだけ使うシングルトン
    static let shared = AudioSessionManager()

    // 常駐トーンをループ再生するプレイヤー（常駐の要）
    private var silencePlayer: AVAudioPlayer?

    // 常駐トーンの音量（20Hzなのでどちらの値でも耳には聞こえない）
    // ・通常時 … アプリ常駐に必要な最小限
    // ・ダッキング中 … 「自分が鳴り続けている」状態を保ち、他アプリの音量を下げ続けるため上げる
    private let idleVolume: Float = 0.01
    private let duckingVolume: Float = 1.0

    // 現在ダッキング中かどうか（重い setActive を無駄に繰り返さないための状態管理）
    private var isDucking = false

    private init() {}

    // 起動時に1回呼ぶ。セッション開始＋無音ループ再生を始める
    func start() {
        configureSession()
        startSilenceLoop()
    }

    // ダッキング開始：アナウンスの間だけ他アプリの音量を下げる。
    // .duckOthers を付けると「他アプリ」のみ下がり、自分の読み上げ等は通常音量で乗る。
    // あわせて常駐トーンの音量を上げ、ビープの合間も「自分が鳴り続けている」状態にして
    // ダッキングが途切れないようにする（＝下げっぱなしを維持）。
    func beginDucking() {
        guard !isDucking else { return }   // すでに下げ中なら重い処理を繰り返さない
        isDucking = true
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, options: [.mixWithOthers, .duckOthers])
        // setActive(true) で .duckOthers を明示的に発動させ、窓の間ずっと下げ続ける
        try? session.setActive(true)
        silencePlayer?.volume = duckingVolume
    }

    // ダッキング終了：常駐トーンを通常音量に戻し、他アプリの音量も元に戻す
    func endDucking() {
        guard isDucking else { return }    // 下げていなければ何もしない
        isDucking = false
        let session = AVAudioSession.sharedInstance()
        silencePlayer?.volume = idleVolume
        try? session.setCategory(.playback, options: [.mixWithOthers])
        // setActive(true) で .duckOthers を外した設定を反映し、他アプリ音量を戻す
        try? session.setActive(true)
    }

    // オーディオセッションを再生用に構成して有効化
    private func configureSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            // .playback      … 消音スイッチを無視し、バックグラウンドでも鳴らせる
            // .mixWithOthers … 他アプリの再生を止めず共存させる
            // （常時トーンを流すため、ここで .duckOthers は付けない。
            //   他アプリ音を下げるダッキングは発話時のみ別途行う想定）
            try session.setCategory(.playback, options: [.mixWithOthers])
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
            player.volume = idleVolume  // 通常は最小限の音量（20Hzなので無音同然）
            player.play()
            silencePlayer = player
        } catch {
            print("常駐トーンの再生に失敗: \(error)")
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

        // --- data サブチャンク（極小音量のトーン）---
        // 完全な無音だとオーディオ経路がアイドル化し、背面で読み上げが固まる。
        // 人にはほぼ聞こえない超低音(20Hz)・極小振幅のトーンで経路を起こし続ける。
        data.append(contentsOf: Array("data".utf8))
        data.append(uint32: UInt32(dataSize))
        let frequency = 20.0               // 20Hz（多くの端末スピーカーでほぼ聞こえない超低音）
        // 振幅は大きめに作っておき、実際の音量は再生時の player.volume で2段階に制御する
        // （通常は idleVolume、ダッキング中は duckingVolume）
        let amplitude = 8000.0             // 20Hz なので端末スピーカーではこの振幅でもほぼ無音
        for i in 0..<sampleCount {
            let t = Double(i) / Double(sampleRate)
            let value = Int16(amplitude * sin(2.0 * Double.pi * frequency * t))
            data.append(uint16: UInt16(bitPattern: value))
        }

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
