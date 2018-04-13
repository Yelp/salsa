//
//  SketchNestable.swift
//  Salsa
//
//  Created by Max Rabiciuc on 8/11/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

/// Conform a `UIView` to this type in order for it to be picked up as a nested Symbol
public protocol SketchNestable {
  /// Returns a `SymbolInstance` that represents this view
  func nestedSymbol() -> SymbolInstance
}

