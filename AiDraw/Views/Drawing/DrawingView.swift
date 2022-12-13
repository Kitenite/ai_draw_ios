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
    @State private var canvasView = PKCanvasView()

    // Image picker
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    // State of the application
    @State private var isUploadingDrawing = false
    @State private var isRunningInference = false
    @State private var isShowingSidebar = false

    // Helpers
    internal var imageHelper = ImageHelper()
    internal var serviceHelper = ServiceHelper()

    // Alert
    @State private var showOnboarding = true
    @EnvironmentObject private var alertManager: AlertManager
    
    // Cluster status
    @State internal var runningTasksCount: Int = 0
    @State var clusterStatusTimer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    @State var clusterWakeTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    // Progress bars
    let inferenceProgressBar = ProgressBarView(title: "", currentValue: 0, totalValue: 100)
    let clusterStatusProgressBar = ProgressBarView(title: "", currentValue: 0, totalValue: 4500)

    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    if (isRunningInference) {
                        inferenceProgressBar
                    }
                    if (runningTasksCount <= 0) {
                        clusterStatusProgressBar
                    }
                }
                Spacer()
                HStack {
                    Button(action: restoreBackwardsSnapshot) {
                        Image(systemName: "arrow.uturn.left")
                    }.disabled(drawingProject.backwardsSnapshots.isEmpty)
                    Button(action: restoreForwardSnapshot) {
                        Image(systemName: "arrow.uturn.right")
                    }.disabled(drawingProject.forwardSnapshots.isEmpty)
                    Button(action: clearDrawing) {
                        Image(systemName: "eraser")
                    }
                    Button(action: clearBackground) {
                        Image(systemName: "trash")
                    }
                    Spacer()
                    // Service state and button
                    if (runningTasksCount <= 0) {
                        Text("Waking AI...")
                    }
                    
                    if (!isRunningInference && runningTasksCount > 0) {
                        Button(action: uploadDrawingForInference) {
                            Text("Use AI")
                        }.sheet(isPresented: $isUploadingDrawing) {
                            PostToInferenceModalView(sourceImage: getDrawingAsImageWithBackground(), prompt: drawingProject.prompt, addInferredImageHandler: addInferredImage, inferenceFailedHandler: inferenceFailed, startInferenceHandler: startInferenceHandler)
                        }
                    } else {
                        ProgressView()
                    }
                }
                .padding(.horizontal)
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
                                        }
                                    }
                                }
                            },
                            trailing: HStack {
                                Button(action: {showOnboarding = true}) {
                                    Image(systemName: "questionmark.circle")
                                }
                            }
                        )
                        .border(/*@START_MENU_TOKEN@*/Color.gray/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                }
                Spacer()
            }
        }.onChange(of: scenePhase) { newScenePhase in
            saveProjectState()
        }.task {
            serviceHelper.wakeService()
            serviceHelper.getClusterStatus(handler: clusterStatusHandler)
        }.onReceive(clusterStatusTimer) { time in
            serviceHelper.getClusterStatus(handler: clusterStatusHandler)
        }.onReceive(clusterWakeTimer) { time in
            serviceHelper.wakeService()
        }.alert(isPresented: $alertManager.isPresented) {
            alertManager.alert
        }.fullScreenCover(isPresented: $showOnboarding, content: {
            OnboardingView(showOnboarding: $showOnboarding)
        })
    }
}

private extension DrawingView {
    func saveDrawing() {
        drawingProject.drawing = canvasView.drawing
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
        drawingProject.prompt = newPrompt
        inferenceProgressBar.startTimer()
     }
    
    func addInferredImage(inferredImage: UIImage) {
        let croppedImage = imageHelper.cropImageToRect(sourceImage: inferredImage, cropRect: CGRect(origin: CGPoint.zero, size: canvasView.frame.size))
        clearDrawing()
        updateBackgroundImage(newImage: croppedImage)
        isRunningInference = false
        inferenceProgressBar.stopTimer()
    }
    
    func inferenceFailed(title: String, message: String) {
        alertManager.presentAlert(title: title, message: message, dismissButton: nil)
        isRunningInference = false
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
        if (runningTasksCount > 0) {
            clusterStatusTimer.upstream.connect().cancel()
            clusterStatusProgressBar.stopTimer()
        } else {
            
            if (!clusterStatusProgressBar.isTimerActive && !inferenceProgressBar.isTimerActive) {
                clusterStatusProgressBar.startTimer()
            }
        }
    }
    
    func showInfoAlert() {
        var title = "AI is ready"
        var message = "Send it your drawing and description for enhancement"
        if (runningTasksCount == 0) {
            title = "AI is waking up"
            message = "AI went to sleep from inactivity.\nIt'll take 5 minutes to wake it.\nUse this time to create your drawing."
        }
        alertManager.presentAlert(title: title, message: message, dismissButton: nil)
    }
   
    func clearDrawing() {
        saveBackwardsSnapshot()
        canvasView.drawing = PKDrawing()
    }
    
    func clearBackground() {
        saveBackwardsSnapshot()
        drawingProject.backgroundImage = UIImage(color: .white)
    }
    
    func createSnapshot() -> DrawingSnapshot {
        let newSnapshot = DrawingSnapshot(drawing: canvasView.drawing, backgroundImage: drawingProject.backgroundImage)
        return newSnapshot
    }
    
    func saveBackwardsSnapshot() {
        let newSnapshot = createSnapshot()
        drawingProject.backwardsSnapshots.append(newSnapshot)
    }
    
    func saveForwardSnapshot() {
        let newSnapshot = createSnapshot()
        drawingProject.forwardSnapshots.append(newSnapshot)
    }
    
    func restoreBackwardsSnapshot() {
        saveForwardSnapshot()
        if (!drawingProject.backwardsSnapshots.isEmpty) {
            let snapshot = drawingProject.backwardsSnapshots.popLast()
            if (snapshot != nil) {
                applySnapshot(snapshot: snapshot!)
            }
        }
    }
    
    func restoreForwardSnapshot() {
        saveBackwardsSnapshot()
        if (!drawingProject.forwardSnapshots.isEmpty ) {
            let snapshot = drawingProject.forwardSnapshots.popLast()
            if (snapshot != nil) {
               applySnapshot(snapshot: snapshot!)
            }
        }
    }
    func applySnapshot(snapshot: DrawingSnapshot) {
        canvasView.drawing = snapshot.drawing
        drawingProject.backgroundImage = snapshot.backgroundImage
        saveProjectState()
    }
}

struct DrawingView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingView(drawingProject: .constant(DrawingProject(name: "coffee-1", backgroundImage: UIImage(named: "coffee-1"))))
    }
}
