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
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    // Drawing
    @Binding var drawingProject: DrawingProject
    @State private var canvasView = PKCanvasView()
    @State private var prompt = ""
    @State private var erasedDrawing: PKDrawing?

    // Image picker
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    // Background images
    @State private var backgroundImages: [UIImage] = []
    
    // State of the application
    @State private var isUploadingDrawing = false
    @State private var isRunningInference = false
    @State private var isShowingSidebar = false

    // Helpers
    internal var imageHelper = ImageHelper()
    
    var body: some View {
        NavigationStack {
            ZStack {
                if (drawingProject.backgroundImage != nil) {
                    Image(uiImage: drawingProject.backgroundImage!)
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                        .padding(20.0)
                }
                CanvasView(canvasView: $canvasView, onSaved: saveDrawing)
                    .padding(20.0)
                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                    .navigationBarTitle(Text(drawingProject.name), displayMode: .inline)
                    .navigationBarBackButtonHidden(true)
                    .navigationBarItems(
                        leading: HStack {
                            Button(action : {
                                self.mode.wrappedValue.dismiss()
                                saveProjectState()
                            }){
                                Image(systemName: "chevron.backward")
                            }
                            Spacer(minLength: 10)
                            Button(action: downloadCurrentDrawingAndBackground) {
                                Image(systemName: "square.and.arrow.down")
                            }
                            if ((erasedDrawing) != nil) {
                                Button(action: restoreDrawing) {
                                    Image(systemName: "arrow.uturn.left")
                                }
                            }
                            Button(action: deleteDrawing) {
                                Image(systemName: "trash")
                            }
                        },
                        trailing: HStack {
                            if (isRunningInference) {
                                ProgressView()
                            } else {
                                Button(action: uploadDrawingForInference) {
                                    Image(systemName: "brain")
                                }.sheet(isPresented: $isUploadingDrawing) {
                                    PostToInferenceModalView(sourceImage: getDrawingAsImageWithBackground(), addInferredImage: addInferredImage, startInferenceHandler: startInferenceHandler, prompt: prompt)
                                }
                            }
                            
                            // Upload photo button
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
                            
                            // History button
                            if( backgroundImages.count > 0) {
                                Button {
                                    isShowingSidebar = true
                                } label: {
                                    Image(systemName: "square.3.stack.3d.top.filled")
                                }.popover(
                                    isPresented: $isShowingSidebar,
                                    arrowEdge: .top
                                ) {
                                    HistoryPopoverView(backgroundImages: backgroundImages, downloadImage: imageHelper.downloadImage )
                                }
                            }

                        }
                    )
            }
        }
    }
}

private extension DrawingView {
    func saveDrawing() {}
    
    func saveProjectState() {
        drawingProject.drawing = canvasView.drawing
        drawingProject.displayImage = getDrawingAsImageWithBackground()
    }
    
    func getDrawingAsImageWithBackground() -> UIImage {
        let drawingImage = getDrawingAsImage()
        if (drawingProject.backgroundImage != nil) {
            return imageHelper.overlayDrawingOnBackground(backgroundImage: drawingProject.backgroundImage!, drawingImage: drawingImage, canvasSize: canvasView.frame.size)
        }
        return drawingImage
    }
    
    func getDrawingAsImage() -> UIImage {
        return canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
    }
    
    
    func downloadCurrentDrawingAndBackground() {
        let currentDrawingAndBackground = getDrawingAsImageWithBackground()
        imageHelper.downloadImage(image: currentDrawingAndBackground)
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
        let croppedImage = imageHelper.cropImageToRect(sourceImage: newInferredImage.inferredImage, cropRect: CGRect(origin: CGPoint.zero, size: canvasView.frame.size))
        addImageToBackgroundImages(newImage: croppedImage)
        deleteDrawing()
        isRunningInference = false
    }
    
    func handleUploadedPhotoData(data: Data) {
        let uploadedPhoto = UIImage(data: data)
        if (uploadedPhoto != nil) {
            let croppedImage = imageHelper.cropImageToRect(sourceImage: uploadedPhoto!, cropRect: CGRect(origin: CGPoint.zero, size: canvasView.frame.size))
            addImageToBackgroundImages(newImage: croppedImage)
        }
   
    }
    
    func addImageToBackgroundImages(newImage: UIImage) {
        backgroundImages.append(newImage)
        drawingProject.backgroundImage = newImage
    }
    
    func deleteDrawing() {
        erasedDrawing = canvasView.drawing
        canvasView.drawing = PKDrawing()
    }
    
    func restoreDrawing() {
        if (erasedDrawing != nil) {
            canvasView.drawing = erasedDrawing!
        }
    }
}

struct DrawingView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingView(drawingProject: .constant(DrawingProject(name: "coffee-1")))
    }
}