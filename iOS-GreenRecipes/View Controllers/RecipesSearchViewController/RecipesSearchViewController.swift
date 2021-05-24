//
//  RecipesSearchViewController.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 22/05/2021.
//

import UIKit

class RecipesSearchViewController: UIViewController {
  enum RecipesSection: Int, CaseIterable {
    case categories
  }
  // swiftlint:disable implicitly_unwrapped_optional
  var dataController: DataController!
  var recipesSearchCollectionView: UICollectionView!
  var dataSource: UICollectionViewDiffableDataSource<RecipesSection, RecipeCategoriesController.RecipeCategory>!
  // swiftlint:enable implicitly_unwrapped_optional

  let recipeCategoriesController = RecipeCategoriesController()

  override func viewDidLoad() {
    super.viewDidLoad()
    overrideUserInterfaceStyle = .dark
    configureHierarchy()
    configureDataSource()
    applySnapshots()
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

extension RecipesSearchViewController {
  func configureHierarchy() {
    recipesSearchCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
    recipesSearchCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    recipesSearchCollectionView.backgroundColor = .systemGroupedBackground
    recipesSearchCollectionView.delegate = self
    view.addSubview(recipesSearchCollectionView)
  }

  func createRecipeWithDetailRegistration() -> UICollectionView.CellRegistration<RecipeWithDetailViewCell, RecipeData> {
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
      print("Recipe Title: \(recipe.title)")
    }
  }

  func configureDataSource() {
    let recipeCategoryCellRegistration = UICollectionView.CellRegistration
    <RecipeCategoryViewCell, RecipeCategoriesController.RecipeCategory> { cell, _, recipeCategory in
      cell.recipeCategoryImageView.image = recipeCategory.recipeCategoryImage
      cell.recipeCategoryTitle.text = recipeCategory.recipeCategoryName
    }

    dataSource = UICollectionViewDiffableDataSource<RecipesSection, RecipeCategoriesController.RecipeCategory>(
      collectionView: recipesSearchCollectionView) { collectionView, indexPath, identifier -> UICollectionViewCell? in
      return collectionView.dequeueConfiguredReusableCell(
        using: recipeCategoryCellRegistration,
        for: indexPath,
        item: identifier
      )
    }
  }

  func createLayout() -> UICollectionViewLayout {
    let sectionProvider = { (sectionIndex: Int, _ : NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
      guard let sectionType = RecipesSection(rawValue: sectionIndex) else { return nil }

      let section: NSCollectionLayoutSection

      if sectionType == .categories {
        // orthogonal scrolling sections
        let itemSize = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(0.6),
          heightDimension: .estimated(150)
        )

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
      } else {
        fatalError("Unknown section")
      }
      return section
    }
    return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
  }

  func applySnapshots() {
    let sections = RecipesSection.allCases
    var snapshot = NSDiffableDataSourceSnapshot<RecipesSection, RecipeCategoriesController.RecipeCategory>()
    snapshot.appendSections(sections)
    let recipeCategories = recipeCategoriesController.recipeCategories
    snapshot.appendItems(recipeCategories, toSection: .categories)
    dataSource.apply(snapshot)
  }
}

extension RecipesSearchViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let recipesCategory = self.dataSource.itemIdentifier(for: indexPath)?.recipeCategoryName else {
      recipesSearchCollectionView.deselectItem(at: indexPath, animated: true)
      return
    }
    print(recipesCategory)
    guard let recipesSearchData = try? getData(
      fromJSON: "RecipesSearchResponseIndian"
    ) else { return }
    let recipesSearchResponse = try? JSONDecoder().decode(RecipesData.self, from: recipesSearchData)
    print(recipesSearchResponse?.results ?? [])
    let selectedCell = collectionView.cellForItem(at: indexPath) as? RecipeCategoryViewCell
    selectedCell?.recipeCategoryImageView.alpha = 1
  }

  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    let selectedCell = collectionView.cellForItem(at: indexPath) as? RecipeCategoryViewCell
    selectedCell?.recipeCategoryImageView.alpha = 0.5
  }
}
