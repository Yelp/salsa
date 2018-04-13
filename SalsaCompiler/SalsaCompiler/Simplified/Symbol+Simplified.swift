//
//  Symbol+Simplified.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 10/16/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation

extension SymbolMaster {
  override func simplified(isRoot: Bool = false) -> [Layer] {
    // Forward simplification to the sublayers
    let simplified: [[Layer]] = layers.map({ $0.simplified() })
    return [SymbolMaster(name: name, frame: frame, layers: simplified.flatMap { $0 })]
  }
}

