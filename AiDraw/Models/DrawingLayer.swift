//
//  DrawingLayer.swift
//  AiDraw
//
//  Created by Kiet Ho on 1/1/23.
//

import SwiftUI

struct DrawingLayer: Codable {
    @CodableImage var image: UIImage?
    let title: String
    var isActive: Bool
    var isVisible: Bool
}
