//
//  SymbolMaster+SketchJsonConvertable.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 9/15/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation

extension SymbolMaster {
  override func toSketchJson() -> [String : Any] {
    guard let symbolID = IdentifierStore.identifier(forSymbolNamed: name) else {
      exit(withMessage: "Could not find symbol named: \(name)")
    }
    return super.toSketchJson().merging(with: [
      "_class": "symbolMaster",
      "backgroundColor": Color.clear.toSketchJson(),
      "hasBackgroundColor": false,
      "includeBackgroundColorInInstance": false,
      "symbolID": symbolID,
      "changeIdentifier": 0
    ])
  }
}

