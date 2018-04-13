//
//  SalsaExampleTests.swift
//  SalsaExampleTests
//
//  Created by Max Rabiciuc on 2/21/18.
//  Copyright © 2018 Yelp. All rights reserved.
//

import XCTest
import Salsa
@testable import SalsaExample

class SalsaExampleTests: XCTestCase {
  func testExample() {
    SalsaConfig.exportDirectory = "/tmp/SalsaExample"
    let document = Document.makeStyleGuideDocument()
    do {
      try document.export()
    } catch {
      XCTFail("Failed to export file")
    }
  }
}

extension Document {

  static func makeStyleGuideDocument() -> Document {
    let artboardsAndSymbols = makeArtboardsAndSymbols(from: providers)
    let typography = Artboard.typographyArtboard(topRight: CGPoint(x: -80, y: 0))
    return Document(
      pages: [
        Page(name: "Symbols", layers: artboardsAndSymbols.symbols),
        Page(name: "Overview", layers: [typography] + artboardsAndSymbols.artboards)
      ],
      colors: [UIColor.red.makeSketchColor(), UIColor.white.makeSketchColor(), UIColor.blue.makeSketchColor()],
      textStyles: FontStyle.allStyles.map { Text.SharedStyle(name: String(describing: $0), textStyle: Text.Style(font: $0.font)) }
    )
  }

  static let providers: [[ArtboardRepresentable.Type]] = [
    [UserView.self], [Button.self]
  ]
}

extension Artboard {
  // Creates an artboard that shows off all supported YLDesign.TextStyles
  static func typographyArtboard(topRight: CGPoint) -> Artboard {
    let padding: CGFloat = 20
    var width: CGFloat = 0
    var y = padding
    let text: [Text] = FontStyle.allStyles.map { textStyle in
      let fontName = textStyle.font.sketchCompatibleName
      let fontType = fontName.components(separatedBy: "-").last!
      let label = UILabel()
      label.text = "\(String(describing: textStyle)) (\(Int(textStyle.font.pointSize))pt \(fontType))"
      label.font = textStyle.font
      label.translatesAutoresizingMaskIntoConstraints = false
      let size = label.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
      let text = label.makeSketchText()!
      text.frame = CGRect(x: padding, y: y, width: size.width, height: size.height)
      width = max(width, size.width)
      y += padding + size.height
      return text
    }

    let size = CGSize(width: width + padding * 2, height: y)

    return Artboard(name: "Typography", layers: text, frame: CGRect(origin: CGPoint(x: topRight.x - size.width, y: topRight.y), size: size), color: .white)
  }
}

