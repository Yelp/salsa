//
//  CGRect+SketchJson.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 9/15/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation

extension CGRect: SketchJsonConvertable {
  func toSketchJson() -> [String: Any] {
    return [
      "_class": "rect",
      "constrainProportions": false,
      "height": size.height,
      "width": size.width,
      "x": origin.x,
      "y": origin.y,
    ]
  }
}

