//
//  UIColor+SketchFactory.swift
//  Salsa
//
//  Created by Max Rabiciuc on 9/19/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import UIKit

extension UIColor {
  /// Creates a `Color` with the same RGB values as self
  public func makeSketchColor() -> Color {
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    getRed(&r, green: &g, blue: &b, alpha: &a)
    return Color(red: r, green: g, blue: b, alpha: a)
  }
}

