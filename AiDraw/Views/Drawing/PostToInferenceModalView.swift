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
    
    // Art style picker
    static let styles: [ArtStyle] = [
        ArtStyle(key: "none", prefix: "", suffix: ""),
        ArtStyle(key: "cubism", prefix: "A painting of ", suffix: ", cubism"),
        ArtStyle(key: "surrealism", prefix: "A painting of ", suffix: ", surrealism"),
        ArtStyle(key: "art deco", prefix: "A painting of ", suffix: ", art deco"),
        ArtStyle(key: "classical", prefix: "A painting of ", suffix: ", classical"),
        ArtStyle(key: "magic realism", prefix: "A painting of ", suffix: ", magic realism"),
        ArtStyle(key: "neo-baroque", prefix: "A painting of ", suffix: ", neo-baroque"),
        ArtStyle(key: "orientalism", prefix: "A painting of ", suffix: ", orientalism"),
    ]
    @State private var selectedStyleKey: String = styles[0].key
    let styleKeys = styles.map { $0.key }
    let styleDict = styles.reduce(into: [String: ArtStyle]()) {$0[$1.key] = $1}
    
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
                    Text("Select a style:")
                    Picker("Select an art style", selection: $selectedStyleKey) {
                        ForEach(styleKeys, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu )
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
                let style = styleDict[selectedStyleKey]!
                let enhancedPrompt: String = style.prefix + prompt + style.suffix
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


