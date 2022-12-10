//
//  ProgressBarView.swift
//  AiDraw
//
//  Created by Kiet Ho on 12/3/22.
//

import SwiftUI

struct ProgressBarView: View {
    @State var title: String = ""
    @State var currentValue: Float
    @State var totalValue: Float
    @State var isTimerActive = false
    @State internal var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack{
            ProgressView(title, value: currentValue, total: totalValue)
        }.onReceive(timer) { _ in
            if (currentValue < totalValue) {
                currentValue = currentValue + 1
            }
        }
    }
}

extension ProgressBarView {
    func startTimer() {
        currentValue = 0
        timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
        isTimerActive = true
    }
    
    func stopTimer() {
        currentValue = 0
        timer.upstream.connect().cancel()
        isTimerActive = false
    }
}

struct ProgressBarView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBarView(title: "", currentValue: 50, totalValue: 100)
    }
}
