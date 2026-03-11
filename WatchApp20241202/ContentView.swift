//
//  ContentView.swift

import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        DigitalClockView()
            .onAppear {
                // アプリ起動中はスリープを無効化
                UIApplication.shared.isIdleTimerDisabled = true
            }
            .onDisappear {
                // 画面が消えたらスリープを再有効化
                UIApplication.shared.isIdleTimerDisabled = false
            }
    }
}

#Preview {
    ContentView()
}
