//
//  Document+Export.swift
//  Salsa
//
//  Created by Max Rabiciuc on 2/22/18.
//  Copyright © 2018 Yelp. All rights reserved.
//

import Foundation

public extension Document {
  public enum DocumentExportError: Error {
    case failedToSerialize
    case failedToCreateDirectory
    case failedToSaveFile
  }

  /// Exports a `Document` to the directory path specified in `SalsaConfig.exportDirectory`
  public func export(fileName: String = "generated") throws {
    let dictionary = toJson()
    guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) else {
      throw DocumentExportError.failedToSerialize
    }

    guard let jsonText = String(data: jsonData, encoding: .utf8) else {
      throw DocumentExportError.failedToSerialize
    }

    if !FileManager.default.fileExists(atPath: SalsaConfig.exportDirectory) {
      do {
        try FileManager.default.createDirectory(atPath: SalsaConfig.exportDirectory, withIntermediateDirectories: true, attributes: nil)
      } catch {
        throw DocumentExportError.failedToCreateDirectory
      }
    }


    let pageFilePath = "\(SalsaConfig.exportDirectory)/\(fileName).salsa"
    let url = NSURL.fileURL(withPath: pageFilePath)
    do {
      try jsonText.write(to: url, atomically: false, encoding: String.Encoding.utf8)
    } catch {
      throw DocumentExportError.failedToSaveFile
    }
  }
}

