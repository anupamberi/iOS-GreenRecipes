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
    var recipesInCategory: [RecipeData]
    let identifier = UUID()

    func hash(into hasher: inout Hasher) {
      hasher.combine(identifier)
      hasher.combine(recipesInCategory.count)
    }
    static func == (lhs: RecipeCategory, rhs: RecipeCategory) -> Bool {
      return lhs.identifier == rhs.identifier && lhs.recipesInCategory.count == rhs.recipesInCategory.count
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
    guard let recipeImageMexican = UIImage(named: "mexican") else { return [] }
    guard let recipeImageItalian = UIImage(named: "italian") else { return [] }
    guard let recipeImageMiddleEastern = UIImage(named: "middle-eastern") else { return [] }
    guard let recipeImageSnack = UIImage(named: "snack") else { return [] }
    guard let recipeImageSoup = UIImage(named: "soup") else { return [] }

    let recipeCategorySnack = RecipeCategory(
      categoryName: "Snack",
      categoryImage: recipeImageSnack
    )

    let recipeCategorySoup = RecipeCategory(
      categoryName: "Soup",
      categoryImage: recipeImageSoup
    )

    let recipeCategoryIndian = RecipeCategory(
      categoryName: "Indian",
      categoryImage: recipeImageIndian
    )

    let recipeCategoryMexican = RecipeCategory(
      categoryName: "Mexican",
      categoryImage: recipeImageMexican
    )

    let recipeCategoryMiddleEastern = RecipeCategory(
      categoryName: "Middle Eastern",
      categoryImage: recipeImageMiddleEastern
    )

    let recipeCategoryItalian = RecipeCategory(
      categoryName: "Italian",
      categoryImage: recipeImageItalian
    )

    recipeCategories.append(recipeCategorySnack)
    recipeCategories.append(recipeCategorySoup)
    recipeCategories.append(recipeCategoryIndian)
    recipeCategories.append(recipeCategoryMexican)
    recipeCategories.append(recipeCategoryMiddleEastern)
    recipeCategories.append(recipeCategoryItalian)

    return recipeCategories
  }
}
