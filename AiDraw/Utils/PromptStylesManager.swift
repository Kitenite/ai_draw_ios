//
//  PromptStylesManager.swift
//  AiDraw
//
//  Created by Zak Rogness on 12/21/22.
//

import Foundation

class PromptStylesManager {
    static let shared = PromptStylesManager()
    
    private var sharedPromptStyles: PromptStyles? = nil
    private var promptStylesDict: [String: [[String: PromptArtStyle]]]? = nil
    
    func getArtTypeKeys() -> [String] {
        if (sharedPromptStyles?.promptStyles != nil) {
            return Array(sharedPromptStyles!.promptStyles.keys)
        }
        return []
    }
    
    func getSubstylesByArtType(artType: String) -> [PromptSubstyle] {
        if (sharedPromptStyles?.promptStyles[artType]?.substyles != nil) {
            return sharedPromptStyles!.promptStyles[artType]!.substyles!
        }
        return []
    }
    
    func getSubstyleKey(artType: String, index: Int) -> String {
        if (sharedPromptStyles?.promptStyles[artType]?.substyles != nil) {
            return sharedPromptStyles!.promptStyles[artType]!.substyles![index].key
        }
        return ""
    }
    
    func getSubstyleValueKeys(artType: String, index: Int) -> [String] {
        if (sharedPromptStyles?.promptStyles[artType]?.substyles != nil) {
            return sharedPromptStyles!.promptStyles[artType]!.substyles![index].values.map { $0.key }
        }
        return []
    }
    
    func getPromptArtStyle(artType: String, substyleValueKey: String, substyleIndex: Int) -> PromptArtStyle? {
        return promptStylesDict?[artType]?[substyleIndex][substyleValueKey]
    }
    
    func getArtTypePrefix(artType: String) -> String? {
        return sharedPromptStyles?.promptStyles[artType]?.prefix
    }
    
    func getArtTypeSuffix(artType: String) -> String? {
        return sharedPromptStyles?.promptStyles[artType]?.suffix
    }
    
    func getPromptArtStylePrefix(artType: String, substyleIndex: Int, substyleValue: String) -> String? {
        if (promptStylesDict?[artType] != nil && promptStylesDict![artType]!.count > substyleIndex) {
            return promptStylesDict?[artType]?[substyleIndex][substyleValue]?.prefix
        }
        return nil
    }
    
    func getPromptArtStyleSuffix(artType: String, substyleIndex: Int, substyleValue: String) -> String? {
        if (promptStylesDict?[artType] != nil && promptStylesDict![artType]!.count > substyleIndex) {
            return promptStylesDict?[artType]?[substyleIndex][substyleValue]?.suffix
        }
        return nil
    }
    
    // TODO: retry logic
    private init() {
        let serviceHelper = ServiceHelper.shared
        serviceHelper.getPromptStyles { result in
            self.sharedPromptStyles = result
            self.buildSubstyleDict(promptStylesInput: result)
        }
    }
    
    private func buildSubstyleDict(promptStylesInput: PromptStyles?) {
        if (promptStylesInput?.promptStyles != nil) {
            var res = [String: [[String: PromptArtStyle]]] ()
            for (key, val) in promptStylesInput!.promptStyles {
                let substyles = val.substyles
                res[key] = [[String: PromptArtStyle]] ()
                if (substyles != nil && substyles!.count > 0) {
                    for i in 0...substyles!.count - 1 {
                        res[key]!.append([String: PromptArtStyle] ())
                        for substyleVal in substyles![i].values {
                            res[key]![i][substyleVal.key] = substyleVal
                        }
                    }
                }
            }
            self.promptStylesDict = res
        }
    }
}
