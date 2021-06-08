//
//  RecipesTabBarController.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 23/05/2021.
//

import UIKit

// MARK: - The tab bar layout of the app.
// Used only for dependency injection of the data controller instance
class RecipesTabBarController: UITabBarController {
  // swiftlint:disable implicitly_unwrapped_optional
  var dataController: DataController!
  // swiftlint:enable implicitly_unwrapped_optional
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}
