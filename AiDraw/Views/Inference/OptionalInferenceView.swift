//
//  OptionalInferenceView.swift
//  AiDraw
//
//  Created by Kiet Ho on 1/2/23.
//

import SwiftUI

struct OptionalInferenceView: View {
    
    // Prompt styles
    var promptStylesManager = PromptStylesManager.shared
    
    @State private var selectedArtTypeKey: String = "None"
    @State private var selectedSubstyleKeys: [String] = [String](repeating: "None", count: 4)

    // Advanced options
    @State private var advancedOptions = AdvancedOptions()

    var body: some View {
        VStack {
            Text("Optional").bold()
            
            DisclosureGroup("Art Type") {
                OptionPickerView(
                    keys: promptStylesManager.getArtTypeKeys(),
                    selectedKey: $selectedArtTypeKey
                )
            }
            
            ForEach(selectedSubstyleKeys.indices, id: \.self) { index in
                if (promptStylesManager.getSubstylesByArtType(artType: selectedArtTypeKey).count > index) {
                    DisclosureGroup(promptStylesManager.getSubstyleKey(artType: selectedArtTypeKey, index: index)) {
                        OptionPickerView(
                            keys: promptStylesManager.getSubstyleValueKeys(artType: selectedArtTypeKey, index: index),
                            selectedKey: $selectedSubstyleKeys[index]
                        )
                    }
                }
            }
 
            DisclosureGroup("Advanced options") {
                AdvancedOptionsModalView(advancedOptions: $advancedOptions)
            }
        }.padding()
        
    }
}

struct OptionalInferenceView_Previews: PreviewProvider {
    static var previews: some View {
        OptionalInferenceView()
    }
}
