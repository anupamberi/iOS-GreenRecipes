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

  enum RecipesSection: Int, CaseIterable {
    case randomRecipes, quickAndEasyRecipes, breakfast, mainCourse, beverage, dessert

    var description: String {
      switch self {
      case .randomRecipes: return "Recommended for you"
      case .quickAndEasyRecipes: return "Quick & Easy"
      case .breakfast: return "Breakfast"
      case .mainCourse: return "Main Course"
      case .beverage: return "Refreshing Beverages"
      case .dessert: return "Desserts"
      }
    }

    var widthRatio: Float {
      switch self {
      case .randomRecipes, .breakfast, .mainCourse, .beverage: return 1.0
      case .quickAndEasyRecipes, .dessert:
        return 0.50
      }
    }

    var height: Float {
      switch self {
      case .randomRecipes, .breakfast, .mainCourse, .beverage: return 300.0
      case .quickAndEasyRecipes, .dessert: return 250.0
      }
    }

    var recipeImageSize: String {
      switch self {
      case .randomRecipes, .breakfast, .mainCourse, .beverage:
        return RecipesClient.RecipePhotoSize.large.stringValue
      case .quickAndEasyRecipes, .dessert:
        return RecipesClient.RecipePhotoSize.medium.stringValue
      }
    }

    func orthogonalScrollingBehavior() -> UICollectionLayoutSectionOrthogonalScrollingBehavior {
      switch self {
      case .randomRecipes, .breakfast, .mainCourse, .beverage:
        return UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPagingCentered
      case .quickAndEasyRecipes, .dessert:
        return UICollectionLayoutSectionOrthogonalScrollingBehavior.continuousGroupLeadingBoundary
      }
    }
  }
  // swiftlint:disable implicitly_unwrapped_optional
  var dataController: DataController!
  var recipesCollectionView: UICollectionView!
  var dataSource: UICollectionViewDiffableDataSource<RecipesSection, RecipeData>!
  // swiftlint:enable implicitly_unwrapped_optional

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
    guard let recipesSection = RecipesSection(rawValue: indexPath.section) else { fatalError("Unknown section") }

    let selectedRecipeData: RecipeData

    switch recipesSection {
    case .randomRecipes: selectedRecipeData = randomRecipesData[indexPath.row]
    case .breakfast: selectedRecipeData = breakfastRecipesData[indexPath.row]
    case .mainCourse: selectedRecipeData = mainCourseRecipesData[indexPath.row]
    case .beverage: selectedRecipeData = beverageRecipesData[indexPath.row]
    case .quickAndEasyRecipes: selectedRecipeData = quickAndEasyRecipesData[indexPath.row]
    case .dessert: selectedRecipeData = dessertRecipesData[indexPath.row]
    }

    guard let recipeDetailViewController = self.storyboard?.instantiateViewController(
      identifier: "RecipeDetailViewController"
    ) as? RecipeDetailViewController else { return }

    recipeDetailViewController.recipeData = selectedRecipeData
    self.navigationController?.pushViewController(recipeDetailViewController, animated: true)
  }
}
