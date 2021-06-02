//
//  ProfileViewController.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 31/05/2021.
//

import UIKit

class ProfileViewController: UIViewController {
  static let headerElementKind = "header-element-kind"

  enum BookmarkedRecipes: Int, CaseIterable {
    case recipes

    var description: String {
      switch self {
      case .recipes:
        return "Bookmarked Recipes"
      }
    }
  }
  // swiftlint:disable implicitly_unwrapped_optional
  var dataController: DataController!
  var recipesCollectionView: UICollectionView!
  var dataSource: UICollectionViewDiffableDataSource<BookmarkedRecipes, Recipe>!
  // swiftlint:enable implicitly_unwrapped_optional
  var bookmarkedRecipes: [Recipe] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    overrideUserInterfaceStyle = .dark
    initDataController()
    configureTitle()
    configureHierarchy()
    configureDataSource()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    applyInitialSnapshot()
  }

  func initDataController() {
    dataController = getDataController()
  }
}

extension ProfileViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let selectedRecipe = bookmarkedRecipes[indexPath.row]

    guard let recipeDetailViewController = self.storyboard?.instantiateViewController(
      identifier: "RecipeDetailViewController"
    ) as? RecipeDetailViewController else { return }

    recipeDetailViewController.recipe = selectedRecipe
    recipeDetailViewController.dataController = dataController
    recipeDetailViewController.modalPresentationStyle = .fullScreen
    present(recipeDetailViewController, animated: true, completion: nil)
  }
}
