//
//  SymbolInstance+SketchJson.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 9/15/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation

extension SymbolInstance {
  override func toSketchJson() -> [String : Any] {
    guard let symbolID = IdentifierStore.identifier(forSymbolNamed: name) else {
      exit(withMessage: "Could not find symbol named: \(name)")
    }
    return super.toSketchJson().merging(with: [
      "_class": "symbolInstance",
      "horizontalSpacing": 0,
      "masterInfluenceEdgeMaxXPadding": 0,
      "masterInfluenceEdgeMaxYPadding": 0,
      "masterInfluenceEdgeMinXPadding": 0,
      "masterInfluenceEdgeMinYPadding": 0,
      "symbolID": symbolID,
      "verticalSpacing": 0
    ])
  }
}

