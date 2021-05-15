//
//  RecipeWithTitleViewCell.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 15/05/2021.
//

import UIKit

class RecipeWithTitleViewCell: UICollectionViewCell {
  static let reuseIdentifier = "RecipeWithTitleReuseIdentifier"
  var recipeImageView = UIImageView()
  var recipeTitleLabel = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension RecipeWithTitleViewCell {
  func configure() {
    recipeImageView.contentMode = .scaleAspectFill
    recipeImageView.clipsToBounds = true
    recipeImageView.layer.cornerRadius = 5

    recipeTitleLabel.font = UIFont.systemFont(ofSize: 14)
    recipeTitleLabel.textAlignment = .center
    recipeTitleLabel.numberOfLines = 3
    recipeTitleLabel.lineBreakMode = .byWordWrapping
    recipeTitleLabel.allowsDefaultTighteningForTruncation = true
    recipeTitleLabel.textColor = .systemGreen

    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 10

    stackView.addArrangedSubview(recipeImageView)
    stackView.addArrangedSubview(recipeTitleLabel)

    contentView.addSubview(stackView)

    // Setup constraints
    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      recipeTitleLabel.heightAnchor.constraint(equalToConstant: 40)
    ])
  }
}
