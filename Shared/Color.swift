//
//  Color.swift
//  Salsa
//
//  Created by Max Rabiciuc on 9/20/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation
import CoreGraphics

/// Represents an RGB color in Sketch
public class Color: NSObject, JSONDictEncodable {
  /// Possible values are from 0 to 1
  public let red: CGFloat
  /// Possible values are from 0 to 1
  public let green: CGFloat
  /// Possible values are from 0 to 1
  public let blue: CGFloat
  /// Possible values are from 0 to 1
  public let alpha: CGFloat

  /// Creates a Color in RGB color space. Parameter values should be from 0 to 1
  public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
    self.red = red; self.green = green; self.blue = blue; self.alpha = alpha
  }

  required public init?(json: [String: Any]) {
    guard
      let red = json["red"] as? CGFloat,
      let green = json["green"] as? CGFloat,
      let blue = json["blue"] as? CGFloat,
      let alpha = json["alpha"] as? CGFloat
      else { return nil }
    self.red = red; self.green = green; self.blue = blue; self.alpha = alpha
  }

  func toJson() -> [String: Any] {
    return ["red": red, "green": green, "blue": blue, "alpha": alpha]
  }

  /// Creates a transparent color
  public static var clear: Color { return Color(red: 1, green: 1, blue: 1, alpha: 0) }
  /// Creates a white color
  public static var white: Color { return Color(red: 1, green: 1, blue: 1, alpha: 1) }
}

