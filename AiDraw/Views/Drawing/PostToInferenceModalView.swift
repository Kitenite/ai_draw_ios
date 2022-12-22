//
//  PostToInferenceModalView.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/21/22.
//

import SwiftUI
import PencilKit

struct PostToInferenceModalView: View {
    @Environment(\.presentationMode) var presentation
    
    // Inputs
    let sourceImage: UIImage
    @State var prompt: String
    @State internal var inpaintPrompt: String = ""
    
    // Handlers
    let addInferredImageHandler: (UIImage) -> Void
    let inferenceFailedHandler: (String, String) -> Void
    let startInferenceHandler: (String) -> Void
    
    // Helpers
    internal var serviceHelper = ServiceHelper()
    @FocusState private var promptTextFieldIsFocused: Bool
    
    // Masking for inpainting
    @State private var maskCanvasView = PKCanvasView()
    @State private var maskDrawing = PKDrawing()
    @State private var isMasking = false
    
    // Prompt styles
    var promptStylesManager = PromptStylesManager.shared
    
    @State private var selectedArtTypeKey: String = "None"
    @State private var selectedSubstyleKey0: String = "None"
    @State private var selectedSubstyleKey1: String = "None"
    @State private var selectedSubstyleKey2: String = "None"
    
    var body: some View {
        VStack {
            Toggle("Apply mask", isOn: $isMasking)
            
            ZStack {
                Image(uiImage: sourceImage)
                    .aspectRatio(1, contentMode: .fit)
                
                CanvasView(canvasView: $maskCanvasView, drawing: maskDrawing, onSaved: saveMask, isMask: true)
                    .aspectRatio(1, contentMode: .fit)
                    .border(Color.red, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                    .hidden(!isMasking)
            }
            
            if (isMasking) {
                Text("Draw your mask and describe what you want to fill in")
                TextField(
                    "Only the masked part will be filled in by AI",
                    text: $inpaintPrompt
                )
                .textFieldStyle(.roundedBorder)
                
            } else {
                Text("Describe your drawing")
                TextField(
                    "Be as descriptive as you can",
                    text: $prompt
                )
                .textFieldStyle(.roundedBorder)
                
                HStack(spacing: 0) {
                    VStack() {
                        Text("Art Type:")
                        Picker("Select an art style", selection: $selectedArtTypeKey) {
                            ForEach(promptStylesManager.getArtTypeKeys(), id: \.self) {
                                Text($0)
                            }
                        }
                    }
                    .pickerStyle(.menu )
                    if (promptStylesManager.getSubstylesByArtType(artType: selectedArtTypeKey).count > 0) {
                        VStack() {
                            Text(promptStylesManager.getSubstyleKey(artType: selectedArtTypeKey, index: 0) + ":")
                            Picker("Select an art style", selection: $selectedSubstyleKey0) {
                                ForEach(promptStylesManager.getSubstyleValueKeys(artType: selectedArtTypeKey, index: 0), id: \.self) {
                                    Text($0)
                                }
                            }
                        }
                        .pickerStyle(.menu )
                    }
                }
                HStack(spacing: 0) {
                    if (promptStylesManager.getSubstylesByArtType(artType: selectedArtTypeKey).count > 1) {
                        VStack() {
                            Text(promptStylesManager.getSubstyleKey(artType: selectedArtTypeKey, index: 1) + ":")
                            Picker("Select an art style", selection: $selectedSubstyleKey1) {
                                ForEach(promptStylesManager.getSubstyleValueKeys(artType: selectedArtTypeKey, index: 1), id: \.self) {
                                    Text($0)
                                }
                            }
                        }
                        .pickerStyle(.menu )
                    }
                    if (promptStylesManager.getSubstylesByArtType(artType: selectedArtTypeKey).count > 2) {
                        VStack() {
                            Text(promptStylesManager.getSubstyleKey(artType: selectedArtTypeKey, index: 2) + ":")
                            Picker("Select an art style", selection: $selectedSubstyleKey2) {
                                ForEach(promptStylesManager.getSubstyleValueKeys(artType: selectedArtTypeKey, index: 2), id: \.self) {
                                    Text($0)
                                }
                            }
                        }
                        .pickerStyle(.menu )
                    }
                }
            }
            
            Button(action: sendDrawing) {
                Text("Use AI")
            }
        }
        .padding(.all)
    }
}

private extension PostToInferenceModalView {
    func saveMask() {}
    
    func sendDrawing() {
        if (prompt != "") {
            if (isMasking) {
                let maskImage = maskCanvasView.getMaskAsImage()
                serviceHelper.postImgToImgRequest(prompt: inpaintPrompt, image: sourceImage, mask: maskImage, inferenceResultHandler: inferenceResultHandler)
            } else {
                let enhancedPrompt: String = buildPrompt()
                serviceHelper.postImgToImgRequest(prompt: enhancedPrompt, image: sourceImage, inferenceResultHandler: inferenceResultHandler)
            }
            startInferenceHandler(prompt)
        }
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
        let mockSourceImage = UIImage(named: "coffee-1")
        PostToInferenceModalView(sourceImage: mockSourceImage ?? UIImage(), prompt: "", addInferredImageHandler: mockInferenceHandler, inferenceFailedHandler: mockInferenceFailedHandler, startInferenceHandler: mockInferenceHandler)
    }
}


