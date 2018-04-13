//
//  UserView.swift
//  SalsaExample
//
//  Created by Max Rabiciuc on 2/21/18.
//  Copyright © 2018 Yelp. All rights reserved.
//

import UIKit

struct User {
  let name: String
  let subtitle: String?
  let image: UIImage
}

class UserView: UIView {
  let nameLabel: UILabel = {
    let label = UILabel()
    label.font = FontStyle.regularBold.font
    label.numberOfLines = 1
    return label
  }()

  let subtitleLabel: UILabel = {
    let label = UILabel()
    label.font = FontStyle.small.font
    label.textColor = .gray
    label.numberOfLines = 1
    return label
  }()

  let imageView: UIImageView = {
    let size: CGFloat = 42
    let imageView = UIImageView()
    imageView.layer.cornerRadius = size / 2
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill
    NSLayoutConstraint.activate([
      imageView.heightAnchor.constraint(equalToConstant: size),
      imageView.widthAnchor.constraint(equalToConstant: size)
    ])
    return imageView
  }()

  var onlineBadge: UIView = {
    let size: CGFloat = 12
    let badge = UIView()
    badge.backgroundColor = .green
    badge.layer.borderColor = UIColor.white.cgColor
    badge.layer.borderWidth = 2
    badge.layer.cornerRadius = size / 2
    NSLayoutConstraint.activate([
      badge.heightAnchor.constraint(equalToConstant: size),
      badge.widthAnchor.constraint(equalToConstant: size)
    ])
    return badge
  }()

  init(user: User, isOnline: Bool) {
    super.init(frame: .zero)
    addSubview(imageView)
    addSubview(nameLabel)
    addSubview(subtitleLabel)
    addSubview(onlineBadge)
    imageView.image = user.image
    nameLabel.text = user.name
    subtitleLabel.text = user.subtitle
    subtitleLabel.isHidden = user.subtitle?.isEmpty ?? true
    onlineBadge.isHidden = !isOnline
    installConstraints()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func installConstraints() {
    let pad: CGFloat = 10
    let views = [
      "imageView": imageView,
      "nameLabel": nameLabel,
      "subtitleLabel": subtitleLabel,
      "onlineBadge": onlineBadge
    ]
    views.forEach {
      $1.translatesAutoresizingMaskIntoConstraints = false
    }

    let metrics = [
      "pad": pad
    ]

    let labelConstraints: [NSLayoutConstraint] = subtitleLabel.isHidden ? [
      nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -pad),
      nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: pad),
    ] : [
      nameLabel.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -2),
      subtitleLabel.topAnchor.constraint(equalTo: centerYAnchor, constant: 2)
    ]

    let constraints: [[NSLayoutConstraint]] = [
      NSLayoutConstraint.constraints(withVisualFormat: "V:|-pad-[imageView]-pad-|", options: [], metrics: metrics, views: views),
      NSLayoutConstraint.constraints(withVisualFormat: "H:|-pad-[imageView]-pad-[nameLabel]-pad-|", options: [], metrics: metrics, views: views),
      NSLayoutConstraint.constraints(withVisualFormat: "H:[imageView]-pad-[subtitleLabel]-pad-|", options: [], metrics: metrics, views: views),
      labelConstraints,
      [
        onlineBadge.rightAnchor.constraint(equalTo: imageView.rightAnchor),
        onlineBadge.topAnchor.constraint(equalTo: imageView.centerYAnchor, constant: pad),
      ],
    ]
    NSLayoutConstraint.activate(constraints.flatMap { $0 })
  }
}
