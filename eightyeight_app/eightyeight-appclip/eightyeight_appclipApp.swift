//
//  eightyeight_appclipApp.swift
//  eightyeight-appclip
//
//  Created by yoshioka on 2024/07/23.
//

import SwiftUI

@main
struct eightyeight_appclipApp: App {
    
    @StateObject private var appClipManager = AppClipManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appClipManager)
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform:  handleUserActivity)
        }
    }
    
    func handleUserActivity(_ userActivity: NSUserActivity)
    {
        NSLog("handleUserActivity")
        appClipManager.handleIncomingURL(userActivity)
    }
}

