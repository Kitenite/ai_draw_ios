//
//  CodeableImage.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/28/22.
//

import Foundation
import SwiftUI

@propertyWrapper
public struct CodableImage: Codable {
    
    var image: UIImage?
    
    public enum CodingKeys: String, CodingKey {
        case image
    }
    
    public init(image: UIImage?) {
        self.image = image
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let b = try? container.decodeNil(forKey: CodingKeys.image), b {
            
            self.image = nil
            
        } else {
    
            let data = try container.decode(Data.self, forKey: CodingKeys.image)
            
            guard let image = UIImage(data: data) else {
                throw DecodingError.dataCorruptedError(forKey: CodingKeys.image, in: container, debugDescription: "Decoding image failed")
            }
            
            self.image = image
        
        }
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let data = image?.pngData() {
            try container.encode(data, forKey: CodingKeys.image)
        } else {
            try container.encodeNil(forKey: CodingKeys.image)
        }
    }
    
    public init(wrappedValue: UIImage?) {
        self.init(image: wrappedValue)
    }

    public var wrappedValue: UIImage? {
        get { image }
        set {
            image = newValue
        }
    }
    
}
