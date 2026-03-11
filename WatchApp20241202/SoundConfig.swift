//
//  SoundConfig.swift

import AudioToolbox

// 音声設定（UserDefaults から読み込み、設定画面からの変更に対応）
enum SoundConfig {

    // UserDefaults のキー
    private static let forecastSoundKey = "forecastSoundID"
    private static let timeSoundKey = "timeSoundID"
    private static let forecastLeadKey = "forecastLeadSeconds"

    // デフォルト値
    static let defaultForecastSoundID: SystemSoundID = 1340
    static let defaultTimeSoundID: SystemSoundID = 1167
    static let defaultForecastLeadSeconds = 3

    // 予報音 ID（UserDefaults に保存値があればそれを使用）
    static var forecastSoundID: SystemSoundID {
        let saved = UserDefaults.standard.integer(forKey: forecastSoundKey)
        return SystemSoundID(saved != 0 ? saved : Int(defaultForecastSoundID))
    }

    // 時報音 ID（UserDefaults に保存値があればそれを使用）
    static var timeSoundID: SystemSoundID {
        let saved = UserDefaults.standard.integer(forKey: timeSoundKey)
        return SystemSoundID(saved != 0 ? saved : Int(defaultTimeSoundID))
    }

    // 時報の何秒前から予報音を鳴らすか（UserDefaults に保存値があればそれを使用）
    static var forecastLeadSeconds: Int {
        let saved = UserDefaults.standard.integer(forKey: forecastLeadKey)
        return saved != 0 ? saved : defaultForecastLeadSeconds
    }
}
