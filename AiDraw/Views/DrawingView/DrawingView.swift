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
    
    // Drawing
    var drawing: DrawingState
    @State private var canvasView = PKCanvasView()
    @State private var prompt = ""
    @State private var erasedDrawing: PKDrawing?

    // Image picker
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    // Background images
    @State private var drawingStates: [DrawingState] = []
    @State private var selectedDrawingState: DrawingState = DrawingState(name:"coffee-1")
    
    // State of the application
    @State private var isUploadingDrawing = false
    @State private var isRunningInference = false
    @State private var isShowingPopover = false

    
    var body: some View {
        NavigationStack {
            ZStack {
                if (selectedDrawingState.backgroundImage != nil) {
                    Image(uiImage: selectedDrawingState.backgroundImage!)
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
//                            Button {
//                                isShowingPopover = true
//                            } label: {
//                                Image(systemName: "square.3.stack.3d.top.filled")
//                            }.popover(
//                                isPresented: $isShowingPopover,
//                                arrowEdge: .top
//                            ) {
//                                // Add drawing states in here, show as list, swap with select using handler
//                                let mockDrawingStates =  [DrawingState(image: UIImage(named: "coffee-1")!), DrawingState(image: UIImage(named: "coffee-2")!)]
//                                StatesPopoverView(drawingStates: mockDrawingStates, selectedDrawingState: mockDrawingStates[0], onStateSelected: onDrawingStateSelected)
//                                    .frame(height: 1000)
//                            }
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

                        }
                    )
            }
        }
    }
}

private extension DrawingView {
    
    func saveDrawing() {}
    
    func getDrawingAsImageWithBackground() -> UIImage {
        let drawingImage = getDrawingAsImage()
        if (backgroundImage != nil) {
            return overlayDrawingOnBackground(backgroundImage: backgroundImage!, drawingImage: drawingImage)
        }
        return drawingImage
    }
    
    func getDrawingAsImage() -> UIImage {
        return canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
    }
    
    func overlayDrawingOnBackground(backgroundImage: UIImage, drawingImage : UIImage) -> UIImage {
        let newImage = autoreleasepool { () -> UIImage in
            
            UIGraphicsBeginImageContextWithOptions(canvasView.frame.size, false, 0.0)
            backgroundImage.draw(in: CGRect(origin: CGPoint.zero, size: canvasView.frame.size))
            drawingImage.draw(in: CGRect(origin: CGPoint.zero, size: canvasView.frame.size))
            let createdImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            return createdImage ?? drawingImage
        }
        return newImage
    }
    
    func downloadDrawing() {
      let image = getDrawingAsImageWithBackground()
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
        let croppedImage = cropImageToRect(sourceImage: newInferredImage.inferredImage, cropRect: CGRect(origin: CGPoint.zero, size: canvasView.frame.size))
        addImageToBackgroundImages(newImage: croppedImage)
        deleteDrawing()
        isRunningInference = false
    }
    
    func handleUploadedPhotoData(data: Data) {
        let uploadedPhoto = UIImage(data: data)
        if (uploadedPhoto != nil) {
            let croppedImage = cropImageToRect(sourceImage: uploadedPhoto!, cropRect: CGRect(origin: CGPoint.zero, size: canvasView.frame.size))
            addImageToBackgroundImages(newImage: croppedImage)
        }
   
    }
    
    func cropImageToRect(sourceImage: UIImage, cropRect: CGRect) -> UIImage {
        // The shortest side
        let sideLength = min(
            sourceImage.size.width,
            sourceImage.size.height
        )
        
        // Determines the x,y coordinate of a centered
        // sideLength by sideLength square
        let sourceSize = sourceImage.size
        let xOffset = (sourceSize.width - sideLength) / 2.0
        let yOffset = (sourceSize.height - sideLength) / 2.0

        // The cropRect is the rect of the image to keep,
        // in this case centered
        let cropRect = CGRect(
            x: xOffset,
            y: yOffset,
            width: sideLength,
            height: sideLength
        ).integral

        // Center crop the image
        let sourceCGImage = sourceImage.cgImage!
        let croppedCGImage = sourceCGImage.cropping(
            to: cropRect
        )!
        
        // Use the cropped cgImage to initialize a cropped
        // UIImage with the same image scale and orientation
        let croppedImage = UIImage(
            cgImage: croppedCGImage,
            scale: sourceImage.imageRendererFormat.scale,
            orientation: sourceImage.imageOrientation
        )
        
        return croppedImage
    }
    
    func addImageToBackgroundImages(newImage: UIImage) {
        backgroundImages.append(newImage)
        backgroundImage = newImage
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
    
    func onDrawingStateSelected(drawingState: DrawingState) {

    }
}


struct DrawingView_Previews: PreviewProvider {
    static var previews: some View {
//        let mockBackgroundImages = [UIImage(named: "coffee-0"), UIImage(named: "coffee-1")]
        DrawingView(drawing: DrawingState(name: "coffee-0"))
    }
}
