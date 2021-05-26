//
//  RecipesSearchViewController.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 22/05/2021.
//

import UIKit

class RecipesSearchViewController: UIViewController {
  enum RecipeCategories: Int, CaseIterable {
    case categories
  }
  enum Recipes: Int, CaseIterable {
    case results
  }
  // swiftlint:disable implicitly_unwrapped_optional
  var dataController: DataController!
  var recipesSearchContainerView: UIStackView!
  var recipeCategoriesCollectionView: UICollectionView!
  var recipesCollectionView: UICollectionView!
  // swiftlint:disable operator_usage_whitespace
  var recipeCategoriesDataSource: UICollectionViewDiffableDataSource<RecipeCategories,
    RecipeCategoriesController.RecipeCategory>!
  var recipesDataSource: UICollectionViewDiffableDataSource<Recipes, RecipeData>!
  // swiftlint:enable implicitly_unwrapped_optional

  var recipesSearchBar = UISearchBar()
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
    self.recipeCategoriesCollectionView.delegate?.collectionView?(
      self.recipeCategoriesCollectionView,
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
    <RecipeCategoryViewCell, RecipeCategoriesController.RecipeCategory> { cell, _, recipeCategory in
      cell.recipeCategoryImageView.image = recipeCategory.recipeCategoryImage
      cell.recipeCategoryTitle.text = recipeCategory.recipeCategoryName
    }
    recipeCategoriesDataSource = UICollectionViewDiffableDataSource<RecipeCategories,
      RecipeCategoriesController.RecipeCategory>(
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
      section.orthogonalScrollingBehavior = .groupPaging
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

  private func applySnapshots() {
    // Recipe Categories Section
    applyRecipeCategoriesSnapshot()
    // Recipe Results Section
    let recipesSearched = searchRecipes(jsonFile: "RecipesSearchResponseIndian")
    applySearchedRecipesSnapshot(recipes: recipesSearched)
  }

  private func applyRecipeCategoriesSnapshot() {
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

  private func applySearchedRecipesSnapshot(recipes: [RecipeData]) {
    let sections = Recipes.allCases
    var snapshot = NSDiffableDataSourceSnapshot<Recipes, RecipeData>()
    snapshot.appendSections(sections)
    // Recipe Results Section
    var recipesSnapshot = NSDiffableDataSourceSectionSnapshot<RecipeData>()
    recipesSnapshot.append(recipes)
    recipesDataSource.apply(recipesSnapshot, to: .results, animatingDifferences: true)
  }

  private func reloadRecipeCategoryData(searchFile: String, indexPath: IndexPath) {
    guard var recipeCategory = recipeCategoriesDataSource.itemIdentifier(for: indexPath) else {
      print("Cannot find recipeCategory")
      return
    }
    if recipeCategory.recipesInCategory.isEmpty {
      print("Searching data")
      let recipesSearched = searchRecipes(jsonFile: searchFile)
      recipeCategory.recipesInCategory = recipesSearched
      applySearchedRecipesSnapshot(recipes: recipesSearched)
      updateRecipeCategoryWithRecipes(updatedCategory: recipeCategory, indexPath: indexPath)
    } else {
      print("Already searched previously")
      applySearchedRecipesSnapshot(recipes: recipeCategory.recipesInCategory)
    }
  }
}


extension RecipesSearchViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if collectionView == recipesCollectionView {
      guard let recipeData = recipesDataSource.itemIdentifier(for: indexPath) else { return }
      guard let recipeDetailViewController = self.storyboard?.instantiateViewController(
        identifier: "RecipeDetailViewController"
      ) as? RecipeDetailViewController else { return }
      recipeDetailViewController.recipeData = recipeData
      self.navigationController?.pushViewController(recipeDetailViewController, animated: true)
    } else {
      print("Selecting")
      let categoryCell = collectionView.cellForItem(at: indexPath) as? RecipeCategoryViewCell
      categoryCell?.recipeCategoryImageView.alpha = 1
//      guard let recipeCategory = recipeCategoriesDataSource.itemIdentifier(for: indexPath) else { return }
//      switch recipeCategory.recipeCategoryName {
//      case "Indian":
//        reloadRecipeCategoryData(searchFile: "RecipesSearchResponseIndian", indexPath: indexPath)
//      case "Chinese":
//        print("chinese")
//        reloadRecipeCategoryData(searchFile: "RecipesSearchResponseChinese", indexPath: indexPath)
//      case "Middle Eastern":
//        print("Middle Eastern")
//        reloadRecipeCategoryData(
//          searchFile: "RecipesSearchResponseMiddleEastern",
//          indexPath: indexPath
//        )
//      case "Italian":
//        print("Italian")
//        reloadRecipeCategoryData(searchFile: "RecipesSearchResponseItalian", indexPath: indexPath)
//      default:
//        fatalError("Unknown recipe category")
//      }
    }
  }

  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    let selectedCell = collectionView.cellForItem(at: indexPath) as? RecipeCategoryViewCell
    selectedCell?.recipeCategoryImageView.alpha = 0.5
  }
}

extension RecipesSearchViewController: UISearchBarDelegate {
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    recipesSearchBar.showsCancelButton = true
    recipeCategoriesCollectionView.isHidden = true
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    recipeCategoriesCollectionView.isHidden = false
    recipesSearchBar.showsCancelButton = false
    recipesSearchBar.text = ""
    recipesSearchBar.resignFirstResponder()
  }
}
