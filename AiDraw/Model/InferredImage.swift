//
//  InferredImage.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/21/22.
//

import Foundation
import SwiftUI

struct InferredImage: Identifiable {
  let id = UUID()
  let inferredImage: UIImage
  let sourceImage: UIImage
}
