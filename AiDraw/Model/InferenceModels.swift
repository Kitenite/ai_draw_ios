//
//  InferenceModels.swift
//  AiDraw
//
//  Created by Kiet Ho on 11/23/22.
//

import Foundation

struct ShortPollRequestInput: Codable {
    let output_location: String
}

struct InferenceRequestInput: Codable {
    let prompt: String
    let request_type: String
    var init_img_url: String?
    var init_img: String?
}

enum InferenceRequestTypes: String {
    case TEXT_TO_IMG = "text_to_image"
    case IMG_TO_IMG = "image_to_image"
    case INPAINTING = "inpainting"
}

struct InferenceResponse: Decodable {
    let input_img_url: String
    let output_img_url: String
    let payload:InferenceRequestInput
}
