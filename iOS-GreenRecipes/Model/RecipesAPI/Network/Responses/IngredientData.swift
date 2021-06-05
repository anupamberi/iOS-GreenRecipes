//
//  IngredientData.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 08/05/2021.
//

import Foundation

struct IngredientData: Codable {
  var id: Int?
  var aisle: String?
  var image: String?
  var consistency: String?
  var name: String
  var nameClean: String?
  var original: String
  var originalString: String
  var originalName: String
  var amount: Float
  var unit: String
  var meta: [String]
  var metaInformation: [String]
}
