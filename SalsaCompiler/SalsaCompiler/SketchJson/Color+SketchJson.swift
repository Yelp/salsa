//
//  Color+SketchJson.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 9/15/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Cocoa

extension Color: SketchJsonConvertable {
  func toSketchJson() -> [String: Any] {
    return [
      "_class": "color",
      "alpha": alpha,
      "blue": blue,
      "green": green,
      "red": red
    ]
  }
}

