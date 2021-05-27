//
//  RecipesSectionProperties.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 27/05/2021.
//

import UIKit

struct RecipesSectionProperties: Hashable {
  let description: String
  let widthRatio: Float
  let height: Float
  let recipeImageSize: String
  let scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior

  var recipesInSection: [RecipeData]

  private let identifier = UUID()

  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }

  static func == (lhs: RecipesSectionProperties, rhs: RecipesSectionProperties) -> Bool {
    return lhs.identifier == rhs.identifier
  }

  init(
    description: String,
    widthRatio: Float,
    heightRatio: Float,
    recipeImageSize: String,
    scrollingBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior
  ) {
    self.description = description
    self.widthRatio = widthRatio
    self.height = heightRatio
    self.recipeImageSize = recipeImageSize
    self.scrollingBehavior = scrollingBehaviour
    self.recipesInSection = []
  }
}
