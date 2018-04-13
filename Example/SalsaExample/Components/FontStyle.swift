//
//  FontStyle.swift
//  SalsaExample
//
//  Created by Max Rabiciuc on 2/21/18.
//  Copyright © 2018 Yelp. All rights reserved.
//

import UIKit

enum FontStyle {
  case large, regular, regularBold, small
  var font: UIFont {
    switch self {
    case .large:
      return .systemFont(ofSize: 18)
    case .regular:
      return .systemFont(ofSize: 14)
    case .regularBold:
      return .boldSystemFont(ofSize: 14)
    case .small:
      return .systemFont(ofSize: 12)
    }
  }

  static var allStyles: [FontStyle] {
    return [.large, .regular, .regularBold, .small]
  }
}
