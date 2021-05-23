//
//  RecipesTabBarController.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 23/05/2021.
//

import UIKit

class RecipesTabBarController: UITabBarController {
  // swiftlint:disable implicitly_unwrapped_optional
  var dataController: DataController!
  // swiftlint:enable implicitly_unwrapped_optional
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

extension RecipesTabBarController: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    switch viewController {
    case let viewController as RecipesHomeViewController:
      // inject dataController
      viewController.dataController = dataController
    case let viewController as RecipesSearchViewController:
      // inject dataController
      viewController.dataController = dataController
    default:
      break
    }
    return true
  }
}
