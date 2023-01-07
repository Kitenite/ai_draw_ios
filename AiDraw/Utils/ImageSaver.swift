//
//  ImageSaver.swift
//  AiDraw
//
//  Created by Kiet Ho on 1/5/23.
//

import SwiftUI
import ImageIO
import Photos

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage, caption: String = "") {
        var imageData: Data
        if (caption == "") {
            imageData = image.jpegData(compressionQuality: 1)!
        } else {
            imageData = addImageCaption(image: image, caption: caption)
        }
        
        // Save photo
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: imageData, options: nil)
            let options = PHAssetResourceCreationOptions()
            options.shouldMoveFile = true
        }) { success, error in
            // Do callbacks here
            if (success) {
                print("Saved photo to album!")
            } else {
                print(error?.localizedDescription ?? "error")
            }
        }
    }
    
    func addImageCaption(image: UIImage, caption: String) -> Data{
        let imageData: Data = image.jpegData(compressionQuality: 1)!
        let cgImgSource: CGImageSource = CGImageSourceCreateWithData(imageData as CFData, nil)!
        let uti: CFString = CGImageSourceGetType(cgImgSource)!
        let dataWithEXIF: NSMutableData = NSMutableData(data: imageData)
        let destination: CGImageDestination = CGImageDestinationCreateWithData((dataWithEXIF as CFMutableData), uti, 1, nil)!
        let imageProperties = CGImageSourceCopyPropertiesAtIndex(cgImgSource, 0, nil)! as NSDictionary
        let mutable: NSMutableDictionary = imageProperties.mutableCopy() as! NSMutableDictionary
        
        // Edit metadata here
        mutable[kCGImagePropertyIPTCDictionary as String] = [
            "\(kCGImagePropertyIPTCCaptionAbstract as String)" : caption
        ]
        
        CGImageDestinationAddImageFromSource(destination, cgImgSource, 0, (mutable as CFDictionary))
        CGImageDestinationFinalize(destination)
        return (dataWithEXIF as Data)
    }
}
