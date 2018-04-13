//
//  JsonUtils.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 9/14/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation

public func parseJsonFile(at filePath: String) -> [String: Any] {
  // get the contentData
  guard let contentData = FileManager.default.contents(atPath: filePath) else {
    fatalError("Could not find file: \(filePath)")
  }

  // get the string
  guard let content = String(data: contentData, encoding: .utf8)?.dictionaryRepresentation() else {
    fatalError("Could not parse file: \(filePath)")
  }
  return content
}

public extension Dictionary {
  func toJsonString() -> String? {
    if let theJSONData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) {
      return String(data: theJSONData, encoding: .ascii)
    }
    return nil
  }
}

extension String {
  func dictionaryRepresentation() -> [String: Any]? {
    if let data = self.data(using: .utf8) {
      do {
        return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
      } catch {
        fatalError(error.localizedDescription)
      }
    }
    return nil
  }
}

