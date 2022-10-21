//
//  DrawingView.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/19/22.
//

import SwiftUI
import PencilKit

struct DrawingView: View {
    
    var drawing: DrawingThumbnail
    @State private var canvasView = PKCanvasView()
    @State private var isUploadingDrawing = false
    @State private var isRunningInference = false
    @State private var prompt = ""
    @State private var inferredImages: [InferredImage] = []

    var body: some View {
        NavigationStack {
            ZStack {
                CanvasView(canvasView: $canvasView, onSaved: saveDrawing)
                    .padding(20.0)
                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                    .background(Color.gray)
                    .navigationBarTitle(Text(drawing.name), displayMode: .inline)
                    .navigationBarItems(
                        leading: HStack {
                            Spacer(minLength: 10)
                            Button(action: downloadDrawing) {
                                Image(systemName: "square.and.arrow.down")
                            }

                        },
                        trailing: HStack {
                            Button(action: uploadDrawingForInference) {
                                Image(systemName: "brain")
                            }.sheet(isPresented: $isUploadingDrawing) {
                              PostToInferenceModalView(sourceImage: canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale), addInferredImage: addInferredImage, startInferenceHandler: startInferenceHandler, prompt: prompt)
                            }
                            Image(systemName: "photo.on.rectangle.angled")
                            Image(systemName: "square.3.stack.3d.top.filled")
                        }
                    )
            }
        }
    }
}

private extension DrawingView {
    func saveDrawing() {}
    
    func downloadDrawing() {
      let image = canvasView.drawing.image(
        from: canvasView.bounds, scale: UIScreen.main.scale
      )
      let imageSaver = ImageSaver()
      imageSaver.writeToPhotoAlbum(image: image)
    }
    
    func uploadDrawingForInference() {
        isUploadingDrawing = true
    }
    
    func startInferenceHandler(newPrompt: String) {
        isUploadingDrawing = false
       isRunningInference = true
       prompt = newPrompt
     }
    
    func addInferredImage(newInferredImage: InferredImage) {
      inferredImages.append(newInferredImage)
      isRunningInference = false
    }
}


struct DrawingView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingView(drawing: DrawingThumbnail(name: "coffee-0"))
    }
}
