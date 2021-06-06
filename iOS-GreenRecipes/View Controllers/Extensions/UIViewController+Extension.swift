//
//  UIViewController+Extension.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 21/05/2021.
//

import UIKit

private var activityView : UIView?

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

  // MARK: Reusable activity progress indicators among different UIViewControllers
  // Reference: https://www.youtube.com/watch?v=twgb5IPwR4I
  // swiftlint:disable force_unwrapping
  func showActivity(activityMessage: String) {
    activityView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 150))
    activityView?.clipsToBounds = true
    activityView?.layer.cornerRadius = 10
    activityView?.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
    activityView?.center.x = view.center.x
    activityView?.center.y = view.center.y - 100

    let activityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    activityIndicatorView.color = .white

    let activityTitle = UILabel()
    activityTitle.translatesAutoresizingMaskIntoConstraints = false
    activityTitle.numberOfLines = 3
    activityTitle.textAlignment = .center
    activityTitle.lineBreakMode = .byWordWrapping
    activityTitle.textColor = .white
    activityTitle.text = activityMessage

    activityView?.addSubview(activityTitle)
    activityView?.addSubview(activityIndicatorView)
    view.addSubview(activityView!)

    activityTitle.leadingAnchor.constraint(equalTo: activityView!.leadingAnchor, constant: 10).isActive = true
    activityTitle.trailingAnchor.constraint(equalTo: activityView!.trailingAnchor, constant: -10).isActive = true
    activityTitle.topAnchor.constraint(equalTo: activityView!.topAnchor, constant: 10).isActive = true

    activityIndicatorView.centerXAnchor.constraint(equalTo: activityView!.centerXAnchor).isActive = true
    activityIndicatorView.topAnchor.constraint(equalTo: activityTitle.bottomAnchor, constant: 20).isActive = true
    activityIndicatorView.startAnimating()
  }
  // swiftlint:enable force_unwrapping

  func removeActivity() {
    activityView?.removeFromSuperview()
    activityView = nil
  }
}
