//
//  CoreGraphics+Extensions.swift
//  Salsa
//
//  Created by Max Rabiciuc on 9/20/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import CoreGraphics

extension CGRect: JSONDictEncodable {
  public func toJson() -> [String: Any] {
    return ["height": size.height, "width": size.width, "x": origin.x, "y": origin.y]
  }

  init?(json: [String: Any]) {
    guard
      let x = json["x"] as? CGFloat,
      let y = json["y"] as? CGFloat,
      let width = json["width"] as? CGFloat,
      let height = json["height"] as? CGFloat
    else { return nil }
    self.init(x: x, y: y, width: width, height: height)
  }
}

extension CGPoint: JSONDictEncodable {
  public func toJson() -> [String: Any] {
    return ["x": x, "y": y]
  }

  init?(json: [String: Any]) {
    guard let x = json["x"] as? CGFloat, let y = json["y"] as? CGFloat else { return nil }
    self.init(x: x, y: y)
  }
}

public extension CGRect {
  public var top: CGFloat { return origin.y }
  public var left: CGFloat { return origin.x }
  public var bottom: CGFloat { return origin.y + size.height }
  public var right: CGFloat { return origin.x + size.width }

  init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
    self.init(x: left, y: top, width: right - left, height: bottom - top)
  }

  /// Creates a new CGRect that wraps both self and the passed in CGRect
  func combined(with other: CGRect) -> CGRect {
    return CGRect(top: min(top, other.top), left: min(left, other.left), bottom: max(bottom, other.bottom), right: max(right, other.right))
  }
}

