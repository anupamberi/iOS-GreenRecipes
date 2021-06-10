//
//  RecipeCategoryCell.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 24/05/2021.
//

import UIKit

// MARK: - Represents a recipe category as a collection view cell
class RecipeCategoryViewCell: UICollectionViewCell {
  static let reuseIdentifier = "RecipeCategoryCellReuseIdentifier"

  override var isSelected: Bool {
    didSet {
      recipeCategoryImageView.alpha = isSelected ? 1.0 : 0.5
    }
  }
  var recipeCategoryImageView = UIImageView()
  var recipeCategoryTitle = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension RecipeCategoryViewCell {
  func configure() {
    recipeCategoryImageView.contentMode = .scaleAspectFill
    recipeCategoryImageView.translatesAutoresizingMaskIntoConstraints = false
    recipeCategoryImageView.clipsToBounds = true
    recipeCategoryImageView.layer.cornerRadius = 10
    recipeCategoryImageView.alpha = 0.5

    recipeCategoryTitle.font = UIFont.systemFont(ofSize: 18)
    recipeCategoryTitle.allowsDefaultTighteningForTruncation = true
    recipeCategoryTitle.translatesAutoresizingMaskIntoConstraints = false
    recipeCategoryTitle.textColor = .white

    contentView.addSubview(recipeCategoryImageView)
    contentView.addSubview(recipeCategoryTitle)

    NSLayoutConstraint.activate([
      recipeCategoryImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      recipeCategoryImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      recipeCategoryImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
      recipeCategoryImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

      recipeCategoryTitle.heightAnchor.constraint(equalToConstant: 20),
      recipeCategoryTitle.centerXAnchor.constraint(equalTo: recipeCategoryImageView.centerXAnchor),
      recipeCategoryTitle.centerYAnchor.constraint(equalTo: recipeCategoryImageView.centerYAnchor)
    ])
  }
}
