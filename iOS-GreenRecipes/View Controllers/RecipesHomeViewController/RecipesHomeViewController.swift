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

  func addRandomRecipes(_ recipesSection: RecipesSectionProperties) {
    print("Start loading random recipes")
    RecipesClient.getRandomRecipes(tags: "vegan", total: 5) { randomRecipes, error in
      if error != nil {
        self.showStatus(
          title: "Recipes search error",
          message: "An error occured while retrieving random recipes. \(error?.localizedDescription ?? "")"
        )
      } else {
        recipesSection.recipesInSection = self.uniqueRecipes(recipes: randomRecipes)
        print("Random recipes ids")
        for randomRecipe in randomRecipes {
          print(randomRecipe.id)
        }
        self.applyRecipesSectionDataSnapshot(recipes: recipesSection.recipesInSection, recipesSection: recipesSection)
        print("Finished loading random recipes")
        self.recipesDownloadGroup.leave()
      }
    }
  }

  func addQuickEasyRecipes(_ recipesSection: RecipesSectionProperties) {
    print("Start loading quick recipes")
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
        print("Quick and Easy recipes ids")
        for recipe in recipesSection.recipesInSection {
          print(recipe.id)
        }
        self.applyRecipesSectionDataSnapshot(
          recipes: recipesSection.recipesInSection,
          recipesSection: recipesSection
        )
        UserDefaults.standard.set(total, forKey: recipesSection.preferenceKey)
        print("Finished loading quick and easy recipes")
        self.recipesDownloadGroup.leave()
      }
    }
  }

  func addRecipes(_ recipesSection: RecipesSectionProperties) {
    print("Start loading \(recipesSection.searchKey) recipes")
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
        print("\(recipesSection.description)")
        for recipe in recipesSection.recipesInSection {
          print(recipe.id)
        }
        self.applyRecipesSectionDataSnapshot(
          recipes: recipesSection.recipesInSection,
          recipesSection: recipesSection
        )
        UserDefaults.standard.set(total, forKey: recipesSection.preferenceKey)
        print("Finished loading \(recipesSection.searchKey) recipes")
        self.recipesDownloadGroup.leave()
      }
    }
  }

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
