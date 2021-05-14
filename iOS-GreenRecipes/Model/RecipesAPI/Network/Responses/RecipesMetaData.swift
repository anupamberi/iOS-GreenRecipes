//
//  RecipesMetaData.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 13/05/2021.
//

import Foundation

struct RecipeMetaData: Codable {
  var id: Int
  var title: String
  var image: String
  var imageType: String
}

struct RecipesMetaData: Codable {
  var results: [RecipeMetaData]
}
