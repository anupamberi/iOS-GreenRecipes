//
//  ProfileViewController.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 31/05/2021.
//

import UIKit
import CoreData

// MARK: - Presents the user bookmarked recipes
class ProfileViewController: UIViewController {
  static let headerElementKind = "header-element-kind"
  // MARK: - Properties
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

  // MARK: - Shows the user preferences controller for app settings
  @objc func preferencesTapped() {
    guard let preferencesViewController = self.storyboard?.instantiateViewController(
      identifier: "PreferencesViewController"
    ) as? PreferencesViewController else { return }
    navigationController?.pushViewController(preferencesViewController, animated: true)
  }

  // MARK: - Retrieve all bookmarked recipes from saved recipes
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

// MARK: - Delegate to handle selection for showing the recipe detail view
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
