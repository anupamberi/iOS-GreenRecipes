//
//  RecipeCollectionViewCell.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 13/05/2021.
//

import UIKit

// MARK: - Represents a recipe with summary detail as a collection view cell
class RecipeWithDetailViewCell: UICollectionViewCell {
  static let reuseIdentifier = "RecipeCellReuseIdentifier"
  var recipeImageView = UIImageView()
  var recipeTitleLabel = UILabel()
  var recipePreparationTime = UILabel()
  var recipeIngredientsCount = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension RecipeWithDetailViewCell {
  func configure() {
    contentView.backgroundColor = .systemGray6
    contentView.layer.cornerRadius = 15

    recipeImageView.contentMode = .scaleAspectFill
    recipeImageView.clipsToBounds = true
    recipeImageView.layer.cornerRadius = 15
    recipeImageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

    recipeTitleLabel.font = UIFont.systemFont(ofSize: 16)
    recipeTitleLabel.allowsDefaultTighteningForTruncation = true
    recipeTitleLabel.textColor = .systemGreen

    recipePreparationTime.font = UIFont.systemFont(ofSize: 12)
    recipePreparationTime.adjustsFontSizeToFitWidth = true
    recipePreparationTime.textColor = .white

    recipeIngredientsCount.font = UIFont.systemFont(ofSize: 12)
    recipeIngredientsCount.adjustsFontSizeToFitWidth = true
    recipeIngredientsCount.textColor = .white

    let cookingImageView = UIImageView(image: UIImage(named: "cooking"))
    cookingImageView.clipsToBounds = true
    cookingImageView.contentMode = .scaleAspectFill

    let ingredientsImageView = UIImageView(image: UIImage(named: "ingredients"))
    ingredientsImageView.clipsToBounds = true
    ingredientsImageView.contentMode = .scaleAspectFill

    let vStackView = UIStackView()
    vStackView.axis = .vertical
    vStackView.alignment = .center
    vStackView.translatesAutoresizingMaskIntoConstraints = false
    vStackView.spacing = 10

    let hStackView = UIStackView()
    hStackView.axis = .horizontal
    hStackView.alignment = .fill
    hStackView.distribution = .equalCentering
    hStackView.spacing = 15
    hStackView.translatesAutoresizingMaskIntoConstraints = false

    let spacerView = UIView(frame: .zero)
    spacerView.translatesAutoresizingMaskIntoConstraints = false
    spacerView.heightAnchor.constraint(equalToConstant: 10).isActive = true

    hStackView.addArrangedSubview(cookingImageView)
    hStackView.addArrangedSubview(recipePreparationTime)
    hStackView.addArrangedSubview(ingredientsImageView)
    hStackView.addArrangedSubview(recipeIngredientsCount)

    vStackView.addArrangedSubview(recipeImageView)
    vStackView.addArrangedSubview(recipeTitleLabel)
    vStackView.addArrangedSubview(hStackView)
    vStackView.addArrangedSubview((spacerView))

    contentView.addSubview(vStackView)

    // Setup constraints
    NSLayoutConstraint.activate([
      vStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      vStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      vStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
      vStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      recipeTitleLabel.heightAnchor.constraint(equalToConstant: 20),
      cookingImageView.widthAnchor.constraint(equalToConstant: 20),
      cookingImageView.heightAnchor.constraint(equalToConstant: 20),
      ingredientsImageView.heightAnchor.constraint(equalToConstant: 20),
      ingredientsImageView.widthAnchor.constraint(equalToConstant: 20),
      hStackView.heightAnchor.constraint(equalToConstant: 20)
    ])
  }
}
