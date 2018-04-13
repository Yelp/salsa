//
//  Layer+Simplified.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 9/18/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Cocoa

// Removes redundant layers from the hierarchy
extension Layer {
  // Base implementation does nothing, subclass to add special implementation for different layer types
  @objc func simplified(isRoot: Bool = false) -> [Layer] {
    return [self]
  }
}

