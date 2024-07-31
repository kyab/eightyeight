//
//  AppDelegate.swift
//  eightyeight-appclip
//
//  Created by yoshioka on 2024/07/28.
//
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    var appClipManager = AppClipManager()

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            appClipManager.handleIncomingURL(userActivity)
            return true
        }
        return false
    }
}
