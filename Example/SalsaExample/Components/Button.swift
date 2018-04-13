//
//  Button.swift
//  SalsaExample
//
//  Created by Max Rabiciuc on 2/21/18.
//  Copyright © 2018 Yelp. All rights reserved.
//

import UIKit

class Button: UIButton {
  enum Style {
    case blueShort, blueTall, redShort, redTall, link
    var textColor: UIColor {
      switch self {
      case .blueShort, .blueTall, .redShort, .redTall:
        return .white
      case .link:
        return UIColor(red: 0/255.0, green: 151/255.0, blue: 236/255.0, alpha: 1.0)
      }
    }

    var height: CGFloat {
      switch self {
      case .blueTall, .redTall:
        return 40
      case .blueShort, .redShort, .link:
        return 24
      }
    }

    var backgroundColor: UIColor {
      switch self {
      case .blueTall, .blueShort:
        return UIColor(red: 0/255.0, green: 151/255.0, blue: 236/255.0, alpha: 1.0)
      case .redTall, .redShort:
        return .red
      case .link:
        return .clear
      }
    }

    var fontStyle: FontStyle {
      switch self {
      case .blueTall, .redTall:
        return .large
      case .blueShort, .redShort:
        return .regular
      case .link:
        return .small
      }

    }
  }

  init(title: String, style: Style) {
    super.init(frame: .zero)
    setTitle(title, for: .normal)
    setTitleColor(style.textColor, for: .normal)
    backgroundColor = style.backgroundColor
    heightAnchor.constraint(equalToConstant: style.height).isActive = true
    titleLabel?.font = style.fontStyle.font
    layer.cornerRadius = 10
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
