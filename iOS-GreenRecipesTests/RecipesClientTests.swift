//
//  RecipesClientTests.swift
//  iOS-GreenRecipesTests
//
//  Created by Anupam Beri on 08/05/2021.
//

import XCTest

class RecipesClientTests: XCTestCase {
  func testGetRandomRecipes() throws {
    let expectation = XCTestExpectation(description: "Get random recipes based on tags")
    var obtainedRecipes: [RecipeData] = []

    let expectedRecipesCount = 5
    RecipesClient.getRandomRecipes(tags: "vegan", total: expectedRecipesCount) { recipes, error in
      if error != nil {
        XCTFail("Received an error while retrieving recipes : \(String(describing: error?.localizedDescription))")
      }
      obtainedRecipes = recipes
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 10.0)
    // Check if we have received the correct number of recipes
    XCTAssertEqual(obtainedRecipes.count, expectedRecipesCount)
    for recipe in obtainedRecipes {
      XCTAssertTrue(recipe.vegan)
    }
  }

  func testGetRecipeInformationOK() throws {
    let expectation = XCTestExpectation(description: "Get recipe information based on id")
    var obtainedRecipeInformation: RecipeData?

    let recipeId = 11156
    RecipesClient.getRecipeInformation(recipeId: recipeId) { recipe, error in
      guard let recipe = recipe else {
        XCTFail("Received an error while retrieving recipe: \(String(describing: error?.localizedDescription))")
        return
      }
      obtainedRecipeInformation = recipe
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 10.0)
    // Check if we have received the correct number of recipes
    XCTAssertEqual(recipeId, obtainedRecipeInformation?.id)
  }

  func testGetRecipeInformationKO() throws {
    let expectation = XCTestExpectation(description: "Get recipe information based on id")

    let recipeId = 132351156
    let expectedErrorMessage = "A recipe with the id 132351156 does not exist."
    var obtainedErrorMessage = ""
    RecipesClient.getRecipeInformation(recipeId: recipeId) { _, error in
      guard let error = error else {
        return
      }
      obtainedErrorMessage = error.localizedDescription
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    XCTAssertEqual(expectedErrorMessage, obtainedErrorMessage)
  }

  func testGetRecipeNutritionOK() throws {
    let expectation = XCTestExpectation(description: "Get recipe nutrition information based on id")
    var obtainedRecipeNutrition: NutritionData?

    let recipeId = 659604
    RecipesClient.getRecipeNutrition(recipeId: recipeId) { nutrition, error in
      guard let nutrition = nutrition else {
        XCTFail("Received an error while retrieving nutrition: \(String(describing: error?.localizedDescription))")
        return
      }
      obtainedRecipeNutrition = nutrition
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 10.0)
    // Check if we have received the correct number of recipes
    XCTAssertNotNil(obtainedRecipeNutrition?.calories)
  }

  func testGetRecipeNutritionKO() throws {
    let expectation = XCTestExpectation(description: "Get recipe nutrition based on id")

    let recipeId = 132351156
    let expectedErrorMessage = "A recipe with the id 132351156 does not exist."
    var obtainedErrorMessage = ""
    RecipesClient.getRecipeNutrition(recipeId: recipeId) { _, error in
      guard let error = error else {
        return
      }
      obtainedErrorMessage = error.localizedDescription
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    XCTAssertEqual(expectedErrorMessage, obtainedErrorMessage)
  }

  func testSearchRecipes() throws {
    let expectation = XCTestExpectation(description: "Search recipes")

    let searchQuery = "hummus"
    var obtainedRecipesMetaData: [RecipeData] = []

    RecipesClient.searchRecipes(query: searchQuery) { recipesData, _ in
      obtainedRecipesMetaData = recipesData
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    XCTAssertEqual(obtainedRecipesMetaData.count, 5)
    for obtainedRecipeMetaData in obtainedRecipesMetaData {
      XCTAssertTrue(obtainedRecipeMetaData.title.lowercased().contains(searchQuery))
    }
  }
}
