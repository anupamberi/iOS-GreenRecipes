//
//  PreferencesViewController.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 02/06/2021.
//

import UIKit

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
