//
//  SceneDelegate.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 08/05/2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  let dataController = DataController(modelName: "GreenRecipes")

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let _ = (scene as? UIWindowScene) else { return }
    dataController.load()
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    // Save changes in the application's managed object context when the application transitions to the background.
    dataController.saveContext()
  }
}
