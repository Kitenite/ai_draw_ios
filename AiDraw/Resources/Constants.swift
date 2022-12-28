//
//  Constants.swift
//  AiDraw
//
//  Created by Kiet Ho on 11/23/22.
//

import Foundation

struct Constants {
    static let API_ROOT = "https://waw35mmbsj.execute-api.us-east-1.amazonaws.com/dev"
    // APIs
    static let INFERENCE_API = "\(API_ROOT)/inference"
    static let SHORT_POLL_API = "\(API_ROOT)/shortpoll"
    static let WAKE_API = "\(API_ROOT)/wake"
    static let STATUS_API = "\(API_ROOT)/status"
    static let PROMPT_STYLES_API = "\(API_ROOT)/prompt-styles"
    
    // Push Notification topics
    static let WAKE_TOPIC = "WAKE"
    
    // Advertisement IDs
    static let BANNER_AD_ID = "ca-app-pub-1255434922571560/3146758738"
    static let INTERSTITIAL_AD_ID = "ca-app-pub-1255434922571560/5705489373"
    
    // Test Advertisement IDs
//    static let BANNER_AD_ID = "ca-app-pub-3940256099942544/2934735716"
//    static let INTERSTITIAL_AD_ID = "ca-app-pub-3940256099942544/4411468910"
}
