//
//  RecipesHomeViewController+Extension.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 27/05/2021.
//

import UIKit

// MARK: - Extension that generates the collection view sections and updates the data using a diffable data source
extension RecipesHomeViewController {
  func configureTitle() {
    navigationItem.title = "Today's recipes"
    navigationItem.largeTitleDisplayMode = .automatic
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

  // MARK: - Create a custom registration for recipe with details cell
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

  // MARK: - Create a custom registration for recipe with title cell
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

  // MARK: - Create a diffable data source to manage recipes data across multiple sections.
  func configureDataSource() {
    // create registrations up front, then choose the appropriate one to use in the cell provider
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

  // swiftlint:disable function_body_length
  // MARK: - Create recipe categories sections based on the last save user preferences
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
        default: fatalError("Unknown recipe preference category")
        }
      }
    }
    var snapshot = NSDiffableDataSourceSnapshot<RecipesSectionProperties, RecipeData>()
    snapshot.appendSections(recipesSections)
    dataSource.apply(snapshot, animatingDifferences: true)
  }
  // swiftlint:enable function_body_length

  // MARK: - Download data for multiple recipe categories and update the view.
  // We use a DispatchGroup to assure correct display of the activity view.
  // Other solutions make use of DispatchQueue background and DispatchSemaphore
  // But this approach causes unncessary waiting to assure synchronicity whereas DispatchGroup avoids that.
  func initRecipesSectionsData() {
    showActivity(activityMessage: "Fetching recipes")
    recipesSections.forEach { _ in
      recipesDownloadGroup.enter()
    }
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

    // All recipes are downloaded, remove the activity indicator
    recipesDownloadGroup.notify(queue: .main) {
      self.removeActivity()
    }
  }

  func applyRecipesSectionDataSnapshot(recipes: [RecipeData], recipesSection: RecipesSectionProperties) {
    var recipesSectionSnapshot = NSDiffableDataSourceSectionSnapshot<RecipeData>()
    recipesSectionSnapshot.append(recipes)
    dataSource.apply(recipesSectionSnapshot, to: recipesSection, animatingDifferences: true)
  }

  func applyInitialSnapshot() {
    initRecipesSections()
    initRecipesSectionsData()
  }
}
