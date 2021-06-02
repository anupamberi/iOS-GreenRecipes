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
}
