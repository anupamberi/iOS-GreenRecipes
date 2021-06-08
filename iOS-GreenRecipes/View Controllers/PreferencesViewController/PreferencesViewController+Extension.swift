//
//  PreferencesViewController+Extension.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 02/06/2021.
//

import UIKit

// MARK: - Creates a table view layout for presenting different user preferences
extension PreferencesViewController {
  func configureHierarchy() {
    preferencesTableView = UITableView(frame: .zero, style: .grouped)
    view.addSubview(preferencesTableView)
    preferencesTableView.dataSource = self
    preferencesTableView.translatesAutoresizingMaskIntoConstraints = false
    preferencesTableView.frame = view.bounds
    preferencesTableView.register(
      PreferenceTableViewCell.self,
      forCellReuseIdentifier: PreferenceTableViewCell.reuseIdentifier
    )
  }

  func configureData() {
    if let homePreferencesData = UserDefaults.standard.array(forKey: "HomePreferences") as? [String] {
      createHomePreferences(preferencesData: homePreferencesData)
    }
    if let searchPreferencesData = UserDefaults.standard.array(forKey: "SearchPreferences") as? [String] {
      createSearchPreferences(preferencesData: searchPreferencesData)
    }
  }

  private func createHomePreferences(preferencesData: [String]) {
    var homePreferences: [Preference] = []
    HomePreferences.allCases.forEach { searchPreference in
      let preference = Preference(
        title: searchPreference.description,
        key: searchPreference.description,
        icon: UIImage(named: "preferences"),
        isOn: preferencesData.contains(searchPreference.description)
      )
      homePreferences.append(preference)
    }

    let homePreferencesSection = PreferencesSection(
      title: "Home",
      preferences: homePreferences
    )
    preferencesSections.append(homePreferencesSection)
  }

  private func createSearchPreferences(preferencesData: [String]) {
    var searchPreferences: [Preference] = []
    SearchPreferences.allCases.forEach { searchPreference in
      let preference = Preference(
        title: searchPreference.description,
        key: searchPreference.description,
        icon: UIImage(named: "preferences"),
        isOn: preferencesData.contains(searchPreference.description)
      )
      searchPreferences.append(preference)
    }

    let searchPreferencesSection = PreferencesSection(
      title: "Search Categories",
      preferences: searchPreferences
    )
    preferencesSections.append(searchPreferencesSection)
  }

  func configureTitle() {
    navigationItem.title = "Preferences"
    navigationItem.largeTitleDisplayMode = .always
  }
}

// MARK: - Table view data source as PreferencesSections
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
    // Update view controller with changed data
    preferenceCell.togglePreferenceChangedCallback = { preferenceValue in
      let preferencesSection = self.preferencesSections[indexPath.section]
      if preferencesSection.title == "Home" {
        self.updatePreferences(
          preferencesTitle: "HomePreferences",
          preferenceKey: preference.key,
          preferenceValue: preferenceValue
        )
      } else {
        self.updatePreferences(
          preferencesTitle: "SearchPreferences",
          preferenceKey: preference.key,
          preferenceValue: preferenceValue
        )
      }
    }
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
