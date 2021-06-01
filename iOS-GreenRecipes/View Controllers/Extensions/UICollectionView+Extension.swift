//
//  UICollectionView+Extension.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 01/06/2021.
//
import UIKit

// MARK: - Utility functions to show custom view with placeholder message
// References : https://stackoverflow.com/questions/43772984/how-to-show-a-message-when-collection-view-is-empty
extension UICollectionView {
  func setEmptyMessage(_ message: String) {
    let messageLabel = UILabel()
    messageLabel.text = message
    messageLabel.translatesAutoresizingMaskIntoConstraints = false
    messageLabel.textColor = .white
    messageLabel.numberOfLines = 0
    messageLabel.textAlignment = .center
    messageLabel.font = UIFont(name: "TrebuchetMS", size: 20)
    messageLabel.sizeToFit()
    self.backgroundView = messageLabel
  }

  func restore() {
    self.backgroundView = nil
  }
}
