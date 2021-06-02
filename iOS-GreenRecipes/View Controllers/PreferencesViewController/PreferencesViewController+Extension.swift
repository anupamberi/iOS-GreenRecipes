//
//  PreferencesViewController+Extension.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 02/06/2021.
//

import UIKit

extension PreferencesViewController {
  func configureHierarchy() {
    preferencesTableView = UITableView(frame: .zero, style: .grouped)
    view.addSubview(preferencesTableView)
    preferencesTableView.delegate = self
    preferencesTableView.dataSource = self
    preferencesTableView.translatesAutoresizingMaskIntoConstraints = false
    preferencesTableView.frame = view.bounds
    preferencesTableView.register(PreferenceTableViewCell.self, forCellReuseIdentifier: PreferenceTableViewCell.reuseIdentifier)
  }

  func configureData() {
    let homePreferencesSection = PreferencesSection(
      title: "Home",
      preferences: [
        Preference(title: "Recommendations", icon: UIImage(named: "preference"), isOn: true, handler: {
          print("show recommendations")
        }),
        Preference(title: "Breakfast Recipes", icon: UIImage(named: "preference"), isOn: true, handler: {
          print("breakfast")
        }),
        Preference(title: "Main Course Recipes", icon: UIImage(named: "preference"), isOn: true, handler: {
          print("main course")
        }),
        Preference(title: "Beverages", icon: UIImage(named: "preference"), isOn: true, handler: {
          print("beverages")
        }),
       Preference(title: "Desserts", icon: UIImage(named: "preference"), isOn: true, handler: {
          print("Desserts")
        }),
      ]
    )

    let searchPreferencesSection = PreferencesSection(
      title: "Search Categories",
      preferences: [
        Preference(title: "Snacks", icon: UIImage(named: "preference"), isOn: true, handler: {
          print("snacks")
        }),
        Preference(title: "Soups", icon: UIImage(named: "preference"), isOn: true, handler: {
          print("soups")
        }),
        Preference(title: "Indian", icon: UIImage(named: "preference"), isOn: true, handler: {
          print("indian")
        }),
        Preference(title: "Mexican", icon: UIImage(named: "preference"), isOn: true, handler: {
          print("mexican")
        }),
        Preference(title: "Italian", icon: UIImage(named: "preference"), isOn: true, handler: {
          print("italian")
        })
      ]
    )
    preferencesSections.append(homePreferencesSection)
    preferencesSections.append(searchPreferencesSection)
  }

  func configureTitle() {
    navigationItem.title = "Preferences"
    navigationItem.largeTitleDisplayMode = .always
  }
}

extension PreferencesViewController: UITableViewDelegate {
}

extension PreferencesViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return preferencesSections[section].preferences.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let preference = preferencesSections[indexPath.section].preferences[indexPath.row]
    guard let preferenceCell = preferencesTableView.dequeueReusableCell(
      withIdentifier: PreferenceTableViewCell.reuseIdentifier,
      for: indexPath
    ) as? PreferenceTableViewCell else {
      return UITableViewCell()
    }
    preferenceCell.configure(preference: preference)
    return preferenceCell
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return preferencesSections[section].title
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return preferencesSections.count
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
