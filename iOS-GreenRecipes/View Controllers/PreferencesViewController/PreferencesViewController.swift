//
//  PreferencesViewController.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 02/06/2021.
//

import UIKit

// MARK: - Displays a table view with different user preferences
class PreferencesViewController: UIViewController {
  // swiftlint:disable implicitly_unwrapped_optional
  var preferencesTableView: UITableView!
  // swiftlint:enable implicitly_unwrapped_optional
  var preferencesSections: [PreferencesSection] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    overrideUserInterfaceStyle = .dark
    configureData()
    configureHierarchy()
    configureTitle()
  }

  // Save the updated user preferences to UserDefaults
  func updatePreferences(preferencesTitle: String, preferenceKey: String, preferenceValue: Bool) {
    if var preferences = UserDefaults.standard.array(forKey: preferencesTitle) as? [String] {
      if preferenceValue {
        preferences.append(preferenceKey)
      } else {
        preferences = preferences.filter { !$0.contains(preferenceKey) }
      }
      // save updated preferences
      UserDefaults.standard.set(preferences, forKey: preferencesTitle)
    }
  }
}
