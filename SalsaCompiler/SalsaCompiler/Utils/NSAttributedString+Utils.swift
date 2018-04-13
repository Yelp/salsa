//
//  NSAttributedString+Utils.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 10/26/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Cocoa

extension NSAttributedString {
  /// Attempts to find a size that will fit into the given size.
  /// The returned size is not guaranteed to be smaller than the given size.
  func size(fitting size: CGSize) -> CGSize {
    // It appears iOS and Sketch allow text to go over its bounds by 1px so we add 1 to width and height
    let boundingRect = self.boundingRect(with: CGSize(width: size.width + 1.01, height: size.height + 1.01), options: .usesLineFragmentOrigin)

    // Split the string into individual lines
    let lines = splitIntoLines(forWidth: boundingRect.width, height: boundingRect.height)

    // Measure each line's height and width and put them together
    return lines.reduce(.zero, { size, line in
      let height = size.height + line.lineHeight
      let width = max(size.width, line.size().width)
      return CGSize(width: width, height: height)
    })
  }

  var lineHeight: CGFloat {
    // We can't size the string without a font
    guard string.count > 0, let font = fontAttributes(in: NSMakeRange(0, string.count))[.font] as? NSFont else { return size().height }
    return font.ascender + abs(font.descender) + font.leading
  }

  func fits(size: CGSize) -> Bool {
    let height = self.size(fitting: CGSize(width: size.width, height: .greatestFiniteMagnitude)).height
    return size.height >= height
  }

  /// Returns a string truncated to fit the given size.
  /// Note: the given size must be taller than one line of text.
  func truncated(toFit size: CGSize) -> NSAttributedString {
    var size = size
    // if the size is less than one line, then adjust the size to fit one line so we can truncate properly
    if size.height < lineHeight {
      size.height = lineHeight
    }

    guard !fits(size: size) else { return self }

    // Lines if the string wasn't height bound
    let nonTruncatedLines = splitIntoLines(forWidth: size.width, keepNewlines: true)
    // Lines if we bind the height
    let truncatedLines = splitIntoLines(forWidth: size.width, height: size.height, keepNewlines: true)

    // If the number of lines match and the last line has the same amount of character that means the entire string fits into the bounds
    if nonTruncatedLines.count == truncatedLines.count && nonTruncatedLines.last?.string.count == truncatedLines.last?.string.count { return self }

    // If there is no last line then just return an an elipses
    guard let lastLine = truncatedLines.last else { return  NSAttributedString(string: "…", attributes: attributes(at: 0, effectiveRange: nil)) }

    // Figure out where the last line needs to be truncated
    let lastLineTruncated: NSAttributedString = {
      var count = lastLine.string.count
      // Keep popping off the last character and appending an elipses until the last line fits the given width
      while (count > 0) {
        let attributed = NSMutableAttributedString(attributedString: lastLine.attributedSubstring(from: NSRange(location: 0, length: count)).trimmingTrailingSpaces())
        let elipses = NSAttributedString(string: "…", attributes: lastLine.attributes(at: count - 1, effectiveRange: nil))
        attributed.append(elipses)
        if attributed.size().width <= size.width {
          return attributed
        }
        count -= 1
      }
      // If last line doesn't fit even with 0 characters we just return an elipses
      return NSAttributedString(string: "…", attributes: lastLine.attributes(at: 0, effectiveRange: nil))
    }()

    // Put the lines back together into one string
    let truncatedString = NSMutableAttributedString()
    truncatedLines.dropLast().forEach { truncatedString.append($0) }
    truncatedString.append(lastLineTruncated)

    return truncatedString
  }
}


