//
//  RecipesSearchViewController+UISearchBarDelegate.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 27/05/2021.
//

import UIKit

extension RecipesSearchViewController: UISearchBarDelegate {
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    recipesSearchBar.showsCancelButton = true
    recipeCategoriesCollectionView.isHidden = true
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    recipeCategoriesCollectionView.isHidden = false
    recipesSearchBar.showsCancelButton = false
    recipesSearchBar.text = ""
    DispatchQueue.main.async {
      self.recipesSearchBar.resignFirstResponder()
      self.restoreRecipes()
    }
  }

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    // Get the search text
    guard let searchText = searchBar.text else { return }
    // Search among recipes
    // Retrieve recipe information
    RecipesClient.searchRecipes(
      query: searchText,
      mealType: nil,
      cuisineType: nil,
      maxReadyTime: nil,
      offset: 0
    ) { _, searchedRecipes, error in
      if error != nil {
        self.showStatus(
          title: "Recipes search error",
          message: "An error occured while searching for recipes \(error?.localizedDescription ?? "")"
        )
      } else {
        DispatchQueue.main.async {
          self.applySearchedRecipesSnapshot(recipes: searchedRecipes)
          self.recipesSearchBar.showsCancelButton = false
          self.recipesSearchBar.resignFirstResponder()
        }
      }
    }
  }

  func restoreRecipes() {
    guard let recipeCategory = recipeCategoriesDataSource.itemIdentifier(
      for: lastSelectedRecipeCategory
    ) else {
      return
    }
    self.applySearchedRecipesSnapshot(recipes: recipeCategory.recipesInCategory)
  }
}
