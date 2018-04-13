//
//  SymbolMaster.swift
//  Salsa
//
//  Created by Max Rabiciuc on 9/20/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Foundation
import CoreGraphics

/// Represents a SymbolMaster in sketch, these should go in their own special separate Symbols Page.
/// If you want to have nested dropdowns use a "/" in the name. i.e. `Button/Blue/Small`
public class SymbolMaster: LayerContainer {
  /**
   Creates a SymbolMaster that can be referenced by a `SymbolInstance`
   - parameter name:    Name as it appears in sketch. __Must be Unique.__ Use a "/" in the name to create nested dropdowns. i.e. `Button/Blue/Small`
   - parameter frame:   Frame of the SymbolMaster inside its parent `Page`
   - parameter layers:  Child layers that are contained inside the SymbolMaster
   */
  public init(name: String, frame: CGRect, layers: [Layer]) {
    super.init(name: name, frame: frame, layers: layers)
  }

  required public init?(json: [String : Any]) {
    super.init(json: json)
  }
}

/**
 Instance of a Symbol in Sketch.

 References a `SymbolMaster`.

 __Must have the same name as the SymbolMaster it's referencing__
 */
public class SymbolInstance: Layer {

  /**
   Creates a SymbolInstance that references a `SymbolMaster`
   - parameter name:    Name of the `SymbolMaster` being referenced
   - parameter frame:   Frame of the SymbolInstance inside its parent container
   */
  public init(name: String, frame: CGRect) {
    super.init(name: name, frame: frame)
  }

  required public init?(json: [String : Any]) {
    super.init(json: json)
  }
}
