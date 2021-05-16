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
    // swiftlint:disable force_unwrapping
    XCTAssertEqual(recipesResponse.recipes!.count, 5)
    // swiftlint:enable force_unwrapping
  }

  func testRecipesRandomSearchResponse() throws {
    let jsonData = try getData(fromJSON: "RecipesRandomSearchResponse2")

    XCTAssertNoThrow(try JSONDecoder().decode(RecipesData.self, from: jsonData))
    let recipesResponse = try JSONDecoder().decode(RecipesData.self, from: jsonData)
    XCTAssertNotNil(recipesResponse.recipes)
    // swiftlint:disable force_unwrapping
    XCTAssertEqual(recipesResponse.recipes!.count, 5)
    // swiftlint:enable force_unwrapping
  }

  func testRecipesRandomSearchResponseWithoutImage() throws {
    let jsonData = try getData(fromJSON: "RecipesRandomSearchResponseWithoutImage")

    XCTAssertNoThrow(try JSONDecoder().decode(RecipesData.self, from: jsonData))
    let recipesResponse = try JSONDecoder().decode(RecipesData.self, from: jsonData)
    XCTAssertNotNil(recipesResponse.recipes)
    // swiftlint:disable force_unwrapping
    XCTAssertEqual(recipesResponse.recipes!.count, 5)
    // swiftlint:enable force_unwrapping
  }

  func testRecipesSearchResponse() throws {
    let jsonData = try getData(fromJSON: "RecipesSearchResponse")

    XCTAssertNoThrow(try JSONDecoder().decode(RecipesData.self, from: jsonData))
    let recipesResponse = try JSONDecoder().decode(RecipesData.self, from: jsonData)
    XCTAssertNotNil(recipesResponse.results)
    // swiftlint:disable force_unwrapping
    XCTAssertEqual(recipesResponse.results!.count, 10)
    // swiftlint:enable force_unwrapping
  }

  func testRecipesSearchResponseHummus() throws {
    let jsonData = try getData(fromJSON: "RecipesSearchResponseHummus")

    XCTAssertNoThrow(try JSONDecoder().decode(RecipesData.self, from: jsonData))
    let recipesResponse = try JSONDecoder().decode(RecipesData.self, from: jsonData)
    XCTAssertNotNil(recipesResponse.results)
    // swiftlint:disable force_unwrapping
    XCTAssertEqual(recipesResponse.results!.count, 7)
    // swiftlint:enable force_unwrapping
  }

  func testRecipesSearchResponseDessert() throws {
    let jsonData = try getData(fromJSON: "RecipesSearchResponseDessert")

    XCTAssertNoThrow(try JSONDecoder().decode(RecipesData.self, from: jsonData))
    let recipesResponse = try JSONDecoder().decode(RecipesData.self, from: jsonData)
    XCTAssertNotNil(recipesResponse.results)
    // swiftlint:disable force_unwrapping
    XCTAssertEqual(recipesResponse.results!.count, 10)
    // swiftlint:enable force_unwrapping
  }

  func testRecipesSearchResponseMainCourse() throws {
    let jsonData = try getData(fromJSON: "RecipesSearchResponseMainCourse")

    XCTAssertNoThrow(try JSONDecoder().decode(RecipesData.self, from: jsonData))
    let recipesResponse = try JSONDecoder().decode(RecipesData.self, from: jsonData)
    XCTAssertNotNil(recipesResponse.results)
    // swiftlint:disable force_unwrapping
    XCTAssertEqual(recipesResponse.results!.count, 10)
    // swiftlint:enable force_unwrapping
  }

  func testRecipesSearchResponseBreakfast() throws {
    let jsonData = try getData(fromJSON: "RecipesSearchResponseBreakfast")

    XCTAssertNoThrow(try JSONDecoder().decode(RecipesData.self, from: jsonData))
    let recipesResponse = try JSONDecoder().decode(RecipesData.self, from: jsonData)
    XCTAssertNotNil(recipesResponse.results)
    // swiftlint:disable force_unwrapping
    XCTAssertEqual(recipesResponse.results!.count, 10)
    // swiftlint:enable force_unwrapping
  }
}
