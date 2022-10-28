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
    var drawing: DrawingThumbnail
    @State private var canvasView = PKCanvasView()
    @State private var prompt = ""
    @State private var erasedDrawing: PKDrawing?

    // Image picker
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    // Background images
    @State private var backgroundImages: [UIImage] = []
    @State private var backgroundImage: UIImage?
    
    // State of the application
    @State private var isUploadingDrawing = false
    @State private var isRunningInference = false
    @State private var isShowingSidebar = false

    
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
                                    VStack {
                                        Text("History")
                                            .padding(10)
                                        ForEach(backgroundImages.indices, id: \.self) {index in
                                            HStack {
                                                Image(uiImage: backgroundImages[index])
                                                    .resizable()
                                                    .frame(width: 100, height: 100)
                                                Button {
                                                    downloadImage(image: backgroundImages[index])
                                                } label: {
                                                    Image(systemName: "square.and.arrow.down")
                                                }
                                                
                                            }
                                            
                                        }
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
    
    func downloadCurrentDrawingAndBackground() {
      let currentDrawingAndBackground = getDrawingAsImageWithBackground()
        downloadImage(image: currentDrawingAndBackground)
    }
    
    func downloadImage(image: UIImage) {
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
}


struct DrawingView_Previews: PreviewProvider {
    static var previews: some View {
//        let mockBackgroundImages = [UIImage(named: "coffee-0"), UIImage(named: "coffee-1")]
        DrawingView(drawing: DrawingThumbnail(name: "coffee-0"))
    }
}
