//
//  AnalyticsHelper.swift
//  AiDraw
//
//  Created by Kiet Ho on 11/29/22.
//

import Foundation
import FirebaseAnalytics

class AnalyticsHelper {
    static let shared = AnalyticsHelper()

    func logEvent(id: String, title: String) {
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
          AnalyticsParameterItemID: id,
          AnalyticsParameterItemName: title,
          AnalyticsParameterContentType: "cont",
        ])
    }
    
}
