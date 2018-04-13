//
//  ShapePath.swift
//  Salsa
//
//  Created by Max Rabiciuc on 12/6/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import CoreGraphics

/// Protocol for representing shapes in Sketch
protocol ShapePath: class, JSONDictEncodable, SketchJsonConvertable {
  var cgPath: CGPath { get }
  var curvePoints: [CurvePoint] { get }
  var isClosed: Bool { get }
}

extension ShapePath {
  // This is kind of awkward
  // We do this because RectanglePath and BezierPath's conformance to this is provided only in extensions in the SalsaCompiler target
  func toSketchJson() -> [String: Any] { return [:] }

  var boundingBox: CGRect {
    return cgPath.boundingBox
  }
}

// A type that mirrors the Sketch representation of a point in a bezier curve
struct CurvePoint {
  var point: CGPoint
  var curveFrom: CGPoint?
  var curveTo: CGPoint?
  var curveMode: CurveMode
  var cornerRadius: CGFloat

  enum CurveMode: Int {
    case linear = 1
    case cubic = 2
  }
}

/// Constructs a concrete `ShapePath` given a valid json dict
func makeShapePath(json: [String: Any]) -> ShapePath? {
  let types: [ShapePath.Type] = [RectanglePath.self, BezierPath.self]
  var typeMap: [String: ShapePath.Type] = [:]
  types.forEach { typeMap[String(describing: $0)] = $0 }
  guard let typeString = json["_type"] as? String, let shapeLayerType = typeMap[typeString] else { return nil }
  return shapeLayerType.init(json: json)
}

/// Represents rectangular shapes with rounded corners
public class RectanglePath: Layer  {
  let cornerRadius: CGFloat

  public init(frame: CGRect, cornerRadius: CGFloat) {
    self.cornerRadius = cornerRadius
    super.init(name: "Rounded Rect", frame: frame)
  }

  required public init?(json: [String : Any]) {
    guard let cornerRadius = json["cornerRadius"] as? CGFloat else { return nil }
    self.cornerRadius = cornerRadius
    var json = json
    if json["name"] == nil {
      json["name"] = "Rounded Rect"
    }
    super.init(json: json)
  }

  override func toJson() -> [String : Any] {
    return super.toJson().merging(with: [
      "cornerRadius": cornerRadius
      ])
  }
}

extension RectanglePath: ShapePath {
  var isClosed: Bool { return true }

  var cgPath: CGPath {
    return CGPath(roundedRect: frame, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
  }

  var curvePoints: [CurvePoint] {
    let frame = self.frame
    return [
      CurvePoint(point: CGPoint(x: frame.minX, y: frame.minY), curveFrom: nil, curveTo: nil, curveMode: .linear, cornerRadius: self.cornerRadius),
      CurvePoint(point: CGPoint(x: frame.maxX, y: frame.minY), curveFrom: nil, curveTo: nil, curveMode: .linear, cornerRadius: self.cornerRadius),
      CurvePoint(point: CGPoint(x: frame.maxX, y: frame.maxY), curveFrom: nil, curveTo: nil, curveMode: .linear, cornerRadius: self.cornerRadius),
      CurvePoint(point: CGPoint(x: frame.minX, y: frame.maxY), curveFrom: nil, curveTo: nil, curveMode: .linear, cornerRadius: self.cornerRadius),
    ]
  }
}

/// Represents Path layer in Sketch
public class BezierPath: Layer {
  /// List of path operations meant to represent the given BezierPath
  let operations: [PathOperation]

  /// Constructs a BezierPath from the given `CGPath`
  public init(path: CGPath) {
    var operations: [PathOperation] = []
    path.forEach { element in
      switch element.type {
      case .moveToPoint:
        operations.append(.move(point: element.points[0]))
      case .addLineToPoint:
        operations.append(.line(point: element.points[0]))
      case .addQuadCurveToPoint:
        operations.append(.quadCurve(point: element.points[1], control: element.points[0]))
      case .addCurveToPoint:
        operations.append(.cubicCurve(point: element.points[2], control1: element.points[0], control2: element.points[1]))
      case .closeSubpath:
        guard let first = operations.first else { return }
        operations.append(.line(point: first.points.first!))
      }
    }
    self.operations = operations
    super.init(name: "Path", frame: path.boundingBox)
  }

  // Overrides

  required public init?(json: [String : Any]) {
    operations = {
      guard let points = json["operations"] as? [[String: Any]] else { return [] }
      return points.compactMap { PathOperation(json: $0) }
    }()
    super.init(json: json)
  }

  override func toJson() -> [String: Any] {
    return super.toJson().merging(with: [
      "operations": operations.map { $0.toJson() }
    ])
  }
}

extension BezierPath: ShapePath {

  var curvePoints: [CurvePoint] {
    // Conversion to Sketch CurvePoints taken from here: https://github.com/airbnb/Lona/blob/master/LonaStudio/Utils/Sketch.swift
    var curvePoints: [CurvePoint] = []
    self.operations.forEach { operation in
      switch operation {
      case let .move(point):
        curvePoints.append(CurvePoint(point: point, curveFrom: nil, curveTo: nil, curveMode: .linear, cornerRadius: 0))
      case let .line(point):
        curvePoints.append(CurvePoint(point: point, curveFrom: nil, curveTo: nil, curveMode: .linear, cornerRadius: 0))
      case let .quadCurve(point, control):
        if var last = curvePoints.last {
          let startPoint = last.point
          // sketch doesn't have quad curves so we make a cubic curve out of the quad curve
          let control1 = CGPoint(x: startPoint.x + (2.0/3.0) * (control.x - startPoint.x), y: startPoint.y + (2.0/3.0) * (control.y - startPoint.y))
          let control2 = CGPoint(x: point.x + (2.0/2.0) * control.x - point.x, y: point.y + (2.0/2.0) * control.y - point.y)

          last.curveFrom = control1
          last.curveMode = .cubic
          curvePoints[curvePoints.count - 1] = last
          curvePoints.append(CurvePoint(point: point, curveFrom: nil, curveTo: control2, curveMode: .cubic, cornerRadius: 0))
        }
      case let .cubicCurve(point, control1, control2):
        if var last = curvePoints.last {
          last.curveFrom = control1
          last.curveMode = .cubic
          curvePoints[curvePoints.count - 1] = last
          curvePoints.append(CurvePoint(point: point, curveFrom: nil, curveTo: control2, curveMode: .cubic, cornerRadius: 0))
        }
      }
    }

    // Sketch shapes have their points in the reverse order so we reverse the array to make things match
    return curvePoints.reversed().map({ curvePoint in
      var curvePoint = curvePoint
      let temp = curvePoint.curveFrom
      curvePoint.curveFrom = curvePoint.curveTo
      curvePoint.curveTo = temp
      return curvePoint
    })
  }

  /// Creates a CGPath equivalent to the given BezierPath
  public var cgPath: CGPath {
    let path = CGMutablePath()
    operations.forEach { operation in
      switch operation {
      case let .move(point):
        path.move(to: point)
      case let .line(point):
        path.addLine(to: point)
      case let .quadCurve(point, control):
        path.addQuadCurve(to: point, control: control)
      case let .cubicCurve(point, control1, control2):
        path.addCurve(to: point, control1: control1, control2: control2)
      }
    }
    return path
  }

  /// Wether the first and last points in the path are equal to eachother
  public var isClosed: Bool {
    return operations.first?.point == operations.last?.point
  }
}

extension BezierPath {
  /// Json encodable type for representing an individual operation in a bezier curve
  enum PathOperation: JSONDictEncodable {
    /// Move to a point without drawing a line
    case move(point: CGPoint)
    /// Draw a straight line to a new point
    case line(point: CGPoint)
    /// Draw a quadratic curve to the point
    case quadCurve(point: CGPoint, control: CGPoint)
    /// Draw a cubic curve to the point
    case cubicCurve(point: CGPoint, control1: CGPoint, control2: CGPoint)

    var points: [CGPoint] {
      switch self {
      case let .move(point): return [point]
      case let .line(point): return [point]
      case let .quadCurve(point, control): return [point, control]
      case let .cubicCurve(point, control1, control2): return [point, control1, control2]
      }
    }

    var point: CGPoint {
      switch self {
      case let .move(point): return point
      case let .line(point): return point
      case let .quadCurve(point, _): return point
      case let .cubicCurve(point, _, _): return point
      }
    }

    init?(json: [String: Any]) {
      guard let type = json["type"] as? String  else { return nil }
      let points = (json["points"] as? [[String: Any]] ?? []).compactMap { CGPoint(json: $0) }

      switch type {
      case "move":
        guard points.count >= 1 else { return nil }
        self = .move(point: points[0])
      case "line":
        guard points.count >= 1 else { return nil }
        self = .line(point: points[0])
      case "quadCurve":
        guard points.count >= 2 else { return nil }
        self = .quadCurve(point: points[0], control: points[1])
      case "cubicCurve":
        guard points.count >= 3 else { return nil }
        self = .cubicCurve(point: points[0], control1: points[1], control2: points[2])
      default:
        return nil
      }
    }

    func toJson() -> [String: Any] {
      let type: String = {
        switch self {
        case .move: return "move"
        case .line: return "line"
        case .quadCurve: return "quadCurve"
        case .cubicCurve: return "cubicCurve"
        }
      }()
      return [
        "type": type,
        "points": points.map { $0.toJson() }
      ]
    }
  }
}

