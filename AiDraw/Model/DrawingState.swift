//
//  InferredImage.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/21/22.
//

import Foundation
import SwiftUI
import PencilKit

struct DrawingState: Identifiable {
    let id = UUID()
    var name: String
    var backgroundImage: UIImage?
    var drawing: PKDrawing?
    var thumbnailImage: UIImage?
}
