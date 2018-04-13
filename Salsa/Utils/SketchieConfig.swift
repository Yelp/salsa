//
//  SalsaConfig.swift
//  Salsa
//
//  Created by Max Rabiciuc on 3/19/18.
//  Copyright © 2018 Yelp. All rights reserved.
//

import Foundation

public struct SalsaConfig {
  /// Directory in which exported files will be stored.
  /// This must be set before using any any Salsa methods.
  /// Salsa will create this directory if it doesn't exist.
  /// Image assets will be saved to `exportDirectory/images/`.
  public static var exportDirectory: String = "/tmp/SalsaExport/"

  /// Directory where image assets will be stored
  public static var imageExportDirectory: String {
    return exportDirectory + "/images/"
  }
}

