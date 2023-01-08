//
//  MaskOptions.swift
//  AiDraw
//
//  Created by Kiet Ho on 12/27/22.
//

import Foundation
import SwiftUI
import PencilKit

struct MaskOptions {
    var prompt: String = ""
    var sourceImage: UIImage? = UIImage()
    var canvasView: PKCanvasView = PKCanvasView()
    var maskImage: UIImage?
    var invertMask: Bool = false
}
