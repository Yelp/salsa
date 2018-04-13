//
//  UILabel+SketchFactory.swift
//  Salsa
//
//  Created by Max Rabiciuc on 9/19/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import UIKit
import CoreText

extension UILabel {
  /// Overriding to provide text content
  @objc override func contentLayers() -> [Layer] {
    let views = equivalentViews()
    if views.count == 1 {
      return [makeSketchText()].compactMap { $0 }
    }
    return views.map { $0.makeSketchGroup() }
  }

  /// Generates a `Text` layer that mimics the `UILabel`
  public func makeSketchText() -> Text? {
    guard text != nil else { return nil }
    // Get the natural height of the text
    let height = systemLayoutSizeFitting(self.frame.size).height
    // Center the text vertically in the frame of the UILabel which is what UILabel does automatically
    let textFrame = CGRect(origin: CGPoint(x: 0, y: frame.size.height / 2 - height / 2), size: CGSize(width: frame.size.width, height: height))

    return Text(segments: textSegments, wrapText: numberOfLines != 1, frame: textFrame)
  }

  /// Returns the firstLineHeadIndent of the string if one exists
  var firstLineHeadIndent: CGFloat {
    guard let attributedText = attributedText, !attributedText.string.isEmpty else { return 0 }
    guard let paragraphStyle = attributedText.attributes(at: 0, effectiveRange: nil)[.paragraphStyle] as? NSParagraphStyle else { return 0 }
    return paragraphStyle.firstLineHeadIndent
  }

  var textSegments: [Text.Segment] {
    guard let text = text else { return [] }
    guard let attributedText = attributedText else {
      return [
        Text.Segment(
          text: text,
          style: Text.Style(
            fontDescriptor: font.sketchCompatibleName,
            fontSize: font.pointSize,
            color: textColor.makeSketchColor(),
            alignment: textAlignment.sketchAlignment,
            isUnderlined: false
          )
        )
      ]
    }

    let segments: [Text.Segment] = text.enumerated().map {
      let attributes = attributedText.attributes(at: $0.0, effectiveRange: nil)
      let font: UIFont = attributes[.font] as? UIFont ?? self.font
      let color: UIColor = attributes[.foregroundColor] as? UIColor ?? textColor
      let alignment = textAlignment.sketchAlignment
      let isUnderlined: Bool = {
        guard let underlineStyle = attributes[.underlineStyle] as? NSUnderlineStyle.RawValue else { return false }
        return underlineStyle != NSUnderlineStyle.styleNone.rawValue
      }()
      return Text.Segment(
        text: String($0.1),
        style: Text.Style(
          fontDescriptor: font.sketchCompatibleName,
          fontSize: font.pointSize,
          color: color.makeSketchColor(),
          alignment: alignment,
          isUnderlined: isUnderlined
        )
      )
    }

    // Sketch has no concept of firstLineHeadIndent so this is a hack to get it to work in sketch
    // We just add spaces to the front of the string until their width matches the width of the firstLineHeadIndent
    // This isn't exactly 1:1 but it seems to be good enough for our needs
    let spacerSegments: [Text.Segment] = {
      guard firstLineHeadIndent != 0 else { return [] }
      let spacerWidth = NSAttributedString(string: " ", attributes: [.font: font]).size().width
      let numberOfSpacers: Int = Int(round(firstLineHeadIndent / spacerWidth))
      return [Text.Segment(text: String(Array(repeating: Character(" "), count: numberOfSpacers)), style: Text.Style(fontDescriptor: font.sketchCompatibleName, fontSize: font.pointSize, color: textColor.makeSketchColor(), alignment: textAlignment.sketchAlignment))]
    }()

    return spacerSegments + segments
  }
}

// Here be dragons. I'm so sorry.
private extension UILabel {
  // Sketch can't handle labels with images in them
  // For cases like this we need to break up the label into smaller labels and image views
  func equivalentViews() -> [UIView] {
    // no attributed text = no problem
    guard let attributedText = attributedText else { return [self] }

    // Split the string up into lines
    let lines = attributedText.splitIntoLines(forWidth: frame.width, height: frame.height)

    // Current y position
    var currentLineY: CGFloat = 0
    // Any NSAttachments we find will be put into a UIImageView
    var imageViews: [UIView] = []
    // We're going to create a UILabel for each line. For lines with images we may have more than one label per line
    var labels: [UIView] = []
    lines.forEach { line in
      // Images get placed onto the baseline of the string
      // The baseline is defined by the largest descender. So before we figure out frames for the images we need to find the largest descender
      var largestDescender: CGFloat = 0
      line.string.enumerated().forEach { index, _ in
        // Iterate through the line, check font at each point, and record the largest descender found
        let attributes = line.attributes(at: index, effectiveRange: nil)
        if let font = attributes[.font] as? UIFont {
          largestDescender = min(largestDescender, font.descender)
        }
      }
      if largestDescender == 0 {
        largestDescender = self.font.descender
      }
      largestDescender = min(largestDescender, 0)

      // Now that we have the largest descender we can iterate through the line and search for images
      // splitIndex keeps track of where we split the line if we found an image on this line
      var splitIndex = 0

      // When we find an image we'll break off the current substring and assign it to this label.
      // Starts off as nil because the first character might be an image
      // When we find an image we'll push this label onto the labels array and mark the image index as the splitIndex
      var currentLabel: UILabel? = nil

      // Helper that configures a label with a substring of the current line with the given range and gives it a frame.
      // Then appends it to the labels array
      func appendLabel(_ label: UILabel, withSubstringRange range: NSRange) {
        // Trim off trailing spaces to make the label hug its text
        let substring = line.attributedSubstring(from: range).trimmingTrailingSpaces()
        label.attributedText = substring
        // Calculate label frame based on where the split index is and the currentLineY
        let x = line.attributedSubstring(from: NSRange(location: 0, length: splitIndex)).size().width
        let origin = CGPoint(x: x, y: currentLineY)
        label.frame = CGRect(origin: origin, size: substring.size())
        labels.append(label)
      }

      line.string.enumerated().forEach { index, character in
        let attributes = line.attributes(at: index, effectiveRange: nil)

        if let attachment: NSTextAttachment = attributes[.attachment] as? NSTextAttachment {
          let bounds = attachment.bounds

          // Measure the string up to this point to get the x coordinate of the image
          let x = line.attributedSubstring(from: NSRange(location: 0, length: index)).size().width - bounds.minX

          // Bottom of the image lines up with the baseline
          let bottom = line.size().height + largestDescender
          let y = bottom - bounds.height - bounds.minY + currentLineY

          // Creating the image view
          let origin = CGPoint(x: x , y: y)
          let imageView = UIImageView(frame: CGRect(origin: origin, size: bounds.size))
          imageView.image = attachment.image
          imageViews.append(imageView)

          // If we had a label running we want to push it onto the labels array and start a new label
          if let label = currentLabel {
            appendLabel(label, withSubstringRange: NSRange(location: splitIndex, length: index - splitIndex))
            currentLabel = nil
          }
          splitIndex = index + 1
        // Skip over space characters
        } else if currentLabel == nil && (character == "\u{2060}" || character == " ") {
          splitIndex += 1
        // If there wasn't an image at this character and no space at this character then we start a new label
        } else if currentLabel == nil {
          currentLabel = UILabel()
          currentLabel?.font = self.font
          currentLabel?.textColor = textColor
        }
      }

      // If theres a label left at the end we want to append it as well
      if let label = currentLabel {
        appendLabel(label, withSubstringRange: NSRange(location: splitIndex, length: line.string.count - splitIndex))
      }

      currentLineY += line.size().height
    }

    // If there are no images in the string then we can just return self
    if imageViews.isEmpty {
      return [self]
    }

    // TODO: It would be nice to re-combine adjacent labels if possible. However this fits our usecase for now

    return imageViews + labels
  }
}

private extension NSTextAlignment {
  var sketchAlignment: Text.Style.Alignment {
    switch self {
    case .right :
      return .right
    case .center:
      return .center
    default:
      return .left
    }
  }
}

