//
//  Artboard.swift
//  Salsa
//
//  Created by Max Rabiciuc on 9/20/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation
import CoreGraphics

/// Represents a Sketch artboard
/// Artboards act as containers for other layers
public class Artboard: LayerContainer {
  /// Background color of the artboard
  public let color: Color

  /**
   Constructs an Artboard that contains the given layers
   - parameter name:      Name of the artboard in Sketch
   - parameter layers:    List of layers that are contained inside the artboard
   - parameter frame:     Frame of the arboard within the page
   - parameter color:     Background color of the artboard
   */
  public init(name: String, layers: [Layer], frame: CGRect, color: Color) {
    self.color = color
    super.init(name: name, frame: frame, layers: layers)
  }

  public required init?(json: [String : Any]) {
    guard
      let colorJson = json["color"] as? [String: Any], let color = Color(json: colorJson)
      else { return nil }

    self.color = color
    super.init(json: json)
  }

  override public func toJson() -> [String: Any] {
    var json = super.toJson()
    json["color"] = color.toJson()
    return json
  }
}

