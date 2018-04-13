//
//  UIToolbar+SketchFactory.swift
//  Salsa
//
//  Created by Max Rabiciuc on 12/6/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import UIKit

public extension UIToolbar {
  private func backgroundSnapshot() -> Bitmap? {
    let image = backgroundImage(forToolbarPosition: .any, barMetrics: .default)
    guard let path = image?.saveToDisk() else { return nil }
    return Bitmap(fileName: path, frame: bounds)
  }

  /// Overrides contentLayers to provide a background image
  @objc override func contentLayers() -> [Layer] {
    return [backgroundSnapshot()].compactMap { $0 }
  }
}

