//
//  RecipesHomeViewController.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 08/05/2021.
//

import UIKit

class RecipesHomeViewController: UIViewController {
  static let headerElementKind = "header-element-kind"
  static let backgroundElementKind = "background-element-kind"

  enum RecipesSection: Int, CaseIterable {
    case randomRecipes, quickAndEasyRecipes, mainCourse, breakfast, hummus, dessert

    var description: String {
      switch self {
      case .randomRecipes: return "Recommended for you"
      case .quickAndEasyRecipes: return "Quick & Easy"
      case .mainCourse: return "Main Course"
      case .breakfast: return "Breakfast"
      case .hummus: return "Hummus"
      case .dessert: return "Desserts"
      }
    }

    var widthRatio: Float {
      switch self {
      case .randomRecipes, .breakfast, .mainCourse: return 1.0
      case .quickAndEasyRecipes, .dessert, .hummus:
        return 0.50
      }
    }

    var height: Float {
      switch self {
      case .randomRecipes, .breakfast, .mainCourse: return 300.0
      case .quickAndEasyRecipes, .dessert, .hummus: return 250.0
      }
    }

    var recipeImageSize: String {
      switch self {
      case .randomRecipes, .breakfast, .mainCourse:
        return RecipesClient.RecipePhotoSize.large.stringValue
      case .quickAndEasyRecipes, .dessert, .hummus:
        return RecipesClient.RecipePhotoSize.medium.stringValue
      }
    }

    func orthogonalScrollingBehavior() -> UICollectionLayoutSectionOrthogonalScrollingBehavior {
      switch self {
      case .randomRecipes, .breakfast, .mainCourse:
        return UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPagingCentered
      case .quickAndEasyRecipes, .dessert, .hummus:
        return UICollectionLayoutSectionOrthogonalScrollingBehavior.continuousGroupLeadingBoundary
      }
    }
  }
  // swiftlint:disable implicitly_unwrapped_optional
  var dataController: DataController!
  var recipesCollectionView: UICollectionView!
  var dataSource: UICollectionViewDiffableDataSource<RecipesSection, RecipeData>!
  // swiftlint:enable implicitly_unwrapped_optional

  var randomRecipesData: [RecipeData] = []
  var quickAndEasyRecipesData: [RecipeData] = []
  var mainCourseRecipesData: [RecipeData] = []
  var breakfastRecipesData: [RecipeData] = []
  var hummusRecipesData: [RecipeData] = []
  var dessertRecipesData: [RecipeData] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    overrideUserInterfaceStyle = .dark

    configureTitle()
    configureHierarchy()
    configureDataSource()
    fetchData()
  }
}

extension RecipesHomeViewController {
  func configureTitle() {
    navigationItem.title = "Green Recipes"
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

    guard let hummusRecipesJsonData = try? getData(
      fromJSON: "RecipesSearchResponseHummus"
    ) else { return }
    let hummusResponse = try? JSONDecoder().decode(RecipesData.self, from: hummusRecipesJsonData)
    hummusRecipesData = hummusResponse?.results ?? []

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
      guard let sectionType = RecipesSection(rawValue: sectionIndex) else { return nil }
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
      section.orthogonalScrollingBehavior = sectionType.orthogonalScrollingBehavior()
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
      guard let section = RecipesSection(rawValue: indexPath.section) else { fatalError("Unknown section") }
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
      print("Recipe Title: \(recipe.title)")
    }
  }

  func createRecipeWithTitleRegistration() -> UICollectionView.CellRegistration<RecipeWithTitleViewCell, RecipeData> {
    return UICollectionView.CellRegistration<RecipeWithTitleViewCell, RecipeData> { cell, indexPath, recipe in
      guard let section = RecipesSection(rawValue: indexPath.section) else { fatalError("Unknown section") }
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
      print("Recipe Title: \(recipe.title)")
    }
  }

  func configureDataSource() {
    // create registrations up front, then choose the appropirate one to use in the cell provider
    let recipeWithDetail = createRecipeWithDetailRegistration()
    let recipeWithTitle = createRecipeWithTitleRegistration()
    // data source
    dataSource = UICollectionViewDiffableDataSource<RecipesSection, RecipeData>(
      collectionView: recipesCollectionView) { collectionView, indexPath, recipe -> UICollectionViewCell? in
      guard let recipesSection = RecipesSection(rawValue: indexPath.section) else { fatalError("Unknown section") }

      switch recipesSection {
      case .randomRecipes, .breakfast, .mainCourse:
        return collectionView.dequeueConfiguredReusableCell(using: recipeWithDetail, for: indexPath, item: recipe)
      case .quickAndEasyRecipes, .hummus, .dessert:
        return collectionView.dequeueConfiguredReusableCell(using: recipeWithTitle, for: indexPath, item: recipe)
      }
    }

    let recipesSupplementaryRegistration = UICollectionView.SupplementaryRegistration<RecipesSectionTitleView>(
      elementKind: RecipesHomeViewController.headerElementKind) { supplementaryView, _, indexPath in
      guard let section = RecipesSection(rawValue: indexPath.section) else { return }
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
    let sections = RecipesSection.allCases
    var snapshot = NSDiffableDataSourceSnapshot<RecipesSection, RecipeData>()
    snapshot.appendSections(sections)

    snapshot.appendItems(randomRecipesData, toSection: .randomRecipes)
    snapshot.appendItems(quickAndEasyRecipesData, toSection: .quickAndEasyRecipes)
    snapshot.appendItems(mainCourseRecipesData, toSection: .mainCourse)
    snapshot.appendItems(breakfastRecipesData, toSection: .breakfast)
    snapshot.appendItems(hummusRecipesData, toSection: .hummus)
    snapshot.appendItems(dessertRecipesData, toSection: .dessert)

    dataSource.apply(snapshot)
  }
}

extension RecipesHomeViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let recipesSection = RecipesSection(rawValue: indexPath.section) else { fatalError("Unknown section") }

    let selectedRecipeData: RecipeData

    switch recipesSection {
    case .randomRecipes: selectedRecipeData = randomRecipesData[indexPath.row]
    case .breakfast: selectedRecipeData = breakfastRecipesData[indexPath.row]
    case .mainCourse: selectedRecipeData = mainCourseRecipesData[indexPath.row]
    case .hummus: selectedRecipeData = hummusRecipesData[indexPath.row]
    case .quickAndEasyRecipes: selectedRecipeData = quickAndEasyRecipesData[indexPath.row]
    case .dessert: selectedRecipeData = dessertRecipesData[indexPath.row]
    }

    let recipeDetailViewController = self.storyboard?.instantiateViewController(
      identifier: "RecipeDetailViewController"
    ) as! RecipeDetailViewController

    recipeDetailViewController.recipeData = selectedRecipeData
    self.navigationController?.pushViewController(recipeDetailViewController, animated: true)
  }
}
