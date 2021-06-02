//
//  ProfileViewController+Extension.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 31/05/2021.
//

import UIKit
import CoreData

extension ProfileViewController {
  func configureTitle() {
    navigationItem.title = "Bookmarked Recipes"
    navigationItem.largeTitleDisplayMode = .always
  }

  func configureHierarchy() {
    recipesCollectionView = UICollectionView(
      frame: view.bounds,
      collectionViewLayout: createLayout()
    )
    recipesCollectionView.autoresizingMask = [.flexibleHeight]
    recipesCollectionView.backgroundColor = .systemGroupedBackground
    recipesCollectionView.delegate = self
    recipesCollectionView.alwaysBounceVertical = false
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

  func createProfileRecipeRegistration() -> UICollectionView.CellRegistration<BookmarkedRecipeViewCell, Recipe> {
    return UICollectionView.CellRegistration<BookmarkedRecipeViewCell, Recipe> { cell, _, recipe in
      if let recipeImage = recipe.image {
        cell.recipeImageView.image = UIImage(data: recipeImage)
      } else {
        cell.recipeImageView.image = UIImage(named: "placeholder")
      }
      cell.recipeTitleLabel.text = recipe.title
      cell.toggleBookmarkTappedCallback = {
        // Get the recipe at referenced based on its id and update its bookmark status
        let recipeToUpdateBookmark = self.bookmarkedRecipes.first { $0.id == recipe.id }
        recipeToUpdateBookmark?.isBookmarked.toggle()
        try? self.dataController.viewContext.save()
      }
    }
  }

  func configureDataSource() {
    // create registration up front
    let recipeWithDetail = createProfileRecipeRegistration()
    // data source
    dataSource = UICollectionViewDiffableDataSource<BookmarkedRecipes, Recipe>(
      collectionView: recipesCollectionView) { collectionView, indexPath, recipe -> UICollectionViewCell? in
      return collectionView.dequeueConfiguredReusableCell(using: recipeWithDetail, for: indexPath, item: recipe)
    }

    let recipesSupplementaryRegistration = UICollectionView.SupplementaryRegistration<ProfileHeaderView>(
      elementKind: ProfileViewController.headerElementKind) { supplementaryView, _, indexPath in
      if let section = BookmarkedRecipes(rawValue: indexPath.section) {
        supplementaryView.label.text = String(describing: section.description)
        supplementaryView.label.textColor = .white
      }
    }

    dataSource.supplementaryViewProvider = { _, _, index in
      return self.recipesCollectionView.dequeueConfiguredReusableSupplementary(
        using: recipesSupplementaryRegistration,
        for: index
      )
    }
  }

  func fetchBookmarkedRecipes(completion: @escaping ([Recipe]) -> Void) {
    let recipesRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
    let bookmarkLiteral: NSNumber = true
    let recipesPredicate = NSPredicate(format: "isBookmarked == %@", bookmarkLiteral)
    recipesRequest.predicate = recipesPredicate

    let recipesSortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
    recipesRequest.sortDescriptors = [recipesSortDescriptor]

    do {
      let recipes = try dataController.viewContext.fetch(recipesRequest)
      completion(recipes)
    } catch {
      completion([])
    }
  }

  func applyInitialSnapshot() {
    fetchBookmarkedRecipes { bookmarkedRecipes in
      self.bookmarkedRecipes = bookmarkedRecipes
      if bookmarkedRecipes.isEmpty {
        self.recipesCollectionView.setEmptyMessage("You haven't bookmarked any recipes yet.")
      } else {
        self.recipesCollectionView.restore()
      }
      // set the view height
      // self.recipesCollectionView.heightAnchor.constraint(equalToConstant: CGFloat(bookmarkedRecipes.count * 300)).isActive = true
      let bookmarkedRecipesSection = BookmarkedRecipes.allCases
      var snapshot = NSDiffableDataSourceSnapshot<BookmarkedRecipes, Recipe>()
      snapshot.appendSections(bookmarkedRecipesSection)

      var bookmarkedRecipesSnapshot = NSDiffableDataSourceSectionSnapshot<Recipe>()
      bookmarkedRecipesSnapshot.append(bookmarkedRecipes)
      self.dataSource.apply(bookmarkedRecipesSnapshot, to: .recipes, animatingDifferences: true)
    }
  }
}
