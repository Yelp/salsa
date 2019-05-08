//
//  SharedUtils.swift
//  Salsa
//
//  Created by Max Rabiciuc on 10/4/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import CoreGraphics
import CoreText
import Foundation

extension CGPath {
  /// Returns true if the given path is entirely contained inside of self
  func contains(path: CGPath) -> Bool {
    // Can't contain something if its boundingBox is larger than our boundingBox
    if path.boundingBox.contains(rect: boundingBox) {
      return false
    }
    var x = min(path.boundingBox.left, boundingBox.left)
    let maxX = max(path.boundingBox.right, boundingBox.right)
    var y = min(path.boundingBox.top, boundingBox.top)
    let maxY = max(path.boundingBox.bottom, boundingBox.bottom)

    // This is very archaic but its apparently the only way to do this
    // Go through every point in the two paths and see if points contained by the inner path are also contained by the outer path
    while y < maxY {
      while x < maxX {
        let point = CGPoint(x: x, y: y)
        // inner path contains the point but outer path doesn't
        if path.contains(point) && !contains(point) {
          return false
        }
        x+=1
      }
      y+=1
    }
    return true
  }

  // Allows us to iterate through the operations of a CGPath
  // taken from https://stackoverflow.com/questions/12992462/how-to-get-the-cgpoints-of-a-cgpath
  func forEach(body: @escaping @convention(block) (CGPathElement) -> Void) {
    typealias Body = @convention(block) (CGPathElement) -> Void
    let callback: @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CGPathElement>) -> Void = { info, element in
      let body = unsafeBitCast(info, to: Body.self)
      body(element.pointee)
    }
    let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
    self.apply(info: unsafeBody, function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
  }

  // Returns a CGPath whose points are offset by the given amount
  func offset(by point: CGPoint) -> CGPath {
    var transform = CGAffineTransform(translationX: point.x, y: point.y)
    return copy(using: &transform)!
  }
}

fileprivate extension CGRect {
  /// Returns true if the given rect is entirely contained inside of self
  func contains(rect: CGRect) -> Bool {
    return rect.top > top && rect.left > left && rect.bottom > bottom && rect.right < right
  }
}

extension Dictionary {
  mutating func merge(with other: Dictionary) {
    for (key, value) in other {
      updateValue(value, forKey: key)
    }
  }

  func merging(with other: Dictionary) -> Dictionary {
    var ret = self
    ret.merge(with: other)
    return ret
  }

  init(_ elements: [Element]) {
    self.init()
    elements.forEach { self[$0] = $1 }
  }
}

extension NSAttributedString {
  /// Helper for splitting an attributed string up into lines
  /// Modified solution from https://stackoverflow.com/questions/4421267/how-to-get-text-from-nth-line-of-uilabel
  func splitIntoLines(forWidth width: CGFloat, height: CGFloat = .greatestFiniteMagnitude, keepNewlines: Bool = false) -> [NSAttributedString] {
    let frameSetter: CTFramesetter = CTFramesetterCreateWithAttributedString(self as CFAttributedString)
    let path = CGMutablePath()
    path.addRect(CGRect(x: 0, y: 0, width: width, height: height))

    let frame: CTFrame = CTFramesetterCreateFrame(frameSetter, CFRange(), path, nil)
    // Can't do a simple 'as' here but this cast never fails. Guard is just here to make the code pretty
    guard let lines = CTFrameGetLines(frame) as? [CTLine] else { return [] }
    return lines.map {
      let lineRange = CTLineGetStringRange($0)
      let lineString = attributedSubstring(from: NSRange(location: lineRange.location, length: lineRange.length))
      // CTFrameGetLines leaves the newline character at the end of the line.
      // We might want to strip this
      if lineString.string.last == "\n" && !keepNewlines {
        return attributedSubstring(from: NSRange(location: lineRange.location, length: lineRange.length - 1))
      }
      return lineString
    }
  }

  func trimmingTrailingSpaces() -> NSAttributedString {
    let mutableString = NSMutableAttributedString(attributedString: self)
    mutableString.trimTrailingSpaces()
    return mutableString
  }
}


extension NSMutableAttributedString {
  func trimTrailingSpaces() {
    while string.last == " " {
      deleteCharacters(in: NSRange(location: string.count - 1, length: 1))
    }
  }
}

