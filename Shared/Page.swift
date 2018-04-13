//
//  Page.swift
//  Salsa
//
//  Created by Max Rabiciuc on 9/20/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation
import CoreGraphics

/// Represents a Page inside a Sketch `Document`
public struct Page {
  /// Child layers displayed inside the Page
  public let layers: [Layer]
  /// Name of the Page as it appears in Sketch
  public let name: String

  /**
   Creates a Page to be used inside of a `Document`

   - parameter name:    Name of the Page as it appears in Sketch
   - parameter layers:  Child layers displayed inside the Page
   */
  public init(name: String, layers: [Layer]) {
    self.name = name; self.layers = layers
  }
}

extension Page: JSONDictEncodable {
  init?(json: [String: Any]) {
    guard let name = json["name"] as? String, let layersJson = json["layers"] as? [[String: Any]] else { return nil }
    self.init(name: name, layers: layersJson.compactMap { Layer.makeLayer(json: $0)})
  }

  func toJson() -> [String: Any] {
    return ["name": name, "layers": layers.map { $0.toJson() }]
  }
}

