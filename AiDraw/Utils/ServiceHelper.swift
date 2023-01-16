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
    
    func postInferenceRequest(
        prompt: String,
        image: UIImage?,
        mask: UIImage? = nil,
        advancedOptions: AdvancedOptions,
        inferenceResultHandler: @escaping (String) -> Void,
        inferenceFailedHandler: @escaping (String, String) -> Void
    ) {
        // Optional image
        var imageData: String? = nil
        if (image != nil) {
            let resizedImage = image!.aspectFittedToHeight(512/3)
            imageData = resizedImage.jpegData(compressionQuality: 0)?.base64EncodedString()
        }
        
        // Optional mask
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
        ){ $0.timeoutInterval = 300 }.responseDecodable(of: InferenceResponseV2.self) { response in
            if (response.value != nil) {
                if (response.value!.error != nil) {
                    inferenceFailedHandler("Image generation failed", response.value!.error!)
                } else if (response.value!.image != nil) {
                    inferenceResultHandler(response.value!.image!)
                }
            } else {
                inferenceFailedHandler("Image generation failed", "Server error. Try again in a few seconds or report this issue")
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
