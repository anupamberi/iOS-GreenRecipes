//
//  ProfileRecipeViewCell.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 31/05/2021.
//

import UIKit

// MARK: - A custom cell to show the bookmarked recipe
class ProfileRecipeViewCell: UICollectionViewCell {
  static let reuseIdentifier = "ProfileRecipeViewCell"
  var recipeImageView = UIImageView()
  var recipeTitleLabel = UILabel()
  var recipeSubTitleLabel = UILabel()
  var toggleLikeButton = UIButton(frame: .zero)
  var toggleLikeTappedCallback: (() -> Void)?

  var toggleBookmarkButton = UIButton(frame: .zero)
  var toggleBookmarkTappedCallback: (() -> Void)?

  private var bookmarked = true
  private var liked = true

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension ProfileRecipeViewCell {
  func configure() {
    contentView.backgroundColor = .black
    recipeImageView.contentMode = .scaleAspectFill
    recipeImageView.clipsToBounds = true
    recipeImageView.layer.cornerRadius = 10

    recipeTitleLabel.font = UIFont.systemFont(ofSize: 18)
    recipeTitleLabel.textAlignment = .left
    recipeTitleLabel.numberOfLines = 3
    recipeTitleLabel.lineBreakMode = .byWordWrapping
    recipeTitleLabel.allowsDefaultTighteningForTruncation = true
    recipeTitleLabel.textColor = .white

    recipeSubTitleLabel.font = UIFont.systemFont(ofSize: 16)
    recipeSubTitleLabel.textAlignment = .left
    recipeSubTitleLabel.numberOfLines = 3
    recipeSubTitleLabel.lineBreakMode = .byWordWrapping
    recipeSubTitleLabel.allowsDefaultTighteningForTruncation = true
    recipeSubTitleLabel.textColor = .systemGray

    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .leading
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 5

    let spacerView = UIView(frame: .zero)
    spacerView.translatesAutoresizingMaskIntoConstraints = false
    spacerView.heightAnchor.constraint(equalToConstant: 10).isActive = true

    stackView.addArrangedSubview(recipeImageView)
    stackView.addArrangedSubview(recipeTitleLabel)
    stackView.addArrangedSubview(recipeSubTitleLabel)
    stackView.addArrangedSubview(spacerView)

    toggleBookmarkButton.translatesAutoresizingMaskIntoConstraints = false
    toggleBookmarkButton.addTarget(self, action: #selector(toggleBookmarked), for: .touchUpInside)
    toggleBookmarkButton.imageView?.contentMode = .scaleAspectFit
    contentView.addSubview(toggleBookmarkButton)

    toggleLikeButton.translatesAutoresizingMaskIntoConstraints = false
    toggleLikeButton.addTarget(self, action: #selector(toggleLiked), for: .touchUpInside)
    toggleLikeButton.imageView?.contentMode = .scaleAspectFit
    contentView.addSubview(toggleLikeButton)

    contentView.addSubview(stackView)

    contentView.bringSubviewToFront(toggleBookmarkButton)
    contentView.bringSubviewToFront(toggleLikeButton)

    // Setup constraints
    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      recipeTitleLabel.heightAnchor.constraint(equalToConstant: 30),
      recipeSubTitleLabel.heightAnchor.constraint(equalToConstant: 20),

      toggleBookmarkButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
      toggleBookmarkButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
      toggleBookmarkButton.widthAnchor.constraint(equalToConstant: 30),
      toggleBookmarkButton.heightAnchor.constraint(equalToConstant: 30),

      toggleLikeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
      toggleLikeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
      toggleLikeButton.widthAnchor.constraint(equalToConstant: 30),
      toggleLikeButton.heightAnchor.constraint(equalToConstant: 30)
    ])
  }

  func configure(recipe: Recipe) {
    bookmarked = recipe.isBookmarked
    bookmarked ? toggleBookmarkButton.setImage(UIImage(named: "bookmarked"), for: .normal) :
      toggleBookmarkButton.setImage(UIImage(named: "bookmark"), for: .normal)

    liked = recipe.isLiked
    recipe.isLiked ? toggleLikeButton.setImage(UIImage(named: "liked"), for: .normal) :
      toggleLikeButton.setImage(UIImage(named: "like"), for: .normal)

    if let recipeImage = recipe.image {
      recipeImageView.image = UIImage(data: recipeImage)
    } else {
      recipeImageView.image = UIImage(named: "placeholder")
    }
    recipeTitleLabel.text = recipe.title
    if recipe.servings == 1 || recipe.servings == 0 {
      recipeSubTitleLabel.text = String("1 serving")
    } else {
      recipeSubTitleLabel.text = String("\(recipe.servings) servings")
    }
  }

  // MARK: - Toogle the bookmark and notify the view controller through a callback
  @objc func toggleBookmarked() {
    bookmarked.toggle()
    bookmarked ? toggleBookmarkButton.setImage(UIImage(named: "bookmarked"), for: .normal) :
      toggleBookmarkButton.setImage(UIImage(named: "bookmark"), for: .normal)
    // Callback to alert the view controller
    toggleBookmarkTappedCallback?()
  }

  // MARK: - Toogle the liked and notify the view controller through a callback
  @objc func toggleLiked() {
    liked.toggle()
    liked ? toggleLikeButton.setImage(UIImage(named: "liked"), for: .normal) :
      toggleLikeButton.setImage(UIImage(named: "like"), for: .normal)
    // Callback to alert the view controller
    toggleLikeTappedCallback?()
  }
}
