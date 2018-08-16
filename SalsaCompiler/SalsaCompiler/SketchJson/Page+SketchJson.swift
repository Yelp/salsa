//
//  Page+SketchJsonConvertable.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 9/15/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation

extension Page: SketchJsonConvertable {
  func toSketchJson() -> [String: Any] {
    guard let id = IdentifierStore.identifier(forPageNamed: name) else {
      exit(withMessage: "Couldn't get id for page: \(name)")
    }
    return Layer.makeBaseSketchJson().merging(with: [
      "do_objectID": id,
      "_class": "page",
      "layers": layers.map { $0.toSketchJson() },
      "frame": CGRect(x: 0, y: 0, width: 1000, height: 1000).toSketchJson(),
      "name": name,
    ])
  }
}

