//
//  InpaintView.swift
//  AiDraw
//
//  Created by Kiet Ho on 12/25/22.
//

import SwiftUI
import PencilKit

struct CreateMaskModalView: View {
    @Environment(\.dismiss) private var dismiss

    // Masking for inpainting
    @Binding var maskOptions: MaskOptions
    @State private var isMasking = false
    
    let normalText = "AI will fill in the MASKED parts"
    let invertedText = "AI will fill in the UNMASKED parts"
    
    var body: some View {
        VStack {
            HStack() {
                Button(action: goBackWithoutSaving) {
                    Text("Cancel")
                }
                Spacer()
                Button(action: {
                    maskOptions.canvasView.drawing = PKDrawing()
                }) {
                    Text("Clear mask")
                }
            }
            ZStack {
                Image(uiImage: maskOptions.sourceImage)
                    .aspectRatio(1, contentMode: .fit)
                CanvasView(canvasView: $maskOptions.canvasView, drawing: maskOptions.canvasView.drawing, onSaved: saveMask, isMask: true)
                    .aspectRatio(1, contentMode: .fit)
                    .border(Color.gray, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
            }
            Text("Draw your mask. \(maskOptions.invertMask ? invertedText : normalText)")
            Toggle(isOn: $maskOptions.invertMask) {
                Text("Invert mask")
            }
            Button("Apply changes") {
                applyMask()
                dismiss()
            }
            Spacer()
        }
        .padding()
    }
}

extension CreateMaskModalView {
    func saveMask() {}

    func applyMask() -> Void {
        if (maskOptions.canvasView.drawing.bounds.isEmpty) {
            maskOptions.maskImage = nil
        } else {
            maskOptions.maskImage = maskOptions.canvasView.getMaskAsImage(invert: maskOptions.invertMask)
        }
    }
    
    func goBackWithoutSaving() -> Void {
        dismiss()
    }
}

struct CreateMaskModalView_Previews: PreviewProvider {
    static var previews: some View {
        CreateMaskModalView(maskOptions: .constant(MaskOptions()))
    }
}
