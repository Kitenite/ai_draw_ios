//
//  DrawingView.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/19/22.
//

import SwiftUI
import PencilKit
import PhotosUI

struct DrawingSnapshot {
    let drawing: PKDrawing
    let background: UIImage?
}

struct DrawingView: View {
    @Environment(\.presentationMode) private var mode: Binding<PresentationMode>
    @Environment(\.scenePhase) private var scenePhase

    // Drawing
    @Binding var drawingProject: DrawingProject
    @State private var canvasView = PKCanvasView()
    @State private var prompt = ""
    
    // History
    @State private var backwardsSnapshots: [DrawingSnapshot] = []
    @State private var forwardSnapshots: [DrawingSnapshot] = []

    // Image picker
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    // State of the application
    @State private var isUploadingDrawing = false
    @State private var isRunningInference = false
    @State private var isShowingSidebar = false

    // Helpers
    internal var imageHelper = ImageHelper()
    internal var inferenceHelper = InferenceHelper()

    // Alert
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // Tooltip
    @State private var tooltipVisible = true
    
    // Cluster status
    @State internal var runningTasksCount: Int = 0
    @State var clusterStatusTimer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button(action: restoreBackwardsSnapshot) {
                        Image(systemName: "arrow.uturn.left")
                    }.disabled(backwardsSnapshots.isEmpty)
                    Button(action: restoreForwardSnapshot) {
                        Image(systemName: "arrow.uturn.right")
                    }.disabled(forwardSnapshots.isEmpty)
                    Button(action: clearDrawing) {
                        Image(systemName: "eraser")
                    }
                    Button(action: clearBackground) {
                        Image(systemName: "trash")
                    }
                    Spacer()
                    // Service state and button
                    if (runningTasksCount <= 0) {
                        Text("Starting service...")
                    }
                    if (isRunningInference) {
                        ProgressView()
                    } else {
                        Button(action: uploadDrawingForInference) {
                            Image(systemName: "brain")
                        }.sheet(isPresented: $isUploadingDrawing) {
                            PostToInferenceModalView(sourceImage: getDrawingAsImageWithBackground(), addInferredImage: addInferredImage, inferenceFailed: inferenceFailed, startInferenceHandler: startInferenceHandler, prompt: prompt)
                        }.disabled(runningTasksCount <= 0)
                    }
                  
                }
                .padding(.horizontal)
                .task {
                    inferenceHelper.getClusterStatus(handler: clusterStatusHandler)
                }.onReceive(clusterStatusTimer) { time in
                    inferenceHelper.getClusterStatus(handler: clusterStatusHandler)
                }
                    
                ZStack {
                    if (drawingProject.backgroundImage != nil) {
                        Image(uiImage: drawingProject.backgroundImage!)
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                    }
                    CanvasView(canvasView: $canvasView, drawing: drawingProject.drawing, onSaved: saveDrawing)
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
                                PhotosPicker(
                                    selection: $selectedItem,
                                    matching: .images,
                                    photoLibrary: .shared()
                                ) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                }.onChange(of: selectedItem) { newItem in
                                    Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                            handleImportedPhoto(data: data)
                                            print(data)
                                        }
                                    }
                                }
                            },
                            trailing: HStack {
                                
                                // History button
//                                if( backgroundImages.count > 0) {
//                                    Button {
//                                        isShowingSidebar = true
//                                    } label: {
//                                        Image(systemName: "square.3.stack.3d.top.filled")
//                                    }.popover(
//                                        isPresented: $isShowingSidebar,
//                                        arrowEdge: .top
//                                    ) {
//                                        HistoryPopoverView(backgroundImages: backgroundImages, downloadImage: imageHelper.downloadImage )
//                                    }
//                                }
                                Button(action: showInfoAlert) {
                                    Image(systemName: "questionmark.circle")
                                }
                            }
                        )
                    .border(/*@START_MENU_TOKEN@*/Color.gray/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                }
            }
        }.onChange(of: scenePhase) { newScenePhase in
            saveProjectState()
        }.alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage)
            )
        }.task {
            inferenceHelper.wakeService()
        }
    }
}

private extension DrawingView {
    func saveDrawing() {
        drawingProject.drawing = canvasView.drawing
        inferenceHelper.wakeService()
        saveBackwardsSnapshot()
    }
    
    func saveProjectState() {
        drawingProject.displayImage = getDrawingAsImageWithBackground()
        drawingProject.drawing = canvasView.drawing
    }
    
    func dismissDrawingView() {
        saveProjectState()
        self.mode.wrappedValue.dismiss()
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
        clearDrawing()
        updateBackgroundImage(newImage: croppedImage)
        isRunningInference = false
    }
    
    func inferenceFailed(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        isRunningInference = false
        showAlert = true
    }
    
    func handleImportedPhoto(data: Data) {
        let importedPhoto = UIImage(data: data)
        if (importedPhoto != nil) {
            let croppedImage = imageHelper.cropImageToRect(sourceImage: importedPhoto!, cropRect: CGRect(origin: CGPoint.zero, size: canvasView.frame.size))
            saveBackwardsSnapshot()
            updateBackgroundImage(newImage: croppedImage)
        }
    }
    
    func updateBackgroundImage(newImage: UIImage) {
        drawingProject.backgroundImage = newImage
        saveProjectState()
    }
    
    func clusterStatusHandler(clusterStatusResponse: ClusterStatusResponse) {
        runningTasksCount = clusterStatusResponse.runningTasksCount
    }
    
    func showInfoAlert() {
        if (runningTasksCount == 0) {
            alertTitle = "Service is starting"
            alertMessage = "The service turned off because no users were active. It could take 5-10 minutes to turn it back on. You can still use the rest of the functionalities."
            
        } else {
            alertTitle = "Service is running"
            alertMessage = "Hit the brain button and provide a prompt to transform your image. The service will turn off after 15 minutes of inactivity."
        }
        showAlert = true
    }
   
    func clearDrawing() {
        saveBackwardsSnapshot()
        canvasView.drawing = PKDrawing()
    }
    
    func clearBackground() {
        saveBackwardsSnapshot()
        drawingProject.backgroundImage = nil
    }
    
    func createSnapshot() -> DrawingSnapshot {
        let newSnapshot = DrawingSnapshot(drawing: canvasView.drawing, background: drawingProject.backgroundImage)
        return newSnapshot
    }
    
    func saveBackwardsSnapshot() {
        let newSnapshot = createSnapshot()
        backwardsSnapshots.append(newSnapshot)
    }
    
    func saveForwardSnapshot() {
        let newSnapshot = createSnapshot()
        forwardSnapshots.append(newSnapshot)
    }
    
    func restoreBackwardsSnapshot() {
        saveForwardSnapshot()
        if (!backwardsSnapshots.isEmpty ) {
            let snapshot = backwardsSnapshots.popLast()
            if (snapshot != nil) {
                applySnapshot(snapshot: snapshot!)
            }
           
        }
    }
    
    func restoreForwardSnapshot() {
        saveBackwardsSnapshot()
        if (!forwardSnapshots.isEmpty ) {
            let snapshot = forwardSnapshots.popLast()
            if (snapshot != nil) {
               applySnapshot(snapshot: snapshot!)
            }
           
        }
    }
    
    func applySnapshot(snapshot: DrawingSnapshot) {
        canvasView.drawing = snapshot.drawing
        drawingProject.backgroundImage = snapshot.background
        saveProjectState()
    }
}

struct DrawingView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingView(drawingProject: .constant(DrawingProject(name: "coffee-1", backgroundImage: UIImage(named: "coffee-1"))))
    }
}
