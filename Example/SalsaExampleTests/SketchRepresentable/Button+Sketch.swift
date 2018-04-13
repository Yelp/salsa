//
//  Button+Sketch.swift
//  SalsaExampleTests
//
//  Created by Max Rabiciuc on 2/22/18.
//  Copyright © 2018 Yelp. All rights reserved.
//

@testable import SalsaExample
import Salsa

extension Button: SymbolRepresentable {
  public static var viewWidth: CGFloat? { return 100 }
  public static var artboardInsets: UIEdgeInsets { return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) }
  public static var artboardColor: Color { return .white }

  public static func artboardElements() -> [[ArtboardElement]] {
    let blueShort = Button(title: "Button", style: .blueShort)
    let blueTall = Button(title: "Button", style: .blueTall)

    let redShort = Button(title: "Button", style: .redShort)
    let redTall = Button(title: "Button", style: .redTall)

    let link = Button(title: "Button", style: .link)
    return [
      [
        ArtboardElement(view: blueShort, name: "Blue/Short"),
        ArtboardElement(view: blueTall, name: "Blue/Tall")
      ],
      [
        ArtboardElement(view: redShort, name: "Red/Short"),
        ArtboardElement(view: redTall, name: "Red/Tall")
      ],
      [ArtboardElement(view: link, name: "Link")]
    ]
  }
}
