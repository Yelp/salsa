//
//  Document.swift
//  Salsa
//
//  Created by Max Rabiciuc on 9/20/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation
import CoreGraphics

/// Encapsulates the entire Sketch document
public struct Document {
  /// Pages of the document
  public let pages: [Page]

  /// Global colors defined in the document
  public let colors: [Color]

  /// Global text styles defined in the document
  public let textStyles: [Text.SharedStyle]

  /**
   Creates an entire Sketch Document
   - parameter pages:       List of Pages shown in the Document
   - parameter colors:      Global colors shared across the entire document
   - parameter textStyles:  Global text styles shared across the entire document
   */
  public init(pages: [Page], colors: [Color], textStyles: [Text.SharedStyle]) {
    self.pages = pages; self.colors = colors; self.textStyles = textStyles
  }
}

extension Document: JSONDictEncodable {
  public func toJson() -> [String: Any] {
    return ["pages": pages.map { $0.toJson() }, "colors": colors.map { $0.toJson() }, "textStyles": textStyles.map { $0.toJson() }]
  }

  public init?(json: [String: Any]) {
    let pages: [Page] = {
      guard let pages = json["pages"] as? [[String: Any]] else { return [] }
      return pages.compactMap { Page(json: $0) }
    }()

    self.init(
      pages: pages,
      colors: {
        guard let colors = json["colors"] as? [[String: Any]] else { return [] }
        return colors.compactMap { Color(json: $0) }
    }(),
      textStyles: {
        guard let textStyles = json["textStyles"] as? [[String: Any]] else { return [] }
        return textStyles.compactMap { Text.SharedStyle(json: $0) }
    }()
    )
  }
}

