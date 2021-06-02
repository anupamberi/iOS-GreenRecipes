//
//  ProfileHeaderView.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 02/06/2021.
//

import UIKit

class ProfileHeaderView: UICollectionReusableView {
  let label = UILabel()
  static let reuseIdentifier = "ProfileHeaderReuseIdentifier"

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension ProfileHeaderView {
  func configure() {
    backgroundColor = .black
    addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.adjustsFontForContentSizeCategory = true
    label.textAlignment = .left
    label.text = "Profile"
    let inset = CGFloat(10)
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
      label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
      label.topAnchor.constraint(equalTo: topAnchor, constant: inset),
      label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
    ])
    label.font = UIFont.preferredFont(forTextStyle: .title3)
  }
}
