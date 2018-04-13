//
//  Layer.swift
//  Salsa
//
//  Created by Max Rabiciuc on 9/20/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation
import CoreGraphics

/** Represents a generic Sketch layer.
 This is the base class for all the layer types

 __This is an abstract class, do not instantiate directly!__
 */
public class Layer: NSObject, JSONDictEncodable {
  /// Name of the Layer as it appears in Sketch
  public let name: String
  /// Frame of the layer inside its parent
  public var frame: CGRect
  public let shadow: Shadow?

  /**
   Constructs a Layer object with the given parameters
   - parameter name:    Name of the Layer in Sketch
   - parameter frame:   Frame of the Layer inside its container
   - parameter shadow:  Optional shadow shown underneath the Layer, defaults to nil
   */
  init(name: String, frame: CGRect, shadow: Shadow? = nil) {
    self.name = name
    self.frame = frame
    self.shadow = shadow
  }

  /// Instantiates the appropriate layer type from the given json dict
  static func makeLayer(json: [String: Any]) -> Layer? {
    let layerTypes: [Layer.Type] = [SymbolInstance.self, Artboard.self, Group.self, SymbolMaster.self, Bitmap.self, Text.self, Shape.self, RectanglePath.self, BezierPath.self]
    var typeMap: [String: Layer.Type] = [:]
    layerTypes.forEach { typeMap[String(describing: $0)] = $0 }
    guard let typeString = json["_type"] as? String, let layerType = typeMap[typeString] else { return nil }
    return layerType.init(json: json)
  }

  // MARK: JSONDictEncodable
  /// Do not use this directly, use `makeLayer(json:)` instead
  required public init?(json: [String: Any]) {
    guard
      let name = json["name"] as? String,
      let frameJson = json["frame"] as? [String: Any], let frame = CGRect(json: frameJson)
      else { return nil }
    self.name = name
    self.frame = frame
    self.shadow = {
      guard let shadowJson = json["shadow"] as? [String: Any] else { return nil }
      return Shadow(json: shadowJson)
    }()
  }

  func toJson() -> [String : Any] {
    var json: [String: Any] = [
      "_type": String(describing: type(of: self)),
      "name": name,
      "frame": frame.toJson()
    ]
    if let shadow = shadow {
      json["shadow"] = shadow.toJson()
    }
    return json
  }
}

/**
 A type of `Layer` that can contains other layers.

 __This is an abstract class, do not instantiate directly!__
 */
public class LayerContainer: Layer {
  public let layers: [Layer]

  init(name: String, frame: CGRect, layers: [Layer], shadow: Shadow? = nil) {
    self.layers = layers
    super.init(name: name, frame: frame, shadow: shadow)
  }

  /// Do not use this directly, use `makeLayer(json:)` instead
  required public init?(json: [String : Any]) {
    let layers = json["layers"] as? [[String: Any]] ?? []
    self.layers = layers.compactMap { Layer.makeLayer(json: $0) }
    super.init(json: json)
  }

  override func toJson() -> [String: Any] {
    var json = super.toJson()
    json["layers"] = layers.map { $0.toJson() }
    return json
  }
}

