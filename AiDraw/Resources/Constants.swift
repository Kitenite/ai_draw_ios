//
//  Constants.swift
//  AiDraw
//
//  Created by Kiet Ho on 11/23/22.
//

import Foundation

struct Constants {
    static let API_ROOT = "https://waw35mmbsj.execute-api.us-east-1.amazonaws.com/dev"
    static let INFERENCE_API = "\(API_ROOT)/inference"
    static let SHORT_POLL_API = "\(API_ROOT)/shortpoll"
    static let WAKE_API = "\(API_ROOT)/wake"
    static let STATUS_API = "\(API_ROOT)/status"
    static let PROMPT_STYLES_API = "\(API_ROOT)/prompt-styles"
    static let WAKE_TOPIC = "WAKE"
    static let BANNER_AD_ID = "ca-app-pub-1255434922571560/3146758738"
}
