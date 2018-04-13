//
//  UIFont+Utils.swift
//  Salsa
//
//  Created by Max Rabiciuc on 10/26/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import UIKit

public extension UIFont {
  /// Converts the name of the font as it appears in iOS to a name that Sketch can understand
  public var sketchCompatibleName: String {
    var fontName = self.fontName
    // System fonts on iOS are prefixed with .SFUI but on macOS the prefix is SFPro
    // We update the name or else sketch won't understand the font name
    fontName = fontName.replacingOccurrences(of: ".SFUI", with: "SFPro")

    // It seems the official names for these fonts on macOS have a -Regular in them but on iOS they don't
    // So we append -Regular to make sure we can instantiate them properly in Sketch
    if fontName == "SFProText" {
      fontName = "SFProText-Regular"
    } else if fontName == "SFProDisplay" {
      fontName = "SFProDisplay-Regular"
    }
    return fontName
  }
}

extension Text.Style {
  public init(font: UIFont, color: Color = UIColor.black.makeSketchColor(), alignment: Alignment = .left, isUnderlined: Bool = false) {
    self.init(fontDescriptor: font.sketchCompatibleName, fontSize: font.pointSize, color: color, alignment: alignment, isUnderlined: isUnderlined)
  }
}

