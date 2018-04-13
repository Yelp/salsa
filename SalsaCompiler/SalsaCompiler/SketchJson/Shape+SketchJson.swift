//
//  Shape+SketchJson.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 9/15/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation

extension Shape {
  override func toSketchJson() -> [String: Any] {
    return super.toSketchJson().merging(with: [
      "_class": "shapeGroup",
      "resizingConstraint": ResizingConstraint.makeConstraint(with: [.top, .left, .bottom, .right]),
      "style": styleJson(),
      "hasClickThrough": false,
      "hasClippingMask": isMask,
      "layers": [path.toSketchJson()]
    ])
  }

  func styleJson() -> [String: Any] {
    return [
      "_class": "style",
      "borders": [borderJson()],
      "endDecorationType": 0,
      "fills": [fillJson()],
      "miterLimit": 10,
      "startDecorationType": 0
    ]
  }

  func borderJson() -> [String: Any] {
    return [
      "_class": "border",
      "isEnabled": true,
      "color": borderColor.toSketchJson(),
      "fillType": 0,
      "position": 1,
      "thickness": borderWidth
    ]
  }

  func fillJson() -> [String: Any] {
    var json: [String: Any] = makeFill(color: backgroundColor)
    if let gradient = gradient {
      json["gradient"] = gradient.toSketchJson()
      json["fillType"] = 1
    }
    return json
  }
}

