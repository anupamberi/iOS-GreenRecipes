//
//  RecipesData.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 08/05/2021.
//

import Foundation

struct RecipesData: Codable {
  let recipes: [RecipeData]?
  let results: [RecipeData]?
  let totalResults: Int?
}
