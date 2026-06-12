//
//  WatchApp20241202App.swift
//  WatchApp20241202
//
//  Created by 上原賢 on 2024/12/02.
//

import SwiftUI

@main
struct WatchApp20241202App: App {

    // 起動時にオーディオ基盤を開始（バックグラウンドでも音声を鳴らすため）
    init() {
        AudioSessionManager.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
