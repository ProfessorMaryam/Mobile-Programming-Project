//
//  AppDelegate.swift
//  Eventosaurus
//
//  Created by BP-36-201-14 on 01/12/2024.
//

import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Application Lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize Firebase when the app launches
        FirebaseApp.configure()
        
        return true
    }

}

// MARK: - UISceneSession Lifecycle

@available(iOS 13.0, *)
extension AppDelegate {
    
    // This method is called when a new scene session is being created.
    // We use it to configure the scene.
    internal func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Return the configuration for the scene. You can adjust the name as needed.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // Called when the user discards a scene session.
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Use this method to release any resources that were specific to the discarded scenes.
    }
}
