//
//  Extensions.swift
//  AiDraw
//
//  Created by Kiet Ho on 12/10/22.
//

import SwiftUI
import Foundation

// Create image with solid color background 
public extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

// String to json conversion
public extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

extension View {
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
}
