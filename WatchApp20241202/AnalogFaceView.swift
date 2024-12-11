//
//  AnalogFaceView.swift


import SwiftUI

struct AnalogFaceView: View {
    let hourAngle: Double
    let minuteAngle: Double
    let secondAngle: Double
    
    var body: some View {
        ZStack{
            //時計の文字盤...数字
            ForEach(1...12, id: \.self) { number in
            Text("\(number)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .rotationEffect(.degrees(-Double(number) * 30))
                    .offset(y: -110)
                    .rotationEffect(.degrees(Double(number) * 30))
            }
            
            //時計の文字盤...目盛り
            ForEach(0..<12) { tick in
            Rectangle()
                    .fill(Color.primary)
                    .frame(width: 2, height: 10)
                    .offset(y: -90)
                    .rotationEffect(.degrees(Double(tick) * 30))
            }
            
            //時針
            Rectangle()
                .fill(Color.primary)
                .frame(width: 4, height: 50)
                .offset(y: -25)
                .rotationEffect(.degrees(hourAngle))
                .animation(.easeInOut(duration: 0.5), value: hourAngle)
            
            //分針
            Rectangle()
                .fill(Color.primary)
                .frame(width: 3, height: 70)
                .offset(y: -35)
                .rotationEffect(.degrees(minuteAngle))
            
            //秒針
            Rectangle()
                .fill(Color.red)
                .frame(width: 2, height: 90)
                .offset(y: -45)
                .rotationEffect(.degrees(secondAngle))
                .animation(.linear(duration: 1), value: secondAngle)
            
            //中心の円
            Circle()
                .fill(Color.primary)
                .frame(width: 10, height: 10)
        }
        .frame(width: 200, height: 200)
    }
}

#Preview {
    AnalogFaceView(hourAngle: 60, minuteAngle: 30, secondAngle: 120)
}
