//
//  Text.swift
//  Salsa
//
//  Created by Max Rabiciuc on 9/20/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation
import CoreGraphics

/// Represents a Text layer in Sketch
public class Text: Layer {
  /// Whether the text should wrap or stay on a single line
  public let wrapText: Bool
  /// List of Text segments in left to right order as they appear in the Text container
  public let segments: [Segment]

  /**
   Creates an instance a Sketch Text layer
   - parameter segments:  List of styled text segments from left to right order
   - wrapText:            Whether the text should stay on one line or word wrap to more than one line
   - frame:               Frame of the Text layer in its parent container
   */
  init(segments: [Segment], wrapText: Bool, frame: CGRect) {
    self.segments = segments
    self.wrapText = wrapText
    super.init(name: segments.text, frame: frame)
  }

  public required init?(json: [String : Any]) {
    guard
      let wrapText = json["wrapText"] as? Bool,
      let segmentsJson = json["segments"] as? [[String: Any]]
    else { return nil }

    self.wrapText = wrapText
    self.segments = segmentsJson.compactMap { Segment(json: $0) }
    super.init(json: json)
  }

  override public func toJson() -> [String: Any] {
    var json = super.toJson()
    json["wrapText"] = wrapText
    json["segments"] = segments.map { $0.toJson() }
    return json
  }

  // MARK: Nested types

  // Unfortunately these nested types have to be defined here or else they don't get picked up by other files
  // This is a swift bug being tracked at: https://bugs.swift.org/browse/SR-631

  /// A struct containing styling information about a string
  public struct Style: JSONDictEncodable {
    public enum Alignment: Int { case left, right, center }

    /// Name of the font as it appears in macOS.
    /// Standard naming convention is `FontNameInCamelCase-FontWeightInCamelCase.`
    /// i.e. SFPro-Regular, Arial-Black, HelveticaNeue-UltraLight
    public let fontDescriptor: String

    /// Font point size
    public let fontSize: CGFloat

    /// Color of the `Segment`
    public let color: Color

    /// Whether the `Segment` is left, right, or center aligned. The alignment of the first `Segment` in a `Text` layer will be inhereted by all other segments
    public let alignment: Alignment

    /// Whether the `Segment` is underlined
    public let isUnderlined: Bool

    /**
     Creates a `Style` used for styling a `Segment` of `Text`
     - parameter fontDescriptor: Name of the font as it appears in macOS.
         Standard naming convention is `FontNameInCamelCase-FontWeightInCamelCase`.
         i.e. SFPro-Regular, Arial-Black, HelveticaNeue-UltraLight

     - parameter fontSize:      Font point size
     - parameter color:         Color of the `Segment`
     - parameter alignment:     Whether the `Segment` is left, right, or center aligned. The alignment of the first `Segment` in a `Text` layer will be inhereted by all other segments
     - parameter isUnderlined:  Whether the `Segment` is underlined
     */
    public init(fontDescriptor: String, fontSize: CGFloat, color: Color, alignment: Alignment, isUnderlined: Bool = false) {
      self.fontDescriptor = fontDescriptor; self.fontSize = fontSize; self.color = color; self.alignment = alignment; self.isUnderlined = isUnderlined;
    }

    public init?(json: [String: Any]) {
      guard let fontDescriptor = json["fontDescriptor"] as? String,
        let fontSize = json["fontSize"] as? CGFloat,
        let colorJson = json["color"] as? [String: Any], let color = Color(json: colorJson),
        let alignmentRaw = json["alignment"] as? Int
      else { return nil }

      self.init(
        fontDescriptor: fontDescriptor,
        fontSize: fontSize,
        color: color,
        alignment: Alignment(rawValue: alignmentRaw) ?? .left,
        isUnderlined: json["isUnderlined"] as? Bool ?? false
      )
    }

    public func toJson() -> [String: Any] {
      return ["fontDescriptor": fontDescriptor, "fontSize": fontSize, "color": color.toJson(), "alignment": alignment.rawValue, "isUnderlined": isUnderlined]
    }
  }

  /// Container for representing `Styles` that are shared within a document
  public struct SharedStyle: JSONDictEncodable {
    public let name: String
    public let textStyle: Style

    public init(name: String, textStyle: Style) {
      self.name = name; self.textStyle = textStyle
    }

    public func toJson() -> [String: Any] {
      return ["name": name, "textStyle": textStyle.toJson()]
    }

    public init?(json: [String: Any]) {
      guard
        let name = json["name"] as? String,
        let textStyleJson = json["textStyle"] as? [String: Any], let textStyle = Text.Style(json: textStyleJson)
      else { return nil }
      self.init(name: name, textStyle: textStyle)
    }
  }

  /// Represents a styled segment of a string
  public struct Segment: JSONDictEncodable {
    /// String represented by this `Segment`
    public let text: String
    /// `Style` applied to this `Segment`
    public let style: Style
    /**
     Creates a `Segment` to be used inside of a `Text` layer
     - parameter text:    String represented by this `Segment`
     - parameter style:   `Style` applied to this `Segment`
     */
    public init(text: String, style: Style) {
      self.text = text; self.style = style
    }

    public init?(json: [String: Any]) {
      guard
        let styleJson = json["style"] as? [String: Any], let style = Text.Style(json: styleJson),
        let text = json["text"] as? String
      else { return nil }
      self.init(text: text, style: style)
    }

    public func toJson() -> [String : Any] {
      return [
        "text": text,
        "style": style.toJson(),
      ]
    }
  }
}

extension Collection where Iterator.Element == Text.Segment {
  var text: String {
    return reduce("", { $0 + $1.text })
  }
}

