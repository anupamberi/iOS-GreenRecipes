//
//  UIViewController+Extension.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 21/05/2021.
//

import UIKit

extension UIViewController {
  func getVerticalStackView(enableSpacing: Bool) -> UIStackView {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.distribution = .fill

    if enableSpacing {
      stackView.spacing = 10
    }
    return stackView
  }
}
