//
//  PreferenceTableViewCell.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 02/06/2021.
//

import UIKit

class PreferenceTableViewCell: UITableViewCell {
  static let reuseIdentifier = "PreferenceTableViewCell"

  private let containerView = UIView()
  private let iconImageView = UIImageView()
  private let title = UILabel()
  private let onSwitch = UISwitch()
  var togglePreferenceChangedCallback: ((Bool) -> Void)?

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configure()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let size: CGFloat = contentView.frame.size.height - 12
    containerView.frame = CGRect(x: 15, y: 6, width: size, height: size)
    let imageSize: CGFloat = size / 1.5
    iconImageView.frame = CGRect(
      x: (size - imageSize) / 2,
      y: (size - imageSize) / 2,
      width: imageSize,
      height: imageSize
    )

    title.frame = CGRect(
      x: 25 + containerView.frame.size.width,
      y: 0,
      width: contentView.frame.size.width - 20 - containerView.frame.size.width - 10,
      height: contentView.frame.size.height
    )

    onSwitch.sizeToFit()
    onSwitch.frame = CGRect(
      x: contentView.frame.size.width - onSwitch.frame.size.width - 20,
      y: contentView.frame.size.height - onSwitch.frame.size.height,
      width: onSwitch.frame.size.width,
      height: onSwitch.frame.size.height
    )
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    iconImageView.image = nil
    title.text = nil
    containerView.backgroundColor = nil
    onSwitch.isOn = false
  }

  func configure(preference: Preference) {
    title.text = preference.title
    iconImageView.image = preference.icon
    onSwitch.isOn = preference.isOn
    onSwitch.addTarget(self, action: #selector(preferenceToggled), for: .valueChanged)
  }

  private func configure() {
    containerView.clipsToBounds = true
    containerView.backgroundColor = .systemPurple
    containerView.layer.cornerRadius = 8
    containerView.layer.masksToBounds = true

    iconImageView.tintColor = .white
    iconImageView.contentMode = .scaleAspectFit

    onSwitch.onTintColor = .systemGreen

    title.numberOfLines = 1
    title.adjustsFontSizeToFitWidth = true

    contentView.addSubview(title)
    containerView.addSubview(iconImageView)
    contentView.addSubview(containerView)
    contentView.addSubview(onSwitch)
  }

  @objc func preferenceToggled() {
    togglePreferenceChangedCallback?(onSwitch.isOn)
  }
}
