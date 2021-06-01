//
//  ProfileRecipeViewCell.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 31/05/2021.
//

import UIKit

class BookmarkedRecipeViewCell: UICollectionViewCell {
  static let reuseIdentifier = "ProfileRecipeViewCell"
  var recipeImageView = UIImageView()
  var recipeTitleLabel = UILabel()
  var toggleBookmarkButton = UIButton(frame: .zero)
  var toggleBookmarkTappedCallback: (() -> ())?

  private var bookmarked = true

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension BookmarkedRecipeViewCell {
  func configure() {
    contentView.backgroundColor = .systemGray6
    contentView.layer.cornerRadius = 10

    recipeImageView.contentMode = .scaleAspectFill
    recipeImageView.clipsToBounds = true
    recipeImageView.layer.cornerRadius = 10
    recipeImageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

    recipeTitleLabel.font = UIFont.systemFont(ofSize: 20)
    recipeTitleLabel.textAlignment = .center
    recipeTitleLabel.numberOfLines = 3
    recipeTitleLabel.lineBreakMode = .byWordWrapping
    recipeTitleLabel.allowsDefaultTighteningForTruncation = true
    recipeTitleLabel.textColor = .white

    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 10

    let spacerView = UIView(frame: .zero)
    spacerView.translatesAutoresizingMaskIntoConstraints = false
    spacerView.heightAnchor.constraint(equalToConstant: 10).isActive = true

    stackView.addArrangedSubview(recipeImageView)
    stackView.addArrangedSubview(recipeTitleLabel)
    stackView.addArrangedSubview(spacerView)

    toggleBookmarkButton.translatesAutoresizingMaskIntoConstraints = false
    toggleBookmarkButton.setImage(UIImage(named: "bookmarked"), for: .normal)
    toggleBookmarkButton.addTarget(self, action: #selector(toogleBookmarked), for: .touchUpInside)
    toggleBookmarkButton.imageView?.contentMode = .scaleAspectFit
    contentView.addSubview(toggleBookmarkButton)
    contentView.addSubview(stackView)

    contentView.bringSubviewToFront(toggleBookmarkButton)
    // Setup constraints
    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      recipeTitleLabel.heightAnchor.constraint(equalToConstant: 40),

      toggleBookmarkButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
      toggleBookmarkButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
      toggleBookmarkButton.widthAnchor.constraint(equalToConstant: 30),
      toggleBookmarkButton.heightAnchor.constraint(equalToConstant: 30)
    ])
  }

  @objc func toogleBookmarked() {
    bookmarked.toggle()
    bookmarked ? toggleBookmarkButton.setImage(UIImage(named: "bookmarked"), for: .normal) :
      toggleBookmarkButton.setImage(UIImage(named: "bookmark"), for: .normal)
    // Callback to alert the view controller
    toggleBookmarkTappedCallback?()
  }
}
