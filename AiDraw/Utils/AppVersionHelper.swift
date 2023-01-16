//
//  AppVersionHelper.swift
//  AiDraw
//
//  Created by Kiet Ho on 1/8/23.
//

import Foundation

class AppVersionHelper {
    static let SYSTEM_VERSION_KEY = "CFBundleShortVersionString"
    static let SAVED_VERSION_KEY = "savedVersion"
    
    // Get current Version of the App
    static func getCurrentAppVersion() -> String {
        let appVersion = Bundle.main.infoDictionary?[SYSTEM_VERSION_KEY]
        let version = (appVersion as! String)
        return version
    }
    
    // Check if app if app has been started after update
    static func isFirstLaunch() -> Bool {
        let version = getCurrentAppVersion()
        let savedVersion = UserDefaults.standard.string(forKey: SAVED_VERSION_KEY)
        let isFirstLaunch: Bool = (savedVersion != version)
        UserDefaults.standard.setValue(version, forKey: SAVED_VERSION_KEY)
        return isFirstLaunch
    }
}
