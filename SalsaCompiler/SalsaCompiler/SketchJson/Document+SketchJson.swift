//
//  Document+SketchJson.swift
//
//
//  Created by Max Rabiciuc on 9/18/17.
//

import Foundation

extension Document {
  func toSketchJson(pageIds: [String]) -> [String: Any] {
    let pages: [[String: Any]] = pageIds.map {
      return [
        "_class": "MSJSONFileReference",
        "_ref_class": "MSImmutablePage",
        "_ref": "pages/\($0)"
      ]
    }
    return [
      "_class": "document",
      "do_objectID": makeObjectId(),
      "assets": [
        "_class": "assetCollection",
        "colors": colors.map { $0.toSketchJson() },
        "gradients": [Any](),
        "imageCollection": [
          "_class": "imageCollection",
          "images": [Any]()
        ],
        "images": [Any]()
      ],
      "currentPageIndex": 0,
      "enableLayerInteraction": true,
      "enableSliceInteraction": true,
      "foreignSymbols": [Any](),
      "layerStyles": [
        "_class": "sharedStyleContainer",
        "objects": [Any]()
      ],
      "layerSymbols": [
        "_class": "symbolContainer",
        "objects": [Any]()
      ],
      "layerTextStyles": [
        "_class": "sharedTextStyleContainer",
        "objects": textStyles.map { $0.toSketchJson() }
      ],
      "pages": pages
    ]
  }
}

