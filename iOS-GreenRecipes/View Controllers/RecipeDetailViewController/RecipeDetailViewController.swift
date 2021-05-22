//
//  RecipeDetailViewController.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 16/05/2021.
//

import UIKit
import Charts

class RecipeDetailViewController: UIViewController {
  var recipeData: RecipeData!

  var recipeNutritionData: NutritionData!

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.systemGray6

    self.navigationItem.title = recipeData.title
    self.navigationItem.backButtonTitle = ""

    overrideUserInterfaceStyle = .dark

//    RecipesClient.getRecipeNutrition(recipeId: recipeData.id) { recipeNutritionData, error in
//      guard let nutritionData = recipeNutritionData else { return }
//      self.recipeNutritionData = nutritionData
//    }

    guard let recipeNutritionResponseJsonData = try? getData(
      fromJSON: "RecipeNutritionResponse"
    ) else { return }
    let recipeNutritionResponse = try? JSONDecoder().decode(NutritionData.self, from: recipeNutritionResponseJsonData)
    recipeNutritionData = recipeNutritionResponse
    configure()
  }

  func getData(fromJSON fileName: String) throws -> Data {
    let bundle = Bundle(for: type(of: self))
    guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
      throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotOpenFile, userInfo: nil)
    }
    do {
      let data = try Data(contentsOf: url)
      return data
    } catch {
      throw error
    }
  }
}
