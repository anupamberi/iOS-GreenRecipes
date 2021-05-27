//
//  RecipeDetailViewController.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 16/05/2021.
//

import UIKit
import Charts

class RecipeDetailViewController: UIViewController {
  // swiftlint:disable implicitly_unwrapped_optional
  var dataController: DataController!
  var recipeData: RecipeData!
  var recipeNutritionData: NutritionData!
  // swiftlint:enable implicitly_unwrapped_optional
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.systemGray6

    self.navigationItem.title = recipeData.title
    self.navigationItem.backButtonTitle = ""

    overrideUserInterfaceStyle = .dark

    RecipesClient.getRecipeNutrition(recipeId: recipeData.id) { recipeNutrition, error in
      self.recipeNutritionData = recipeNutrition
      self.configure()
    }
  }
}
