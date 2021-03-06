//
//  PreferencesModel.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 02/06/2021.
//

import UIKit

// MARK: - Model entities for the user preferences
struct PreferencesSection {
  let title: String
  let preferences: [Preference]
}

struct Preference {
  let title: String
  let key: String
  let icon: UIImage?
  let isOn: Bool
}

enum SearchPreferences: String, CaseIterable {
  case snacks, soups, indian, mexican, middleEastern, italian

  var description: String {
    switch self {
    case .snacks: return "Snacks"
    case .soups: return "Soups"
    case .indian: return "Indian"
    case .mexican: return "Mexican"
    case .middleEastern: return "Middle Eastern"
    case .italian: return "Italian"
    }
  }
}

enum HomePreferences: String, CaseIterable {
  case recommendations, quickAndEasy, breakfast, mainCourse, beverages, desserts

  var description: String {
    switch self {
    case .recommendations: return "Recommended For You"
    case .breakfast: return "Breakfast"
    case .quickAndEasy: return "Quick & Easy"
    case .mainCourse: return "Main Course"
    case .beverages: return "Beverages"
    case .desserts: return "Desserts"
    }
  }
}
