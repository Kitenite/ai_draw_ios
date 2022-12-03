//
//  AnalyticsHelper.swift
//  AiDraw
//
//  Created by Kiet Ho on 11/29/22.
//

import Foundation
import FirebaseAnalytics

class AnalyticsHelper {
    
    func logHomeScreen() {
        logEvent(id: "home-screen", title: "Home screen")
    }
    
    func logEvent(id: String, title: String) {
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
          AnalyticsParameterItemID: id,
          AnalyticsParameterItemName: title,
          AnalyticsParameterContentType: "cont",
        ])
    }
    
    
}
