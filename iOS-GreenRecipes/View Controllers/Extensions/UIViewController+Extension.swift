//
//  UIViewController+Extension.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 21/05/2021.
//

import UIKit

extension UIViewController {
  func getDataController() -> DataController {
    guard let recipesTabBar = tabBarController as? RecipesTabBarController else {
      fatalError("No data controller set")
    }
    return recipesTabBar.dataController
  }

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

  func createTitleLabel(size: Int, textToSet: String) -> UILabel {
    let title = UILabel()
    title.translatesAutoresizingMaskIntoConstraints = false
    title.font = UIFont.systemFont(ofSize: CGFloat(size))
    title.textAlignment = .left
    title.numberOfLines = 0
    title.lineBreakMode = .byWordWrapping
    title.allowsDefaultTighteningForTruncation = true
    title.textColor = .white
    title.text = textToSet
    return title
  }

  func showStatus(title: String, message: String) {
    let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertViewController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
      // Return control back to the view controller
      DispatchQueue.main.async {
        self.dismiss(animated: true, completion: nil)
      }
    }))
    present(alertViewController, animated: true, completion: nil)
  }

  func createSubTitleLabel(size: Int, textToSet: String) -> UILabel {
    let title = createTitleLabel(size: size, textToSet: textToSet)
    title.textColor = .systemGray
    return title
  }

  func spacing(value: CGFloat) -> UIView {
    let spacerView = UIView(frame: .zero)
    spacerView.translatesAutoresizingMaskIntoConstraints = false
    spacerView.heightAnchor.constraint(equalToConstant: value).isActive = true
    return spacerView
  }

  func line() -> UIView {
    let lineView = UIView(frame: .zero)
    lineView.translatesAutoresizingMaskIntoConstraints = false
    lineView.widthAnchor.constraint(equalToConstant: view.bounds.width).isActive = true
    lineView.heightAnchor.constraint(equalToConstant: 0.25).isActive = true
    lineView.backgroundColor = .gray
    return lineView
  }

  func lineWithEqualSpacing(value: CGFloat) -> UIView {
    let lineWithSpacingView = getVerticalStackView(enableSpacing: false)
    lineWithSpacingView.addArrangedSubview(spacing(value: value))
    lineWithSpacingView.addArrangedSubview(line())
    lineWithSpacingView.addArrangedSubview(spacing(value: value))
    return lineWithSpacingView
  }
}
