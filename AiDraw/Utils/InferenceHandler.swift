//
//  InferenceHandler.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/21/22.
//

import Foundation
import UIKit
import Alamofire

class InferenceHandler {
    func postImgToImgRequest(prompt: String, image: UIImage, inferenceResultHandler: @escaping (InferenceResponse) -> Void) {
        let imageData = image.jpegData(compressionQuality: 0)
        let encodedImageData = imageData?.base64EncodedString()
        let input = InferenceRequestInput(
            prompt: prompt,
            request_type: InferenceRequestTypes.IMG_TO_IMG.rawValue,
            init_img: encodedImageData
        )
        AF.request(
            Constants.INFERENCE_API,
            method: .post,
            parameters: input,
            encoder: JSONParameterEncoder.default
        ).responseDecodable(of: InferenceResponse.self) { response in
            debugPrint("Response: \(response)")
            if ((response.value) != nil) {
                inferenceResultHandler(response.value!)
            }
        }
    }

    func shortPollForImg(output_location: String, shortPollResultHandler: @escaping (String) -> Void) {
        let input = ShortPollRequestInput(
            output_location: output_location
        )
        AF.request(
            Constants.SHORT_POLL_API,
            method: .post,
            parameters: input,
            encoder: JSONParameterEncoder.default
        ) { $0.timeoutInterval = 300 }
            .responseString { response in
                if (response.value != nil) {
                    shortPollResultHandler(response.value!)
                }
        }
    }
    
    func wakeService() {
        print("Waking service")
        AF.request(
            Constants.WAKE_API,
            method: .get
        ).response { response in
            print(response)
        }
    }
    
    func getClusterStatus() {
        print("Getting cluster status")
        AF.request(
            Constants.STATUS_API,
            method: .get
        ).response { response in
            print(response)
        }
    }
}
