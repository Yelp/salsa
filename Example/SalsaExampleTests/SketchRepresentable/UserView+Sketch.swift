//
//  Button+Sketch.swift
//  SalsaExampleTests
//
//  Created by Max Rabiciuc on 2/21/18.
//  Copyright © 2018 Yelp. All rights reserved.
//

@testable import SalsaExample
import Salsa

extension UserView: SymbolRepresentable {
  public static var name: String { return "User View" }
  public static var artboardInsets: UIEdgeInsets { return UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0) }
  public static func artboardElements() -> [[ArtboardElement]] {
    let onlineTwoLines = UserView(user: User(name: "User Name", subtitle: "Last conversation message", image: UIImage(named: "user")!), isOnline: true)
    let offlineTwoLines = UserView(user: User(name: "User Name", subtitle: "Last conversation message", image: UIImage(named: "user")!), isOnline: false)
    let onlineOneLine = UserView(user: User(name: "User Name", subtitle: nil, image: UIImage(named: "user")!), isOnline: true)
    let offlineOneLine = UserView(user: User(name: "User Name", subtitle: nil, image: UIImage(named: "user")!), isOnline: false)
    return [[
      ArtboardElement(view: onlineTwoLines, name: "Two Lines/Online"),
      ArtboardElement(view: offlineTwoLines, name: "Two Lines/Offline"),
      ArtboardElement(view: onlineOneLine, name: "One Line/Online"),
      ArtboardElement(view: offlineOneLine, name: "One Line/Offline"),
    ]]
  }
}






