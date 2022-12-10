//
//  PostToInferenceModalView.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/21/22.
//

import SwiftUI

struct PostToInferenceModalView: View {
    @Environment(\.presentationMode) var presentation
    
    let sourceImage: UIImage
    @State var prompt: String

    // Handlers
    let addInferredImageHandler: (UIImage) -> Void
    let inferenceFailed: (String, String) -> Void
    let startInferenceHandler: (String) -> Void
    internal var serviceHelper = ServiceHelper()
    
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
    
    let styleKeys = styles.map { $0.key }
    let styleDict = styles.reduce(into: [String: ArtStyle]()) {
        $0[$1.key] = $1
    }
    @State private var selectedStyleKey: String = styles[0].key

    var body: some View {
        VStack {
            Text("Describe your drawing")
            TextField(
              "Be as descriptive as you can",
              text: $prompt
            )
            .textFieldStyle(.roundedBorder)
            Image(uiImage: sourceImage)
              .resizable()
              .aspectRatio(1, contentMode: .fit)
              .padding(5)
            
            HStack(spacing: 0) {
                Text("Select a style:")
                Picker("Select an art style", selection: $selectedStyleKey) {
                    ForEach(styleKeys, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.menu )
                
            }
            
            Button(action: sendDrawing) {
              Text("Use AI")
            }
        }
        .padding(.all)
    }
}


    
private extension PostToInferenceModalView {
    func sendDrawing() {
        if (prompt != "") {
            let style = styleDict[selectedStyleKey]!
            let enhancedPrompt: String = style.prefix + prompt + style.suffix
            serviceHelper.postImgToImgRequest(prompt: enhancedPrompt, image: sourceImage, inferenceResultHandler: inferenceResultHandler)
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
                inferenceFailed("Creation failed", "Connection timed out. Try again in a few minutes or report this issue.")
            }
        }
    }
}

func mockInferenceHandler(prompt: String) {}
func mockInferenceHandler(image: UIImage) {}
func mockInferenceFailed(title: String, description: String) {}
struct PostToInferenceModalView_Previews: PreviewProvider {
    static var previews: some View {
        let mockSourceImage = UIImage(named: "coffee-1")
        PostToInferenceModalView(sourceImage: mockSourceImage ?? UIImage(), addInferredImage: mockInferenceHandler, inferenceFailed: mockInferenceFailed, startInferenceHandler: mockInferenceHandler, prompt: "")
    }
}


