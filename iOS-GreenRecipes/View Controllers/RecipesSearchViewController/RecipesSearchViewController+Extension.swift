//
//  RecipesSearchViewController+Extension.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 27/05/2021.
//

import UIKit

extension RecipesSearchViewController {
  func configureHierarchy() {
    recipesSearchContainerView = UIStackView()
    recipesSearchContainerView.translatesAutoresizingMaskIntoConstraints = false
    recipesSearchContainerView.axis = .vertical
    recipesSearchContainerView.distribution = .fill

    view.addSubview(recipesSearchContainerView)

    NSLayoutConstraint.activate([
      recipesSearchContainerView.topAnchor.constraint(equalTo: view.topAnchor),
      recipesSearchContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      recipesSearchContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      recipesSearchContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
    configureRecipesSearchController()
    configureRecipeCategoriesView()
    configureRecipesView()
  }

  func configureRecipesSearchController() {
    navigationController?.navigationBar.largeContentTitle = "Search"
    navigationItem.titleView = recipesSearchBar
    navigationItem.hidesSearchBarWhenScrolling = true
    recipesSearchBar.delegate = self
    recipesSearchBar.placeholder = "Search recipes (e.g toast, avocado, rice)"
  }

  func configureRecipeCategoriesView() {
    recipeCategoriesCollectionView = UICollectionView(
      frame: recipesSearchContainerView.bounds,
      collectionViewLayout: createRecipeCategoriesLayout()
    )
    recipeCategoriesCollectionView.allowsMultipleSelection = false
    recipeCategoriesCollectionView.backgroundColor = .systemGroupedBackground
    recipeCategoriesCollectionView.delegate = self
    recipesSearchContainerView.addArrangedSubview(recipeCategoriesCollectionView)

    NSLayoutConstraint.activate([
      recipeCategoriesCollectionView.heightAnchor.constraint(equalToConstant: 200)
    ])
  }

  func configureRecipesView() {
    recipesCollectionView = UICollectionView(
      frame: recipesSearchContainerView.bounds,
      collectionViewLayout: createRecipesLayout()
    )

    recipesCollectionView.backgroundColor = .systemGroupedBackground
    recipesCollectionView.delegate = self
    recipesSearchContainerView.addArrangedSubview(recipesCollectionView)
  }

  func createRecipeCellRegistration() -> UICollectionView.CellRegistration<RecipeWithDetailViewCell, RecipeData> {
    return UICollectionView.CellRegistration<RecipeWithDetailViewCell, RecipeData> { cell, _, recipe in
      cell.recipeImageView.image = UIImage(named: "placeholder")
      DispatchQueue.global(qos: .background).async {
        DispatchQueue.main.async {
          RecipesClient.downloadRecipePhoto(
            recipeId: recipe.id,
            recipeImageSize: RecipesClient.RecipePhotoSize.large.stringValue,
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

  func configureDataSource() {
    configureRecipeCategoriesDataSource()
    configureRecipesDataSource()
  }

  func configureRecipeCategoriesDataSource() {
    let recipeCategoryCellRegistration = UICollectionView.CellRegistration
    <RecipeCategoryViewCell, RecipeCategoriesController.RecipeCategory> { cell, indexPath, recipeCategory in
      cell.recipeCategoryImageView.image = recipeCategory.recipeCategoryImage
      cell.recipeCategoryTitle.text = recipeCategory.recipeCategoryName
      if indexPath.row == 0 && self.lastSelectedRecipeCategory == indexPath {
        self.lastSelectedRecipeCategory = indexPath
        cell.isSelected = true
      }
      cell.isSelected = (self.lastSelectedRecipeCategory == indexPath)
    }
    recipeCategoriesDataSource =
      UICollectionViewDiffableDataSource<RecipeCategories, RecipeCategoriesController.RecipeCategory>(
      collectionView: recipeCategoriesCollectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
      return collectionView.dequeueConfiguredReusableCell(
        using: recipeCategoryCellRegistration,
        for: indexPath,
        item: item
      )
      }
  }

  func configureRecipesDataSource() {
    let recipeCellRegistration = createRecipeCellRegistration()

    recipesDataSource = UICollectionViewDiffableDataSource<Recipes, RecipeData>(
      collectionView: recipesCollectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
      return collectionView.dequeueConfiguredReusableCell(
        using: recipeCellRegistration,
        for: indexPath,
        item: item
      )
    }
  }

  func createRecipeCategoriesLayout() -> UICollectionViewLayout {
    let sectionProvider = { (_: Int, _ : NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
      let section: NSCollectionLayoutSection
      // orthogonal scrolling sections
      let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .fractionalHeight(1.0)
      )
      let item = NSCollectionLayoutItem(layoutSize: itemSize)

      let groupSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(0.4),
        heightDimension: .estimated(80)
      )

      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
      section = NSCollectionLayoutSection(group: group)
      section.interGroupSpacing = 10
      section.orthogonalScrollingBehavior = .continuous
      section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
      return section
    }
    return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
  }

  func createRecipesLayout() -> UICollectionViewLayout {
    let sectionProvider = { (_: Int, _ : NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
      let section: NSCollectionLayoutSection
      let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .fractionalHeight(1.0)
      )
      let item = NSCollectionLayoutItem(layoutSize: itemSize)

      let groupSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(300)
      )
      let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
      section = NSCollectionLayoutSection(group: group)
      section.interGroupSpacing = 10
      section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
      return section
    }
    return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
  }

  func applySnapshots() {
    // Recipe Categories Section
    applyRecipeCategoriesSnapshot()
    DispatchQueue.global(qos: .background).async {
      DispatchQueue.main.async {
        self.reloadRecipesData(indexPath: self.lastSelectedRecipeCategory)
      }
    }
  }

  func applyRecipeCategoriesSnapshot() {
    let sections = RecipeCategories.allCases
    var snapshot = NSDiffableDataSourceSnapshot<RecipeCategories, RecipeCategoriesController.RecipeCategory>()
    snapshot.appendSections(sections)
    recipeCategoriesDataSource.apply(snapshot, animatingDifferences: true)
    // Recipe Categories Section
    let recipeCategories = recipeCategoriesController.recipeCategories
    var recipeCategoriesSnapshot = NSDiffableDataSourceSectionSnapshot<RecipeCategoriesController.RecipeCategory>()
    recipeCategoriesSnapshot.append(recipeCategories)
    recipeCategoriesDataSource.apply(recipeCategoriesSnapshot, to: .categories, animatingDifferences: true)
  }

  private func updateRecipeCategoryWithRecipes(
    updatedCategory: RecipeCategoriesController.RecipeCategory,
    indexPath: IndexPath
  ) {
    guard let oldRecipeCategory = recipeCategoriesDataSource.itemIdentifier(for: indexPath) else { return }
    var snapshot = recipeCategoriesDataSource.snapshot()

    snapshot.insertItems([updatedCategory], beforeItem: oldRecipeCategory)
    snapshot.deleteItems([oldRecipeCategory])
    recipeCategoriesDataSource.apply(snapshot, animatingDifferences: true)
  }

  func applySearchedRecipesSnapshot(recipes: [RecipeData]) {
    let sections = Recipes.allCases
    var snapshot = NSDiffableDataSourceSnapshot<Recipes, RecipeData>()
    snapshot.appendSections(sections)
    // Recipe Results Section
    var recipesSnapshot = NSDiffableDataSourceSectionSnapshot<RecipeData>()
    recipesSnapshot.append(recipes)
    recipesDataSource.apply(recipesSnapshot, to: .results, animatingDifferences: true)
  }

  func reloadRecipesData(indexPath: IndexPath) {
    guard var recipeCategory = recipeCategoriesDataSource.itemIdentifier(for: indexPath) else {
      print("Cannot find recipeCategory")
      return
    }
    if recipeCategory.recipesInCategory.isEmpty {
      // Retrieve recipe information
      RecipesClient.searchRecipes(
        query: "",
        mealType: recipeCategory.recipeCategoryMealType,
        cuisineType: recipeCategory.recipeCategoryCuisineType
      ) { searchedRecipes, error in
        recipeCategory.recipesInCategory = searchedRecipes
        self.applySearchedRecipesSnapshot(recipes: searchedRecipes)
        self.updateRecipeCategoryWithRecipes(updatedCategory: recipeCategory, indexPath: indexPath)
      }
    } else {
      print("Already searched previously")
      applySearchedRecipesSnapshot(recipes: recipeCategory.recipesInCategory)
    }
  }
}
