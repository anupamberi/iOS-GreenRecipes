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
  var allRecipes: [Int: RecipeData] = [:]

  override func viewDidLoad() {
    super.viewDidLoad()

    overrideUserInterfaceStyle = .dark
    initDataController()
    configureTitle()
    configureHierarchy()
    configureDataSource()
    applyInitialSanpshot()
  }

  func initDataController() {
    dataController = getDataController()
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
