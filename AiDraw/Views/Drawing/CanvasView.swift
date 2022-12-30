//
//  CanvasView.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/20/22.
//

import SwiftUI
import PencilKit

struct CanvasView {
    @Binding var canvasView: PKCanvasView
    var drawing: PKDrawing
    let onSaved: () -> Void
    var isMask: Bool = false
    @State var toolPicker = PKToolPicker()
}

// MARK: - UIViewRepresentable
extension CanvasView: UIViewRepresentable {
    func makeUIView(context: Context) -> PKCanvasView {
        #if targetEnvironment(simulator)
          canvasView.drawingPolicy = .anyInput
        #endif
        
        canvasView.tool = PKInkingTool(.pen, color: .gray, width: 10)
        canvasView.drawing = drawing
        
        // Force light mode for consistency
        toolPicker.colorUserInterfaceStyle = .light
        canvasView.overrideUserInterfaceStyle = .light
        
        // Clear background for custom background
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        setupCanvas(context: context)
        return canvasView
    }
    
    func setupCanvas(context: Context){
        if (!isMask) {
            showToolPicker()
        } else {
            canvasView.drawingPolicy = .anyInput
            canvasView.tool = PKInkingTool(.marker, color: .lightGray, width: 50)
        }
        canvasView.delegate = context.coordinator
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Run when screen size changes or reappear
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(canvasView: $canvasView, onSaved: onSaved)
    }
}

private extension CanvasView {
    func showToolPicker() {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }
}

class Coordinator: NSObject {
  var canvasView: Binding<PKCanvasView>
  let onSaved: () -> Void

  init(canvasView: Binding<PKCanvasView>, onSaved: @escaping () -> Void) {
    self.canvasView = canvasView
    self.onSaved = onSaved
  }
}

extension Coordinator: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        if !canvasView.drawing.bounds.isEmpty {
          onSaved()
        }
    }
}

extension PKCanvasView {
    func getDrawingAsImage(backgroundImage: UIImage? = nil) -> UIImage {
        var drawingImage: UIImage? = nil
        self.traitCollection.performAsCurrent {
            drawingImage = self.drawing.image(from: self.bounds, scale: UIScreen.main.scale)
        }
        if (backgroundImage != nil) {
            drawingImage = ImageHelper.shared.overlayDrawingOnBackground(backgroundImage: backgroundImage!, drawingImage: drawingImage!, canvasSize: self.frame.size)
        }
        return drawingImage!
    }
    
    func getMaskAsImage(invert: Bool = false) -> UIImage {
        var strokeColor: UIColor = .white
        var backgroundColor: UIColor = .black

        if (invert) {
            strokeColor = .black
            backgroundColor = .white
        }
        
        if !self.drawing.strokes.isEmpty {
            self.drawing.strokes[0].ink.color = strokeColor
        }
        return getDrawingAsImage(backgroundImage: UIImage(color: backgroundColor))
    }
}
