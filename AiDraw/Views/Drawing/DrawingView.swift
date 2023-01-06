//
//  DrawingView.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/19/22.
//

import SwiftUI
import PencilKit
import StoreKit

struct DrawingView: View {
    // Environment variables
    @Environment(\.presentationMode) private var mode: Binding<PresentationMode>
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.undoManager) private var undoManager
    @Environment(\.requestReview) var requestReview
    @EnvironmentObject private var alertManager: AlertManager
    @AppStorage("inference_count") var inferenceCount = 0
    
    // Drawing
    @Binding var drawingProject: DrawingProject
    @State private var canvasView = PKCanvasView()
    
    // State of the application
    @State private var isUploadingDrawing = false
    @State private var isRunningInference = false
    @State private var isShowingOnboarding = false
    @State private var isShowingLayersPopup = false
    
    @State private var isDrawingMode = true
    @State private var isDragginMode = false
    
    // Helpers
    internal var imageHelper = ImageHelper.shared
    internal var serviceHelper = ServiceHelper.shared
    internal var analytics = AnalyticsHelper.shared
    
    // Cluster status
    @State internal var runningTasksCount: Int = 0
    @State var clusterStatusTimer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    @State var clusterWakeTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    // Progress bars
    let inferenceProgressBar = ProgressBarView(title: "", currentValue: 0, totalValue: 100)
    let clusterStatusProgressBar = ProgressBarView(title: "", currentValue: 0, totalValue: 4500)
    
    // Early initialize prompt styles singleton so it is populated when user submits
    let promptStylesManager = PromptStylesManager.shared
    
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
                if (isDrawingMode) {
                    HStack {
                        Button(action: undoDrawing) {
                            Image(systemName: "arrow.uturn.left")
                        }
                        Button(action: redoDrawing) {
                            Image(systemName: "arrow.uturn.right")
                        }
                        Button(action: clearDrawing) {
                            Image(systemName: "eraser")
                        }
                        Button(action: clearBackground) {
                            Image(systemName: "trash")
                        }
                        Spacer()
                    }.padding(.horizontal)
                }
                
                ZStack {
                    if (drawingProject.backgroundImage != nil) {
                        Image(uiImage: drawingProject.backgroundImage!)
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                    }
                    CanvasView(canvasView: $canvasView, drawing: drawingProject.drawing, onSaved: saveDrawing)
                        .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                        .border(/*@START_MENU_TOKEN@*/Color.gray/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                }
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: HStack {
                    Button(action : dismissDrawingView){
                        Image(systemName: "chevron.backward")
                    }
                    Spacer(minLength: 10)
                    PhotoPickerView(photoImportedHandler: photoImportedHandler) {
                        Image(systemName: "photo")
                    }
                    Menu {
                        Section("Export") {
                            Button(action : downloadCurrentDrawingAndBackground){
                                Text("Save to photos")
                            }
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    Button(action: {isShowingOnboarding = true}) {
                        Image(systemName: "questionmark.circle")
                    }
                },
                trailing: HStack {
                    //                    Button(action : {
                    //                        isDrawingMode = false
                    //                        isDragginMode = true
                    //                    }){
                    //                        Image(systemName: (isDragginMode ? "hand.point.up.left.fill": "hand.point.up.left"))
                    //                    }
                    //
                    //                    Button(action : {
                    //                        isDragginMode = false
                    //                        isDrawingMode = true
                    //                    }){
                    //                        Image(systemName: (isDrawingMode ? "paintbrush.pointed.fill": "paintbrush.pointed"))
                    //                    }
                    //
                    //                    Button( action: {
                    //                        isShowingLayersPopup = true
                    //                    }) {
                    //                        Image(systemName: "square.on.square")
                    //                    }.popover(isPresented: $isShowingLayersPopup, arrowEdge: .top) {
                    //                        LayersModalView(layers: $drawingProject.layers, activeLayerIndex: 0)
                    //                    }
                    //
                    
                    
                    // TODO: Remove later
                    if (runningTasksCount <= 0) {
                        Text("Waking AI...")
                    }
                    
                    if (!isRunningInference && runningTasksCount > 0) {
                        Button(action: uploadDrawingForInference) {
                            Text("AI").bold().font(.title)
                        }.popover(isPresented: $isUploadingDrawing) {
                            SendToAiView(
                                image: canvasView.getDrawingAsImage(backgroundImage: drawingProject.backgroundImage),
                                prompt: drawingProject.prompt,
                                selectedArtTypeKey: drawingProject.selectedArtTypeKey,
                                selectedSubstyleKeys: drawingProject.selectedSubstyleKeys,
                                advancedOptions: drawingProject.advancedOptions,
                                addInferredImageHandler: addInferredImage,
                                inferenceFailedHandler: inferenceFailed, startInferenceHandler: startInferenceHandler
                            )
                        }
                    } else {
                        ProgressView()
                    }
                }
            )
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
        }.fullScreenCover(isPresented: $isShowingOnboarding, content: {
            OnboardingView(showOnboarding: $isShowingOnboarding)
        })
    }
}

private extension DrawingView {
    func saveDrawing() {
        saveBackwardsSnapshot()
    }
    
    func clearDrawing() {
        saveBackwardsSnapshot()
        canvasView.drawing = PKDrawing()
        analytics.logEvent(id: "clear-drawing", title: "Clear drawing")
    }
    
    func clearBackground() {
        saveBackwardsSnapshot()
        drawingProject.backgroundImage = UIImage(color: .white)
        analytics.logEvent(id: "clear-background", title: "Clear background")
    }
    
    func saveProjectState() {
        drawingProject.displayImage = canvasView.getDrawingAsImage(backgroundImage: drawingProject.backgroundImage)
        drawingProject.drawing = canvasView.drawing
    }
    
    func dismissDrawingView() {
        saveProjectState()
        self.mode.wrappedValue.dismiss()
    }
    
    func downloadCurrentDrawingAndBackground() {
        let currentDrawingAndBackground = canvasView.getDrawingAsImage(backgroundImage: drawingProject.backgroundImage)
        imageHelper.downloadImage(image: currentDrawingAndBackground)
    }
    
    func uploadDrawingForInference() {
        isUploadingDrawing = true
    }
    
    func startInferenceHandler(prompt: String, selectedArtTypeKey: String, selectedSubstyleKeys: [String], advancedOptions: AdvancedOptions) {
        isUploadingDrawing = false
        isRunningInference = true
        inferenceProgressBar.startTimer()

        // Save project settings
        drawingProject.prompt = prompt
        drawingProject.selectedArtTypeKey = selectedArtTypeKey
        drawingProject.selectedSubstyleKeys = selectedSubstyleKeys
        drawingProject.advancedOptions = advancedOptions

        analytics.logEvent(id: "uploaded-drawing", title: "Uploaded drawing")
    }
    
    func addInferredImage(inferredImage: UIImage) {
        let croppedImage = imageHelper.cropImageToRect(sourceImage: inferredImage, cropRect: CGRect(origin: CGPoint.zero, size: canvasView.frame.size))
        clearDrawing()
        updateBackgroundImage(newImage: croppedImage)
        isRunningInference = false
        inferenceProgressBar.stopTimer()
        analytics.logEvent(id: "inference-succeeded", title: "Inference succeeded")
        
        // Request review every 5 inference
        inferenceCount += 1
        if (inferenceCount % 5 == 0) {
            requestReview()
        }
    }
    
    func inferenceFailed(title: String, message: String) {
        alertManager.presentAlert(title: title, message: message, dismissButton: nil)
        isRunningInference = false
        analytics.logEvent(id: "inference-failed", title: "Inference failed")
    }
    
    func photoImportedHandler(data: Data) {
        let importedPhoto = UIImage(data: data)
        if (importedPhoto != nil) {
            let croppedImage = imageHelper.cropImageToRect(sourceImage: importedPhoto!, cropRect: CGRect(origin: CGPoint.zero, size: canvasView.frame.size))
            saveBackwardsSnapshot()
            updateBackgroundImage(newImage: croppedImage)
            analytics.logEvent(id: "import-photo", title: "Import photo")
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
    
    func createSnapshot() -> DrawingSnapshot {
        return DrawingSnapshot(drawing: canvasView.drawing, backgroundImage: drawingProject.backgroundImage)
    }
    
    func saveBackwardsSnapshot() {
        let newSnapshot = createSnapshot()
        drawingProject.backwardsSnapshots.append(newSnapshot)
    }
    
    func saveForwardSnapshot() {
        let newSnapshot = createSnapshot()
        drawingProject.forwardSnapshots.append(newSnapshot)
    }
    
    func undoDrawing() {
        let snapshot = drawingProject.backwardsSnapshots.popLast()
        if (snapshot != nil) {
            saveForwardSnapshot()
            drawingProject.backgroundImage = snapshot!.backgroundImage
            if (canvasView.drawing != snapshot!.drawing) {
                canvasView.drawing = snapshot!.drawing
            } else {
                undoManager?.undo()
            }
        } else {
            undoManager?.undo()
        }
        analytics.logEvent(id: "undo-drawing", title: "Undo drawing")
    }
    
    func redoDrawing() {
        let snapshot = drawingProject.forwardSnapshots.popLast()
        if (snapshot != nil) {
            saveBackwardsSnapshot()
            drawingProject.backgroundImage = snapshot!.backgroundImage
            if (canvasView.drawing != snapshot!.drawing) {
                canvasView.drawing = snapshot!.drawing
            } else {
                undoManager?.redo()
            }
        } else {
            undoManager?.redo()
        }
        analytics.logEvent(id: "redo-drawing", title: "Redo drawing")
    }
}

struct DrawingView_Previews: PreviewProvider {
    static let mockAlertManager = AlertManager()
    static var previews: some View {
        DrawingView(drawingProject: .constant(DrawingProject(name: "Coffee", backgroundImage: UIImage(named: "coffee-1"))))
            .environmentObject(mockAlertManager)
    }
}
