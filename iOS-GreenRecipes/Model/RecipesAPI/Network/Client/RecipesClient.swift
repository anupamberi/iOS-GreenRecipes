//
//  RecipesClient.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 08/05/2021.
//
import Foundation
import UIKit

class RecipesClient {
  // static let apiKey = "dc3174ea537b405b95020abec265e994"
  static let apiKey = "da7335677bd94ba5bd0212c833151639"

  enum Endpoints {
    static let base = "https://api.spoonacular.com/recipes/"

    case getRandomRecipes
    case getRecipeInformation(Int)
    case getRecipeNutrition(Int)
    case searchRecipes(String)

    var stringValue: String {
      switch self {
      case .getRandomRecipes:
        return Endpoints.base + "random?"
      case .getRecipeInformation(let recipeId):
        return Endpoints.base + "\(recipeId)/information?"
      case .getRecipeNutrition(let recipeId):
        return Endpoints.base + "\(recipeId)/nutritionWidget.json?"
      case .searchRecipes(let query):
        return Endpoints.base + "complexSearch?query=\(query)"
      }
    }

    var url: URL {
      return URL(string: stringValue)!
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
        completion(response.recipes, nil)
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
        print(response)
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
        print(response)
        completion(response, nil)
      } else {
        completion(nil, error)
      }
    }
  }

  class func searchRecipes(query: String, completion: @escaping ([RecipeMetaData], Error?) -> Void) {
    let recipesSearchBaseURL = Endpoints.searchRecipes(query).url
    let recipesSearchParams = [
      URLQueryItem(name: "diet", value: "vegan"),
      URLQueryItem(name: "apiKey", value: RecipesClient.apiKey),
      URLQueryItem(name: "number", value: String(5))
    ]
    guard let recipesSearchURL = recipesSearchBaseURL.appending(recipesSearchParams) else { return }
    print(recipesSearchURL)
    taskForGETRequest(url: recipesSearchURL, response: RecipesMetaData.self) { response, error in
      if let response = response {
        print(response)
        completion(response.results, nil)
      } else {
        completion([], error)
      }
    }
  }

  // MARK: - Download the photo image given its URL
  class func downloadPhoto(
    photoImageURL: String,
    completion: @escaping(_ image: UIImage?) -> Void
  ) {
    // Construct the URL from the given photo information
    if let url = URL(string: photoImageURL),
    let imageData = try? Data(contentsOf: url),
    let image = UIImage(data: imageData) {
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
  class func getRecipeType() -> String {
    let hour = Calendar.current.component(.hour, from: Date())

    switch hour {
    case 6..<12 : return "breakfast"
    case 12..<15 : return "main course"
    case 15..<17 : return "beverage"
    case 17..<19 : return "snack"
    case 17..<21 : return "main course,soup"
    default: return "main course,soup,salad"
    }
  }
}
