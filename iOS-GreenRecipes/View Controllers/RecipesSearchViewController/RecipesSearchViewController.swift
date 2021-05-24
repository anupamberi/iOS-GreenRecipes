//
//  RecipesSearchViewController.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 22/05/2021.
//

import UIKit

class RecipesSearchViewController: UIViewController {
  struct RecipesSectionDataItem: Hashable {
    var recipeCategory: RecipeCategoriesController.RecipeCategory?
    var recipe: RecipeData?
    private let identifier = UUID()

    init(recipeCategory: RecipeCategoriesController.RecipeCategory? = nil, recipe: RecipeData? = nil) {
      self.recipeCategory = recipeCategory
      self.recipe = recipe
    }
  }

  enum RecipesSectionData: Int, CaseIterable {
    case categories
    case results
  }
  // swiftlint:disable implicitly_unwrapped_optional
  var dataController: DataController!
  var recipesSearchCollectionView: UICollectionView!
  var dataSource: UICollectionViewDiffableDataSource<RecipesSectionData, RecipesSectionDataItem>!
  // swiftlint:enable implicitly_unwrapped_optional

  let recipeCategoriesController = RecipeCategoriesController()

  override func viewDidLoad() {
    super.viewDidLoad()
    overrideUserInterfaceStyle = .dark
    configureHierarchy()
    configureDataSource()
    applySnapshots()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // Select the first item in first section
    let indexPath = IndexPath(row: 0, section: 0)
    recipesSearchCollectionView.delegate?.collectionView?(
      recipesSearchCollectionView,
      didSelectItemAt: indexPath
    )
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

  func searchRecipes(jsonFile: String) -> [RecipeData] {
    guard let recipesSearchData = try? getData(fromJSON: jsonFile) else { return [] }
    let recipesSearchResponse = try? JSONDecoder().decode(RecipesData.self, from: recipesSearchData)
    return recipesSearchResponse?.results ?? []
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
    let recipeCategoryCellRegistration = UICollectionView.CellRegistration
    <RecipeCategoryViewCell, RecipesSectionDataItem> { cell, _, recipeSearchItem in
      cell.recipeCategoryImageView.image = recipeSearchItem.recipeCategory?.recipeCategoryImage
      cell.recipeCategoryTitle.text = recipeSearchItem.recipeCategory?.recipeCategoryName
    }

    let recipeCellRegistration = createRecipeCellRegistration()

    dataSource = UICollectionViewDiffableDataSource<RecipesSectionData, RecipesSectionDataItem>(
      collectionView: recipesSearchCollectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
      guard let sectionKind = RecipesSectionData(rawValue: indexPath.section) else { fatalError("Unknown") }
      switch sectionKind {
      case .categories:
        return collectionView.dequeueConfiguredReusableCell(
          using: recipeCategoryCellRegistration,
          for: indexPath,
          item: item
        )
      case .results:
        return collectionView.dequeueConfiguredReusableCell(
          using: recipeCellRegistration,
          for: indexPath,
          item: item.recipe
        )
      }
    }
  }

  func createLayout() -> UICollectionViewLayout {
    let sectionProvider = { (sectionIndex: Int, _ : NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
      guard let sectionType = RecipesSectionData(rawValue: sectionIndex) else { return nil }

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
      } else if sectionType == .results {
        // orthogonal scrolling sections
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
      } else {
        fatalError("Unknown section")
      }
      return section
    }
    return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
  }

  private func applySnapshots() {
    let sections = RecipesSectionData.allCases
    var snapshot = NSDiffableDataSourceSnapshot<RecipesSectionData, RecipesSectionDataItem>()
    snapshot.appendSections(sections)
    // Recipe Categories Section
    applyRecipeCategoriesSnapshot()
    // Recipe Results Section
    let recipesSearched = searchRecipes(jsonFile: "RecipesSearchResponseIndian")
    applySearchedRecipesSnapshot(recipes: recipesSearched)
  }

  private func applySearchedRecipesSnapshot(recipes: [RecipeData]) {
    // Recipe Results Section
    var recipesSearchedSectionItem: [RecipesSectionDataItem] = []
    for recipe in recipes {
      let recipeSearchItem = RecipesSectionDataItem(recipeCategory: nil, recipe: recipe)
      recipesSearchedSectionItem.append(recipeSearchItem)
    }
    var recipesSearchSnapshot = NSDiffableDataSourceSectionSnapshot<RecipesSectionDataItem>()
    recipesSearchSnapshot.append(recipesSearchedSectionItem)
    dataSource.apply(recipesSearchSnapshot, to: .results, animatingDifferences: true)
  }

  private func applyRecipeCategoriesSnapshot() {
    // Recipe Categories Section
    let recipeCategories = recipeCategoriesController.recipeCategories
    var recipeCategoriesSectionItem: [RecipesSectionDataItem] = []
    for recipeCategory in recipeCategories {
      let recipeSearchItem = RecipesSectionDataItem(recipeCategory: recipeCategory, recipe: nil)
      recipeCategoriesSectionItem.append(recipeSearchItem)
    }
    var recipeCategoriesSnapshot = NSDiffableDataSourceSectionSnapshot<RecipesSectionDataItem>()
    recipeCategoriesSnapshot.append(recipeCategoriesSectionItem)
    dataSource.apply(recipeCategoriesSnapshot, to: .categories, animatingDifferences: true)
  }
}

extension RecipesSearchViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let selectedCell = collectionView.cellForItem(at: indexPath) as? RecipeWithDetailViewCell {
      guard let recipeData = self.dataSource.itemIdentifier(for: indexPath)?.recipe else { return }
      let recipeDetailViewController = self.storyboard?.instantiateViewController(
        identifier: "RecipeDetailViewController"
      ) as! RecipeDetailViewController
      recipeDetailViewController.recipeData = recipeData
      self.navigationController?.pushViewController(recipeDetailViewController, animated: true)
    } else {
      print("Category")
      guard let category = self.dataSource.itemIdentifier(for: indexPath)?.recipeCategory?.recipeCategoryName else {
        recipesSearchCollectionView.deselectItem(at: indexPath, animated: true)
        return
      }

      switch category {
      case "Indian":
        applySearchedRecipesSnapshot(recipes: searchRecipes(jsonFile: "RecipesSearchResponseIndian"))
      case "Chinese":
        print("Chinese")
        applySearchedRecipesSnapshot(recipes: searchRecipes(jsonFile: "RecipesSearchResponseChinese"))
      case "Middle Eastern":
        applySearchedRecipesSnapshot(recipes: searchRecipes(jsonFile: "RecipesSearchResponseMiddleEastern"))
      case "Italian":
        applySearchedRecipesSnapshot(recipes: searchRecipes(jsonFile: "RecipesSearchResponseItalian"))
      default:
        fatalError("Unknown recipe category")
      }
      let categoryCell = collectionView.cellForItem(at: indexPath) as? RecipeCategoryViewCell
      categoryCell?.recipeCategoryImageView.alpha = 1
    }
  }

  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    let selectedCell = collectionView.cellForItem(at: indexPath) as? RecipeCategoryViewCell
    selectedCell?.recipeCategoryImageView.alpha = 0.5
  }
}
