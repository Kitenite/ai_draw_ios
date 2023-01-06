//
//  BorderedButtonStyle.swift
//  AiDraw
//
//  Created by Kiet Ho on 1/5/23.
//

import SwiftUI

struct BorderedButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        BorderedButtonStyleView(configuration: configuration)
    }
}

private extension BorderedButtonStyle {
    struct BorderedButtonStyleView: View {
        @Environment(\.isEnabled) var isEnabled
        let configuration: BorderedButtonStyle.Configuration
        
        var body: some View {
            return configuration.label
                .bold()
                .foregroundColor(isEnabled ? .blue : .gray)
                .opacity(configuration.isPressed ? 0.8 : 1.0)
                .opacity(isEnabled ? 1.0 : 0.8)
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .padding([.bottom, .top], 12)
                .padding([.trailing, .leading], 20)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(isEnabled ? .blue : .gray, lineWidth: 2)
                        .opacity(isEnabled ? 1.0 : 0.8)
                )
        }
    }
}

struct BorderedButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button(action: {}) {
            Text("Fancy button")
        }.buttonStyle(BorderedButtonStyle()).disabled(true)
    }
}
