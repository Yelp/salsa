//
//  Bitmap+SketchJson.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 9/15/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation

extension Bitmap {
  override func toSketchJson() -> [String: Any] {
    var json = super.toSketchJson().merging(with: [
      "_class": "bitmap",
      "resizingConstraint": ResizingConstraint.makeConstraint(with: [.left, .width, .height]),
      "clippingMask": "{{0, 0}, {1, 1}}",
      "fillReplacesImage": false,
      "image": [
        "_class": "MSJSONFileReference",
        "_ref_class": "MSImageData",
        "_ref": "images/\(fileName)"
      ],
      "nineSliceCenterRect": "{{0, 0}, {0, 0}}",
      "nineSliceScale": "{0, 0}"
    ])
    if let tintColor = tintColor {
      let style = json["style"] as? [String: Any] ?? makeEmptyStyle()
      json["style"] = style.merging(with: [
        "fills": [makeFill(color: tintColor)
      ]])
    }
    return json
  }
}
