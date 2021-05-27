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

  var sections: [RecipesSectionProperties] = []
  var randomRecipesData: [RecipeData] = []
  var quickAndEasyRecipesData: [RecipeData] = []
  var mainCourseRecipesData: [RecipeData] = []
  var breakfastRecipesData: [RecipeData] = []
  var dessertRecipesData: [RecipeData] = []
  var beverageRecipesData: [RecipeData] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    overrideUserInterfaceStyle = .dark

    configureTitle()
    configureHierarchy()
    configureDataSource()
    fetchData()
  }
}

extension RecipesHomeViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let recipesSection = sections[indexPath.section]
    let selectedRecipeData = recipesSection.recipesInSection[indexPath.row]

    guard let recipeDetailViewController = self.storyboard?.instantiateViewController(
      identifier: "RecipeDetailViewController"
    ) as? RecipeDetailViewController else { return }

    recipeDetailViewController.recipeData = selectedRecipeData
    self.navigationController?.pushViewController(recipeDetailViewController, animated: true)
  }
}
