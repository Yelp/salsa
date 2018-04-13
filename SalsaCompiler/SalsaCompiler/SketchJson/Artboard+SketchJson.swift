//
//  Artboard+SketchJsonConvertable.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 9/15/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation

extension Artboard {
  override func toSketchJson() -> [String: Any] {
    return super.toSketchJson().merging(with: [
      "_class": "artboard",
      "backgroundColor": color.toSketchJson(),
      "hasBackgroundColor": true,
    ])
  }
}

