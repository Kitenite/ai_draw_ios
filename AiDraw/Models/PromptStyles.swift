//
//  PromptStyles.swift
//  AiDraw
//
//  Created by Zak Rogness on 12/21/22.
//

import Foundation

struct PromptArtStyle: Decodable {
    let key: String
    var prefix: String? = nil
    var suffix: String? = nil
}

struct PromptSubstyle: Decodable {
    let key: String
    var values: [PromptArtStyle]
}

struct PromptStyle: Decodable {
    let prefix: String?
    let suffix: String?
    let substyles: [PromptSubstyle]?
}

struct PromptStyles: Decodable {
    let promptStyles: Dictionary<String, PromptStyle>
}

