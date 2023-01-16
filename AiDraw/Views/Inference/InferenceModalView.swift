//
//  SendToAIModalView.swift
//  AiDraw
//
//  Created by Kiet Ho on 1/1/23.
//

import SwiftUI

struct InferenceModalView: View {
    // Inputs
    var image: UIImage?
    @State var prompt: String
    @State var selectedArtTypeKey: String
    @State var selectedSubstyleKeys: [String]
    @State var advancedOptions: AdvancedOptions
    
    // Handlers
    let addInferredImageHandler: (UIImage) -> Void
    let inferenceFailedHandler: (String, String) -> Void
    let startInferenceHandler: (String, String, String, [String], AdvancedOptions) -> Void
    
    // Helpers
    internal var serviceHelper = ServiceHelper.shared
    internal var analytics = AnalyticsHelper.shared
    var promptStylesManager = PromptStylesManager.shared
    
    var body: some View {
        VStack {
            ScrollView {
                if (image != nil) {
                    Image(uiImage: image!)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 300, height: 300)
                        .border(Color.gray, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                        .padding()
                }
                VStack {
                    Text("Describe your image").bold()
                    TextField(
                        "Be as descriptive as you can",
                        text: $prompt
                    )
                    .textFieldStyle(.roundedBorder)
                }.padding()
                OptionalInferenceView(
                    selectedArtTypeKey: $selectedArtTypeKey,
                    selectedSubstyleKeys: $selectedSubstyleKeys,
                    advancedOptions: $advancedOptions
                )
                Button(action: sendDrawing) {
                    Text("Generate Image")
                }
                .buttonStyle(BorderedButtonStyle())
                .disabled(prompt == "")
            }
           
        }
    }
}

private extension InferenceModalView {
    func sendDrawing() {
        let enhancedPrompt: String = buildPrompt()
        if (image != nil) {
            serviceHelper.postInferenceRequest(
                prompt: enhancedPrompt,
                image: image!,
                advancedOptions: advancedOptions,
                inferenceResultHandler: inferenceResultHandler
            )
            analytics.logEvent(id: "drawing-sent", title: "Sent drawing for inference")
        } else {
            print("Post to text to image")
        }
        startInferenceHandler(prompt, enhancedPrompt, selectedArtTypeKey, selectedSubstyleKeys, advancedOptions)
    }

    func inferenceResultHandler(inferenceResult: String) {
        let imageData: String = inferenceResult
        let dataDecoded: Data? = Data(base64Encoded: imageData, options: .ignoreUnknownCharacters)
        if (dataDecoded != nil) {
            
            let decodedImage: UIImage? = UIImage(data: dataDecoded!)
            if (decodedImage != nil) {
                addInferredImageHandler(decodedImage!)
            } else {
                inferenceFailedHandler("Creation failed", "Connection timed out. Try again in a few minutes or report this issue.")
            }
        }
    }
    
    func buildPrompt() -> String {
        var enhancedPrompt = selectedArtTypeKey == "None" ? prompt : "of \(prompt)"
        enhancedPrompt = addPrefix(prefix: promptStylesManager.getArtTypePrefix(artType: selectedArtTypeKey),
                                   prompt: enhancedPrompt)
        enhancedPrompt = addSuffix(suffix: promptStylesManager.getArtTypeSuffix(artType: selectedArtTypeKey),
                                   prompt: enhancedPrompt)
        for (index, selectedSubStyleKey) in selectedSubstyleKeys.enumerated() {
            enhancedPrompt = addPrefix(prefix: promptStylesManager.getPromptArtStylePrefix(artType: selectedArtTypeKey, substyleIndex: index, substyleValue: selectedSubStyleKey), prompt: enhancedPrompt)
            enhancedPrompt = addSuffix(suffix: promptStylesManager.getPromptArtStyleSuffix(artType: selectedArtTypeKey, substyleIndex: index, substyleValue: selectedSubStyleKey),
                                       prompt: enhancedPrompt)
        }
        return enhancedPrompt
    }
    
    func addPrefix(prefix: String?, prompt: String) -> String {
        if (prefix != nil && prefix != "") {
            return prefix! + " " + prompt
        }
        return prompt
    }
    
    func addSuffix(suffix: String?, prompt: String) -> String {
        if (suffix != nil && suffix != "") {
            return prompt + ", " + suffix!
        }
        return prompt
    }
}


private func mockStartInferenceHandler(prompt: String, enahncedPrompt: String, selectedArtTypeKey: String, selectedSubstyleKeys: [String], advancedOptions: AdvancedOptions) {}
private func mockAddInferredImageHandler(image: UIImage) {}
private func mockInferenceFailedHandler(title: String, message: String) {}
struct SendToAIModalView_Previews: PreviewProvider {
    static var previews: some View {
        InferenceModalView(
            image: UIImage(named: "coffee-1")!,
            prompt: "This is my prompt",
            selectedArtTypeKey: "",
            selectedSubstyleKeys: ["None","None","None","None"],
            advancedOptions: AdvancedOptions(),
            addInferredImageHandler: mockAddInferredImageHandler,
            inferenceFailedHandler: mockInferenceFailedHandler,
            startInferenceHandler: mockStartInferenceHandler
        )
    }
}
