//
//  OptionPickerView.swift
//  AiDraw
//
//  Created by Kiet Ho on 1/2/23.
//

import SwiftUI

struct Option {
    var title: String
    var image: UIImage
}
struct OptionPickerView: View {
    
    var keys: [String]
    var promptStylesManager = PromptStylesManager.shared
    @Binding var selectedKey: String
    @State private var selectedOptionIndex: Int = 0
    
    let gridLayout: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(keys.indices, id: \.self) { index in
                    SelectableOptionView(
                        image: UIImage(named: keys[index]) ?? UIImage(named: "coffee-1")!,
                        selected: selectedKey == keys[index],
                        title: keys[index]
                    )
                    .onTapGesture {
                        selectedKey = keys[index]
                    }
                }
            }
            .padding(.all, 20)
        }
    }
}

struct OptionPickerView_Previews: PreviewProvider {
    @State static var selectedKey = "None"
    static var previews: some View {
        OptionPickerView(keys: ["Example0", "Example1", "Example2","Example3"], selectedKey: $selectedKey)
    }
}
