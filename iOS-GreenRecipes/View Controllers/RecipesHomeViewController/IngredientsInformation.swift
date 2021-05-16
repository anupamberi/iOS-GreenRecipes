//
//  IngredientsInformation.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 15/05/2021.
//

import Foundation

struct IngredientsInformation: Codable {
  var ingredientsInformation: [IngredientInformation]
}

struct IngredientInformation: Codable {
  var id: Int
  var name: String
  var image: String
  var information: String
  var caloricBreakdown: CaloricBreakdown
}

struct CaloricBreakdown: Codable {
  var percentProtein: Float
  var percentCarbs: Float
  var percentFat: Float
}
