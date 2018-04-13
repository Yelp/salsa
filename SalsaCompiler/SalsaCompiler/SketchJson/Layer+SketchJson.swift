//
//  Layer+SketchJsonConvertable.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 9/15/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation

extension Layer: SketchJsonConvertable {
  @objc func toSketchJson() -> [String: Any] {
    var styleJson = makeEmptyStyle()
    if let shadow = shadow {
      styleJson["shadows"] = [shadow.toSketchJson()]
    }

    return Layer.makeBaseSketchJson().merging(with: [
      "frame": frame.toSketchJson(),
      "name": name,
      "style": styleJson
    ])
  }

  static func makeBaseSketchJson() -> [String: Any] {
    return [
      "do_objectID": makeObjectId(),
      "exportOptions": makeExportOptions(),
      "isFlippedHorizontal": false,
      "isFlippedVertical": false,
      "isLocked": false,
      "isVisible": true,
      "layerListExpandedType": 0,
      "nameIsFixed": false,
      "resizingConstraint": ResizingConstraint.makeConstraint(),
      "resizingType": 0,
      "rotation": 0,
      "shouldBreakMaskChain": false,
      "hasClickThrough": false,
      "style": makeEmptyStyle(),
      "horizontalRulerData": makeRulerData(),
      "includeBackgroundColorInExport": true,
      "includeInCloudUpload": true,
      "resizesContent": false,
      "verticalRulerData": makeRulerData(),
    ]
  }
}

extension LayerContainer {
  @objc override func toSketchJson() -> [String : Any] {
    return super.toSketchJson().merging(with: [
      "layers": layers.map { $0.toSketchJson() },
    ])
  }
}

