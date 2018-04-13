//
//  Shadow.swift
//  Salsa
//
//  Created by Max Rabiciuc on 9/27/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import CoreGraphics

/// Represents a Shadow that can be attached to any `Layer`
public struct Shadow {
  /// Blur radius of the shadow
  let radius: CGFloat

  /// Shadow's offset from its layer's origin
  let offset: CGPoint

  /// Color of the shadow
  let color: Color

  /**
   Creates a Shadow that can be attached to any `Layer`

   - parameter radius:  Blur radius of the shadow
   - parameter offset:  Shadow's offset from its layer's origin
   - parameter color:   Color of the shadow
   */
  public init(radius: CGFloat, offset: CGPoint, color: Color) {
    self.radius = radius
    self.offset = offset
    self.color = color
  }
}

extension Shadow: JSONDictEncodable {
  init?(json: [String: Any]) {
    guard
      let radius = json["radius"] as? CGFloat,
      let offsetJson = json["offset"] as? [String: Any], let offset = CGPoint(json: offsetJson),
      let colorJson = json["color"] as? [String: Any], let color = Color(json: colorJson)
    else { return nil }
    self.init(radius: radius, offset: offset, color: color)
  }
  func toJson() -> [String : Any] {
    return [
      "radius": radius,
      "offset": offset.toJson(),
      "color": color.toJson()
    ]
  }
}

