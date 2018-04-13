//
//  ShapePath+SketchJson.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 12/6/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation

extension SketchJsonConvertable where Self: Layer, Self: ShapePath {
  func pathJson() -> [String: Any] {
    let points: [[String: Any]] = []
    let transformedCurvePoints: [CurvePoint] = curvePoints.map {
      func transform(_ point: CGPoint?) -> CGPoint? {
        guard let point = point else { return nil }
        return CGPoint(x: (point.x - frame.origin.x) / frame.size.width, y: (point.y - frame.origin.y) / frame.size.height)
      }
      return CurvePoint(point: transform($0.point)!, curveFrom: transform($0.curveFrom), curveTo: transform($0.curveTo), curveMode: $0.curveMode, cornerRadius: $0.cornerRadius)
    }

    return [
      "_class": "path",
      "isClosed": isClosed,
      "pointRadiusBehaviour": 1,
      "points": transformedCurvePoints.map { $0.toSketchJson() },
    ]
  }

  fileprivate func sharedSketchJson() -> [String: Any] {
    return [
      "frame": CGRect(origin: .zero, size: frame.size).toSketchJson(),
      "booleanOperation": -1,
      "edited": true,
      "path": pathJson(),
    ]
  }
}

extension BezierPath {
  override func toSketchJson() -> [String : Any] {
    return super.toSketchJson().merging(with: sharedSketchJson()).merging(with: [
      "_class": "shapePath",
    ])
  }
}

extension RectanglePath {
  override func toSketchJson() -> [String : Any] {
    return super.toSketchJson().merging(with: sharedSketchJson()).merging(with: [
      "_class": "rectangle",
      "fixedRadius": cornerRadius,
      "hasConvertedToNewRoundCorners": true
    ])
  }
}

extension CurvePoint {
  func toSketchJson() -> [String : Any] {
    return [
      "_class": "curvePoint",
      "cornerRadius": cornerRadius,
      "curveFrom": sketchRepresentation(of: curveFrom ?? point),
      "curveMode": curveMode.rawValue,
      "curveTo": sketchRepresentation(of: curveTo ?? point),
      "hasCurveFrom": curveFrom != nil,
      "hasCurveTo": curveTo != nil,
      "point": sketchRepresentation(of: point)
    ]
  }

  func sketchRepresentation(of point: CGPoint) -> String {
    return "{\(point.x), \(point.y)}"
  }
}

