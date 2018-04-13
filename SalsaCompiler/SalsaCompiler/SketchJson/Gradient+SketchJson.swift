//
//  Gradient+SketchJson.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 9/15/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation

extension Gradient: SketchJsonConvertable {
  func toSketchJson() -> [String: Any] {
    let stops: [[String: Any]] = zip(colors, locations).map { color, location in
      return ["_class": "gradientStop", "color": color.toSketchJson(), "position": location]
    }
    return [
      "_class": "gradient",
      "elipseLength": 0,
      "from": "{\(start.x), \(start.y)}",
      "gradientType": 0,
      "shouldSmoothenOpacity": false,
      "stops": stops,
      "to": "{\(end.x), \(end.y)}"
    ]
  }
}

