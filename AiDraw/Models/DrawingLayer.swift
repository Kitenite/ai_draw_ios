//
//  DrawingLayer.swift
//  AiDraw
//
//  Created by Kiet Ho on 1/1/23.
//

import SwiftUI

struct DrawingLayer: Codable, Equatable {
    var id = UUID()
    let title: String
    @CodableImage var image: UIImage?
    var isActive: Bool
    var isVisible: Bool
    
    static func == (lhs: DrawingLayer, rhs: DrawingLayer) -> Bool {
        lhs.id.uuidString == rhs.id.uuidString
    }
}
