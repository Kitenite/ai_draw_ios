//
//  InferenceTextField.swift
//  AiDraw
//
//  Created by Kiet Ho on 12/27/22.
//

import SwiftUI

struct InferenceTextField: View {
    let header: String
    let placeholder: String
    @Binding var text: String
    @FocusState private var textFieldIsFocused: Bool

    var body: some View {
        VStack {
            Text(header)
            TextField(
                placeholder,
                text: $text,
                axis: .vertical
            )
            .lineLimit(1...5)
            .textFieldStyle(.roundedBorder)
            .focused($textFieldIsFocused)
            // Workaround to dismiss text on enter
            .onChange(of: text) { newValue in
                guard let newValueLastChar = newValue.last else { return }
                if newValueLastChar == "\n" {
                    text.removeLast()
                    textFieldIsFocused = false
                }
            }
        }
        
    }
}

struct InferenceTextField_Previews: PreviewProvider {
    static var previews: some View {
        InferenceTextField(header: "Header", placeholder: "Placeholder", text: .constant("Inside text field"))
    }
}
