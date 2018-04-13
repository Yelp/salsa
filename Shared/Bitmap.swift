//
//  Bitmap.swift
//  Salsa
//
//  Created by Max Rabiciuc on 9/20/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation
import CoreGraphics

/// Represents an image in Sketch.
public class Bitmap: Layer {
  /// References the name of an image thats stored in `SalsaConfig.imageExportDirectory`.
  /// Should not contain the file type. i.e. use "image" instead of "image.png"
  public let fileName: String

  /// Overrides the `Color` of the images, works the same way as setting `tintColor` on `UIImageView` on iOS
  public let tintColor: Color?

  /**
   Constructs a Sketch representation of a Bitmap layer
   - parameter fileName:      References the name of an image thats stored in `SalsaConfig.imageExportDirectory`.
   - parameter frame:         Frame of the Bitmap inside its parent container
   - parameter tintColor:     Overrides the `Color` of the images, works the same way as setting `tintColor` on `UIImageView` on iOS
   */
  init(fileName: String, frame: CGRect, tintColor: Color? = nil) {
    self.fileName = fileName
    if fileName.contains(".") {
      assertionFailure("file names should not include the file type")
    }
    self.tintColor = tintColor
    super.init(name: "Image", frame: frame)
  }

  public required init?(json: [String : Any]) {
    guard let fileName = json["fileName"] as? String else { return nil }
    self.fileName = fileName
    self.tintColor = {
      guard let tintColorJson = json["tintColor"] as? [String: Any] else { return nil }
      return Color(json: tintColorJson)
    }()
    super.init(json: json)
  }

  override public func toJson() -> [String: Any] {
    var json = super.toJson()
    json["fileName"] = fileName
    if let tintColor = tintColor {
      json["tintColor"] = tintColor.toJson()
    }
    return json
  }
}

