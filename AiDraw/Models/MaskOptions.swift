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
    var sourceImage: UIImage = UIImage()
    var canvasView = PKCanvasView()
    var maskImage: UIImage?
    var invertMask: Bool = false
}
