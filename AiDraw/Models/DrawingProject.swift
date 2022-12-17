//
//  ProjectModel.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/28/22.
//

import Foundation
import PencilKit

struct DrawingSnapshot: Codable {
    var drawing: PKDrawing?
    @CodableImage var backgroundImage: UIImage?
}

struct DrawingProject: Identifiable, Codable {
    var id = UUID()
    var createdDate = Date()
    var name: String
    var drawing: PKDrawing = PKDrawing()
    var prompt: String = ""
    var backwardsSnapshots: [DrawingSnapshot] = []
    var forwardSnapshots: [DrawingSnapshot] = []
    @CodableImage var backgroundImage: UIImage? = UIImage(color: .white)
    @CodableImage var displayImage: UIImage? = UIImage(color: .white)
}
