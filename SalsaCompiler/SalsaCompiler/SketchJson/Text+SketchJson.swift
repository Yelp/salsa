//
//  Text+SketchJson.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 9/15/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Cocoa

extension Text {
  override func toSketchJson() -> [String: Any] {
    guard let firstSegment = segments.first else {
      exit(withMessage: "Can't initialize text with no text segments")
    }
    var constraints: [ResizingConstraint] = {
      switch firstSegment.style.alignment {
      case .left: return [.left]
      case .right: return [.right]
      case .center: return []
      }
    }()

    if wrapText {
      constraints += [.height, .width]
    }

    let textFrame = self.textFrame

    return super.toSketchJson().merging(with: [
      "_class": "text",
      "resizingConstraint": ResizingConstraint.makeConstraint(with: constraints),
      "resizingType": 3,
      "attributedString": attributedStringJson(),
      "automaticallyDrawOnUnderlyingPath": false,
      "dontSynchroniseWithSymbol": false,
      "glyphBounds": "{{0, 0}, {\(textFrame.size.width), \(textFrame.size.height)}}",
      "heightIsClipped": false,
      "lineSpacingBehaviour": 2,
      "textBehaviour": wrapText ? 1 : 0,
      "style": firstSegment.style.toSketchJson(),
      "frame": textFrame.toSketchJson()
    ])
  }

  // Creates a frame hugs it's text vertically
  // On both iOS and android if a label is larger than it's text then the text gets centered inside its label
  // However sketch decides to pin the text to the top of the label
  // This is inconsistent so we center the text inside its given frame to make sure things look correct
  var textFrame: CGRect {
    guard let firstSegment = segments.first else { return frame }
    let size = attributedString.size(fitting: frame.size)
    let heightDelta = frame.size.height - size.height
    let y = frame.top + heightDelta / 2

    // Its possible that the returned size is slightly wider than our frame, if thats the case then we adjust the value of x
    let x: CGFloat = {
      guard size.width > frame.size.width || !wrapText else { return frame.left }
      switch firstSegment.style.alignment {
      case .left: return frame.left
      case .center: return frame.left + (frame.size.width - size.width) / 2
      case .right: return frame.left + frame.width - size.width
      }
    }()

    let width: CGFloat = wrapText ? max(size.width, frame.size.width) : size.width

    return CGRect(x: x, y: y, width:  width, height: size.height)
  }

  var attributedString: NSAttributedString {
    let string = NSMutableAttributedString(string: segments.text)
    var index = 0
    segments.forEach { segment in
      let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
      paragraphStyle.alignment = segment.style.alignment.nsTextAlignment()
      guard let font = NSFont(name: segment.style.fontDescriptor, size: segment.style.fontSize) else {
        exit(withMessage: "Could not find font: \(segment.style.fontDescriptor)")
      }

      // Sketch creates attributed strings with a custom attribute for font
      // They use a NSFontDescriptor instead of an NSFont
      // They use a special key for this attribute: MSAttributedStringFontAttribute
      // Using NSFont still works and the string will still render, but font data is not loaded into the sidebar when NSFont is used instead of an NSFontDescriptor
      string.setAttributes([
        NSAttributedStringKey(rawValue: "MSAttributedStringFontAttribute"): font.fontDescriptor,
        .font: font,
        .foregroundColor: segment.style.color.toNSColor(),
        .paragraphStyle: paragraphStyle,
        .kern: font.sketchKern(),
        .underlineStyle: segment.style.isUnderlined ? NSUnderlineStyle.styleSingle.rawValue : NSUnderlineStyle.styleNone.rawValue,
      ], range: NSMakeRange(index, segment.text.count))
      index += segment.text.count
    }
    return string.truncated(toFit: frame.size)
  }

  func attributedStringJson() -> [String: Any] {
    // The attributed string json stores an encoded NSAttributedString
    let encodedString = NSKeyedArchiver.archivedData(withRootObject: attributedString.copy()).base64EncodedString()
    return [
      "_class": "MSAttributedString",
      "archivedAttributedString": [
        "_archive": encodedString
      ]
    ]
  }
}

extension Text.Style: SketchJsonConvertable {
  func toSketchJson() -> [String: Any] {
    let font = NSFont(name: fontDescriptor, size: fontSize)!
    let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = alignment.nsTextAlignment()

    var json: [String: Any] = [
      "_class": "style",
      "endDecorationType": 0,
      "miterLimit": 10,
      "startDecorationType": 0,
      "textStyle": [
        "_class": "textStyle",
        "encodedAttributes": [
          "MSAttributedStringFontAttribute": [
            "_archive": encode(font.fontDescriptor)
          ],
          "NSKern": font.sketchKern(),
          "NSColor": [
            "_archive": encode(color.toNSColor())
          ],
          "NSParagraphStyle": [
            "_archive": encode(paragraphStyle)
          ]
        ],
        "verticalAlignment": 1
      ]
    ]

    if let identifier = IdentifierStore.identifier(forTextStyle: self) {
      json["sharedObjectID"] = identifier
    }

    return json
  }

  func encode(_ obj: Any) -> String {
    return NSKeyedArchiver.archivedData(withRootObject: obj).base64EncodedString()
  }
}

extension NSFont {
  func sketchKern() -> CGFloat {
    // iOS renders it's system font spacing differently from MacOS
    // These kerning numbers were computed programatically
    // I took a very large string and sized it on iOS
    // Then I took the same string and iterated through its size on macOS by increasing the kerning by 0.001 at each iteration until the macOS size matched the iOS size
    // I did this for every point size from 6 to 79
    if fontName.hasPrefix("SFProText") {
      switch pointSize {
      case 6: return  0.241
      case 7: return  0.23
      case 8: return  0.204
      case 9: return  0.167
      case 10: return 0.118
      case 11: return 0.065
      case 12: return 0
      case 13: return -0.075
      case 14: return -0.149
      case 15: return -0.233
      case 16: return -0.311
      case 17: return -0.389
      case 18: return -0.429
      case 19: return -0.481
      default: return 0
      }
    } else if fontName.hasPrefix("SFProDisplay") {
      switch pointSize {
      case 20: return 0.362
      case 21: return 0.349
      case 22: return 0.344
      case 23: return 0.349
      case 24: return 0.352
      case 25: return 0.355
      case 26: return 0.356
      case 27: return 0.356
      case 28: return 0.356
      case 29: return 0.355
      case 30: return 0.367
      case 31: return 0.364
      case 32: return 0.375
      case 33: return 0.371
      case 34: return 0.382
      case 35: return 0.376
      case 36: return 0.387
      case 37: return 0.38
      case 38: return 0.372
      case 39: return 0.381
      case 40: return 0.372
      case 41: return 0.381
      case 42: return 0.37
      case 43: return 0.378
      case 44: return 0.366
      case 45: return 0.352
      case 46: return 0.36
      case 47: return 0.345
      case 48: return 0.352
      case 49: return 0.335
      case 50: return 0.342
      case 51: return 0.324
      case 52: return 0.305
      case 53: return 0.311
      case 54: return 0.291
      case 55: return 0.296
      case 56: return 0.274
      case 57: return 0.279
      case 58: return 0.255
      case 59: return 0.231
      case 60: return 0.235
      case 61: return 0.209
      case 62: return 0.212
      case 63: return 0.185
      case 64: return 0.188
      case 65: return 0.159
      case 66: return 0.162
      case 67: return 0.131
      case 68: return 0.133
      case 69: return 0.135
      case 70: return 0.103
      case 71: return 0.105
      case 72: return 0.106
      case 73: return 0.072
      case 74: return 0.073
      case 75: return 0.037
      case 76: return 0.038
      case 77: return 0.038
      case 78: return 0.001
      case 79: return 0.001
      default: return 0
      }
    }
    return 0
  }
}

extension Text.Style.Alignment {
  func nsTextAlignment() -> NSTextAlignment {
    switch self {
    case .left:
      return .left
    case .center:
      return .center
    case .right:
      return .right
    }
  }
}

extension Text.SharedStyle: SketchJsonConvertable {
  func toSketchJson() -> [String: Any] {
    guard let id = IdentifierStore.identifier(forTextStyle: textStyle) else {
      exit(withMessage: "Failed to get identifier for shared style named: \(name)")
    }
    return [
      "_class": "sharedStyle",
      "do_objectID": id,
      "name": name,
      "value": textStyle.toSketchJson()
    ]
  }
}

extension Text.Style: Hashable {
  public var hashValue: Int {
    // even though theres more properties, we only want to hash the font and the size
    return "font:\(fontDescriptor) size:\(fontSize)".hashValue
  }
}

public func == (lhs: Text.Style, rhs: Text.Style) -> Bool {
  return
    lhs.fontDescriptor == rhs.fontDescriptor &&
      lhs.fontSize == rhs.fontSize &&
      lhs.color == rhs.color &&
      lhs.alignment == rhs.alignment
}

public func == (lhs: Color, rhs: Color) -> Bool {
  return
    lhs.red == rhs.red &&
      lhs.green == rhs.green &&
      lhs.blue == rhs.blue &&
      lhs.alpha == rhs.alpha
}

extension Color {
  func toNSColor() -> NSColor {
    return NSColor(red: red, green: green, blue: blue, alpha: alpha)
  }
}

