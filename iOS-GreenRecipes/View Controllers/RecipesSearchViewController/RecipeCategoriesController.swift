//
//  RecipesCategory.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 24/05/2021.
//

import UIKit

class RecipeCategoriesController {
  struct RecipeCategory: Hashable {
    let recipeCategoryName: String
    let recipeCategoryImage: UIImage
    let recipesInCategory: [RecipeData]?
    let identifier = UUID()

    func hash(into hasher: inout Hasher) {
      hasher.combine(identifier)
    }
    static func == (lhs: RecipeCategory, rhs: RecipeCategory) -> Bool {
      return lhs.identifier == rhs.identifier
    }

    init(categoryName: String, categoryImage: UIImage) {
      self.recipeCategoryName = categoryName
      self.recipeCategoryImage = categoryImage
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

    guard let recipeImageIndian = UIImage(named: "indian") else { return [] }
    guard let recipeImageChinese = UIImage(named: "chinese") else { return [] }
    guard let recipeImageItalian = UIImage(named: "italian") else { return [] }
    guard let recipeImageMiddleEastern = UIImage(named: "hummus") else { return [] }

    let recipeCategoryIndian = RecipeCategory(
      categoryName: "Indian",
      categoryImage: recipeImageIndian
    )

    let recipeCategoryChinese = RecipeCategory(
      categoryName: "Chinese",
      categoryImage: recipeImageChinese
    )
    let recipeCategoryMiddleEastern = RecipeCategory(
      categoryName: "Middle Eastern",
      categoryImage: recipeImageMiddleEastern
    )
    let recipeCategoryItalian = RecipeCategory(
      categoryName: "Italian",
      categoryImage: recipeImageItalian
    )

    recipeCategories.append(recipeCategoryIndian)
    recipeCategories.append(recipeCategoryChinese)
    recipeCategories.append(recipeCategoryMiddleEastern)
    recipeCategories.append(recipeCategoryItalian)

    return recipeCategories
  }
}
