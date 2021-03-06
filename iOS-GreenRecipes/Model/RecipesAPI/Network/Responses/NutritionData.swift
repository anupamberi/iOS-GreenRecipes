//
//  NutritionData.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 13/05/2021.
//

import Foundation

struct NutritionData: Codable {
  var calories: String
  var carbs: String
  var fat: String
  var protein: String
  var bad: [NutritionAmount]
  var good: [NutritionAmount]
}

struct NutritionAmount: Codable {
  var title: String
  var amount: String
  var indented: Bool
  var percentOfDailyNeeds: Double
}
