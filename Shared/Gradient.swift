//
//  Gradient.swift
//  Salsa
//
//  Created by Max Rabiciuc on 9/20/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation
import CoreGraphics

/// Represents a linear gradient in Sketch.
/// Contained inside a `Shape`
public struct Gradient {

  /// Array of colors that are contained in the gradient
  public let colors: [Color]

  /// Position of the colors contained in the gradient.
  /// Must have the same amount of elements as colors.
  /// Range from 0 to 1.
  public let locations: [CGFloat]

  /// Start point. Range from (0,0) to (1,1)
  public let start: CGPoint

  /// End point. Range from (0,0) to (1,1)
  public let end: CGPoint

  /**
   Creates a linear Gradient to be used as a background to a `Shape`
   - parameter colors:      Colors contained in the gradient
   - parameter locations:   Control points of the gradient. Must have the same number of elements as the colors param. Must be between 0 and 1
   - parameter start:       Start point of the gradient. Used to calculate the direction of the gradient. Range from (0,0) to (1,1)
   - parameter end:         End point of the gradient. Used to calculate the direction of the gradient. Range from (0,0) to (1,1)
   */
  public init(colors: [Color], locations: [CGFloat], start: CGPoint, end: CGPoint) {
    self.colors = colors
    self.locations = locations
    self.start = start
    self.end = end
  }
}

extension Gradient: JSONDictEncodable {
  public init?(json: [String: Any]) {
    guard
      let startJson = json["start"] as? [String: Any], let start = CGPoint(json: startJson),
      let endJson = json["end"] as? [String: Any], let end = CGPoint(json: endJson)
    else { return nil }

    self.init(
      colors: {
        guard let colors = json["colors"] as? [[String: Any]] else { return [] }
        return colors.compactMap { Color(json: $0) }
    }(),
      locations: (json["locations"] as? [CGFloat]) ?? [],
      start: start,
      end: end
    )
  }

  func toJson() -> [String: Any] {
    return ["colors": colors.map { $0.toJson() }, "locations": locations.map { $0 }, "start": start.toJson(), "end": end.toJson()]
  }
}

