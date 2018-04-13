//
//  Artboard+Simplified.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 10/16/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation

extension Artboard {
  // Simplify all the sublayers
  @objc override func simplified(isRoot: Bool = false) -> [Layer] {
    let simplified: [[Layer]] = layers.map({ $0.simplified(isRoot: true) })
    return [Artboard(name: name, layers: simplified.flatMap { $0 }, frame: frame, color: color)]
  }
}

