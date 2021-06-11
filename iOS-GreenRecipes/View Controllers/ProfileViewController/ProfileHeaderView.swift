//
//  ProfileHeaderView.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 02/06/2021.
//

import UIKit

// MARK: - Represents a title view of a bookmarked recipes collection view
class ProfileHeaderView: UICollectionReusableView {
  static let reuseIdentifier = "ProfileHeaderReuseIdentifier"

  private let likesButton = UIButton()
  private let bookmarksButton = UIButton()

  var likesButtonClicked: (() -> Void)?
  var bookmarksButtonClicked: (() -> Void)?

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
    highlightLikesButton()
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension ProfileHeaderView {
  func configure() {
    backgroundColor = .black
    likesButton.translatesAutoresizingMaskIntoConstraints = false
    likesButton.setTitle("Likes", for: .normal)
    likesButton.titleLabel?.textAlignment = .center
    likesButton.layer.borderWidth = 2
    likesButton.layer.cornerRadius = 5
    likesButton.layer.borderColor = UIColor.systemGreen.cgColor
    likesButton.addTarget(self, action: #selector(likesTapped), for: .touchUpInside)

    bookmarksButton.translatesAutoresizingMaskIntoConstraints = false
    bookmarksButton.setTitle("Bookmarks", for: .normal)
    bookmarksButton.titleLabel?.textAlignment = .center
    bookmarksButton.layer.borderWidth = 2
    bookmarksButton.layer.cornerRadius = 5
    bookmarksButton.layer.borderColor = UIColor.systemGreen.cgColor
    bookmarksButton.addTarget(self, action: #selector(bookmarksTapped), for: .touchUpInside)

    let buttonsView = UIStackView()
    buttonsView.translatesAutoresizingMaskIntoConstraints = false
    buttonsView.alignment = .center
    buttonsView.axis = .horizontal
    buttonsView.distribution = .fillEqually
    buttonsView.spacing = 20

    addSubview(buttonsView)
    buttonsView.addArrangedSubview(likesButton)
    buttonsView.addArrangedSubview(bookmarksButton)

    NSLayoutConstraint.activate([
      buttonsView.leadingAnchor.constraint(equalTo: leadingAnchor),
      buttonsView.trailingAnchor.constraint(equalTo: trailingAnchor),
      buttonsView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
      buttonsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
    ])
  }

  func highlightLikesButton() {
    // Highlight the button
    likesButton.backgroundColor = .systemGreen
    bookmarksButton.backgroundColor = .none
  }

  @objc func likesTapped() {
    // Highlight the button
    likesButton.backgroundColor = .systemGreen
    bookmarksButton.backgroundColor = .none
    likesButtonClicked?()
  }

  @objc func bookmarksTapped() {
    // Highlight the button
    bookmarksButton.backgroundColor = .systemGreen
    likesButton.backgroundColor = .none
    bookmarksButtonClicked?()
  }
}
