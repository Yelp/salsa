//
//  Shape.swift
//  Salsa
//
//  Created by Max Rabiciuc on 9/20/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation
import CoreGraphics

/// Represents a Shape layer in Sketch
public class Shape: Layer {
  /// Background color of the Shape
  public let backgroundColor: Color

  /// Thickness of the border
  public let borderWidth: CGFloat

  /// Color of the border
  public let borderColor: Color

  /// Optional gradient. If this is set then `backgroundColor` is ignored
  public let gradient: Gradient?

  /// If this is true then this Shape will act as a mask for all layers below it
  public let isMask: Bool

  let path: ShapePath

  /**
   Creates a generic Shape layer in Sketch
   - parameter name:              Name of the Shape as it appears in Sketch
   - parameter backgroundColor:   Background color of the Shape
   - parameter bezierPath:        `BezierPath` representing the structure and posititon of the Shape
   - parameter borderWidth:       Thickness of the border
   - parameter borderColor:       Color of the border
   - parameter isMask:            Wether this Shape will act as a mask for all layers below it
   - parameter gradient:          Optional. If this is not nil set then `backgroundColor` is ignored
   */
  public convenience init(name: String, backgroundColor: Color, bezierPath: BezierPath, borderWidth: CGFloat, borderColor: Color, isMask: Bool, gradient: Gradient?) {
    self.init(name: name, backgroundColor: backgroundColor, path: bezierPath, borderWidth: borderWidth, borderColor: borderColor, isMask: isMask, gradient: gradient)
  }

  /**
   Creates a rectangular Shape layer in Sketch. Use this to be able to surface corner radius sliders in sketch
   - parameter name: Name of the Shape as it appears in Sketch
   - parameter backgroundColor: Background color of the Shape
   - parameter rectanglePath: `RectanglePath` representing the structure and position of the Shape
   - parameter borderWidth: Thickness of the border
   - parameter borderColor: Color of the border
   - parameter isMask:  this is true then this Shape will act as a mask for all layers below it
   - parameter gradient: Optional. If this is not nil set then `backgroundColor` is ignored
   */
  public convenience init(name: String, backgroundColor: Color, rectanglePath: RectanglePath, borderWidth: CGFloat, borderColor: Color, isMask: Bool, gradient: Gradient?) {
    self.init(name: name, backgroundColor: backgroundColor, path: rectanglePath, borderWidth: borderWidth, borderColor: borderColor, isMask: isMask, gradient: gradient)
  }

  init(name: String, backgroundColor: Color, path: ShapePath, borderWidth: CGFloat, borderColor: Color, isMask: Bool, gradient: Gradient?) {
    self.backgroundColor = backgroundColor; self.borderWidth = borderWidth; self.borderColor = borderColor; self.isMask = isMask; self.gradient = gradient; self.path = path
    super.init(name: name, frame: path.boundingBox)
  }

  // MARK: JSONDictEncodable
  public required init?(json: [String : Any]) {
    guard
      let backgroundColorJson = json["backgroundColor"] as? [String: Any], let backgroundColor = Color(json: backgroundColorJson),
      let pathJson = json["path"] as? [String: Any],
      let path = makeShapePath(json: pathJson),
      let borderWidth = json["borderWidth"] as? CGFloat,
      let borderColorJson = json["borderColor"] as? [String: Any], let borderColor = Color(json: borderColorJson),
      let isMask = json["isMask"] as? Bool
      else { return nil }

    let gradient: Gradient? = {
      guard let gradientJson = json["gradient"] as? [String: Any] else { return nil }
      return Gradient(json: gradientJson)
    }()

    self.backgroundColor = backgroundColor; self.path = path; self.borderWidth = borderWidth; self.borderColor = borderColor; self.isMask = isMask; self.gradient = gradient
    super.init(json: json)
  }

  override func toJson() -> [String : Any] {
    var json = super.toJson()
    json["backgroundColor"] = backgroundColor.toJson()
    json["path"] = path.toJson()
    json["borderWidth"] = borderWidth
    json["borderColor"] = borderColor.toJson()
    if let gradient = gradient {
      json["gradient"] = gradient.toJson()
    }
    json["isMask"] = isMask
    return json
  }
}

