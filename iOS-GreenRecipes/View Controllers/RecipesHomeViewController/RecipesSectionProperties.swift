//
//  RecipesSectionProperties.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 27/05/2021.
//

import UIKit
// MARK: - The search key id used while downloading recipes
enum RecipesSectionSearchKey {
  static let random = "random"
  static let quickAndEasy = "quickAndEasy"
  static let breakfast = "breakfast"
  static let mainCourse = "main course"
  static let beverage = "beverage"
  static let dessert = "dessert"
}

// MARK: - The recipes section display data for the data source
class RecipesSectionProperties: Hashable {
  var description: String
  let widthRatio: Float
  let height: Float
  let recipeImageSize: String
  let scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior

  let preferenceKey: String
  let searchKey: String
  var recipesInSection: [RecipeData]

  private let identifier = UUID()

  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }

  static func == (lhs: RecipesSectionProperties, rhs: RecipesSectionProperties) -> Bool {
    return lhs.identifier == rhs.identifier  }

  init(
    description: String,
    preferenceKey: String,
    searchKey: String,
    widthRatio: Float,
    heightRatio: Float,
    recipeImageSize: String,
    scrollingBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior
  ) {
    self.description = description
    self.preferenceKey = preferenceKey
    self.searchKey = searchKey
    self.widthRatio = widthRatio
    self.height = heightRatio
    self.recipeImageSize = recipeImageSize
    self.scrollingBehavior = scrollingBehaviour
    self.recipesInSection = []
  }
}
