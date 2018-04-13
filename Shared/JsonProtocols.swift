//
//  JsonProtocols.swift
//  Salsa
//
//  Created by Max Rabiciuc on 9/20/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation

protocol JSONDictEncodable {
  func toJson() -> [String: Any]
  init?(json: [String: Any])
}

protocol SketchJsonConvertable {
  func toSketchJson() -> [String: Any]
}

