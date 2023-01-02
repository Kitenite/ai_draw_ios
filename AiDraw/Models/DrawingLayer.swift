//
//  DrawingLayer.swift
//  AiDraw
//
//  Created by Kiet Ho on 1/1/23.
//
import SwiftUI

struct DrawingLayer: Codable, Equatable {
    var id = UUID()
    var title: String = "Layer 1"
    @CodableImage var image: UIImage?
    var isVisible: Bool = true
    
    static func == (lhs: DrawingLayer, rhs: DrawingLayer) -> Bool {
        lhs.id.uuidString == rhs.id.uuidString
    }
}
