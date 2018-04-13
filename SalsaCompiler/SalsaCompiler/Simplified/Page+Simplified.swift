//
//  Page+Simplified.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 10/16/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation

extension Page {
  func simplified() -> Page {
    // Forward simplification to the sublayers
    let simplified: [[Layer]] = layers.map({ $0.simplified(isRoot: true) })
    return Page(name: name, layers: simplified.flatMap { $0 })
  }
}

