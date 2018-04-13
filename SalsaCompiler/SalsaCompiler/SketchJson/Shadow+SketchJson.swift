//
//  Shadow+SketchJson.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 9/27/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation

extension Shadow: SketchJsonConvertable {
  func toSketchJson() -> [String : Any] {
    return [
      "_class": "shadow",
      "isEnabled": true,
      "blurRadius": radius,
      "color": color.toSketchJson(),
      "offsetX": offset.x,
      "offsetY": offset.y,
      "spread": 0
    ]
  }
}

