//
//  CALayer+SketchFactory.swift
//  Salsa
//
//  Created by Max Rabiciuc on 12/19/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import UIKit

extension CALayer {
  /// Creates a shape that matches the layer mask of the object
  func makeMaskShape() -> Shape? {
    // if theres a special layer mask then we build a shape out of that
    guard masksToBounds || mask != nil else { return nil }
    let maskLayer = mask ?? self
    return Shape(name: "Mask", backgroundColor: UIColor.clear.makeSketchColor(), path: maskLayer.shapePath.path, borderWidth: 0, borderColor: .clear, isMask: true, gradient: nil)
  }

  /// Returns a Shape representing the border of the layer
  func makeBorderShape() -> Shape? {
    let borderColor = makeSketchColor(from: self.borderColor)
    // If the border is transparent or has no width then theres no point in showing it
    guard borderColor.alpha != 0 && borderWidth != 0 else { return nil }
    return Shape(name: "Border", backgroundColor: UIColor.clear.makeSketchColor(), path: shapePath.path, borderWidth: borderWidth, borderColor: borderColor, isMask: false, gradient: nil)
  }

  /// Creates a shape that is shown in the background of the view
  /// Contains the background color of the view, the gradient of the view, and the border of the view
  func makeBackgroundShape() -> Shape? {
    let backgroundColor = makeSketchColor(from: self.backgroundColor)
    let borderColor =  makeSketchColor(from: self.borderColor)

    let gradient = gradientSublayer?.makeSketchGradient()

    // If theres no border, no background color and no gradient then theres no point in creating this shape
    guard (borderColor.alpha != 0 && borderWidth != 0) || backgroundColor.alpha != 0 || gradient != nil else { return nil }

    return Shape(name: "Background", backgroundColor: backgroundColor, path: shapePath.path, borderWidth: borderWidth, borderColor: borderColor, isMask: false, gradient: gradient)
  }
}

// MARK: fileprivate

// Awkward wrapper class because ShapePath is not available in objc
// Doing this allows us to use it in @objc methods
@objc fileprivate class ShapePathContainer: NSObject {
  let path: ShapePath
  init(path: ShapePath) { self.path = path }
}

/// Helper function for converting an optional CGColor to a sketch color
fileprivate func makeSketchColor(from color: CGColor?) -> Color {
  guard let color = color else { return .clear }
  return UIColor(cgColor: color).makeSketchColor()
}

fileprivate extension CALayer {
  // Background color to be used for generating the background shape
  @objc var sketchBackgroundColor: Color {
    return makeSketchColor(from: backgroundColor)
  }

  // Border color to be used for generating the border shape
  @objc var sketchBorderColor: Color {
    return makeSketchColor(from: borderColor)
  }

  // ShapePath representing the shape of the layer
  @objc var shapePath: ShapePathContainer {
    return ShapePathContainer(path: RectanglePath(frame: CGRect(origin: .zero, size: frame.size), cornerRadius: cornerRadius))
  }

  /// If the layer contains a gradient layer we can use that to create a sketch gradient
  var gradientSublayer: CAGradientLayer? {
    if let gradientLayer = self as? CAGradientLayer {
      return gradientLayer
    }
    guard let sublayers = sublayers else { return nil }
    for layer in sublayers {
      if let gradientLayer = layer as? CAGradientLayer, !layer.isHidden {
        return gradientLayer
      }
    }
    return nil
  }
}

fileprivate extension CAGradientLayer {
  /// Converts a CAGradientLayer into a sketch gradient
  func makeSketchGradient() -> Gradient? {
    guard let cgColors = self.colors as? [CGColor] else { return nil }
    let locations: [CGFloat] = {
      if let locations = self.locations as? [CGFloat] {
        return locations
      } else {
        return cgColors.enumerated().map { index, _ in
          CGFloat(index) / CGFloat(cgColors.count - 1)
        }
      }
    }()
    let colors: [Color] = cgColors.map { UIColor(cgColor: $0).makeSketchColor() }
    return Gradient(colors: colors, locations: locations, start: startPoint, end: endPoint)
  }
}

fileprivate extension CAShapeLayer {
  @objc override var sketchBackgroundColor: Color {
    return makeSketchColor(from: fillColor)
  }

  @objc override var sketchBorderColor: Color {
    return makeSketchColor(from: strokeColor)
  }

  @objc override var shapePath: ShapePathContainer {
    guard let path: CGPath = self.path else { return super.shapePath }
    return ShapePathContainer(path: BezierPath(path: path.offset(by: CGPoint(x: -frame.origin.x, y: -frame.origin.y))))
  }
}


