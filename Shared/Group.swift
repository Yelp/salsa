//
//  Group.swift
//  Salsa
//
//  Created by Max Rabiciuc on 9/20/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation
import CoreGraphics

/// Represents a Group in Sketch. Container for other layer types.
public class Group: LayerContainer {
  /// Transparency applied to all elements inside the group
  public let alpha: CGFloat

  /**
   Constructs a Group containing the given layers
   - parameter frame:     Frame of the Group inside its containing layer
   - parameter layers:    Child layers that are contained inside the group
   - parameter alpha:     Transparency applied to all elements inside the group
   - parameter name:      Name of the group in Sketch
   - parameter shadow:    optional shadow shown underneath the group, defaults to nil
   */
  public init(frame: CGRect, layers: [Layer], alpha: CGFloat, name: String, shadow: Shadow? = nil) {
    self.alpha = alpha
    super.init(name: name, frame: frame, layers: layers, shadow: shadow)
  }

  // MARK: JSONDictEncodable
  public required init?(json: [String : Any]) {
    guard let alpha = json["alpha"] as? CGFloat else { return nil }
    self.alpha = alpha
    super.init(json: json)
  }

  override public func toJson() -> [String: Any] {
    var json = super.toJson()
    json["alpha"] = alpha
    return json
  }
}

