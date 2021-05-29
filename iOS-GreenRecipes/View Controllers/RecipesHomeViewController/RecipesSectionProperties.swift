//
//  RecipesSectionProperties.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 27/05/2021.
//

import UIKit

enum RecipesSectionKey {
  static let random = "random"
  static let quickAndEasy = "quickAndEasy"
  static let breakfast = "breakfast"
  static let mainCourse = "main course"
  static let beverage = "beverage"
  static let dessert = "dessert"
}

class RecipesSectionProperties: Hashable {
  var description: String
  let widthRatio: Float
  let height: Float
  let recipeImageSize: String
  let scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior

  let key: String
  var recipesInSection: [RecipeData]

  private let identifier = UUID()

  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
    hasher.combine(description)
  }

  static func == (lhs: RecipesSectionProperties, rhs: RecipesSectionProperties) -> Bool {
    return lhs.identifier == rhs.identifier && lhs.description == rhs.description
  }

  init(
    description: String,
    key: String,
    widthRatio: Float,
    heightRatio: Float,
    recipeImageSize: String,
    scrollingBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior
  ) {
    self.description = description
    self.key = key
    self.widthRatio = widthRatio
    self.height = heightRatio
    self.recipeImageSize = recipeImageSize
    self.scrollingBehavior = scrollingBehaviour
    self.recipesInSection = []
  }
}
