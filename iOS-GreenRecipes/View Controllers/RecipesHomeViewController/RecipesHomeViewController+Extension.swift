//
//  RecipesHomeViewController+Extension.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 27/05/2021.
//

import UIKit

extension RecipesHomeViewController {
  func configureTitle() {
    navigationItem.title = "Today's recipes"
    navigationItem.largeTitleDisplayMode = .automatic
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
      print(error.localizedDescription)
      throw error
    }
  }

  func fetchData() {
    guard let randomRecipesJsonData = try? getData(
      fromJSON: "RecipesRandomSearchResponse"
    ) else { return }
    let randomRecipesResponse = try? JSONDecoder().decode(RecipesData.self, from: randomRecipesJsonData)
    randomRecipesData = randomRecipesResponse?.recipes ?? []

    guard let quickAndEasyRecipesJsonData = try? getData(
      fromJSON: "RecipesSearchResponse"
    ) else { return }
    let quickAndEasyResponse = try? JSONDecoder().decode(RecipesData.self, from: quickAndEasyRecipesJsonData)
    quickAndEasyRecipesData = quickAndEasyResponse?.results ?? []

    guard let beverageRecipesJsonData = try? getData(
      fromJSON: "RecipesSearchResponseBeverage"
    ) else { return }
    do {
      let beverageResponse = try JSONDecoder().decode(RecipesData.self, from: beverageRecipesJsonData)
      beverageRecipesData = beverageResponse.results ?? []
    } catch {
      print(error.localizedDescription)
    }

    guard let mainCourseRecipesJsonData = try? getData(
      fromJSON: "RecipesSearchResponseMainCourse"
    ) else { return }
    let mainCourseResponse = try? JSONDecoder().decode(RecipesData.self, from: mainCourseRecipesJsonData)
    mainCourseRecipesData = mainCourseResponse?.results ?? []

    guard let breakfastRecipesJsonData = try? getData(
      fromJSON: "RecipesSearchResponseBreakfast"
    ) else { return }
    let breakfastResponse = try? JSONDecoder().decode(RecipesData.self, from: breakfastRecipesJsonData)
    breakfastRecipesData = breakfastResponse?.results ?? []

    guard let dessertRecipesJsonData = try? getData(
      fromJSON: "RecipesSearchResponseDessert"
    ) else { return }
    let dessertResponse = try? JSONDecoder().decode(RecipesData.self, from: dessertRecipesJsonData)
    dessertRecipesData = dessertResponse?.results ?? []

    applyInitialSnapshots()
  }

  func configureHierarchy() {
    let layout = createLayout()
    layout.configuration.interSectionSpacing = 50

    layout.register(
      RecipesSectionBackgroundDecorationView.self,
      forDecorationViewOfKind: RecipesHomeViewController.backgroundElementKind
    )
    recipesCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
    recipesCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    recipesCollectionView.backgroundColor = .systemGroupedBackground
    recipesCollectionView.delegate = self
    view.addSubview(recipesCollectionView)
  }

  func createLayout() -> UICollectionViewCompositionalLayout {
    let sectionProvider = { (sectionIndex: Int, _ : NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
      let sectionType = self.recipesSections[sectionIndex]
      // orthogonal scrolling sections
      let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .fractionalHeight(1.0)
      )
      let item = NSCollectionLayoutItem(layoutSize: itemSize)

      let groupSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(CGFloat(sectionType.widthRatio)),
        heightDimension: .estimated(CGFloat(sectionType.height))
      )

      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
      let section = NSCollectionLayoutSection(group: group)
      section.interGroupSpacing = 10
      section.orthogonalScrollingBehavior = sectionType.scrollingBehavior
      section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

      let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .estimated(20)),
        elementKind: RecipesHomeViewController.headerElementKind,
        alignment: .topLeading
      )
      sectionHeader.pinToVisibleBounds = false
      section.boundarySupplementaryItems = [sectionHeader]

      let sectionBackground = NSCollectionLayoutDecorationItem.background(
        elementKind: RecipesHomeViewController.backgroundElementKind
      )
      section.decorationItems = [sectionBackground]
      return section
    }
    return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
  }

  func createRecipeWithDetailRegistration() -> UICollectionView.CellRegistration<RecipeWithDetailViewCell, RecipeData> {
    return UICollectionView.CellRegistration<RecipeWithDetailViewCell, RecipeData> { cell, indexPath, recipe in
      let section = self.recipesSections[indexPath.section]
      cell.recipeImageView.image = UIImage(named: "placeholder")
      DispatchQueue.global(qos: .background).async {
        DispatchQueue.main.async {
          RecipesClient.downloadRecipePhoto(
            recipeId: recipe.id,
            recipeImageSize: section.recipeImageSize,
            recipeImageType: recipe.imageType ?? RecipesClient.RecipePhotoSize.medium.stringValue) { recipeImage in
            cell.recipeImageView.image = recipeImage
          }
        }
      }
      if recipe.extendedIngredients.count == 1 {
        cell.recipeIngredientsCount.text = String(recipe.extendedIngredients.count) + " ingredient"
      } else {
        cell.recipeIngredientsCount.text = String(recipe.extendedIngredients.count) + " ingredients"
      }
      cell.recipePreparationTime.text = String(recipe.readyInMinutes) + " min prep"
      cell.recipeTitleLabel.text = recipe.title
    }
  }

  func createRecipeWithTitleRegistration() -> UICollectionView.CellRegistration<RecipeWithTitleViewCell, RecipeData> {
    return UICollectionView.CellRegistration<RecipeWithTitleViewCell, RecipeData> { cell, indexPath, recipe in
      let section = self.recipesSections[indexPath.section]
      cell.recipeImageView.image = UIImage(named: "placeholder")
      DispatchQueue.global(qos: .background).async {
        DispatchQueue.main.async {
          RecipesClient.downloadRecipePhoto(
            recipeId: recipe.id,
            recipeImageSize: section.recipeImageSize,
            recipeImageType: recipe.imageType ?? RecipesClient.RecipePhotoSize.medium.stringValue) { recipeImage in
            cell.recipeImageView.image = recipeImage
          }
        }
      }
      cell.recipeTitleLabel.text = recipe.title
    }
  }

  func configureDataSource() {
    // create registrations up front, then choose the appropirate one to use in the cell provider
    let recipeWithDetail = createRecipeWithDetailRegistration()
    let recipeWithTitle = createRecipeWithTitleRegistration()
    // data source
    dataSource = UICollectionViewDiffableDataSource<RecipesSectionProperties, RecipeData>(
      collectionView: recipesCollectionView) { collectionView, indexPath, recipe -> UICollectionViewCell? in
      let section = self.recipesSections[indexPath.section]

      switch section.searchKey {
      case RecipesSectionSearchKey.random,
        RecipesSectionSearchKey.breakfast,
        RecipesSectionSearchKey.mainCourse,
        RecipesSectionSearchKey.beverage:
        return collectionView.dequeueConfiguredReusableCell(using: recipeWithDetail, for: indexPath, item: recipe)
      case RecipesSectionSearchKey.quickAndEasy, RecipesSectionSearchKey.dessert, RecipesSectionSearchKey.beverage:
        return collectionView.dequeueConfiguredReusableCell(using: recipeWithTitle, for: indexPath, item: recipe)
      default: fatalError("Unknown section")
      }
    }

    let recipesSupplementaryRegistration = UICollectionView.SupplementaryRegistration<RecipesSectionTitleView>(
      elementKind: RecipesHomeViewController.headerElementKind) { supplementaryView, _, indexPath in
      let section = self.recipesSections[indexPath.section]
      supplementaryView.label.text = String(describing: section.description)
      supplementaryView.label.textColor = .white
    }

    dataSource.supplementaryViewProvider = { _, _, index in
      return self.recipesCollectionView.dequeueConfiguredReusableSupplementary(
        using: recipesSupplementaryRegistration,
        for: index
      )
    }
  }

  func applyInitialSnapshots() {
    var randomRecipesSection = RecipesSectionProperties(
      description: "Recommended for you",
      preferenceKey: HomePreferences.recommendations.description,
      searchKey: RecipesSectionSearchKey.random,
      widthRatio: 1.0,
      heightRatio: 300.0,
      recipeImageSize: RecipesClient.RecipePhotoSize.large.stringValue,
      scrollingBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPagingCentered
    )

    randomRecipesSection.recipesInSection = randomRecipesData

    var quickAndEasyRecipesSection = RecipesSectionProperties(
      description: "Quick & Easy",
      preferenceKey: HomePreferences.quickAndEasy.description,
      searchKey: RecipesSectionSearchKey.quickAndEasy,
      widthRatio: 0.45,
      heightRatio: 250.0,
      recipeImageSize: RecipesClient.RecipePhotoSize.large.stringValue,
      scrollingBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior.continuousGroupLeadingBoundary
    )

    quickAndEasyRecipesSection.recipesInSection = quickAndEasyRecipesData

    let recipeType = RecipesClient.getRecipeType()

    var recipeTypeSection = RecipesSectionProperties(
      description: recipeType,
      preferenceKey: recipeType,
      searchKey: recipeType,
      widthRatio: 1.0,
      heightRatio: 300.0,
      recipeImageSize: RecipesClient.RecipePhotoSize.large.stringValue,
      scrollingBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPagingCentered
    )

    let dessertRecipesSection = RecipesSectionProperties(
      description: "Desserts",
      preferenceKey: HomePreferences.desserts.description,
      searchKey: RecipesSectionSearchKey.dessert,
      widthRatio: 0.45,
      heightRatio: 250.0,
      recipeImageSize: RecipesClient.RecipePhotoSize.large.stringValue,
      scrollingBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior.continuousGroupLeadingBoundary
    )

    dessertRecipesSection.recipesInSection = dessertRecipesData

    if recipeType == "breakfast" {
      recipeTypeSection.description = "Delicious Breakfast"
      recipeTypeSection.recipesInSection = breakfastRecipesData
    }
    if recipeType == "beverage" {
      recipeTypeSection.description = "Beverages"
      recipeTypeSection.recipesInSection = beverageRecipesData
    }
    if recipeType == "main course" {
      recipeTypeSection.description = "Main Course"
      recipeTypeSection.recipesInSection = mainCourseRecipesData
    }

    recipesSections.append(randomRecipesSection)
    recipesSections.append(quickAndEasyRecipesSection)
    recipesSections.append(recipeTypeSection)
    recipesSections.append(dessertRecipesSection)

    var snapshot = NSDiffableDataSourceSnapshot<RecipesSectionProperties, RecipeData>()
    snapshot.appendSections(recipesSections)

    snapshot.appendItems(randomRecipesSection.recipesInSection, toSection: randomRecipesSection)
    snapshot.appendItems(quickAndEasyRecipesSection.recipesInSection, toSection: quickAndEasyRecipesSection)
    snapshot.appendItems(recipeTypeSection.recipesInSection, toSection: recipeTypeSection)
    snapshot.appendItems(dessertRecipesSection.recipesInSection, toSection: dessertRecipesSection)

    dataSource.apply(snapshot)
  }

  func initRecipesSections() {
    if let homeRecipeCategories = UserDefaults.standard.array(forKey: "HomePreferences") as? [String] {
      homeRecipeCategories.forEach { homeRecipeCategory in
        switch homeRecipeCategory {
        case "Recommended For You":
          let randomRecipesSection = RecipesSectionProperties(
            description: homeRecipeCategory,
            preferenceKey: HomePreferences.recommendations.description,
            searchKey: RecipesSectionSearchKey.random,
            widthRatio: 1.0,
            heightRatio: 300.0,
            recipeImageSize: RecipesClient.RecipePhotoSize.large.stringValue,
            scrollingBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPagingCentered
          )
          recipesSections.append(randomRecipesSection)
        case "Quick & Easy":
          let quickAndEasyRecipesSection = RecipesSectionProperties(
            description: homeRecipeCategory,
            preferenceKey: HomePreferences.quickAndEasy.description,
            searchKey: RecipesSectionSearchKey.quickAndEasy,
            widthRatio: 0.45,
            heightRatio: 250.0,
            recipeImageSize: RecipesClient.RecipePhotoSize.medium.stringValue,
            scrollingBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior.continuousGroupLeadingBoundary
          )
          recipesSections.append(quickAndEasyRecipesSection)
        case "Breakfast":
          let breakfastRecipesSection = RecipesSectionProperties(
            description: homeRecipeCategory,
            preferenceKey: HomePreferences.breakfast.description,
            searchKey: RecipesSectionSearchKey.breakfast,
            widthRatio: 1.0,
            heightRatio: 300.0,
            recipeImageSize: RecipesClient.RecipePhotoSize.large.stringValue,
            scrollingBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPagingCentered
          )
          recipesSections.append(breakfastRecipesSection)
        case "Main Course":
          let mainCourseRecipesSection = RecipesSectionProperties(
            description: homeRecipeCategory,
            preferenceKey: HomePreferences.mainCourse.description,
            searchKey: RecipesSectionSearchKey.mainCourse,
            widthRatio: 1.0,
            heightRatio: 300.0,
            recipeImageSize: RecipesClient.RecipePhotoSize.large.stringValue,
            scrollingBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPagingCentered
          )
          recipesSections.append(mainCourseRecipesSection)
        case "Beverages":
          let beveragesRecipesSection = RecipesSectionProperties(
            description: homeRecipeCategory,
            preferenceKey: HomePreferences.beverages.description,
            searchKey: RecipesSectionSearchKey.beverage,
            widthRatio: 1.0,
            heightRatio: 300.0,
            recipeImageSize: RecipesClient.RecipePhotoSize.large.stringValue,
            scrollingBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPagingCentered
          )
          recipesSections.append(beveragesRecipesSection)
        case "Desserts":
          let dessertRecipesSection = RecipesSectionProperties(
            description: homeRecipeCategory,
            preferenceKey: HomePreferences.desserts.description,
            searchKey: RecipesSectionSearchKey.dessert,
            widthRatio: 0.45,
            heightRatio: 250.0,
            recipeImageSize: RecipesClient.RecipePhotoSize.medium.stringValue,
            scrollingBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior.continuousGroupLeadingBoundary
          )
          recipesSections.append(dessertRecipesSection)
        default: fatalError("Unknown recipe search category")
        }
      }
    }
    var snapshot = NSDiffableDataSourceSnapshot<RecipesSectionProperties, RecipeData>()
    snapshot.appendSections(recipesSections)
    dataSource.apply(snapshot, animatingDifferences: true)
  }

  private func addRandomRecipes(_ recipesSection: RecipesSectionProperties) {
    RecipesClient.getRandomRecipes(tags: "vegan", total: 5) { randomRecipes, error in
      if error != nil {
        self.showStatus(
          title: "Recipes search error",
          message: "An error occured while retrieving random recipes. \(error?.localizedDescription ?? "")"
        )
      } else {
        recipesSection.recipesInSection = self.uniqueRecipes(recipes: randomRecipes)
        print("Random recipes ids")
        for randomRecipe in randomRecipes {
          print(randomRecipe.id)
        }
        self.applyRecipesSectionDataSnapshot(recipes: randomRecipes, recipesSection: recipesSection)
      }
    }
  }

  private func addQuickEasyRecipes(_ recipesSection: RecipesSectionProperties) {
    RecipesClient.searchRecipes(
      query: "",
      mealType: nil,
      cuisineType: nil,
      maxReadyTime: 20,
      offset: RecipesClient.getSearchOffset(key: recipesSection.preferenceKey)
    ) { total, quickAndEasyRecipes, error in
      if error != nil {
        self.showStatus(
          title: "Recipes search error",
          message: "An error occured while searching for recipes. \(error?.localizedDescription ?? "")"
        )
      } else {
        recipesSection.recipesInSection = self.uniqueRecipes(recipes: quickAndEasyRecipes).shuffled()
        print("Quick and Easy recipes ids")
        for recipe in recipesSection.recipesInSection {
          print(recipe.id)
        }
        self.applyRecipesSectionDataSnapshot(
          recipes: recipesSection.recipesInSection,
          recipesSection: recipesSection
        )
        UserDefaults.standard.set(total, forKey: recipesSection.preferenceKey)
      }
    }
  }

  private func addRecipes(_ recipesSection: RecipesSectionProperties) {
    RecipesClient.searchRecipes(
      query: "",
      mealType: recipesSection.searchKey,
      cuisineType: nil,
      maxReadyTime: nil,
      offset: RecipesClient.getSearchOffset(key: recipesSection.preferenceKey)
    ) { total, recipes, error in
      if error != nil {
        self.showStatus(
          title: "Recipes search error",
          message: "An error occured while searching for recipes. \(error?.localizedDescription ?? "")"
        )
      } else {
        recipesSection.recipesInSection = self.uniqueRecipes(recipes: recipes).shuffled()
        print("\(recipesSection.description)")
        for recipe in recipesSection.recipesInSection {
          print(recipe.id)
        }
        self.applyRecipesSectionDataSnapshot(
          recipes: recipesSection.recipesInSection,
          recipesSection: recipesSection
        )
        UserDefaults.standard.set(total, forKey: recipesSection.preferenceKey)
      }
    }
  }

  func initRecipesSectionsData() {
    recipesSections.forEach { recipesSection in
      switch recipesSection.searchKey {
      case RecipesSectionSearchKey.random:
        addRandomRecipes(recipesSection)
      case RecipesSectionSearchKey.quickAndEasy:
        addQuickEasyRecipes(recipesSection)
      case RecipesSectionSearchKey.breakfast,
        RecipesSectionSearchKey.beverage,
        RecipesSectionSearchKey.mainCourse,
        RecipesSectionSearchKey.dessert:
        addRecipes(recipesSection)
      default:
        fatalError("Unknown recipes section")
      }
    }
  }

  func applyRecipesSectionDataSnapshot(recipes: [RecipeData], recipesSection: RecipesSectionProperties) {
    var recipesSectionSnapshot = NSDiffableDataSourceSectionSnapshot<RecipeData>()
    recipesSectionSnapshot.append(recipes)
    dataSource.apply(recipesSectionSnapshot, to: recipesSection, animatingDifferences: true)
  }

  func applyInitialSanpshot() {
    initRecipesSections()
    initRecipesSectionsData()
  }

  func uniqueRecipes(recipes: [RecipeData]) -> [RecipeData] {
    var uniqueRecipes: [RecipeData] = []
    recipes.forEach { recipe in
      let recipeExists = allRecipes[recipe.id] != nil
      if !recipeExists {
        allRecipes[recipe.id] = recipe
        uniqueRecipes.append(recipe)
      }
    }
    return uniqueRecipes
  }
}
