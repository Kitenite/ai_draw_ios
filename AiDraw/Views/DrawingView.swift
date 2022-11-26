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
    @Environment(\.presentationMode) private var mode: Binding<PresentationMode>
    @Environment(\.scenePhase) private var scenePhase

    // Drawing
    @Binding var drawingProject: DrawingProject
    @Binding var selection: String?
    
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
    internal var inferenceHandler = InferenceHandler()

    // Alert
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

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
                CanvasView(canvasView: $canvasView, drawing: drawingProject.drawing, onSaved: saveDrawing)
                    .padding(20.0)
                    .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                    .navigationBarTitle(Text(drawingProject.name), displayMode: .inline)
                    .navigationBarBackButtonHidden(true)
                    .navigationBarItems(
                        leading: HStack {
                            Button(action : dismissDrawingView){
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
                                    PostToInferenceModalView(sourceImage: getDrawingAsImageWithBackground(), addInferredImage: addInferredImage, inferenceFailed: inferenceFailed, startInferenceHandler: startInferenceHandler, prompt: prompt)
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
        }.onChange(of: scenePhase) { newScenePhase in
            saveProjectState()
        }.alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage)
            )
        }
    }
}

private extension DrawingView {
    func saveDrawing() {
        drawingProject.drawing = canvasView.drawing
        inferenceHandler.wakeService()
    }
    
    func saveProjectState() {
        drawingProject.drawing = canvasView.drawing
        drawingProject.displayImage = getDrawingAsImageWithBackground()
    }
    
    func dismissDrawingView() {
        saveProjectState()
        DispatchQueue.main.async {
            selection = nil
            self.mode.wrappedValue.dismiss()
        }
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
    
    func inferenceFailed(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        isRunningInference = false
        showAlert = true
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
        saveProjectState()
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
        DrawingView(drawingProject: .constant(DrawingProject(name: "coffee-1")), selection: .constant(nil))
    }
}
