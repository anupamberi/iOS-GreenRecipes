//
//  RecipesSectionBackgroundDecorationView.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 14/05/2021.
//

import UIKit

class RecipesSectionBackgroundDecorationView: UICollectionReusableView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension RecipesSectionBackgroundDecorationView {
  func configure() {
    backgroundColor = UIColor.black.withAlphaComponent(1.0)
  }
}
