//
//  MKMapView+SketchFactory.swift
//  Salsa
//
//  Created by Max Rabiciuc on 11/6/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import MapKit

extension MKMapView {
  /// Overrides contentLayers to provide a screenshot of the map
  @objc override func contentLayers() -> [Layer] {
    return [mapImage()].compactMap { $0 }
  }

  /// Overrides childLayers to filter which subviews should be rendered
  @objc override func childLayers() -> [Layer] {
    return filteredSubviews.map { $0.makeSketchGroup() }
  }

  private var filteredSubviews: [UIView] {
    let annotationView = findChild(withTypeName: "MKNewAnnotationContainerView")
    let filtered = subviews.filter { String(describing: type(of: $0)) != "_MKMapContentView" && !$0.isHidden }
    return filtered + [annotationView].compactMap { $0 }
  }

  private func mapImage() -> Bitmap? {
    // MKBasicMapView is a subview that contains just the map without any annotations
    guard let basicMapView = findChild(withTypeName: "MKBasicMapView") else { return nil }
    // save a snapshot of the map view as an image, other subviews can be exported like normal
    guard let fileName = basicMapView.screenshotImage?.saveToDisk() else { return nil }
    return Bitmap(fileName: fileName, frame: CGRect(origin: .zero, size: frame.size))
  }

}

private extension UIView {
  func findChild(withTypeName name: String) -> UIView? {
    guard String(describing: type(of: self)) != name else { return self }
    for subview in subviews {
      if let view = subview.findChild(withTypeName: name) {
        return view
      }
    }
    return nil
  }
}

