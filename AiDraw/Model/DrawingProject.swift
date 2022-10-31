//
//  ProjectModel.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/28/22.
//

import Foundation
import PencilKit

struct DrawingProject: Identifiable, Codable {
    var id = UUID()
    var createdDate = Date()
    var name: String
    var drawing: PKDrawing = PKDrawing()
    @CodableImage var backgroundImage: UIImage?
    @CodableImage var displayImage: UIImage? = UIImage(named:"coffee-1")
}
