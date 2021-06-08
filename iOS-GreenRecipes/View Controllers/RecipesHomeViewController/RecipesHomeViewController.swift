//
//  RecipesHomeViewController.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 08/05/2021.
//

import UIKit
import CoreData

// MARK: - The main view controller that is shown on every application launch
class RecipesHomeViewController: UIViewController {
  static let headerElementKind = "header-element-kind"
  static let backgroundElementKind = "background-element-kind"
  // MARK: - Properties
  // swiftlint:disable implicitly_unwrapped_optional
  var dataController: DataController!
  var recipesCollectionView: UICollectionView!
  var dataSource: UICollectionViewDiffableDataSource<RecipesSectionProperties, RecipeData>!
  // swiftlint:enable implicitly_unwrapped_optional
  let recipesDownloadGroup = DispatchGroup()
  var recipesSections: [RecipesSectionProperties] = []
  var allRecipes: [Int: RecipeData] = [:]

  override func viewDidLoad() {
    super.viewDidLoad()

    overrideUserInterfaceStyle = .dark
    initDataController()
    configureTitle()
    configureHierarchy()
    configureDataSource()
    applyInitialSnapshot()
  }

  func initDataController() {
    dataController = getDataController()
  }

  // MARK: - Download and add some random recipes
  func addRandomRecipes(_ recipesSection: RecipesSectionProperties) {
    RecipesClient.getRandomRecipes(tags: "vegan", total: 5) { randomRecipes, error in
      if error != nil {
        self.showStatus(
          title: "Recipes search error",
          message: "An error occured while retrieving random recipes. \(error?.localizedDescription ?? "")"
        )
      } else {
        recipesSection.recipesInSection = self.uniqueRecipes(recipes: randomRecipes)
        self.applyRecipesSectionDataSnapshot(recipes: recipesSection.recipesInSection, recipesSection: recipesSection)
        self.recipesDownloadGroup.leave()
      }
    }
  }

  // MARK: - Download and add quick recipes
  func addQuickEasyRecipes(_ recipesSection: RecipesSectionProperties) {
    RecipesClient.searchRecipes(
      query: "",
      mealType: nil,
      cuisineType: nil,
      maxReadyTime: 20,
      offset: RecipesClient.getSearchOffset(key: recipesSection.preferenceKey)
    ) { total, quickAndEasyRecipes, error in
      if error != nil {
        self.showStatus(
          title: "Recipes search error",
          message: "An error occured while searching for recipes. \(error?.localizedDescription ?? "")"
        )
      } else {
        recipesSection.recipesInSection = self.uniqueRecipes(recipes: quickAndEasyRecipes).shuffled()
        self.applyRecipesSectionDataSnapshot(
          recipes: recipesSection.recipesInSection,
          recipesSection: recipesSection
        )
        // Save the total number of results found to UserDefaults.
        // This is used while setting offset in order to present a new set of recipes on each app load.
        UserDefaults.standard.set(total, forKey: recipesSection.preferenceKey)
        self.recipesDownloadGroup.leave()
      }
    }
  }

  // MARK: - Download and add recipes for specific meal type
  func addRecipes(_ recipesSection: RecipesSectionProperties) {
    RecipesClient.searchRecipes(
      query: "",
      mealType: recipesSection.searchKey,
      cuisineType: nil,
      maxReadyTime: nil,
      offset: RecipesClient.getSearchOffset(key: recipesSection.preferenceKey)
    ) { total, recipes, error in
      if error != nil {
        self.showStatus(
          title: "Recipes search error",
          message: "An error occured while searching for recipes. \(error?.localizedDescription ?? "")"
        )
      } else {
        recipesSection.recipesInSection = self.uniqueRecipes(recipes: recipes).shuffled()
        self.applyRecipesSectionDataSnapshot(
          recipes: recipesSection.recipesInSection,
          recipesSection: recipesSection
        )
        // Save the total number of results found to UserDefaults.
        // This is used while setting offset in order to present a new set of recipes on each app load.
        UserDefaults.standard.set(total, forKey: recipesSection.preferenceKey)
        self.recipesDownloadGroup.leave()
      }
    }
  }

  // MARK: - Assures that all the downloaded recipes have a unique id. It so happens that a same id recipe
  // is downloaded across different categories that affects the uniqueness of the Diffable Data Source.
  func uniqueRecipes(recipes: [RecipeData]) -> [RecipeData] {
    var uniqueRecipes: [RecipeData] = []
    recipes.forEach { recipe in
      let recipeExists = allRecipes[recipe.id] != nil
      if !recipeExists {
        allRecipes[recipe.id] = recipe
        uniqueRecipes.append(recipe)
      }
    }
    return uniqueRecipes
  }
}

// MARK: - The delegate to present the recipe details view controller
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
