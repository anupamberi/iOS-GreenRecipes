//
//  RecipeData.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 08/05/2021.
//

import Foundation

struct RecipeData: Codable, Hashable {
  static func == (lhs: RecipeData, rhs: RecipeData) -> Bool {
    lhs.id == rhs.id && lhs.title == rhs.title
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(title)
  }

  // Recipe general information
  var id: Int
  var title: String
  var readyInMinutes: Int
  var servings: Int
  var sourceUrl: String
  var image: String?
  var imageType: String?
  var summary: String

  // Recipe classification

  var vegetarian: Bool
  var vegan: Bool
  var glutenFree: Bool
  var dairyFree: Bool
  var veryHealthy: Bool
  var cheap: Bool
  var veryPopular: Bool
  var sustainable: Bool
  var weightWatcherSmartPoints: Int
  var gaps: String
  var lowFodmap: Bool
  var aggregateLikes: Int
  var spoonacularScore: Float
  var healthScore: Float
  var creditsText: String
  var license: String?
  var sourceName: String
  var pricePerServing: Float

  // Recipe Ingredeints and instructions
  var extendedIngredients: [IngredientData]
  var analyzedInstructions: [InstructionData]
  var cuisines: [String]
  var dishTypes: [String]
  var diets: [String]
  var occasions: [String]
  var instructions: String
  var originalId: String?
  var spoonacularSourceUrl: String?
}

struct RecipeNotFound: Codable {
  var status: String
  var code: Int
  var message: String
}

extension RecipeNotFound: LocalizedError {
  var errorDescription: String? {
    return message
  }
}
