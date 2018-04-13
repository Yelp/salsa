//
//  Shape+Simplified.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 10/16/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation

extension Shape {
  @objc override func simplified(isRoot: Bool = false) -> [Layer] {
    // If a shape has no border, no background, and isn't a mask then its redundant
    if (borderColor.alpha == 0 || borderWidth == 0) && backgroundColor.alpha == 0 && !isMask {
      return []
    }
    return super.simplified()
  }
}

