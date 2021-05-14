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

  enum Section: Int, Hashable, CaseIterable {
    case randomRecipes, quickAndEasyRecipes // , soupRecipes

    var description: String {
      switch self {
      case .randomRecipes: return "Recommended for you"
      case .quickAndEasyRecipes: return "Quick & Easy"
      // case .sandwichRecipes: return "Quick & Easy Sandwiches"
      // case .soupRecipes: return "soupRecipes"
      }
    }
  }
  // swiftlint:disable implicitly_unwrapped_optional
  var dataController: DataController!
  var recipesCollectionView: UICollectionView!
  var dataSource: UICollectionViewDiffableDataSource<Section, RecipeData>!
  // swiftlint:enable implicitly_unwrapped_optional

  var randomRecipesData: [RecipeData] = []
  var quickAndEasyRecipesData: [RecipeData] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    configureTitle()
    configureHierarchy()
    configureDataSource()
    fetchData()
  }
}

extension RecipesHomeViewController {
  func configureTitle() {
    navigationItem.title = "Green Recipes"
    navigationItem.largeTitleDisplayMode = .always
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
//    RecipesClient.getRandomRecipes(tags: "vegan,dinner", total: 5) { data, error in
//      self.recipesData = data
//      self.applyInitialSnapshots()
//    }
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

    applyInitialSnapshots()
  }

  func configureHierarchy() {
    recipesCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
    recipesCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    recipesCollectionView.backgroundColor = .systemGroupedBackground
    recipesCollectionView.delegate = self
    view.addSubview(recipesCollectionView)
  }

  func createLayout() -> UICollectionViewLayout {
    // orthogonal scrolling sections
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalHeight(1.0)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(350)
    )

    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 10
    section.orthogonalScrollingBehavior = .groupPagingCentered
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

    let layout = UICollectionViewCompositionalLayout(section: section)
    layout.register(
      RecipesSectionBackgroundDecorationView.self,
      forDecorationViewOfKind: RecipesHomeViewController.backgroundElementKind)
    return layout
  }

  func createRecipeCellRegistration() -> UICollectionView.CellRegistration<RecipeCollectionViewCell, RecipeData> {
    return UICollectionView.CellRegistration<RecipeCollectionViewCell, RecipeData> { cell, indexPath, recipe in
      cell.recipeImageView.image = UIImage(named: "placeholder")
      DispatchQueue.global(qos: .background).async {
        DispatchQueue.main.async {
          RecipesClient.downloadPhoto(photoImageURL: recipe.image ?? "") { recipeImage in
            cell.recipeImageView.image = recipeImage
          }
        }
      }
      cell.recipeIngredientsCount.text = String(recipe.analyzedInstructions[0].steps.count) + " ingredients"
      cell.recipePreprationTime.text = String(recipe.readyInMinutes) + " min prep"
      cell.recipeTitleLabel.text = recipe.title
      print("Recipe Title: \(recipe.title)")
    }
  }

  func configureDataSource() {
    // create registrations up front, then choose the appropirate one to use in the cell provider
    let recipeCellRegistration = createRecipeCellRegistration()
    // data source
    dataSource = UICollectionViewDiffableDataSource<Section, RecipeData>(
      collectionView: recipesCollectionView) { collectionView, indexPath, recipe -> UICollectionViewCell? in
      return collectionView.dequeueConfiguredReusableCell(using: recipeCellRegistration, for: indexPath, item: recipe)
    }

    let recipesSupplementaryRegistration = UICollectionView.SupplementaryRegistration<RecipesSectionTitleSupplementaryView>(
      elementKind: RecipesHomeViewController.headerElementKind) { supplementaryView, _, indexPath in
      guard let section = Section(rawValue: indexPath.section) else { return }
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
    let sections = Section.allCases
    var snapshot = NSDiffableDataSourceSnapshot<Section, RecipeData>()
    snapshot.appendSections(sections)

    snapshot.appendItems(randomRecipesData, toSection: .randomRecipes)
    snapshot.appendItems(quickAndEasyRecipesData, toSection: .quickAndEasyRecipes)
    dataSource.apply(snapshot)
  }
}

extension RecipesHomeViewController: UICollectionViewDelegate {
}
