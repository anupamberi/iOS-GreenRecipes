//
//  RecipeDetailViewController.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 16/05/2021.
//

import UIKit
import Charts

class RecipeDetailViewController: UIViewController {
  var recipeData: RecipeData!

  var recipeNutritionData: NutritionData!

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.black

    self.navigationItem.title = recipeData.title
    self.navigationItem.backButtonTitle = ""

//    RecipesClient.getRecipeNutrition(recipeId: recipeData.id) { recipeNutritionData, error in
//      guard let nutritionData = recipeNutritionData else { return }
//      self.recipeNutritionData = nutritionData
//    }

    guard let recipeNutritionResponseJsonData = try? getData(
      fromJSON: "RecipeNutritionResponse"
    ) else { return }
    let recipeNutritionResponse = try? JSONDecoder().decode(NutritionData.self, from: recipeNutritionResponseJsonData)
    recipeNutritionData = recipeNutritionResponse
    configure()
  }

  func getData(fromJSON fileName: String) throws -> Data {
    let bundle = Bundle(for: type(of: self))
    guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
      throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotOpenFile, userInfo: nil)
    }
    do {
      let data = try Data(contentsOf: url)
      return data
    } catch {
      throw error
    }
  }
}

extension RecipeDetailViewController {
  func configure() {
    let recipeDataScrollView = UIScrollView()
    recipeDataScrollView.translatesAutoresizingMaskIntoConstraints = false

    let recipeDetailsStackView = getVerticalStackView(enableSpacing: true)
    recipeDataScrollView.addSubview(recipeDetailsStackView)
    view.addSubview(recipeDataScrollView)

    let recipeImageView = UIImageView()
    recipeImageView.translatesAutoresizingMaskIntoConstraints = false
    recipeImageView.contentMode = .scaleAspectFill
    recipeImageView.clipsToBounds = true
    recipeImageView.layer.cornerRadius = 5

    DispatchQueue.global(qos: .background).async {
      DispatchQueue.main.async {
        RecipesClient.downloadRecipePhoto(
          recipeId: self.recipeData.id,
          recipeImageSize: RecipesClient.RecipePhotoSize.large.stringValue,
          recipeImageType: self.recipeData.imageType ?? "") { recipeImage in
          recipeImageView.image = recipeImage
        }
      }
    }

    let recipeTitle = UILabel()
    recipeTitle.translatesAutoresizingMaskIntoConstraints = false
    recipeTitle.font = UIFont.systemFont(ofSize: 18)
    recipeTitle.textAlignment = .center
    recipeTitle.numberOfLines = 3
    recipeTitle.lineBreakMode = .byWordWrapping
    recipeTitle.allowsDefaultTighteningForTruncation = true
    recipeTitle.textColor = .white
    recipeTitle.text = recipeData.title

    let separatorView = SeparatorView()
    let recipeTitleStackView = getVerticalStackView(enableSpacing: true)
    let recipeBasicInfoView = getRecipeBasicInfoView()

    recipeTitleStackView.addArrangedSubview(recipeTitle)
    recipeTitleStackView.addArrangedSubview(recipeBasicInfoView)

    let recipeNutritionView = getRecipeNutritionInfoView()
    let recipeIngredientsView = getRecipeIngredientsView()
    let recipeInstructionsView = getRecipeInstructionsView()

    recipeDetailsStackView.addArrangedSubview(recipeImageView)
    recipeDetailsStackView.addArrangedSubview(recipeTitleStackView)
    recipeDetailsStackView.addArrangedSubview(separatorView)
    recipeDetailsStackView.addArrangedSubview(recipeNutritionView)
    recipeDetailsStackView.addArrangedSubview(recipeIngredientsView)
    recipeDetailsStackView.addArrangedSubview(recipeInstructionsView)

    // Setup constraints
    NSLayoutConstraint.activate([
      recipeDataScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      recipeDataScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      recipeDataScrollView.topAnchor.constraint(equalTo: view.topAnchor),
      recipeDataScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      recipeDetailsStackView.leadingAnchor.constraint(equalTo: recipeDataScrollView.leadingAnchor),
      recipeDetailsStackView.trailingAnchor.constraint(equalTo: recipeDataScrollView.trailingAnchor),
      recipeDetailsStackView.topAnchor.constraint(equalTo: recipeDataScrollView.topAnchor),
      recipeDetailsStackView.bottomAnchor.constraint(equalTo: recipeDataScrollView.bottomAnchor),
      recipeDetailsStackView.widthAnchor.constraint(equalTo: recipeDataScrollView.widthAnchor),

      recipeTitleStackView.leadingAnchor.constraint(equalTo: recipeDataScrollView.leadingAnchor),
      recipeTitleStackView.trailingAnchor.constraint(equalTo: recipeDataScrollView.trailingAnchor),
      recipeTitleStackView.widthAnchor.constraint(equalTo: recipeDataScrollView.widthAnchor),

      recipeBasicInfoView.leadingAnchor.constraint(equalTo: recipeDataScrollView.leadingAnchor),
      recipeBasicInfoView.trailingAnchor.constraint(equalTo: recipeDataScrollView.trailingAnchor),
      recipeBasicInfoView.widthAnchor.constraint(equalTo: recipeDataScrollView.widthAnchor),

      recipeNutritionView.leadingAnchor.constraint(equalTo: recipeDataScrollView.leadingAnchor),
      recipeNutritionView.trailingAnchor.constraint(equalTo: recipeDataScrollView.trailingAnchor),
      recipeNutritionView.widthAnchor.constraint(equalTo: recipeDataScrollView.widthAnchor),

      recipeIngredientsView.leadingAnchor.constraint(equalTo: recipeDataScrollView.leadingAnchor),
      recipeIngredientsView.trailingAnchor.constraint(equalTo: recipeDataScrollView.trailingAnchor),
      recipeIngredientsView.widthAnchor.constraint(equalTo: recipeDataScrollView.widthAnchor),

      recipeInstructionsView.leadingAnchor.constraint(equalTo: recipeDataScrollView.leadingAnchor),
      recipeInstructionsView.trailingAnchor.constraint(equalTo: recipeDataScrollView.trailingAnchor),
      recipeInstructionsView.widthAnchor.constraint(equalTo: recipeDataScrollView.widthAnchor),
      separatorView.widthAnchor.constraint(equalTo: recipeDataScrollView.widthAnchor),

      recipeImageView.heightAnchor.constraint(equalToConstant: 300.0),
      recipeTitle.heightAnchor.constraint(equalToConstant: 50)
    ])
  }

  func getRecipeBasicInfoView() -> UIView {
    let cookingTime = UILabel()
    cookingTime.font = UIFont.systemFont(ofSize: 14)
    cookingTime.adjustsFontSizeToFitWidth = true
    cookingTime.textColor = .white
    cookingTime.text = String(recipeData.readyInMinutes) + " min"

    let ingredientsCount = UILabel()
    ingredientsCount.font = UIFont.systemFont(ofSize: 14)
    ingredientsCount.adjustsFontSizeToFitWidth = true
    ingredientsCount.textColor = .white

    if recipeData.extendedIngredients.count == 1 {
      ingredientsCount.text = String(recipeData.extendedIngredients.count) + " ingredient"
    } else {
      ingredientsCount.text = String(recipeData.extendedIngredients.count) + " ingredients"
    }

    let caloriesTitle = UILabel()
    caloriesTitle.font = UIFont.systemFont(ofSize: 14)
    caloriesTitle.adjustsFontSizeToFitWidth = true
    caloriesTitle.textColor = .white
    caloriesTitle.text = recipeNutritionData.calories

    let cookingImageView = UIImageView(image: UIImage(named: "cooking"))
    cookingImageView.clipsToBounds = true
    cookingImageView.contentMode = .scaleAspectFill

    let ingredientsImageView = UIImageView(image: UIImage(named: "ingredients"))
    ingredientsImageView.clipsToBounds = true
    ingredientsImageView.contentMode = .scaleAspectFill

    let caloriesImageView = UIImageView(image: UIImage(named: "calories"))
    caloriesImageView.clipsToBounds = true
    caloriesImageView.contentMode = .scaleAspectFill

    let recipeBasicInfoStackView = UIStackView()
    recipeBasicInfoStackView.axis = .horizontal
    recipeBasicInfoStackView.alignment = .fill
    recipeBasicInfoStackView.distribution = .fillEqually
    recipeBasicInfoStackView.spacing = 10
    recipeBasicInfoStackView.translatesAutoresizingMaskIntoConstraints = false

    let cookingTimeView = getRecipeBasicInfoSubView(title: cookingTime, imageView: cookingImageView)
    let ingredientsView = getRecipeBasicInfoSubView(title: ingredientsCount, imageView: ingredientsImageView)
    let caloriesView = getRecipeBasicInfoSubView(title: caloriesTitle, imageView: caloriesImageView)

    recipeBasicInfoStackView.addArrangedSubview(cookingTimeView)
    recipeBasicInfoStackView.addArrangedSubview(ingredientsView)
    recipeBasicInfoStackView.addArrangedSubview(caloriesView)
    return recipeBasicInfoStackView
  }

  func getRecipeBasicInfoSubView(title: UILabel, imageView: UIImageView) -> UIView {
    let basicInfoView = getVerticalStackView(enableSpacing: true)
    basicInfoView.addArrangedSubview(imageView)
    basicInfoView.addArrangedSubview(title)

    NSLayoutConstraint.activate([
      imageView.widthAnchor.constraint(equalToConstant: 30),
      imageView.heightAnchor.constraint(equalToConstant: 30)
    ])
    return basicInfoView
  }

  func getRecipeNutritionInfoView() -> UIView {
    let nutritionView = getVerticalStackView(enableSpacing: false)

    let nutritionTitle = UILabel()
    nutritionTitle.font = UIFont.systemFont(ofSize: 18)
    nutritionTitle.adjustsFontSizeToFitWidth = true
    nutritionTitle.textColor = .white
    nutritionTitle.text = "Nutrition"

    let carbsChart = getNutrientChart(nutrientTitle: "Carbohydrates")
    let proteinChart = getNutrientChart(nutrientTitle: "Protein")
    let fatChart = getNutrientChart(nutrientTitle: "Fat")

    let nutritionInfoView = UIStackView()
    nutritionInfoView.translatesAutoresizingMaskIntoConstraints = false
    nutritionInfoView.axis = .horizontal
    nutritionInfoView.alignment = .center
    nutritionInfoView.distribution = .fill

    nutritionInfoView.addArrangedSubview(carbsChart.view)
    nutritionInfoView.addArrangedSubview(proteinChart.view)
    nutritionInfoView.addArrangedSubview(fatChart.view)

    nutritionView.addArrangedSubview(nutritionTitle)
    nutritionView.addArrangedSubview(nutritionInfoView)

    NSLayoutConstraint.activate([
      nutritionTitle.heightAnchor.constraint(equalToConstant: 50)
    ])

    return nutritionView
  }

  // swiftlint:disable:next large_tuple
  func getNutrientChart(nutrientTitle: String) -> (amount: String, percent: String, view: UIView) {
    let nutrientData = getNutrientData(nutrientTitle: nutrientTitle)

    let nutrientChart = PieChartView()
    nutrientChart.translatesAutoresizingMaskIntoConstraints = false

    let nutrientLabel = UILabel()
    nutrientLabel.textAlignment = .center
    nutrientLabel.font = UIFont.systemFont(ofSize: 14)
    nutrientLabel.adjustsFontSizeToFitWidth = true
    nutrientLabel.textColor = .white

    if nutrientTitle == "Carbohydrates" {
      nutrientLabel.text = "Carbs"
    } else {
      nutrientLabel.text = nutrientTitle
    }

    let nutrientView = getVerticalStackView(enableSpacing: false)

    setUpChartView(nutrientAmount: nutrientData.amount, nutrientPercent: nutrientData.percent, chartView: nutrientChart)
    let nutritionChartDataSet = PieChartDataSet(entries: nutrientData.entries, label: nutrientTitle)

    nutritionChartDataSet.colors = [UIColor.systemGreen, UIColor.black]
    nutritionChartDataSet.drawValuesEnabled = false

    let nutritionChartData = PieChartData(dataSet: nutritionChartDataSet)
    nutrientChart.data = nutritionChartData
    nutrientChart.isUserInteractionEnabled = false

    nutrientView.addArrangedSubview(nutrientChart)
    nutrientView.addArrangedSubview(nutrientLabel)

    return (nutrientData.amount, nutrientData.percent, nutrientView)
  }

  func setUpChartView(nutrientAmount: String, nutrientPercent: String, chartView: PieChartView) {
    let centerText = NSMutableAttributedString(string: nutrientAmount + "\n" + nutrientPercent)
    let paragrapheStyleMutable = NSParagraphStyle.default.mutableCopy()
    guard let paragrapheStyle = paragrapheStyleMutable as? NSMutableParagraphStyle else { return }
    paragrapheStyle.lineBreakMode = .byTruncatingTail
    paragrapheStyle.alignment = .center
    paragrapheStyle.lineSpacing = 5

    centerText.setAttributes(
      [
        .font: UIFont.systemFont(ofSize: 13),
        .paragraphStyle: paragrapheStyle,
        .foregroundColor: UIColor.white
      ],
      range: NSRange(location: 0, length: nutrientAmount.count)
    )
    centerText.setAttributes(
      [
        .font: UIFont.systemFont(ofSize: 10),
        .foregroundColor: UIColor.systemGray5
      ],
      range: NSRange(location: nutrientAmount.count + 1, length: nutrientPercent.count)
    )

    chartView.centerAttributedText = centerText
    chartView.usePercentValuesEnabled = true
    chartView.drawSlicesUnderHoleEnabled = false
    chartView.holeRadiusPercent = 0.85
    chartView.holeColor = .black

    chartView.transparentCircleRadiusPercent = 0.61
    chartView.drawCenterTextEnabled = true
    chartView.drawHoleEnabled = true

    chartView.legend.enabled = false

    NSLayoutConstraint.activate([
      chartView.widthAnchor.constraint(equalToConstant: 100),
      chartView.heightAnchor.constraint(equalToConstant: 100)
    ])
  }

  // swiftlint:disable:next large_tuple
  func getNutrientData(nutrientTitle: String) -> (amount: String, percent: String, entries: [PieChartDataEntry]) {
    var nutrientAmount: String = ""
    var nutrientPercent: String = ""
    var dataEntries: [PieChartDataEntry] = []

    if nutrientTitle == "Protein" {
      recipeNutritionData.good.forEach { nutrient in
        if nutrient.title == nutrientTitle {
          let proteinDataEntry = PieChartDataEntry(
            value: nutrient.percentOfDailyNeeds,
            label: nil
          )
          let remainingDataEntry = PieChartDataEntry(
            value: 100 - nutrient.percentOfDailyNeeds,
            label: nil
          )
          nutrientAmount = nutrient.amount
          nutrientPercent = String(nutrient.percentOfDailyNeeds) + " %"

          dataEntries.append(proteinDataEntry)
          dataEntries.append(remainingDataEntry)
        }
      }
    } else {
      recipeNutritionData.bad.forEach { nutrient in
        if nutrient.title == nutrientTitle {
          let caloriesDataEntry = PieChartDataEntry(
            value: nutrient.percentOfDailyNeeds,
            label: nil
          )
          let remainingDataEntry = PieChartDataEntry(
            value: 100 - nutrient.percentOfDailyNeeds,
            label: nil
          )

          nutrientAmount = nutrient.amount
          nutrientPercent = String(nutrient.percentOfDailyNeeds) + " %"

          dataEntries.append(caloriesDataEntry)
          dataEntries.append(remainingDataEntry)
        }
      }
    }
    return (nutrientAmount, nutrientPercent, dataEntries)
  }

  func getRecipeIngredientsView() -> UIView {
    let ingredientsTitle = UILabel()
    ingredientsTitle.textAlignment = .center
    ingredientsTitle.font = UIFont.systemFont(ofSize: 18)
    ingredientsTitle.adjustsFontSizeToFitWidth = true
    ingredientsTitle.textColor = .white
    ingredientsTitle.text = "Ingredients"

    let ingredientsView = getVerticalStackView(enableSpacing: true)
    ingredientsView.addArrangedSubview(ingredientsTitle)

    for ingredient in recipeData.extendedIngredients {
      let ingredientDescription = UILabel()
      ingredientDescription.textAlignment = .left
      ingredientDescription.numberOfLines = 0
      ingredientDescription.lineBreakMode = .byWordWrapping
      ingredientDescription.allowsDefaultTighteningForTruncation = true
      ingredientDescription.font = UIFont.systemFont(ofSize: 14)
      ingredientDescription.adjustsFontSizeToFitWidth = true
      ingredientDescription.textColor = .white
      ingredientDescription.text = " • " + ingredient.originalString

      ingredientsView.addArrangedSubview(ingredientDescription)
    }
    NSLayoutConstraint.activate([
      ingredientsTitle.heightAnchor.constraint(equalToConstant: 50)
    ])
    return ingredientsView
  }

  func getRecipeInstructionsView() -> UIView {
    let instructionsTitle = UILabel()
    instructionsTitle.textAlignment = .center
    instructionsTitle.font = UIFont.systemFont(ofSize: 18)
    instructionsTitle.adjustsFontSizeToFitWidth = true
    instructionsTitle.textColor = .white
    instructionsTitle.text = "Instructions"

    let instructionsView = getVerticalStackView(enableSpacing: true)
    instructionsView.alignment = .leading
    instructionsView.addArrangedSubview(instructionsTitle)

    for instructionStep in recipeData.analyzedInstructions[0].steps {
      let instructionDescription = UILabel()
      instructionDescription.textAlignment = .left
      instructionDescription.numberOfLines = 0
      instructionDescription.lineBreakMode = .byWordWrapping
      instructionDescription.allowsDefaultTighteningForTruncation = true
      instructionDescription.font = UIFont.systemFont(ofSize: 14)
      instructionDescription.textColor = .white
      instructionDescription.text = " • " + instructionStep.step

      instructionsView.addArrangedSubview(instructionDescription)
    }
    NSLayoutConstraint.activate([
      instructionsTitle.heightAnchor.constraint(equalToConstant: 50)
    ])
    return instructionsView
  }
}
