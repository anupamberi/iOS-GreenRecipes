//
//  SeparatorView.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 21/05/2021.
//

import UIKit

class SeparatorView: UIView {
  init() {
    super.init(frame: .zero)
    setUp()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setUp()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setUp() {
    backgroundColor = .gray
  }

  override var intrinsicContentSize: CGSize {
    return CGSize(width: UIView.noIntrinsicMetric, height: 0.25)
  }
}
