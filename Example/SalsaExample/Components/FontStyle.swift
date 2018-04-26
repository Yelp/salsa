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
      return UIFont(name: "HelveticaNeue", size: 18)!
    case .regular:
      return UIFont(name: "HelveticaNeue", size: 14)!
    case .regularBold:
      return UIFont(name: "HelveticaNeue-Bold", size: 14)!
    case .small:
      return UIFont(name: "HelveticaNeue", size: 12)!
    }
  }

  static var allStyles: [FontStyle] {
    return [.large, .regular, .regularBold, .small]
  }
}
