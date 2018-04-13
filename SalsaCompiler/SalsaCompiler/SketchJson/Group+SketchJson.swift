//
//  Group+SketchJson.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 9/15/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation

extension Group {
  override func toSketchJson() -> [String: Any] {
    let json = super.toSketchJson()
    // we need to add an extra param to the style dict to make alphas work
    var style: [String: Any] = json["style"] as? [String: Any] ?? makeEmptyStyle()
    style["contextSettings"] = [
      "_class": "graphicsContextSettings",
      "blendMode": 0,
      "opacity": alpha
    ]
    return json.merging(with: [
      "_class": "group",
      "style": style
    ])
  }
}

