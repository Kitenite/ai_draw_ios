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
    // Environment variables
    @Environment(\.presentationMode) private var mode: Binding<PresentationMode>
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.undoManager) private var undoManager
    @EnvironmentObject private var alertManager: AlertManager
    @EnvironmentObject var adsViewModel: AdsViewModel
    
    // Drawing
    @Binding var drawingProject: DrawingProject
    @State private var canvasView = PKCanvasView()

    // Image picker
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    // State of the application
    @State private var isUploadingDrawing = false
    @State private var isRunningInference = false
    @State private var isShowingOnboarding = true

    // Helpers
    internal var imageHelper = ImageHelper()
    internal var serviceHelper = ServiceHelper()
    
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
                BannerAdVIew(adPosition: .top, adUnitId: Constants.TEST_BANNER_AD_ID)
                Spacer()
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
                    
                    if (runningTasksCount <= 0) {
                        Text("Waking AI...")
                    }
                    
                    if (!isRunningInference && runningTasksCount > 0) {
                        Button(action: uploadDrawingForInference) {
                            Text("Use AI")
                        }.sheet(isPresented: $isUploadingDrawing) {
                            PostToInferenceModalView(sourceImage: canvasView.getDrawingAsImage(backgroundImage: drawingProject.backgroundImage), prompt: drawingProject.prompt, addInferredImageHandler: addInferredImage, inferenceFailedHandler: inferenceFailed, startInferenceHandler: startInferenceHandler)
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
                        .border(/*@START_MENU_TOKEN@*/Color.gray/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                }
                Spacer()
                BannerAdVIew(adPosition: .bottom, adUnitId: Constants.BANNER_AD_ID)
            }
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
                    Button(action: {isShowingOnboarding = true}) {
                        Image(systemName: "questionmark.circle")
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
    
    func startInferenceHandler(newPrompt: String) {
        isUploadingDrawing = false
        isRunningInference = true
        drawingProject.prompt = newPrompt
        inferenceProgressBar.startTimer()
        showInterstiltialAd()
    }
    
    func showInterstiltialAd() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            adsViewModel.showInterstitial = true
        }
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
    
    func clearDrawing() {
        saveBackwardsSnapshot()
        canvasView.drawing = PKDrawing()
    }
    
    func clearBackground() {
        saveBackwardsSnapshot()
        drawingProject.backgroundImage = UIImage(color: .white)
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
    }
}

struct DrawingView_Previews: PreviewProvider {
    static let mockAlertManager = AlertManager()
    static var previews: some View {
        DrawingView(drawingProject: .constant(DrawingProject(name: "Coffee", backgroundImage: UIImage(named: "coffee-1"))))
            .environmentObject(mockAlertManager)
    }
}
