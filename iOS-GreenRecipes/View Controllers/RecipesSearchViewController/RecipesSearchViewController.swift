//
//  RecipesSearchViewController.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 22/05/2021.
//

import UIKit

// MARK: A collection view controller to search a recipe by keywords.
class RecipesSearchViewController: UIViewController {
  // MARK: - Properties
  enum RecipeCategories: Int, CaseIterable {
    case categories
  }
  enum Recipes: Int, CaseIterable {
    case results
  }
  // swiftlint:disable implicitly_unwrapped_optional
  var dataController: DataController!
  var recipesSearchContainerView: UIStackView!
  var recipeCategoriesCollectionView: UICollectionView!
  var recipesCollectionView: UICollectionView!
  // swiftlint:disable operator_usage_whitespace
  var recipeCategoriesDataSource: UICollectionViewDiffableDataSource<RecipeCategories,
    RecipeCategoriesController.RecipeCategory>!
  var recipesDataSource: UICollectionViewDiffableDataSource<Recipes, RecipeData>!
  // swiftlint:enable implicitly_unwrapped_optional

  var lastSelectedRecipeCategory = IndexPath(row: 0, section: 0)

  var recipesSearchBar = UISearchBar()
  let recipeCategoriesController = RecipeCategoriesController()

  override func viewDidLoad() {
    super.viewDidLoad()
    overrideUserInterfaceStyle = .dark

    initDataController()
    configureHierarchy()
    configureDataSource()
    applySnapshots()
  }

  func initDataController() {
    dataController = getDataController()
  }
}

// MARK: - Delegate to handle recipe categories item selections in order to search the corresponding recipes
extension RecipesSearchViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if collectionView == recipesCollectionView {
      guard let recipeData = recipesDataSource.itemIdentifier(for: indexPath) else { return }
      guard let recipeDetailViewController = self.storyboard?.instantiateViewController(
        identifier: "RecipeDetailViewController"
      ) as? RecipeDetailViewController else { return }
      recipeDetailViewController.recipeData = recipeData
      recipeDetailViewController.dataController = dataController
      recipeDetailViewController.modalPresentationStyle = .fullScreen
      present(recipeDetailViewController, animated: true, completion: nil)
    } else {
      let categoryCell = collectionView.cellForItem(at: indexPath) as? RecipeCategoryViewCell
      categoryCell?.isSelected = true
      lastSelectedRecipeCategory = indexPath

      collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
      DispatchQueue.global(qos: .background).async {
        DispatchQueue.main.async {
          self.reloadRecipesData(indexPath: indexPath)
        }
      }
    }
  }
}
