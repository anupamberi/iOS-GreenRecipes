//
//  RecipesHomeViewController+Extension.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 27/05/2021.
//

import UIKit

extension RecipesHomeViewController {
  func configureTitle() {
    navigationItem.title = "Recommendations"
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

      switch section.key {
      case RecipesSectionKey.random, RecipesSectionKey.breakfast, RecipesSectionKey.mainCourse:
        return collectionView.dequeueConfiguredReusableCell(using: recipeWithDetail, for: indexPath, item: recipe)
      case RecipesSectionKey.quickAndEasy, RecipesSectionKey.dessert, RecipesSectionKey.beverage:
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
      key: RecipesSectionKey.random,
      widthRatio: 1.0,
      heightRatio: 300.0,
      recipeImageSize: RecipesClient.RecipePhotoSize.large.stringValue,
      scrollingBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPagingCentered
    )

    randomRecipesSection.recipesInSection = randomRecipesData

    var quickAndEasyRecipesSection = RecipesSectionProperties(
      description: "Quick & Easy",
      key: RecipesSectionKey.quickAndEasy,
      widthRatio: 0.45,
      heightRatio: 250.0,
      recipeImageSize: RecipesClient.RecipePhotoSize.large.stringValue,
      scrollingBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior.continuousGroupLeadingBoundary
    )

    quickAndEasyRecipesSection.recipesInSection = quickAndEasyRecipesData

    let recipeType = RecipesClient.getRecipeType()

    var recipeTypeSection = RecipesSectionProperties(
      description: recipeType,
      key: recipeType,
      widthRatio: 1.0,
      heightRatio: 300.0,
      recipeImageSize: RecipesClient.RecipePhotoSize.large.stringValue,
      scrollingBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPagingCentered
    )

    var dessertRecipesSection = RecipesSectionProperties(
      description: "Desserts",
      key: RecipesSectionKey.dessert,
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
    let randomRecipesSection = RecipesSectionProperties(
      description: "Recommended for you",
      key: RecipesSectionKey.random,
      widthRatio: 1.0,
      heightRatio: 300.0,
      recipeImageSize: RecipesClient.RecipePhotoSize.large.stringValue,
      scrollingBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPagingCentered
    )

    let quickAndEasyRecipesSection = RecipesSectionProperties(
      description: "Quick & Easy",
      key: RecipesSectionKey.quickAndEasy,
      widthRatio: 0.45,
      heightRatio: 250.0,
      recipeImageSize: RecipesClient.RecipePhotoSize.large.stringValue,
      scrollingBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior.continuousGroupLeadingBoundary
    )

    let recipeType = RecipesClient.getRecipeType()

    let recipeTypeSection = RecipesSectionProperties(
      description: recipeType,
      key: recipeType,
      widthRatio: 1.0,
      heightRatio: 300.0,
      recipeImageSize: RecipesClient.RecipePhotoSize.large.stringValue,
      scrollingBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPagingCentered
    )

    if recipeType == "breakfast" {
      recipeTypeSection.description = "Delicious Breakfast"
    }
    if recipeType == "beverage" {
      recipeTypeSection.description = "Beverages"
    }
    if recipeType == "main course" {
      recipeTypeSection.description = "Main Course"
    }

    let dessertRecipesSection = RecipesSectionProperties(
      description: "Delicious Desserts",
      key: RecipesSectionKey.dessert,
      widthRatio: 0.45,
      heightRatio: 250.0,
      recipeImageSize: RecipesClient.RecipePhotoSize.large.stringValue,
      scrollingBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior.continuousGroupLeadingBoundary
    )

    recipesSections.append(randomRecipesSection)
    recipesSections.append(quickAndEasyRecipesSection)
    recipesSections.append(recipeTypeSection)
    recipesSections.append(dessertRecipesSection)

    var snapshot = NSDiffableDataSourceSnapshot<RecipesSectionProperties, RecipeData>()
    snapshot.appendSections(recipesSections)
    dataSource.apply(snapshot, animatingDifferences: true)
  }

  func initRecipesSectionsData() {
    for recipesSection in recipesSections {
      switch recipesSection.key {
      case RecipesSectionKey.random:
        print(recipesSection.key)
        RecipesClient.getRandomRecipes(tags: "vegan", total: 5) { randomRecipes, error in
          recipesSection.recipesInSection = self.uniqueRecipes(recipes: randomRecipes)
          print("Random recipes ids")
          for randomRecipe in randomRecipes {
            print(randomRecipe.id)
          }
          self.applyRecipesSectionDataSnapshot(recipes: randomRecipes, recipesSection: recipesSection)
        }
      case RecipesSectionKey.quickAndEasy:
        print(recipesSection.key)
        RecipesClient.searchRecipes(
          query: "",
          mealType: nil,
          cuisineType: nil,
          maxReadyTime: 20
        ) { quickAndEasyRecipes, error in
          recipesSection.recipesInSection = self.uniqueRecipes(recipes: quickAndEasyRecipes)
          print("Quick and Easy recipes ids")
          for recipe in recipesSection.recipesInSection {
            print(recipe.id)
          }
          self.applyRecipesSectionDataSnapshot(
            recipes: recipesSection.recipesInSection,
            recipesSection: recipesSection
          )
        }
      case RecipesSectionKey.breakfast,
        RecipesSectionKey.beverage,
        RecipesSectionKey.mainCourse,
        RecipesSectionKey.dessert:
        RecipesClient.searchRecipes(
          query: "",
          mealType: recipesSection.key,
          cuisineType: nil,
          maxReadyTime: nil
        ) { recipes, error in
          recipesSection.recipesInSection = self.uniqueRecipes(recipes: recipes)
          print("\(recipesSection.description)")
          for recipe in recipesSection.recipesInSection {
            print(recipe.id)
          }
          self.applyRecipesSectionDataSnapshot(
            recipes: recipesSection.recipesInSection,
            recipesSection: recipesSection
          )
        }
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
