//
//  CommonFactories.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 9/14/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation

func makeObjectId() -> String {
  return UUID().uuidString
}

func makeExportOptions() -> [String: Any] {
  return [
    "_class": "exportOptions",
    "exportFormats": [],
    "includedLayerIds": [],
    "layerOptions": 0,
    "shouldTrim": false
  ]
}

func makeRulerData() -> [String: Any] {
  return [
    "_class": "rulerData",
    "base": 0,
    "guides": []
  ]
}

func makeEmptyStyle() -> [String: Any] {
  return [
    "_class": "style",
    "endDecorationType": 0,
    "miterLimit": 10,
    "startDecorationType": 0
  ]
}

func makeFill(color: Color) -> [String: Any] {
  return [
    "_class": "fill",
    "isEnabled": true,
    "color": color.toSketchJson(),
    "fillType": 0,
    "noiseIndex": 0,
    "noiseIntensity": 0,
    "patternFillType": 1,
    "patternTileScale": 1
  ]
}

// Metadata that sketch requires in their file
// I just pulled this off of my personal version of sketch
func makeMetaData() -> [String: Any] {
  return [
    "commit": "b8111e3393c4ca1f2399ecfdfc1e9488029ebe7b",
    "appVersion": "48.2",
    "build": 47327,
    "app": "com.bohemiancoding.sketch3",
    "created": [
      "app": "com.bohemiancoding.sketch3",
      "commit": "b8111e3393c4ca1f2399ecfdfc1e9488029ebe7b",
      "build": 47327,
      "appVersion": "48.2",
      "variant": "NONAPPSTORE",
      "version": 97,
      "compatibilityVersion": 93,
    ],
    "compatibilityVersion": 93,
    "version": 97,
    "saveHistory": [
      "NONAPPSTORE.47327"
    ],
    "autosaved": 0,
    "variant": "NONAPPSTORE"
  ]
}
