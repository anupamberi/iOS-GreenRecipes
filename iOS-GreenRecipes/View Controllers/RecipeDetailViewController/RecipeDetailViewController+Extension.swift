//
//  RecipeDetailViewController+Extension.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 22/05/2021.
//

import UIKit
import Charts

// MARK: - Initializes a scroll view layout to display the details of a recipe
extension RecipeDetailViewController {
  // swiftlint:disable function_body_length
  func configure() {
    configureTitle()
    let recipeDataScrollView = UIScrollView()
    recipeDataScrollView.translatesAutoresizingMaskIntoConstraints = false

    let recipeDetailsView = getVerticalStackView(enableSpacing: true)
    recipeDetailsView.backgroundColor = .systemGray5
    recipeDetailsView.layer.cornerRadius = 10

    recipeDataScrollView.addSubview(recipeDetailsView)
    view.addSubview(recipeDataScrollView)

    let cancelButton = UIButton(frame: .zero)
    cancelButton.backgroundColor = .systemGray
    cancelButton.translatesAutoresizingMaskIntoConstraints = false
    cancelButton.setImage(UIImage(named: "cancel"), for: .normal)
    cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    view.addSubview(cancelButton)

    let recipeImageView = createRecipeImageView()
    let recipeTitle = createTitleLabel(size: 24, textToSet: recipe.title ?? "")
    let recipeButtonsView = createButtonsView()
    let nutritionTitle = createTitleLabel(size: 22, textToSet: "Nutrition Information")
    let ingredientsTitle = createTitleLabel(size: 22, textToSet: "Ingredients")

    let ingredientsSubTitle = createSubTitleLabel(size: 14, textToSet: "")
    if recipe.servings == 1 || recipe.servings == 0 {
      ingredientsSubTitle.text = String("1 serving")
    } else {
      ingredientsSubTitle.text = String("\(recipe.servings) servings")
    }
    let instructionsTitle = createTitleLabel(size: 22, textToSet: "Instructions")
    let instructionsSubTitle = createSubTitleLabel(size: 14, textToSet: "Ready in \(recipe.preparationTime) mins")

    let recipeBasicInfoView = createRecipeBasicInfoView()
    let recipeNutritionView = createRecipeNutritionInfoView()
    let recipeIngredientsView = createRecipeIngredientsView()
    let recipeInstructionsView = createRecipeInstructionsView()

    recipeDetailsView.addArrangedSubview(recipeImageView)
    recipeDetailsView.addArrangedSubview(recipeTitle)
    recipeDetailsView.addArrangedSubview(spacing(value: 20))
    recipeDetailsView.addArrangedSubview(recipeBasicInfoView)
    recipeDetailsView.addArrangedSubview(lineWithEqualSpacing(value: 20))
    recipeDetailsView.addArrangedSubview(recipeButtonsView)
    recipeDetailsView.addArrangedSubview(lineWithEqualSpacing(value: 20))
    recipeDetailsView.addArrangedSubview(nutritionTitle)
    recipeDetailsView.addArrangedSubview(spacing(value: 10))
    recipeDetailsView.addArrangedSubview(recipeNutritionView)
    recipeDetailsView.addArrangedSubview(lineWithEqualSpacing(value: 20))
    recipeDetailsView.addArrangedSubview(ingredientsTitle)
    recipeDetailsView.addArrangedSubview(ingredientsSubTitle)
    recipeDetailsView.addArrangedSubview(spacing(value: 10))
    recipeDetailsView.addArrangedSubview(recipeIngredientsView)
    recipeDetailsView.addArrangedSubview(lineWithEqualSpacing(value: 20))
    recipeDetailsView.addArrangedSubview(instructionsTitle)
    recipeDetailsView.addArrangedSubview(instructionsSubTitle)
    recipeDetailsView.addArrangedSubview(spacing(value: 10))
    recipeDetailsView.addArrangedSubview(recipeInstructionsView)

    // Setup constraints
    NSLayoutConstraint.activate([
      recipeDataScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      recipeDataScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      recipeDataScrollView.topAnchor.constraint(equalTo: view.topAnchor),
      recipeDataScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      cancelButton.leadingAnchor.constraint(equalTo: recipeDetailsView.leadingAnchor, constant: 15),
      cancelButton.topAnchor.constraint(equalTo: recipeDetailsView.topAnchor, constant: 15),
      cancelButton.widthAnchor.constraint(equalToConstant: 24),
      cancelButton.heightAnchor.constraint(equalToConstant: 24),

      recipeDetailsView.leadingAnchor.constraint(equalTo: recipeDataScrollView.leadingAnchor),
      recipeDetailsView.trailingAnchor.constraint(equalTo: recipeDataScrollView.trailingAnchor),
      recipeDetailsView.topAnchor.constraint(equalTo: recipeDataScrollView.topAnchor),
      recipeDetailsView.bottomAnchor.constraint(equalTo: recipeDataScrollView.bottomAnchor),
      recipeDetailsView.widthAnchor.constraint(equalTo: recipeDataScrollView.widthAnchor),

      recipeBasicInfoView.leadingAnchor.constraint(equalTo: recipeDataScrollView.leadingAnchor),
      recipeBasicInfoView.trailingAnchor.constraint(equalTo: recipeDataScrollView.trailingAnchor),
      recipeBasicInfoView.widthAnchor.constraint(equalTo: recipeDataScrollView.widthAnchor),

      recipeButtonsView.leadingAnchor.constraint(equalTo: recipeDataScrollView.leadingAnchor),
      recipeButtonsView.trailingAnchor.constraint(equalTo: recipeDataScrollView.trailingAnchor),
      recipeButtonsView.widthAnchor.constraint(equalTo: recipeDataScrollView.widthAnchor),
      recipeButtonsView.heightAnchor.constraint(equalToConstant: 30),

      recipeNutritionView.leadingAnchor.constraint(equalTo: recipeDataScrollView.leadingAnchor),
      recipeNutritionView.trailingAnchor.constraint(equalTo: recipeDataScrollView.trailingAnchor),
      recipeNutritionView.widthAnchor.constraint(equalTo: recipeDataScrollView.widthAnchor),

      recipeIngredientsView.leadingAnchor.constraint(equalTo: recipeDataScrollView.leadingAnchor, constant: 20),
      recipeIngredientsView.trailingAnchor.constraint(equalTo: recipeDataScrollView.trailingAnchor, constant: -20),

      recipeInstructionsView.leadingAnchor.constraint(equalTo: recipeDataScrollView.leadingAnchor, constant: 20),
      recipeInstructionsView.trailingAnchor.constraint(equalTo: recipeDataScrollView.trailingAnchor, constant: -20),

      recipeTitle.leadingAnchor.constraint(equalTo: recipeDataScrollView.leadingAnchor, constant: 20),
      recipeTitle.trailingAnchor.constraint(equalTo: recipeDataScrollView.trailingAnchor, constant: -20),

      nutritionTitle.leadingAnchor.constraint(equalTo: recipeDataScrollView.leadingAnchor, constant: 20),
      nutritionTitle.trailingAnchor.constraint(equalTo: recipeDataScrollView.trailingAnchor, constant: -20),

      ingredientsTitle.leadingAnchor.constraint(equalTo: recipeDataScrollView.leadingAnchor, constant: 20),
      ingredientsTitle.trailingAnchor.constraint(equalTo: recipeDataScrollView.trailingAnchor, constant: -20),

      ingredientsSubTitle.leadingAnchor.constraint(equalTo: recipeDataScrollView.leadingAnchor, constant: 20),
      ingredientsSubTitle.trailingAnchor.constraint(equalTo: recipeDataScrollView.trailingAnchor, constant: -20),

      instructionsTitle.leadingAnchor.constraint(equalTo: recipeDataScrollView.leadingAnchor, constant: 20),
      instructionsTitle.trailingAnchor.constraint(equalTo: recipeDataScrollView.trailingAnchor, constant: -20),

      instructionsSubTitle.leadingAnchor.constraint(equalTo: recipeDataScrollView.leadingAnchor, constant: 20),
      instructionsSubTitle.trailingAnchor.constraint(equalTo: recipeDataScrollView.trailingAnchor, constant: -20),

      recipeImageView.heightAnchor.constraint(equalToConstant: 300)
    ])
  }

  private func configureTitle() {
    self.navigationItem.title = recipe.title
  }

  private func createRecipeImageView() -> UIView {
    let recipeImageView = UIImageView()
    recipeImageView.translatesAutoresizingMaskIntoConstraints = false
    recipeImageView.contentMode = .scaleAspectFill
    recipeImageView.clipsToBounds = true
    recipeImageView.layer.cornerRadius = 10

    // Download the recipe image
    if let recipeImage = recipe.image {
      recipeImageView.image = UIImage(data: recipeImage)
    } else {
      // Download a recipe large image
      // Set the placeholder image
      recipeImageView.image = UIImage(named: "placeholder")
      DispatchQueue.global(qos: .background).async {
        RecipesClient.downloadRecipePhoto(
          recipeId: Int(self.recipe.id),
          recipeImageSize: RecipesClient.RecipePhotoSize.large.stringValue,
          recipeImageType: self.recipe.imageType ?? "") { recipeImage in
          if let recipeImage = recipeImage {
            DispatchQueue.main.async {
              recipeImageView.image = recipeImage
              self.recipe.image = recipeImage.jpegData(compressionQuality: 1.0)
              try? self.dataController.viewContext.save()
            }
          }
        }
      }
    }
    return recipeImageView
  }


  @objc func cancelTapped() {
    // Remove the last recipe entry
    UserDefaults.standard.removeObject(forKey: "lastOpenedRecipe")
    dismiss(animated: true, completion: nil)
  }

  @objc func bookmarkTapped(bookmarkButton: UIButton) {
    recipe.isBookmarked.toggle()
    recipe.isBookmarked ?
      bookmarkButton.setImage(UIImage(named: "bookmarked"), for: .normal) :
      bookmarkButton.setImage(UIImage(named: "bookmark"), for: .normal)
    try? dataController.viewContext.save()
  }

  @objc func shareTapped(shareButton: UIButton) {
    let recipeSouceURL = recipe.sourceURL
    // Define an activity controller
    let activityViewController = UIActivityViewController(
      activityItems: [recipeSouceURL as Any],
      applicationActivities: nil
    )
    self.present(activityViewController, animated: true, completion: nil)
  }

  private func createButtonsView() -> UIView {
    let recipeActionButtonsView = UIStackView()
    recipeActionButtonsView.axis = .horizontal
    recipeActionButtonsView.alignment = .fill
    recipeActionButtonsView.distribution = .fillEqually
    recipeActionButtonsView.spacing = 5
    recipeActionButtonsView.translatesAutoresizingMaskIntoConstraints = false

    let bookmarkButton = UIButton(frame: .zero)
    bookmarkButton.translatesAutoresizingMaskIntoConstraints = false
    recipe.isBookmarked ?
      bookmarkButton.setImage(UIImage(named: "bookmarked"), for: .normal) :
      bookmarkButton.setImage(UIImage(named: "bookmark"), for: .normal)

    bookmarkButton.imageView?.contentMode = .scaleAspectFit
    bookmarkButton.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
    bookmarkButton.setTitle("Bookmark", for: .normal)
    bookmarkButton.titleLabel?.font = .systemFont(ofSize: 14)

    let shareButton = UIButton(frame: .zero)
    shareButton.translatesAutoresizingMaskIntoConstraints = false
    shareButton.setImage(UIImage(named: "share"), for: .normal)
    shareButton.imageView?.contentMode = .scaleAspectFit
    shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
    shareButton.setTitle("Share", for: .normal)
    shareButton.titleLabel?.font = .systemFont(ofSize: 14)

    recipeActionButtonsView.addArrangedSubview(bookmarkButton)
    recipeActionButtonsView.addArrangedSubview(shareButton)
    return recipeActionButtonsView
  }

  private func createRecipeBasicInfoView() -> UIView {
    let cookingTime = UILabel()
    cookingTime.font = UIFont.systemFont(ofSize: 14)
    cookingTime.adjustsFontSizeToFitWidth = true
    cookingTime.textColor = .white
    cookingTime.text = String(recipe.preparationTime) + " min"

    let ingredientsCount = UILabel()
    ingredientsCount.font = UIFont.systemFont(ofSize: 14)
    ingredientsCount.adjustsFontSizeToFitWidth = true
    ingredientsCount.textColor = .white

    if let recipeIngredients = recipe.ingredients {
      if recipeIngredients.count == 1 {
        ingredientsCount.text = String(recipeIngredients.count) + " ingredient"
      } else {
        ingredientsCount.text = String(recipeIngredients.count) + " ingredients"
      }
    }

    let caloriesTitle = UILabel()
    caloriesTitle.font = UIFont.systemFont(ofSize: 14)
    caloriesTitle.adjustsFontSizeToFitWidth = true
    caloriesTitle.textColor = .white
    fetchRecipeNutrition { nutrition in
      if let nutrition = nutrition {
        caloriesTitle.text = nutrition.calories
      }
    }

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

    let cookingTimeView = createRecipeBasicInfoSubView(title: cookingTime, imageView: cookingImageView)
    let ingredientsView = createRecipeBasicInfoSubView(title: ingredientsCount, imageView: ingredientsImageView)
    let caloriesView = createRecipeBasicInfoSubView(title: caloriesTitle, imageView: caloriesImageView)

    recipeBasicInfoStackView.addArrangedSubview(cookingTimeView)
    recipeBasicInfoStackView.addArrangedSubview(ingredientsView)
    recipeBasicInfoStackView.addArrangedSubview(caloriesView)
    return recipeBasicInfoStackView
  }

  private func createRecipeBasicInfoSubView(title: UILabel, imageView: UIImageView) -> UIView {
    let basicInfoView = getVerticalStackView(enableSpacing: true)
    basicInfoView.addArrangedSubview(imageView)
    basicInfoView.addArrangedSubview(title)

    NSLayoutConstraint.activate([
      imageView.widthAnchor.constraint(equalToConstant: 30),
      imageView.heightAnchor.constraint(equalToConstant: 30)
    ])
    return basicInfoView
  }

  private func createRecipeNutritionInfoView() -> UIView {
    let nutritionView = getVerticalStackView(enableSpacing: false)

    let carbsChart = createNutrientChart(nutrientTitle: "Carbohydrates")
    let proteinChart = createNutrientChart(nutrientTitle: "Protein")
    let fatChart = createNutrientChart(nutrientTitle: "Fat")

    let nutritionInfoView = UIStackView()
    nutritionInfoView.translatesAutoresizingMaskIntoConstraints = false
    nutritionInfoView.axis = .horizontal
    nutritionInfoView.alignment = .center
    nutritionInfoView.distribution = .fill

    nutritionInfoView.addArrangedSubview(carbsChart.view)
    nutritionInfoView.addArrangedSubview(proteinChart.view)
    nutritionInfoView.addArrangedSubview(fatChart.view)

    nutritionView.addArrangedSubview(nutritionInfoView)
    return nutritionView
  }

  // swiftlint:disable:next large_tuple
  private func createNutrientChart(nutrientTitle: String) -> (amount: String, percent: String, view: UIView) {
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

    nutritionChartDataSet.colors = [UIColor.systemGreen, UIColor.systemGray5]
    nutritionChartDataSet.drawValuesEnabled = false

    let nutritionChartData = PieChartData(dataSet: nutritionChartDataSet)
    nutrientChart.data = nutritionChartData
    nutrientChart.isUserInteractionEnabled = false

    nutrientView.addArrangedSubview(nutrientChart)
    nutrientView.addArrangedSubview(nutrientLabel)

    return (nutrientData.amount, nutrientData.percent, nutrientView)
  }

  private func setUpChartView(nutrientAmount: String, nutrientPercent: String, chartView: PieChartView) {
    let centerText = NSMutableAttributedString(string: nutrientAmount + "\n" + nutrientPercent)
    let paragrapheStyleMutable = NSParagraphStyle.default.mutableCopy()
    guard let paragrapheStyle = paragrapheStyleMutable as? NSMutableParagraphStyle else { return }
    paragrapheStyle.lineBreakMode = .byTruncatingTail
    paragrapheStyle.alignment = .center
    paragrapheStyle.lineSpacing = 5

    centerText.setAttributes(
      [
        .font: UIFont.systemFont(ofSize: 14),
        .paragraphStyle: paragrapheStyle,
        .foregroundColor: UIColor.white
      ],
      range: NSRange(location: 0, length: nutrientAmount.count)
    )
    centerText.setAttributes(
      [
        .font: UIFont.systemFont(ofSize: 13),
        .foregroundColor: UIColor.white
      ],
      range: NSRange(location: nutrientAmount.count + 1, length: nutrientPercent.count)
    )

    chartView.centerAttributedText = centerText
    chartView.usePercentValuesEnabled = true
    chartView.drawSlicesUnderHoleEnabled = false
    chartView.holeRadiusPercent = 0.85
    chartView.holeColor = .systemGray5

    chartView.transparentCircleRadiusPercent = 0.61
    chartView.drawCenterTextEnabled = true
    chartView.drawHoleEnabled = true

    chartView.legend.enabled = false

    NSLayoutConstraint.activate([
      chartView.widthAnchor.constraint(equalToConstant: 120),
      chartView.heightAnchor.constraint(equalToConstant: 120)
    ])
  }

  // swiftlint:disable:next large_tuple
  func getNutrientData(nutrientTitle: String) -> (amount: String, percent: String, entries: [PieChartDataEntry]) {
    var nutrientAmount: String = ""
    var nutrientPercent: String = ""
    var dataEntries: [PieChartDataEntry] = []

    fetchRecipeNutrition { nutrition in
      guard let nutrition = nutrition else { return }
      if nutrientTitle == "Protein" {
        let proteinDataEntry = PieChartDataEntry(
          value: nutrition.proteinPercent,
          label: nil
        )
        let remainingDataEntry = PieChartDataEntry(
          value: 100 - nutrition.proteinPercent,
          label: nil
        )
        if let proteinAmount = nutrition.protein {
          nutrientAmount = proteinAmount
        }
        nutrientPercent = String(nutrition.proteinPercent) + " %"

        dataEntries.append(proteinDataEntry)
        dataEntries.append(remainingDataEntry)
      }
      if nutrientTitle == "Carbohydrates" {
        let carbsDataEntry = PieChartDataEntry(
          value: nutrition.carbsPercent,
          label: nil
        )
        let remainingDataEntry = PieChartDataEntry(
          value: 100 - nutrition.carbsPercent,
          label: nil
        )

        if let carbsAmount = nutrition.carbs {
          nutrientAmount = carbsAmount
        }
        nutrientPercent = String(nutrition.carbsPercent) + " %"

        dataEntries.append(carbsDataEntry)
        dataEntries.append(remainingDataEntry)
      }
      if nutrientTitle == "Fat" {
        let fatDataEntry = PieChartDataEntry(
          value: nutrition.fatPercent,
          label: nil
        )
        let remainingDataEntry = PieChartDataEntry(
          value: 100 - nutrition.fatPercent,
          label: nil
        )

        if let fatAmount = nutrition.fat {
          nutrientAmount = fatAmount
        }
        nutrientPercent = String(nutrition.fatPercent) + " %"

        dataEntries.append(fatDataEntry)
        dataEntries.append(remainingDataEntry)
      }
    }
    return (nutrientAmount, nutrientPercent, dataEntries)
  }

  private func createRecipeIngredientsView() -> UIView {
    let ingredientsView = getVerticalStackView(enableSpacing: true)
    ingredientsView.alignment = .leading

    fetchRecipeIngredients { recipeIngredients in
      if recipeIngredients.isEmpty {
        let noIngredients = UILabel()
        noIngredients.textAlignment = .center
        noIngredients.font = UIFont.systemFont(ofSize: 18)
        noIngredients.textColor = .white
        noIngredients.text = "No ingredients data found"
        ingredientsView.addArrangedSubview(noIngredients)
      } else {
        for recipeIngredient in recipeIngredients {
          guard let ingredientOriginalString = recipeIngredient.originalString else { continue }
          let ingredientDescription = UILabel()
          ingredientDescription.textAlignment = .left
          ingredientDescription.numberOfLines = 0
          ingredientDescription.lineBreakMode = .byWordWrapping
          ingredientDescription.allowsDefaultTighteningForTruncation = true
          ingredientDescription.font = UIFont.systemFont(ofSize: 16)
          ingredientDescription.textColor = .white

          let ingredientDescriptionText = " • " + ingredientOriginalString
          let ingredientDescriptionAttributedText = NSMutableAttributedString(string: ingredientDescriptionText)
          ingredientDescriptionAttributedText.addAttribute(
            .foregroundColor,
            value: UIColor.systemGreen,
            range: NSRange(location: 0, length: 2))
          ingredientDescription.attributedText = ingredientDescriptionAttributedText
          ingredientsView.addArrangedSubview(ingredientDescription)
        }
      }
    }
    return ingredientsView
  }

  private func createRecipeInstructionsView() -> UIView {
    let instructionsView = getVerticalStackView(enableSpacing: true)
    instructionsView.alignment = .leading

    fetchRecipeInstructions { recipeInstructions in
      if recipeInstructions.isEmpty {
        let noSteps = UILabel()
        noSteps.textAlignment = .center
        noSteps.font = UIFont.systemFont(ofSize: 18)
        noSteps.textColor = .white
        noSteps.text = "No instructions found"
        instructionsView.addArrangedSubview(noSteps)
      } else {
        for instructionStep in recipeInstructions {
          let instructionStepNumber = UILabel()
          instructionStepNumber.textAlignment = .center
          instructionStepNumber.font = UIFont.systemFont(ofSize: 18)
          instructionStepNumber.textColor = .white
          instructionStepNumber.text = "Step " + String(instructionStep.number)
          instructionStepNumber.layer.borderWidth = 2
          instructionStepNumber.layer.cornerRadius = 5
          instructionStepNumber.layer.borderColor = UIColor.systemGreen.cgColor
          instructionStepNumber.widthAnchor.constraint(equalToConstant: 80).isActive = true
          instructionStepNumber.heightAnchor.constraint(equalToConstant: 30).isActive = true

          instructionStepNumber.sizeToFit()

          let instructionDescription = UILabel()
          instructionDescription.textAlignment = .justified
          instructionDescription.numberOfLines = 0
          instructionDescription.lineBreakMode = .byWordWrapping
          instructionDescription.allowsDefaultTighteningForTruncation = true
          instructionDescription.font = UIFont.systemFont(ofSize: 16)
          instructionDescription.textColor = .white
          instructionDescription.text = instructionStep.step

          instructionsView.addArrangedSubview(instructionStepNumber)
          instructionsView.addArrangedSubview(self.spacing(value: 10))
          instructionsView.addArrangedSubview(instructionDescription)
          instructionsView.addArrangedSubview(self.spacing(value: 20))
        }
      }
    }
    return instructionsView
  }
  // swiftlint:disable file_length
}
