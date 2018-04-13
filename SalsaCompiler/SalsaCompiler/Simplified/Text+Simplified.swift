//
//  Text+Simplified.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 10/16/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation

extension Text {
  @objc override func simplified(isRoot: Bool = false) -> [Layer] {
    // If a textfield is empty then its redundant
    if segments.isEmpty {
      return []
    } else {
      return super.simplified()
    }
  }
}

