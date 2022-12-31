//
//  PostToInferenceModalView.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/21/22.
//

import SwiftUI

struct InferenceModalView: View {
    @Environment(\.presentationMode) var presentation

    // Inputs
    let sourceImage: UIImage
    @State var prompt: String
    
    // Handlers
    let addInferredImageHandler: (UIImage) -> Void
    let inferenceFailedHandler: (String, String) -> Void
    let startInferenceHandler: (String) -> Void
    
    // Helpers
    internal var serviceHelper = ServiceHelper.shared
    internal var analytics = AnalyticsHelper.shared

    // Mask options
    @State private var maskOptions = MaskOptions()
    @State private var isMaskModalPresented = false
    
    // Advanced options
    @State private var advancedOptions = AdvancedOptions()
    @State private var isAdvancedOptionsPresented = false
    
    // Prompt styles
    var promptStylesManager = PromptStylesManager.shared
    
    @State private var selectedArtTypeKey: String = "None"
    @State private var selectedSubstyleKey0: String = "None"
    @State private var selectedSubstyleKey1: String = "None"
    @State private var selectedSubstyleKey2: String = "None"
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    if ((maskOptions.maskImage) == nil) {
                        Button("Add mask") {
                            maskOptions.sourceImage = sourceImage
                            isMaskModalPresented = true
                            analytics.logEvent(id: "nav-mask", title: "Navigate to mask")
                        }
                        .sheet(isPresented: $isMaskModalPresented) {
                            CreateMaskModalView(maskOptions: $maskOptions)
                        }
                    } else {
                        Button("Remove mask") {
                            maskOptions = MaskOptions()
                            analytics.logEvent(id: "remove-mask", title: "Removed mask")
                        }
                    }
                    
                    Spacer()
                    Button("Advanced options") {
                        isAdvancedOptionsPresented = true
                        analytics.logEvent(id: "nav-advanced-options", title: "Navigate to advanced options")
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .sheet(isPresented: $isAdvancedOptionsPresented) {
                        AdvancedOptionsModalView(advancedOptions: $advancedOptions)
                    }
                }
                Divider()
                ZStack {
                    Image(uiImage: sourceImage)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .border(Color.gray, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                    
                    if (maskOptions.maskImage != nil) {
                        Image(uiImage: maskOptions.maskImage!)
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .opacity(0.2)
                    }
                }
                
                if (maskOptions.maskImage != nil) {
                    InferenceTextField(
                        header: "Describe the \(maskOptions.invertMask ? "unmasked" : "masked") part",
                        placeholder: "The \(maskOptions.invertMask ? "UNMASKED" : "MASKED") part will be filled in",
                        text: $maskOptions.prompt
                    )
                } else {
                    InferenceTextField(
                        header: "Describe your drawing",
                        placeholder: "Be as descriptive as you can",
                        text: $prompt
                    )
                }
                
                VStack {
                    HStack {
                        Text("Art Type:")
                        Picker("Select an art style", selection: $selectedArtTypeKey) {
                            ForEach(promptStylesManager.getArtTypeKeys(), id: \.self) {
                                Text($0)
                            }
                        }.pickerStyle(.menu )
                    }
                    
                    if (promptStylesManager.getSubstylesByArtType(artType: selectedArtTypeKey).count > 0) {
                        HStack {
                            Text(promptStylesManager.getSubstyleKey(artType: selectedArtTypeKey, index: 0) + ":")
                            Picker("Select an art style", selection: $selectedSubstyleKey0) {
                                ForEach(promptStylesManager.getSubstyleValueKeys(artType: selectedArtTypeKey, index: 0), id: \.self) {
                                    Text($0)
                                }
                            }.pickerStyle(.menu)
                        }
                    }
                    
                    if (promptStylesManager.getSubstylesByArtType(artType: selectedArtTypeKey).count > 1) {
                        HStack {
                            Text(promptStylesManager.getSubstyleKey(artType: selectedArtTypeKey, index: 1) + ":")
                            Picker("Select an art style", selection: $selectedSubstyleKey1) {
                                ForEach(promptStylesManager.getSubstyleValueKeys(artType: selectedArtTypeKey, index: 1), id: \.self) {
                                    Text($0)
                                }
                            }.pickerStyle(.menu)
                        }
                    }
                    
                    if (promptStylesManager.getSubstylesByArtType(artType: selectedArtTypeKey).count > 2) {
                        HStack {
                            Text(promptStylesManager.getSubstyleKey(artType: selectedArtTypeKey, index: 2) + ":")
                            Picker("Select an art style", selection: $selectedSubstyleKey2) {
                                ForEach(promptStylesManager.getSubstyleValueKeys(artType: selectedArtTypeKey, index: 2), id: \.self) {
                                    Text($0)
                                }
                            }.pickerStyle(.menu )
                        }
                    }
                }
                
                Button(action: sendDrawing) {
                    Text("Use AI")
                }.disabled(prompt == "" && maskOptions.prompt == "")
            }
            .padding()
        }
    }
}

private extension InferenceModalView {
    func sendDrawing() {
        let enhancedPrompt: String = buildPrompt()
        serviceHelper.postImgToImgRequest(prompt: maskOptions.maskImage == nil ? enhancedPrompt : maskOptions.prompt, image: sourceImage, mask: maskOptions.maskImage, advancedOptions: advancedOptions, inferenceResultHandler: inferenceResultHandler)
        startInferenceHandler(prompt)
        analytics.logEvent(id: "drawing-sent", title: "Sent drawing for inference")
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
        enhancedPrompt = addPrefix(prefix: promptStylesManager.getPromptArtStylePrefix(artType: selectedArtTypeKey, substyleIndex: 0, substyleValue: selectedSubstyleKey0),
                                   prompt: enhancedPrompt)
        enhancedPrompt = addPrefix(prefix: promptStylesManager.getPromptArtStylePrefix(artType: selectedArtTypeKey, substyleIndex: 1, substyleValue: selectedSubstyleKey1),
                                   prompt: enhancedPrompt)
        enhancedPrompt = addPrefix(prefix: promptStylesManager.getPromptArtStylePrefix(artType: selectedArtTypeKey, substyleIndex: 2, substyleValue: selectedSubstyleKey2),
                                   prompt: enhancedPrompt)
        enhancedPrompt = addSuffix(suffix: promptStylesManager.getArtTypeSuffix(artType: selectedArtTypeKey),
                                   prompt: enhancedPrompt)
        enhancedPrompt = addSuffix(suffix: promptStylesManager.getPromptArtStyleSuffix(artType: selectedArtTypeKey, substyleIndex: 0, substyleValue: selectedSubstyleKey0),
                                   prompt: enhancedPrompt)
        enhancedPrompt = addSuffix(suffix: promptStylesManager.getPromptArtStyleSuffix(artType: selectedArtTypeKey, substyleIndex: 1, substyleValue: selectedSubstyleKey1),
                                   prompt: enhancedPrompt)
        enhancedPrompt = addSuffix(suffix: promptStylesManager.getPromptArtStyleSuffix(artType: selectedArtTypeKey, substyleIndex: 2, substyleValue: selectedSubstyleKey2),
                                   prompt: enhancedPrompt)
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

func mockInferenceHandler(prompt: String) {}
func mockInferenceHandler(image: UIImage) {}
func mockInferenceFailedHandler(title: String, description: String) {}
struct PostToInferenceModalView_Previews: PreviewProvider {
    static var previews: some View {
        let mockSourceImage = UIImage(color: .blue)
        InferenceModalView(sourceImage: mockSourceImage ?? UIImage(), prompt: "", addInferredImageHandler: mockInferenceHandler, inferenceFailedHandler: mockInferenceFailedHandler, startInferenceHandler: mockInferenceHandler)
    }
}


