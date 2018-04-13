//
//  ViewController.swift
//  SalsaExample
//
//  Created by Max Rabiciuc on 2/21/18.
//  Copyright © 2018 Yelp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    let onlineTwoLines = UserView(user: User(name: "User Name", subtitle: "Last conversation message", image: UIImage(named: "user")!), isOnline: true)
    let offlineTwoLines = UserView(user: User(name: "User Name", subtitle: "Last conversation message", image: UIImage(named: "user")!), isOnline: false)
    let onlineOneLine = UserView(user: User(name: "User Name", subtitle: nil, image: UIImage(named: "user")!), isOnline: true)
    let offlineOneLine = UserView(user: User(name: "User Name", subtitle: nil, image: UIImage(named: "user")!), isOnline: false)

    view.addSubview(onlineTwoLines)
    view.addSubview(offlineTwoLines)
    view.addSubview(onlineOneLine)
    view.addSubview(offlineOneLine)

    let views: [String: UIView] = [
      "onlineTwoLines": onlineTwoLines,
      "offlineTwoLines": offlineTwoLines,
      "onlineOneLine": onlineOneLine,
      "offlineOneLine": offlineOneLine
    ]
    views.forEach {
      $1.translatesAutoresizingMaskIntoConstraints = false
    }

    let horizontalConstraints = views.values.map {
      [
        $0.leftAnchor.constraint(equalTo: view.leftAnchor),
        $0.rightAnchor.constraint(equalTo: view.rightAnchor)
      ]
    }.flatMap { $0 }

    let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[onlineTwoLines][offlineTwoLines][onlineOneLine][offlineOneLine]", options: [], metrics: nil, views: views)
    NSLayoutConstraint.activate(verticalConstraints + horizontalConstraints)
  }
}

