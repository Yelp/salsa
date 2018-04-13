//
//  ResizingConstraint.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 9/20/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation

/// Sketch rezising constraints are a bitfield consisting of 6 bits
/// Each bit represents a property that could be constrained
/// A 1 means that property is not constrainted while a 0 means that property is constrained
enum ResizingConstraint: Int {
  case right, width, left, bottom, height, top

  private var bitValue: Int {
    return 1 << self.rawValue
  }

  static func makeConstraint(with values: [ResizingConstraint] = []) -> Int {
    var value = 63
    Set(values).forEach { value -= $0.bitValue }
    return value
  }
}

