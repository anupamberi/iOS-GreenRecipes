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
