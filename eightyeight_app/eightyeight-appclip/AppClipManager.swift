//
//  AppClipManager.swift
//  eightyeight-appclip
//
//  Created by yoshioka on 2024/07/28.
//

import Foundation
import SwiftUI

class AppClipManager: ObservableObject {
    @Published var clipContent: String?

    func handleIncomingURL(_ userActivity: NSUserActivity) {
        NSLog("handleIncomingURL called")
        
        debugPrint("incomingURL = \(userActivity.webpageURL!.absoluteString)")
        let incomingURL = userActivity.webpageURL
        let components = URLComponents(url: incomingURL!, resolvingAgainstBaseURL: true)
        debugPrint("components = \(components!.debugDescription)")
        
        if let queryItems = components?.queryItems {
            NSLog("queryItems let")
            // 必要なパラメータを取得
            if let param1 = queryItems.first(where: { $0.name == "acp" })?.value {
                self.clipContent = "acp: \(param1)"
            } else {
                self.clipContent = "No acp found"
            }
        }else{
            NSLog("foofffff")
            self.clipContent = "No param found"
        }
    }
}
