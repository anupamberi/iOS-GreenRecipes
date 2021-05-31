//
//  RecipesHomeViewController.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 08/05/2021.
//

import UIKit

class RecipesHomeViewController: UIViewController {
  static let headerElementKind = "header-element-kind"
  static let backgroundElementKind = "background-element-kind"

  // swiftlint:disable implicitly_unwrapped_optional
  var dataController: DataController!
  var recipesCollectionView: UICollectionView!
  var dataSource: UICollectionViewDiffableDataSource<RecipesSectionProperties, RecipeData>!
  // swiftlint:enable implicitly_unwrapped_optional

  var recipesSections: [RecipesSectionProperties] = []
  var randomRecipesData: [RecipeData] = []
  var quickAndEasyRecipesData: [RecipeData] = []
  var mainCourseRecipesData: [RecipeData] = []
  var breakfastRecipesData: [RecipeData] = []
  var dessertRecipesData: [RecipeData] = []
  var beverageRecipesData: [RecipeData] = []
  var allRecipes: [Int: RecipeData] = [:]

  override func viewDidLoad() {
    super.viewDidLoad()

    overrideUserInterfaceStyle = .dark
    initDataController()
    configureTitle()
    configureHierarchy()
    configureDataSource()
    // applyInitialSanpshot()
    fetchData()
  }

  func initDataController() {
    guard let recipesTabBar = tabBarController as? RecipesTabBarController else {
      fatalError("No data controller set")
    }
    dataController = recipesTabBar.dataController
  }
}

extension RecipesHomeViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let recipesSection = recipesSections[indexPath.section]
    let selectedRecipeData = recipesSection.recipesInSection[indexPath.row]

    guard let recipeDetailViewController = self.storyboard?.instantiateViewController(
      identifier: "RecipeDetailViewController"
    ) as? RecipeDetailViewController else { return }

    recipeDetailViewController.recipeData = selectedRecipeData
    recipeDetailViewController.dataController = dataController
    recipeDetailViewController.modalPresentationStyle = .fullScreen
    present(recipeDetailViewController, animated: true, completion: nil)
  }
}
