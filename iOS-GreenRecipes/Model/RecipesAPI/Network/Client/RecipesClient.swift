//
//  RecipesClient.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 08/05/2021.
//
import Foundation
import UIKit

// MARK: - The central class for handling network communication with back recipes data
// swiftlint:disable convenience_type
class RecipesClient {
  static let apiKey = "da7335677bd94ba5bd0212c833151639"

  enum Endpoints {
    static let base = "https://api.spoonacular.com/recipes/"
    static let recipePhotoBase = "https://spoonacular.com/recipeImages/"
    static let ingredientPhotoBase = "https://spoonacular.com/cdn/"

    case getRandomRecipes
    case getRecipeInformation(Int)
    case getRecipeNutrition(Int)
    case searchRecipes
    case recipePhoto(Int, String, String)

    var stringValue: String {
      switch self {
      case .getRandomRecipes:
        return Endpoints.base + "random?"
      case .getRecipeInformation(let recipeId):
        return Endpoints.base + "\(recipeId)/information?"
      case .getRecipeNutrition(let recipeId):
        return Endpoints.base + "\(recipeId)/nutritionWidget.json?"
      case .searchRecipes:
        return Endpoints.base + "complexSearch?"
      case let .recipePhoto(id, size, imageType):
        return Endpoints.recipePhotoBase + "\(id)-\(size).\(imageType)"
      }
    }

    var url: URL {
      // swiftlint:disable force_unwrapping
      return URL(string: stringValue)!
      // swiftlint:enable force_unwrapping
    }
  }

  enum RecipePhotoSize {
    case thumbnail, medium, large

    var stringValue: String {
      switch self {
      case .thumbnail:
        return "90x90"
      case .medium:
        return "312x231"
      case .large:
        return "556x370"
      }
    }
  }

  class func getRandomRecipes(tags: String, total: Int, completion: @escaping ([RecipeData], Error?) -> Void) {
    let randomRecipesBaseURL = Endpoints.getRandomRecipes.url
    let recipesSearchURLParams = [
      URLQueryItem(name: "tags", value: tags),
      URLQueryItem(name: "number", value: String(total)),
      URLQueryItem(name: "apiKey", value: RecipesClient.apiKey)
    ]
    guard let randomRecipesSearchURL = randomRecipesBaseURL.appending(recipesSearchURLParams) else { return }
    taskForGETRequest(url: randomRecipesSearchURL, response: RecipesData.self) { response, error in
      if let response = response {
        completion(response.recipes ?? [], nil)
      } else {
        completion([], error)
      }
    }
  }

  class func getRecipeInformation(recipeId: Int, completion: @escaping (RecipeData?, Error?) -> Void) {
    let recipeInformationBaseURL = Endpoints.getRecipeInformation(recipeId).url
    let recipeInformationParams = [
      URLQueryItem(name: "includeNutrition", value: String(false)),
      URLQueryItem(name: "apiKey", value: RecipesClient.apiKey)
    ]
    guard let recipeInformationURL = recipeInformationBaseURL.appending(recipeInformationParams) else { return }
    print(recipeInformationURL)
    taskForGETRequest(url: recipeInformationURL, response: RecipeData.self) { response, error in
      if let response = response {
        completion(response, nil)
      } else {
        completion(nil, error)
      }
    }
  }

  class func getRecipeNutrition(recipeId: Int, completion: @escaping (NutritionData?, Error?) -> Void) {
    let recipeNutritionBaseURL = Endpoints.getRecipeNutrition(recipeId).url
    let recipeNutritionParams = [
      URLQueryItem(name: "apiKey", value: RecipesClient.apiKey)
    ]
    guard let recipeNutritionURL = recipeNutritionBaseURL.appending(recipeNutritionParams) else { return }
    print(recipeNutritionURL)
    taskForGETRequest(url: recipeNutritionURL, response: NutritionData.self) { response, error in
      if let response = response {
        completion(response, nil)
      } else {
        completion(nil, error)
      }
    }
  }

  // swiftlint:disable function_parameter_count
  class func searchRecipes(
    query: String,
    mealType: String?,
    cuisineType: String?,
    maxReadyTime: Int?,
    offset: Int?,
    completion: @escaping (Int, [RecipeData], Error?) -> Void
  ) {
    let recipesSearchBaseURL = Endpoints.searchRecipes.url
    var recipesSearchParams = [
      URLQueryItem(name: "query", value: query),
      URLQueryItem(name: "diet", value: "vegan"),
      URLQueryItem(name: "apiKey", value: RecipesClient.apiKey),
      URLQueryItem(name: "number", value: String(5)),
      URLQueryItem(name: "addRecipeInformation", value: String(true)),
      URLQueryItem(name: "fillIngredients", value: String(true))
    ]
    // Check optional search parameters meal and cuisine types
    if let mealType = mealType {
      recipesSearchParams.append(URLQueryItem(name: "type", value: mealType))
    }

    if let cuisineType = cuisineType {
      recipesSearchParams.append(URLQueryItem(name: "cuisine", value: cuisineType))
    }

    if let maxReadyTime = maxReadyTime {
      recipesSearchParams.append(URLQueryItem(name: "maxReadyTime", value: String(maxReadyTime)))
    }

    if let offset = offset {
      recipesSearchParams.append(URLQueryItem(name: "offset", value: String(offset)))
    }
    guard let recipesSearchURL = recipesSearchBaseURL.appending(recipesSearchParams) else { return }
    taskForGETRequest(url: recipesSearchURL, response: RecipesData.self) { response, error in
      if let response = response {
        completion(response.totalResults ?? 0, response.results ?? [], nil)
      } else {
        completion(0, [], error)
      }
    }
  }
  // swiftlint:enable function_parameter_count

  // MARK: - Download the recipe photo image given id, size and type
  class func downloadRecipePhoto(
    recipeId: Int,
    recipeImageSize: String,
    recipeImageType: String,
    completion: @escaping(_ image: UIImage?) -> Void
  ) {
    // Construct the URL from the given photo information
    let url = Endpoints.recipePhoto(recipeId, recipeImageSize, recipeImageType).url
    guard let imageData = try? Data(contentsOf: url) else { return }
    if let image = UIImage(data: imageData) {
      completion(image)
    } else {
      completion(nil)
    }
  }

  class func taskForGETRequest<ResponseType: Decodable>(
    url: URL,
    response: ResponseType.Type,
    completion: @escaping (ResponseType?, Error?
    ) -> Void
  ) {
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
      guard let data = data else {
        DispatchQueue.main.async {
          completion(nil, error)
        }
        return
      }
      let decoder = JSONDecoder()
      do {
        let responseObject = try decoder.decode(ResponseType.self, from: data)
        DispatchQueue.main.async {
          completion(responseObject, error)
        }
      } catch {
        do {
          let errorResponse = try decoder.decode(RecipeNotFound.self, from: data)
          print(errorResponse)
          DispatchQueue.main.async {
            completion(nil, errorResponse)
          }
        } catch {
          DispatchQueue.main.async {
            completion(nil, error)
          }
        }
      }
    }
    task.resume()
  }
}

extension RecipesClient {
  class func getSearchOffset(key: String) -> Int {
    let total = UserDefaults.standard.integer(forKey: key)
    var offset: Int = 0
    if total != 0 {
      // If previously total recipes for the key were found to be 16, then return an offset that is
      // a random number between 0 and the total minus the number of search results to display
      // swiftlint:disable legacy_random
      offset = Int(arc4random_uniform(UInt32(total - 5)))
    }
    return offset
  }
}
