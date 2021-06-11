//
//  ProfileViewController+Extension.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 31/05/2021.
//

import UIKit

// MARK: - Compositional layout of the bookmarked recipes
extension ProfileViewController {
  func configureTitle() {
    navigationItem.title = "Profile"
    navigationItem.largeTitleDisplayMode = .always
    configurePreferencesButton()
  }

  func configurePreferencesButton() {
    let preferencesButtonSize = CGRect(origin: CGPoint.zero, size: CGSize(width: 25, height: 25))
    let preferencesButton = UIButton(frame: preferencesButtonSize)
    preferencesButton.setImage(UIImage(named: "preferences"), for: .normal)
    preferencesButton.imageView?.contentMode = .scaleAspectFit
    preferencesButton.addTarget(self, action: #selector(preferencesTapped), for: .touchUpInside)
    let preferencesBarButton = UIBarButtonItem(customView: preferencesButton)
    navigationItem.rightBarButtonItem = preferencesBarButton
  }

  // MARK: - Init a collection view with a compositional layout
  func configureHierarchy() {
    recipesCollectionView = UICollectionView(
      frame: view.bounds,
      collectionViewLayout: createLayout()
    )
    recipesCollectionView.autoresizingMask = [.flexibleHeight]
    recipesCollectionView.backgroundColor = .systemGroupedBackground
    recipesCollectionView.delegate = self
    view.addSubview(recipesCollectionView)
  }

  func createLayout() -> UICollectionViewCompositionalLayout {
    let sectionProvider = { (_: Int, _ : NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
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
      let section = NSCollectionLayoutSection(group: group)
      section.interGroupSpacing = 10
      section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

      let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .estimated(20)),
        elementKind: ProfileViewController.headerElementKind,
        alignment: .topLeading
      )
      sectionHeader.pinToVisibleBounds = true
      section.boundarySupplementaryItems = [sectionHeader]
      return section
    }
    return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
  }

  func createProfileRecipeRegistration() -> UICollectionView.CellRegistration<ProfileRecipeViewCell, Recipe> {
    return UICollectionView.CellRegistration<ProfileRecipeViewCell, Recipe> { cell, _, recipe in
      cell.configure(recipe: recipe)
      // Add callback button toggle closure actions
      cell.toggleBookmarkTappedCallback = {
        // Get the recipe at referenced based on its id and update its bookmark status
        let recipeToUpdateBookmark = self.bookmarkedRecipes.first { $0.id == recipe.id }
        recipeToUpdateBookmark?.isBookmarked.toggle()
        try? self.dataController.viewContext.save()
        self.applyBookmarkedRecipesSnapshot()
      }
      cell.toggleLikeTappedCallback = {
        // Get the recipe at referenced based on its id and update its liked status
        let recipeToUpdateLike = self.likedRecipes.first { $0.id == recipe.id }
        recipeToUpdateLike?.isLiked.toggle()
        try? self.dataController.viewContext.save()
        self.applyLikedRecipesSnapshot()
      }
    }
  }

  func configureDataSource() {
    // create registration up front
    let recipeWithDetail = createProfileRecipeRegistration()
    // data source
    dataSource = UICollectionViewDiffableDataSource<ProfileCategoryRecipes, Recipe>(
      collectionView: recipesCollectionView) { collectionView, indexPath, recipe -> UICollectionViewCell? in
      return collectionView.dequeueConfiguredReusableCell(using: recipeWithDetail, for: indexPath, item: recipe)
    }

    let recipesSupplementaryRegistration = UICollectionView.SupplementaryRegistration<ProfileHeaderView>(
      elementKind: ProfileViewController.headerElementKind) { supplementaryView, _, _ in
      supplementaryView.likesButtonClicked = {
        self.likesSelected = true
        self.applyLikedRecipesSnapshot()
      }
      supplementaryView.bookmarksButtonClicked = {
        self.likesSelected = false
        self.applyBookmarkedRecipesSnapshot()
      }
    }

    dataSource.supplementaryViewProvider = { _, _, index in
      return self.recipesCollectionView.dequeueConfiguredReusableSupplementary(
        using: recipesSupplementaryRegistration,
        for: index
      )
    }
  }

  func applySectionsSnapshot() {
    let profileCategoriesSections = ProfileCategoryRecipes.allCases
    var snapshot = NSDiffableDataSourceSnapshot<ProfileCategoryRecipes, Recipe>()
    snapshot.appendSections(profileCategoriesSections)
    dataSource.apply(snapshot, animatingDifferences: true)
  }

  func applyBookmarkedRecipesSnapshot() {
    fetchBookmarkedRecipes { bookmarkedRecipes in
      self.bookmarkedRecipes = bookmarkedRecipes
      if bookmarkedRecipes.isEmpty {
        self.recipesCollectionView.setEmptyMessage("You haven't bookmarked any recipes yet.")
      } else {
        self.recipesCollectionView.restore()
      }

      var bookmarkedRecipesSnapshot = NSDiffableDataSourceSectionSnapshot<Recipe>()
      bookmarkedRecipesSnapshot.append(bookmarkedRecipes)
      self.dataSource.apply(bookmarkedRecipesSnapshot, to: .recipes, animatingDifferences: true)
    }
  }

  func applyLikedRecipesSnapshot() {
    fetchLikedRecipes { likedRecipes in
      self.likedRecipes = likedRecipes
      if likedRecipes.isEmpty {
        self.recipesCollectionView.setEmptyMessage("You haven't liked any recipes yet.")
      } else {
        self.recipesCollectionView.restore()
      }

      var likedRecipesSnapshot = NSDiffableDataSourceSectionSnapshot<Recipe>()
      likedRecipesSnapshot.append(likedRecipes)
      self.dataSource.apply(likedRecipesSnapshot, to: .recipes, animatingDifferences: true)
    }
  }
}
