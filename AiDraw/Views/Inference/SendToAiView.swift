//
//  SendToAIModalView.swift
//  AiDraw
//
//  Created by Kiet Ho on 1/1/23.
//

import SwiftUI

struct SendToAiView: View {
    // Inputs
    @State var prompt: String
    var image: UIImage?
    
    // Handlers
    let addInferredImageHandler: (UIImage) -> Void
    let inferenceFailedHandler: (String, String) -> Void
    let startInferenceHandler: (String) -> Void
    
    // Helpers
    internal var serviceHelper = ServiceHelper.shared
    internal var analytics = AnalyticsHelper.shared
    
    // Prompt styles
    var promptStylesManager = PromptStylesManager.shared
    @State private var selectedArtTypeKey: String = "None"
    @State private var selectedSubstyleKeys: [String] = [String](repeating: "None", count: 4)
    
    // Advanced options
    @State private var advancedOptions = AdvancedOptions()
    
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
            }
            Button(action: sendDrawing) {
                Text("Generate Image")
            }
            .buttonStyle(BorderedButtonStyle())
            .disabled(prompt == "")
        }
    }
}

private extension SendToAiView {
    func sendDrawing() {
        let enhancedPrompt: String = buildPrompt()
        if (image != nil) {
            serviceHelper.postImgToImgRequest(
                prompt: enhancedPrompt,
                image: image!,
                advancedOptions: advancedOptions,
                inferenceResultHandler: inferenceResultHandler
            )
            analytics.logEvent(id: "drawing-sent", title: "Sent drawing for inference")
        } else {
            print("Post to text to image")
        }
        
        startInferenceHandler(prompt)
    }
    
    func inferenceResultHandler(inferenceResponse: InferenceResponse) {
        let output_location = inferenceResponse.output_img_url
        serviceHelper.shortPollForImg(output_location: output_location, shortPollResultHandler: shortPollResultHandler)
    }
    
    func shortPollResultHandler(shortPollResult: String) {
        let imageData: String = shortPollResult
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
        var enhancedPrompt = "of " + prompt
        enhancedPrompt = addPrefix(prefix: promptStylesManager.getArtTypePrefix(artType: selectedArtTypeKey),
                                   prompt: enhancedPrompt)
        enhancedPrompt = addSuffix(suffix: promptStylesManager.getArtTypeSuffix(artType: selectedArtTypeKey),
                                   prompt: enhancedPrompt)
        for (index, selectedSubStyleKey) in selectedSubstyleKeys.enumerated() {
            enhancedPrompt = addPrefix(prefix: promptStylesManager.getPromptArtStylePrefix(artType: selectedArtTypeKey, substyleIndex: index, substyleValue: selectedSubStyleKey), prompt: enhancedPrompt)
            enhancedPrompt = addSuffix(suffix: promptStylesManager.getPromptArtStyleSuffix(artType: selectedArtTypeKey, substyleIndex: index, substyleValue: selectedSubStyleKey),
                                       prompt: enhancedPrompt)
        }
        print(enhancedPrompt)
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


private func mockInferenceHandler(prompt: String) {}
private func mockInferenceHandler(image: UIImage) {}
private func mockInferenceFailedHandler(title: String, description: String) {}
struct SendToAIModalView_Previews: PreviewProvider {
    static var previews: some View {
        let image = UIImage(named: "coffee-1")
        SendToAiView(
            prompt: "This is my prompt",
            image: image!,
            addInferredImageHandler: mockInferenceHandler,
            inferenceFailedHandler: mockInferenceFailedHandler,
            startInferenceHandler: mockInferenceHandler
        )
    }
}
