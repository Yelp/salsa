//
//  UIView+Utils.swift
//  Salsa
//
//  Created by Max Rabiciuc on 11/3/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import UIKit

extension UIView {
  var screenshotImage: UIImage? {
    UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
    drawHierarchy(in: bounds, afterScreenUpdates: true)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }

  func hasSuperview(withName name: String) -> Bool {
    var currentView: UIView = self
    while let superview = currentView.superview {
      if String(describing: type(of: superview)) == name {
        return true
      }
      currentView = superview
    }
    return false
  }

  /// Detects if drawRect has been overriden.
  /// This is pretty gross but it works.
  /// We walk up the class tree until we find the class that owns the drawRect method.
  /// If that class name does not start with an underscore or UI then we assume that its not a UIKit class and we say that the current class is drawRected.
  var isDrawRected: Bool {
    let selector = #selector(draw(_:))
    var objClass: AnyClass = type(of: self)

    while let objSuperClass = objClass.superclass() {
      if self.method(for: selector) != objSuperClass.instanceMethod(for: selector) && !(String(describing: objClass).hasPrefix("_") || String(describing: objClass).hasPrefix("UI")) {
        return true
      }
      objClass = objSuperClass
    }
    return false
  }
}

