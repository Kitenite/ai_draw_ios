//
//  WalkthroughView.swift
//  AiDraw
//
//  Created by Kiet Ho on 12/10/22.
//

import SwiftUI

struct WalkthroughView: View {
    @State var currentIndex = 1
    var body: some View {
        GeometryReader(content: { geometry in
            VStack {
                // .. //
                HStack(alignment: .center, spacing: 8) {
                    if currentIndex > 0 {
                        Button(action: {
                            currentIndex -= 1
                        }) {
                            HStack(alignment: .center, spacing: 10) {
                                Text("Kembali")
                                    .foregroundColor(.green)
                            }
                        }
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            maxHeight: 44
                        )
                        .background(Color.white)
                        .cornerRadius(4)
                        .padding(
                            [.leading, .trailing], 20
                        )
                    }
                    Button(action: {
                        if currentIndex != 2 {
                            currentIndex += 1
                        }
                    }) {
                        HStack(alignment: .center, spacing: 10) {
                            Text(currentIndex == 2 ? "Mulai" : "Lanjut")
                                .foregroundColor(.white)
                            //                      All.arrowRight.accentColor(.white)
                        }
                    }
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        maxHeight: 44
                    )
                    .background(.green)
                    .cornerRadius(4)
                    .padding(
                        [.leading, .trailing], 20
                    )
                }
                Spacer()
            }
        }
        )
        .background(
            switchColor()
                .edgesIgnoringSafeArea(.all)
        )
        .animation(.easeInOut(duration: 0.2))
        
    }
}

extension WalkthroughView {
    private func switchColor() -> Color {
        let tabColor = TabColor(rawValue: currentIndex) ?? .one
        return tabColor
    }
    
}


struct WalkthroughView_Previews: PreviewProvider {
    static var previews: some View {
        WalkthroughView()
    }
}
