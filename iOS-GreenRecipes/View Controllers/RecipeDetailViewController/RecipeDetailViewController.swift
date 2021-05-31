//
//  RecipeDetailViewController.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 16/05/2021.
//

import UIKit
import CoreData

class RecipeDetailViewController: UIViewController {
  // swiftlint:disable implicitly_unwrapped_optional
  var dataController: DataController!
  var recipeData: RecipeData!
  var recipe: Recipe!
  var recipeNutrition: Nutrition!
  // swiftlint:enable implicitly_unwrapped_optional

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.systemGray6
    self.navigationItem.title = recipeData.title
    self.navigationItem.backButtonTitle = ""
    overrideUserInterfaceStyle = .dark

    fetchRecipe { recipe in
      if recipe != nil {
        // Recipe is not saved previously
        self.configure()
      } else {
        // Recipe is not saved previously, we retrieve the recipe nutrition information and save
        RecipesClient.getRecipeNutrition(recipeId: self.recipeData.id) { recipeNutrition, error in
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
  }

  func fetchRecipe(completion: @escaping (Recipe?) -> Void) {
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
