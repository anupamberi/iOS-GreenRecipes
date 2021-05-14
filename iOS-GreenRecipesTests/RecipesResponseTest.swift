//
//  RecipesResponseTest.swift
//  iOS-GreenRecipesTests
//
//  Created by Anupam Beri on 08/05/2021.
//

import XCTest

class RecipesResponseTest: XCTestCase {
  func testRecipesRandomSearchResponseWithNullValues() throws {
    let jsonData = try getData(fromJSON: "RecipesRandomSearchResponseWithNullValues")

    XCTAssertNoThrow(try JSONDecoder().decode(RecipesData.self, from: jsonData))
    let recipesResponse = try JSONDecoder().decode(RecipesData.self, from: jsonData)
    XCTAssertNotNil(recipesResponse.recipes)
    XCTAssertEqual(recipesResponse.recipes.count, 5)
  }

  func testRecipesRandomSearchResponse() throws {
    let jsonData = try getData(fromJSON: "RecipesRandomSearchResponse2")

    XCTAssertNoThrow(try JSONDecoder().decode(RecipesData.self, from: jsonData))
    let recipesResponse = try JSONDecoder().decode(RecipesData.self, from: jsonData)
    XCTAssertNotNil(recipesResponse.recipes)
    XCTAssertEqual(recipesResponse.recipes.count, 5)
  }

  func testRecipesRandomSearchResponseWithoutImage() throws {
    let jsonData = try getData(fromJSON: "RecipesRandomSearchResponseWithoutImage")

    XCTAssertNoThrow(try JSONDecoder().decode(RecipesData.self, from: jsonData))
    let recipesResponse = try JSONDecoder().decode(RecipesData.self, from: jsonData)
    XCTAssertNotNil(recipesResponse.recipes)
    XCTAssertEqual(recipesResponse.recipes.count, 5)
  }
}
