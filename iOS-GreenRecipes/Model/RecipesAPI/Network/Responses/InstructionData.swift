//
//  InstructionsData.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 08/05/2021.
//

import Foundation

struct InstructionData: Codable {
  var name: String
  var steps: [InstructionStepData]
}

struct InstructionStepData: Codable {
  var number: Int
  var step: String
  var ingredients: [InstructionStepIngredientData]
}

struct InstructionStepIngredientData: Codable {
  var id: Int
  var name: String
  var localizedName: String
  var image: String
}
