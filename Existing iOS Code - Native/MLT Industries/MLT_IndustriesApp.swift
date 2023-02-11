//
//  MLT_IndustriesApp.swift
//  MLT Industries
//
//  Created by Davis Allie on 28/6/21.
//

import SwiftUI

@main
struct MLT_IndustriesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .ignoresSafeArea()
        }
    }
}
