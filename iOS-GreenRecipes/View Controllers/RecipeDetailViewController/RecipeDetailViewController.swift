//
//  RecipeDetailViewController.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 16/05/2021.
//

import UIKit
import CoreData

// MARK: - Shows the recipe with all the details e.g calories, nutrition chart, instructions and ingredients.
class RecipeDetailViewController: UIViewController {
  // swiftlint:disable implicitly_unwrapped_optional
  var dataController: DataController!
  var recipeData: RecipeData!
  var recipe: Recipe!
  var recipeNutrition: Nutrition!
  // swiftlint:enable implicitly_unwrapped_optional

  private func downloadRecipeNutrition() {
    // Recipe is not saved previously, we retrieve the recipe nutrition information and save
    RecipesClient.getRecipeNutrition(recipeId: self.recipeData.id) { recipeNutrition, error in
      if error != nil {
        self.showStatus(
          title: "Recipes nutrition data download error",
          message: "An error occured while retrieving nutrition for recipe. \(error?.localizedDescription ?? "")"
        )
      } else {
        self.addRecipeData()
        if let recipeNutrition = recipeNutrition {
          self.addRecipeNutritionData(nutritionData: recipeNutrition)
        }
        // Save recipe
        try? self.dataController.viewContext.save()
        self.configure()
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.systemGray6
    self.navigationItem.backButtonTitle = ""
    overrideUserInterfaceStyle = .dark

    if recipe != nil {
      configure()
    } else {
      fetchRecipe { recipe in
        if recipe != nil {
          // Recipe is saved previously, configure the layout
          self.configure()
        } else {
          self.downloadRecipeNutrition()
        }
      }
    }
  }

  // MARK: - Retrieve a recipe saved from data. Returns nil is not saved
  private func fetchRecipe(completion: @escaping (Recipe?) -> Void) {
    let recipeRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
    let recipeIdToFetch = NSNumber(value: Int32(recipeData.id))
    let recipeIdPredicate = NSPredicate(format: "id == %@", recipeIdToFetch)
    recipeRequest.predicate = recipeIdPredicate

    let recipeSortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
    recipeRequest.sortDescriptors = [recipeSortDescriptor]

    do {
      let recipes = try dataController.viewContext.fetch(recipeRequest)
      recipe = recipes.first
      completion(recipe)
    } catch {
      completion(nil)
    }
  }

  // MARK: - Retrieve a recipe's saved ingredeitns data
  func fetchRecipeIngredients(completion: @escaping ([Ingredient]) -> Void) {
    let ingredientsRequest: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
    let ingredientPredicate = NSPredicate(format: "recipe == %@", recipe)
    ingredientsRequest.predicate = ingredientPredicate
    let ingredientsSortDescriptor = NSSortDescriptor(key: "originalString", ascending: false)
    ingredientsRequest.sortDescriptors = [ingredientsSortDescriptor]

    do {
      let ingredients = try dataController.viewContext.fetch(ingredientsRequest)
      completion(ingredients)
    } catch {
      completion([])
    }
  }

  // MARK: - Retrieve a recipe's saved instructions data
  func fetchRecipeInstructions(completion: @escaping ([Instruction]) -> Void) {
    let instructionsRequest: NSFetchRequest<Instruction> = Instruction.fetchRequest()
    let instructionsPredicate = NSPredicate(format: "recipe == %@", recipe)
    instructionsRequest.predicate = instructionsPredicate
    let instructionsSortDescriptor = NSSortDescriptor(key: "number", ascending: true)
    instructionsRequest.sortDescriptors = [instructionsSortDescriptor]

    do {
      let instructions = try dataController.viewContext.fetch(instructionsRequest)
      completion(instructions)
    } catch {
      completion([])
    }
  }

  // MARK: - Retrieve a recipe's saved nutrition data
  func fetchRecipeNutrition(completion: @escaping (Nutrition?) -> Void) {
    let nutritionRequest: NSFetchRequest<Nutrition> = Nutrition.fetchRequest()
    let nutritionPredicate = NSPredicate(format: "recipe == %@", recipe)
    nutritionRequest.predicate = nutritionPredicate
    let nutritionSortDescriptor = NSSortDescriptor(key: "calories", ascending: false)
    nutritionRequest.sortDescriptors = [nutritionSortDescriptor]

    do {
      let nutritions = try dataController.viewContext.fetch(nutritionRequest)
      completion(nutritions.first)
    } catch {
      completion(nil)
    }
  }

  // MARK: - Initialize and save recipe data from given recipeData reference
  func addRecipeData() {
    recipe = Recipe(context: dataController.viewContext)
    recipe.id = Int32(recipeData.id)
    recipe.createdAt = Date()
    recipe.imageURL = recipeData.image
    recipe.servings = Int16(recipeData.servings)
    recipe.imageType = recipeData.imageType
    recipe.title = recipeData.title
    recipe.preparationTime = Int16(recipeData.readyInMinutes)
    recipe.isBookmarked = false
    recipe.isLiked = false
    recipe.likes = Int32(recipeData.aggregateLikes)
    recipe.sourceURL = recipeData.sourceUrl

    // Add ingredients data
    for ingredient in recipeData.extendedIngredients {
      let recipeIngredient = Ingredient(context: dataController.viewContext)
      recipeIngredient.originalString = ingredient.originalString
      recipeIngredient.recipe = recipe
    }
    // Add instructions data
    if !recipeData.analyzedInstructions.isEmpty {
      for instruction in recipeData.analyzedInstructions[0].steps {
        let recipeInstruction = Instruction(context: dataController.viewContext)
        recipeInstruction.number = Int16(instruction.number)
        recipeInstruction.step = instruction.step
        recipeInstruction.recipe = recipe
      }
    }
  }

  // MARK: - Initialize and save recipe nutrition data from given NutritionData reference
  func addRecipeNutritionData(nutritionData: NutritionData) {
    let recipeNutrition = Nutrition(context: dataController.viewContext)
    recipeNutrition.recipe = recipe
    recipeNutrition.calories = nutritionData.calories
    // Retrieve the carbohydrates, fat and protein amount & percent of daily needs
    nutritionData.bad.forEach { nutrient in
      if nutrient.title == "Carbohydrates" {
        recipeNutrition.carbsPercent = nutrient.percentOfDailyNeeds
        recipeNutrition.carbs = nutrient.amount
      }
      if nutrient.title == "Fat" {
        recipeNutrition.fatPercent = nutrient.percentOfDailyNeeds
        recipeNutrition.fat = nutrient.amount
      }
    }
    nutritionData.good.forEach { nutrient in
      if nutrient.title == "Protein" {
        recipeNutrition.proteinPercent = nutrient.percentOfDailyNeeds
        recipeNutrition.protein = nutrient.amount
      }
    }
  }
}
