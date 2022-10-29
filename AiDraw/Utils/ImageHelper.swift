//
//  ImageHelper.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/28/22.
//

import Foundation
import SwiftUI

class ImageHelper {
    
    func downloadImage(image: UIImage) {
        let imageSaver = ImageSaver()
        imageSaver.writeToPhotoAlbum(image: image)
    }
    
    
    func cropImageToRect(sourceImage: UIImage, cropRect: CGRect) -> UIImage {
        // The shortest side
        let sideLength = min(
            sourceImage.size.width,
            sourceImage.size.height
        )
        
        // Determines the x,y coordinate of a centered
        // sideLength by sideLength square
        let sourceSize = sourceImage.size
        let xOffset = (sourceSize.width - sideLength) / 2.0
        let yOffset = (sourceSize.height - sideLength) / 2.0

        // The cropRect is the rect of the image to keep,
        // in this case centered
        let cropRect = CGRect(
            x: xOffset,
            y: yOffset,
            width: sideLength,
            height: sideLength
        ).integral

        // Center crop the image
        let sourceCGImage = sourceImage.cgImage!
        let croppedCGImage = sourceCGImage.cropping(
            to: cropRect
        )!
        
        // Use the cropped cgImage to initialize a cropped
        // UIImage with the same image scale and orientation
        let croppedImage = UIImage(
            cgImage: croppedCGImage,
            scale: sourceImage.imageRendererFormat.scale,
            orientation: sourceImage.imageOrientation
        )
        
        return croppedImage
    }
    
    func overlayDrawingOnBackground(backgroundImage: UIImage, drawingImage : UIImage, canvasSize: CGSize) -> UIImage {
        let newImage = autoreleasepool { () -> UIImage in
            UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0.0)
            backgroundImage.draw(in: CGRect(origin: CGPoint.zero, size: canvasSize))
            drawingImage.draw(in: CGRect(origin: CGPoint.zero, size: canvasSize))
            let createdImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return createdImage ?? drawingImage
        }
        return newImage
    }
}
