//
//  InferenceHandler.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/21/22.
//

import Foundation
import UIKit

class InferenceHandler {

    func postImgToImgRequest(prompt: String, image: UIImage, inferenceResultHandler: @escaping (String) -> Void) {
        let imageData = image.jpegData(compressionQuality: 0)
        let encodedImageData = imageData?.base64EncodedString()
        let input = InferenceRequestInput(
            prompt: prompt,
            request_type: InferenceRequestTypes.IMG_TO_IMG.rawValue,
            init_img: encodedImageData
        )

        guard let uploadData = try? JSONEncoder().encode(input) else {
            print("Error encoding input: \(input)")
        return
        }
        postHTTPRequest(uploadData: uploadData, api: Constants.INFERENCE_API, handler: inferenceResultHandler)
    }

    func shortPollForImg(output_location: String, shortPollResultHandler: @escaping (String) -> Void) {
        let input = ShortPollRequestInput(
            output_location: output_location
        )
        guard let uploadData = try? JSONEncoder().encode(input) else {
            print("Error encoding input: \(input)")
            return
        }
        postHTTPRequest(uploadData: uploadData, api: Constants.SHORT_POLL_API, handler: shortPollResultHandler)
    }

    private func postHTTPRequest(uploadData: Data, api: String, handler: @escaping (String) -> Void) {
        let url = URL(string: api)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
            if let error = error {
                print("error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("server error)")
                return
            }
            if let mimeType = response.mimeType, mimeType == "application/json", let data = data,
            let dataString = String(data: data, encoding: .utf8) {
                #if DEBUG
                    print("Data returned: \(dataString)")
                #endif
                handler(dataString)
            }
        }
        task.resume()
    }
    
}
