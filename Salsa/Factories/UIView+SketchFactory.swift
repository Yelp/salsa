//
//  UIView+SketchFactory.swift
//  Salsa
//
//  Created by Max Rabiciuc on 9/19/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import UIKit

extension UIView {
  /// The name that will be given to groups representing this view.
  /// Override to provide custom names for your views in Sketch
  @objc open var sketchName: String { return "View" }

  /// Creates a `Group` that mirrors the layout of the view
  @objc public func makeSketchGroup() -> Group {
    return makeSketchGroup(name: sketchName)
  }

  /// Creates a Group that mirrors the layout of the view
  @objc fileprivate func makeSketchGroup(name: String) -> Group {

    // Custom sublayers of the view's layer
    let customLayers: [Layer] = self.customLayers.compactMap { $0.makeBackgroundShape() }

    // These go below everything
    let backgroundLayers: [Layer] = [layer.makeMaskShape(), layer.makeBackgroundShape()].compactMap { $0 }

    // Goes above everything
    let borderLayer: [Layer] = [layer.makeBorderShape()].compactMap { $0 }

    let layers: [Layer] = [backgroundLayers, customLayers, contentLayers(), childLayers(), borderLayer].flatMap { $0 }
    return Group(frame: normalizedFrame, layers: layers, alpha: alpha, name: name, shadow: makeShadow())
  }

  /// Represent the content of the view.
  /// Overriden by views that want to render their own content, like image views labels and maps
  @objc func contentLayers() -> [Layer] {
    return [makeSnapshotBitmapIfNeeded()].compactMap { $0 }
  }

  /// Child layers of the view
  /// Can be overriden for custom behavior
  @objc func childLayers() -> [Layer] {
    return subviews.compactMap {
      if $0.isHidden { // ignore hidden views
        return nil
      } else if let subview = $0 as? SketchNestable { // if a view is SketchNestable then we use the nested symbol for that view instead
        return subview.nestedSymbol()
      } else {
        // Recursively build groups for all the subviews
        return $0.makeSketchGroup()
      }
    }
  }

  /// Returns a frame thats been adjusted for transforms and scroll view offsets
  private var normalizedFrame: CGRect {
    var x = frame.left + transform.tx
    var y = frame.top + transform.ty
    // UIScrollView adjusts the origin of something without changing its frame so if our superview is a UIScrollView we need to tweak our origin
    if let scrollView = superview as? UIScrollView {
      x -= scrollView.contentOffset.x
      y -= scrollView.contentOffset.y
    }
    return CGRect(origin: CGPoint(x: x, y: y), size: frame.size)
  }

  /// Detects if the view is drawRected.
  /// If the view is drawRected it will create a Bitmap that represents a screenshot of the view
  private func makeSnapshotBitmapIfNeeded() -> Bitmap? {
    guard isDrawRected && !frame.isEmpty else { return nil }
    guard let fileName = screenshotImage?.saveToDisk() else { return nil }
    return Bitmap(fileName: fileName, frame: CGRect(origin: .zero, size: frame.size))
  }

  /// CALayers that are not owned by subviews
  private var customLayers: [CALayer] {
    var subviewLayers = Set<CALayer>()
    subviews.forEach { subviewLayers.insert($0.layer) }
    return (layer.sublayers?.filter { !subviewLayers.contains($0) && !$0.isHidden }) ?? []
  }

  /// Creates a shadow object if one exists on the view
  private func makeShadow() -> Shadow? {
    guard let cgColor = layer.shadowColor else { return nil }
    let color = UIColor(cgColor: cgColor).makeSketchColor()
    // Sketch has no shadowOpacity field for the shadow so we combine the color alpha with the shadowOpacity
    let alpha = color.alpha * CGFloat(layer.shadowOpacity)
    // if the shadow is transparent then theres no point in rendering it
    guard alpha != 0 else { return nil }

    return Shadow(
      radius: layer.shadowRadius,
      offset: CGPoint(x: layer.shadowOffset.width, y: layer.shadowOffset.height),
      color: Color(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha * CGFloat(layer.shadowOpacity))
    )
  }

}

