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

    let recipeDetailsStackView = UIStackView()
    recipeDetailsStackView.translatesAutoresizingMaskIntoConstraints = false
    recipeDetailsStackView.axis = .vertical
    recipeDetailsStackView.alignment = .center
    recipeDetailsStackView.distribution = .fill
    recipeDetailsStackView.spacing = 10

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

    let recipeTitleLabel = UILabel()
    recipeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    recipeTitleLabel.font = UIFont.systemFont(ofSize: 18)
    recipeTitleLabel.textAlignment = .center
    recipeTitleLabel.numberOfLines = 3
    recipeTitleLabel.lineBreakMode = .byWordWrapping
    recipeTitleLabel.allowsDefaultTighteningForTruncation = true
    recipeTitleLabel.textColor = .white
    recipeTitleLabel.text = recipeData.title

    let recipeTitleStackView = UIStackView()
    recipeTitleStackView.translatesAutoresizingMaskIntoConstraints = false
    recipeTitleStackView.axis = .vertical
    recipeTitleStackView.alignment = .center
    recipeTitleStackView.distribution = .fill
    recipeTitleStackView.spacing = 10

    let recipeBasicInfoView = getRecipeBasicInfoView()

    recipeTitleStackView.addArrangedSubview(recipeTitleLabel)
    recipeTitleStackView.addArrangedSubview(recipeBasicInfoView)

    let recipeNutritionView = getNutritionInfoView()

    recipeDetailsStackView.addArrangedSubview(recipeImageView)
    recipeDetailsStackView.addArrangedSubview(recipeTitleStackView)
    recipeDetailsStackView.addArrangedSubview(recipeNutritionView)

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

      recipeImageView.heightAnchor.constraint(equalToConstant: 300.0),
      recipeTitleLabel.heightAnchor.constraint(equalToConstant: 50)
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
    let basicInfoView = UIStackView()
    basicInfoView.translatesAutoresizingMaskIntoConstraints = false
    basicInfoView.axis = .vertical
    basicInfoView.alignment = .center
    basicInfoView.distribution = .fill
    basicInfoView.spacing = 10

    basicInfoView.addArrangedSubview(imageView)
    basicInfoView.addArrangedSubview(title)

    NSLayoutConstraint.activate([
      imageView.widthAnchor.constraint(equalToConstant: 30),
      imageView.heightAnchor.constraint(equalToConstant: 30)
    ])
    return basicInfoView
  }

  func getNutritionInfoView() -> UIView {
    let nutritionView = UIStackView()
    nutritionView.translatesAutoresizingMaskIntoConstraints = false
    nutritionView.axis = .vertical
    nutritionView.alignment = .center
    nutritionView.distribution = .fill

    let viewTitle = UILabel()
    viewTitle.font = UIFont.systemFont(ofSize: 18)
    viewTitle.adjustsFontSizeToFitWidth = true
    viewTitle.textColor = .white
    viewTitle.text = "Nutrition"

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

    nutritionView.addArrangedSubview(viewTitle)
    nutritionView.addArrangedSubview(nutritionInfoView)

    NSLayoutConstraint.activate([
      viewTitle.heightAnchor.constraint(equalToConstant: 50)
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

    let nutrientView = UIStackView()
    nutrientView.translatesAutoresizingMaskIntoConstraints = false
    nutrientView.axis = .vertical
    nutrientView.alignment = .center
    nutrientView.distribution = .fill

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
    print(centerText)
    print(nutrientAmount.count)
    print(nutrientPercent.count)
    print(centerText.length)


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
}
