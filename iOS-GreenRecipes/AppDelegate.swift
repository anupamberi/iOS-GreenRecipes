//
//  AppDelegate.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 08/05/2021.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    let isFirstLaunch = !UserDefaults.standard.bool(forKey: "isFirstLaunch")
    if isFirstLaunch {
      UserDefaults.standard.set(true, forKey: "isFirstLaunch")
      // Set the default user preferences
      let homePreferences = [
        "Recommended For You",
        "Quick & Easy",
        "Main Course",
        "Beverages",
        "Desserts"
      ]
      let searchPreferences = [
        "Snacks",
        "Soups",
        "Indian",
        "Mexican",
        "Middle Eastern",
        "Italian"
      ]
      UserDefaults.standard.set(homePreferences, forKey: "HomePreferences")
      UserDefaults.standard.set(searchPreferences, forKey: "SearchPreferences")
    }
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
}
