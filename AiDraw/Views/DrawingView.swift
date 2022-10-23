//
//  DrawingView.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/19/22.
//

import SwiftUI
import PencilKit
import PhotosUI

struct DrawingView: View {
    
    var drawing: DrawingThumbnail
    @State private var canvasView = PKCanvasView()
    @State private var isUploadingDrawing = false
    @State private var isRunningInference = false
    @State private var prompt = ""
    @State private var inferredImages: [InferredImage] = []
    
    // Image Picker
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    @State private var backgroundImage: UIImage?


    var body: some View {
        NavigationStack {
            ZStack {
                if (backgroundImage != nil) {
                    Image(uiImage: backgroundImage!)
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                        .padding(20.0)
                }


                CanvasView(canvasView: $canvasView, onSaved: saveDrawing)
                    .padding(20.0)
                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
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
                            PhotosPicker(
                                selection: $selectedItem,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                Image(systemName: "photo.on.rectangle.angled")
                            }.onChange(of: selectedItem) { newItem in
                                Task {
                                    // Retrieve selected asset in the form of Data
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        handleUploadedPhotoData(data: data)
                                        print(data)
                                    }
                                }
                            }
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
    
    func handleUploadedPhotoData(data: Data) {
//        backgroundImage = UIImage(named: "coffee-1")
        backgroundImage = UIImage(data: data)
    }
    
}


struct DrawingView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingView(drawing: DrawingThumbnail(name: "coffee-0"))
    }
}
