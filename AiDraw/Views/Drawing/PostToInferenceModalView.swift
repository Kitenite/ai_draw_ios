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
    let addInferredImage: (UIImage) -> Void
    let inferenceFailed: (String, String) -> Void
    let startInferenceHandler: (String) -> Void
    @State var prompt: String
    internal var serviceHelper = ServiceHelper()

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
            let enhancedPrompt: String = prompt
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
                addInferredImage(decodedImage!)
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


