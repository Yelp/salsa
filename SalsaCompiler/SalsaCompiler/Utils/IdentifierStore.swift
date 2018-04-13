//
//  IdentifierStore.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 10/9/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation

class IdentifierStore {
  // Maps symbol names to identifiers
  static private var symbolMap: [String: String] = [:]

  // Maps text styles to identifiers
  static private var sharedStyles: [Text.Style: String] = [:]

  // Maps page names to identifiers
  static private var pageMap: [String: String] = [:]


  static func configure(with document: Document) {
    // Pull out all the symbols from the all the pages
    let masterSymbols: [SymbolMaster] = document.pages.map {
      $0.layers.flatMap { $0 as? SymbolMaster }
    }.flatMap { $0 }

    // Build identifiers for all the symbols
    masterSymbols.forEach { symbolMap[$0.name] = UUID().uuidString }

    document.textStyles.forEach { sharedStyles[$0.textStyle] = UUID().uuidString }

    document.pages.forEach { pageMap[$0.name] = UUID().uuidString }
  }

  static func identifier(forSymbolNamed name: String) -> String? {
    return symbolMap[name]
  }

  static func identifier(forTextStyle textStyle: Text.Style) -> String? {
    return sharedStyles[textStyle]
  }

  static func identifier(forPageNamed pageName: String) -> String? {
    return pageMap[pageName]
  }
}

