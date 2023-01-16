//
//  AdvancedOptions.swift
//  AiDraw
//
//  Created by Zak Rogness on 12/23/22.
//

import Foundation

enum Sampler: String, CaseIterable {
    case Euler_a = "Euler a"
    case LMS = "LMS"
    case DPM_fast = "DPM fast"
    case DDIM = "DDIM"
}

struct AdvancedOptions: Codable {
    var seed: Int = 0
    var sampler_index: String = Sampler.Euler_a.rawValue
    var cfg_scale: Float = 7.0
    var restore_faces: Bool = false
    var negative_prompt: String = ""
    var denoising_strength: Float = 0.7
    /* Params that will significantly increase computation cost */
    //var steps: Int?
    //var width: Int?
    //var height: Int?

}
