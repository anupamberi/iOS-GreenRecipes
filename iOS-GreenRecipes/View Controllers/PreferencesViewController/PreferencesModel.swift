//
//  PreferencesModel.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 02/06/2021.
//

import UIKit

struct PreferencesSection {
  let title: String
  let preferences: [Preference]
}

struct Preference {
  let title: String
  let icon: UIImage?
  let isOn: Bool
  let handler: (() -> Void)
}
