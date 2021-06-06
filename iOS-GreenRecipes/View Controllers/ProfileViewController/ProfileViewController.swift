//
//  ProfileViewController.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 31/05/2021.
//

import UIKit
import CoreData

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
    applySnapshot()
  }

  func initDataController() {
    dataController = getDataController()
  }

  @objc func preferencesTapped() {
    guard let preferencesViewController = self.storyboard?.instantiateViewController(
      identifier: "PreferencesViewController"
    ) as? PreferencesViewController else { return }
    navigationController?.pushViewController(preferencesViewController, animated: true)
  }

  func fetchBookmarkedRecipes(completion: @escaping ([Recipe]) -> Void) {
    let recipesRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
    let bookmarkLiteral: NSNumber = true
    let recipesPredicate = NSPredicate(format: "isBookmarked == %@", bookmarkLiteral)
    recipesRequest.predicate = recipesPredicate

    let recipesSortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
    recipesRequest.sortDescriptors = [recipesSortDescriptor]

    do {
      let recipes = try dataController.viewContext.fetch(recipesRequest)
      completion(recipes)
    } catch {
      completion([])
    }
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
