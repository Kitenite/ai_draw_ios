//
//  InferenceHandler.swift
//  AiDraw
//
//  Created by Kiet Ho on 10/21/22.
//

import Foundation
import SwiftUI
import Alamofire

class ServiceHelper {
    static let shared = ServiceHelper()
    
    func postInferenceRequest(prompt: String, image: UIImage, mask: UIImage? = nil, advancedOptions: AdvancedOptions, inferenceResultHandler: @escaping (String) -> Void) {
        let resizedImage = image.aspectFittedToHeight(512/3)
        let imageData: String? = resizedImage.jpegData(compressionQuality: 0)?.base64EncodedString()
        var maskData: String? = nil
        
        if (mask != nil) {
            maskData = mask!.jpegData(compressionQuality: 0)?.base64EncodedString()
        }
        
        let input = InferenceRequestInput(
            prompt: prompt,
            request_type: InferenceRequestTypes.IMG_TO_IMG.rawValue,
            init_img: imageData,
            mask: maskData,
            seed: advancedOptions.seed,
            sampler_index: advancedOptions.sampler_index,
            cfg_scale: advancedOptions.cfg_scale,
            restore_faces: advancedOptions.restore_faces,
            negative_prompt: advancedOptions.negative_prompt,
            denoising_strength: advancedOptions.denoising_strength
        )
        
        AF.request(
            Constants.INFERENCE_API_V2,
            method: .post,
            parameters: input,
            encoder: JSONParameterEncoder.default
        ).responseJSON { response in
            if let json = response.value as? [String: Any], let imageData = json["image"] as? String {
                inferenceResultHandler(imageData)
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
    
    func getClusterStatus(handler: @escaping (ClusterStatusResponse) -> ()) {
        print("Getting cluster status")
        AF.request(
            Constants.STATUS_API,
            method: .get
        ).responseDecodable(of: ClusterStatusResponse.self) { response in
            debugPrint("Response: \(response)")
            if ((response.value) != nil) {
                handler(response.value!)
            }
        }
    }
    
    func getPromptStyles(handler: @escaping (PromptStyles) -> Void) {
        print("Getting prompt styles")
        AF.request(
            Constants.PROMPT_STYLES_API,
            method: .get
        ).responseDecodable(of: PromptStyles.self) { response in
            debugPrint("Response: \(response)")
            if (response.value != nil) {
                handler(response.value!)
            }
        }
    }
}
