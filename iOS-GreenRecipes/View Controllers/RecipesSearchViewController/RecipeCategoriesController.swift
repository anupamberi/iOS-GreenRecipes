//
//  RecipesCategory.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 24/05/2021.
//

import UIKit

class RecipeCategoriesController {
  struct RecipeCategory: Hashable, Equatable {
    var recipeCategoryName: String
    var recipeCategoryImage: UIImage
    var recipeCategoryMealType: String?
    var recipeCategoryCuisineType: String?
    var recipesInCategory: [RecipeData]
    let identifier = UUID()

    func hash(into hasher: inout Hasher) {
      hasher.combine(identifier)
      hasher.combine(recipesInCategory.count)
    }
    static func == (lhs: RecipeCategory, rhs: RecipeCategory) -> Bool {
      return lhs.identifier == rhs.identifier && lhs.recipesInCategory.count == rhs.recipesInCategory.count
    }

    init(
      categoryName: String,
      categoryImage: UIImage,
      categoryMealType: String? = nil,
      categoryCuisineType: String? = nil
    ) {
      self.recipeCategoryName = categoryName
      self.recipeCategoryImage = categoryImage
      self.recipeCategoryMealType = categoryMealType
      self.recipeCategoryCuisineType = categoryCuisineType
      self.recipesInCategory = []
    }
  }

  lazy var recipeCategories: [RecipeCategory] = {
    return generateRecipeCategories()
  }()
}

extension RecipeCategoriesController {
  private func generateRecipeCategories() -> [RecipeCategory] {
    // create multiple recipe categories
    var recipeCategories: [RecipeCategory] = []

    if let recipeSearchCategories = UserDefaults.standard.array(forKey: "SearchPreferences") as? [String] {
      recipeSearchCategories.forEach { recipeCategoryName in
        switch recipeCategoryName {
        case "Snacks":
          guard let recipeImageSnacks = UIImage(named: recipeCategoryName) else { return }
          let snacksCategory = RecipeCategory(
            categoryName: recipeCategoryName,
            categoryImage: recipeImageSnacks,
            categoryMealType: "snack"
          )
          recipeCategories.append(snacksCategory)
        case "Soups":
          guard let recipeImageSoups = UIImage(named: recipeCategoryName) else { return }
          let soupsCategory = RecipeCategory(
            categoryName: recipeCategoryName,
            categoryImage: recipeImageSoups,
            categoryMealType: "soup"
          )
          recipeCategories.append(soupsCategory)
        case "Indian", "Mexican", "Middle Eastern", "Italian":
          guard let recipeImage = UIImage(named: recipeCategoryName) else { return }
          let cuisineCategory = RecipeCategory(
            categoryName: recipeCategoryName,
            categoryImage: recipeImage,
            categoryCuisineType: recipeCategoryName
          )
          recipeCategories.append(cuisineCategory)
        default:
          fatalError("Unknown recipe search category")
        }
      }
    }
    return recipeCategories
  }
}
