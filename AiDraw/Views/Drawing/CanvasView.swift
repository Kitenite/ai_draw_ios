//
//  CanvasView.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/20/22.
//

import SwiftUI

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
        canvasView.tool = PKInkingTool(.pen, color: .gray, width: 10)
        #if targetEnvironment(simulator)
          canvasView.drawingPolicy = .anyInput
        #endif
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawing = drawing
        if (!isMask) {
            showToolPicker()
        } else {
            canvasView.tool = PKInkingTool( PKInkingTool.InkType.marker, color: .lightGray, width: 30)
        }
        canvasView.delegate = context.coordinator
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}

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
