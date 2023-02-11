//
//  AppDelegate.swift
//  MLT Industries
//
//  Created by Davis Allie on 31/3/2022.
//

import Firebase
import Sentry
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        SentrySDK.start { options in
            options.dsn = "https://eab79cc9f3f44ec59930791149239f27@o292781.ingest.sentry.io/6300846"
            //options.debug = true // Enabled debug when first installing is always helpful
            
            // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
            // We recommend adjusting this value in production.
            options.tracesSampleRate = 0.5
        }
        
        return true
    }
    
}
