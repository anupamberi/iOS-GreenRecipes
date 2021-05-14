//
//  RecipeCollectionViewCell.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 13/05/2021.
//

import UIKit

class RecipeCollectionViewCell: UICollectionViewCell {
  static let reuseIdentifier = "RecipeCellReuseIdentifier"
  var recipeImageView = UIImageView()
  var recipeTitleLabel = UILabel()
  var recipePreprationTime = UILabel()
  var recipeIngredientsCount = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    addViews()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension RecipeCollectionViewCell {
  func addViews() {
    recipeImageView.contentMode = .scaleAspectFill
    recipeImageView.clipsToBounds = true

    recipeTitleLabel.font = UIFont.systemFont(ofSize: 18)
    recipeTitleLabel.textColor = .systemGreen

    recipePreprationTime.font = UIFont.systemFont(ofSize: 12)
    recipePreprationTime.textColor = .white

    recipeIngredientsCount.font = UIFont.systemFont(ofSize: 12)
    recipeIngredientsCount.textColor = .white

    let prepStackView = UIStackView()
    prepStackView.axis = .horizontal
    prepStackView.alignment = .center
    prepStackView.translatesAutoresizingMaskIntoConstraints = false

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
    vStackView.layer.cornerRadius = 10
    vStackView.spacing = 10

    let hStackView = UIStackView()
    hStackView.axis = .horizontal
    hStackView.alignment = .fill
    hStackView.distribution = .equalCentering
    hStackView.spacing = 15
    hStackView.translatesAutoresizingMaskIntoConstraints = false

    hStackView.addArrangedSubview(cookingImageView)
    hStackView.addArrangedSubview(recipePreprationTime)
    hStackView.addArrangedSubview(ingredientsImageView)
    hStackView.addArrangedSubview(recipeIngredientsCount)

    vStackView.addArrangedSubview(recipeImageView)
    vStackView.addArrangedSubview(recipeTitleLabel)
    vStackView.addArrangedSubview(hStackView)

    contentView.addSubview(vStackView)

    // Setup constraints
    NSLayoutConstraint.activate([
      vStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      vStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      vStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
      vStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      recipeTitleLabel.heightAnchor.constraint(equalToConstant: 15),
      cookingImageView.widthAnchor.constraint(equalToConstant: 20),
      cookingImageView.heightAnchor.constraint(equalToConstant: 20),
      ingredientsImageView.heightAnchor.constraint(equalToConstant: 20),
      ingredientsImageView.widthAnchor.constraint(equalToConstant: 20),
      hStackView.heightAnchor.constraint(equalToConstant: 20)
    ])
  }
}
