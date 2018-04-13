//
//  Group+Simplified.swift
//  SalsaCompiler
//
//  Created by Max Rabiciuc on 10/16/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import Cocoa

extension Group {
  override func simplified(isRoot: Bool = false) -> [Layer] {
    // Recursively simplify child layers
    let newLayers: [Layer] = layers.map { $0.simplified() }.flatMap { $0 }

    // Candidate for an updated version of self
    let candidate = Group(frame: frame, layers: newLayers, alpha: alpha, name: name, shadow: shadow).filteringMaskIfNeeded()

    if !isRoot && candidate.shouldPurge() {
      // If we don't need self then get convert all sublayer frames and return just the sublayers
      return candidate.layers.flatMap {
        let frame = CGRect(
          origin: CGPoint(
            x: self.frame.origin.x + $0.frame.origin.x,
            y: self.frame.origin.y + $0.frame.origin.y
          ),
          size: $0.frame.size
        )

        $0.frame = frame
        return $0
      }
    }
    return [candidate]
  }

  // A group can be purged if (it has no sublayers) or (it doesn't have custom alpha, it doesn't have a shadow and it doesn't have a mask)
  func shouldPurge() -> Bool {
    return (shadow == nil && !hasMask && alpha == 1) || layers.isEmpty
  }

  var hasMask: Bool {
    return layers.reduce(false, {
      if let shape = $1 as? Shape {
        return $0 || shape.isMask
      }
      return $0
    })
  }

  // Returns a copy of self without a mask if the mask is redundant
  func filteringMaskIfNeeded() -> Group {
    guard let mask: Shape = {
      for layer in layers {
        if let mask = layer as? Shape, mask.isMask == true {
          return mask
        }
      }
      return nil
      }() else { return self } // if there is no mask then return self

    let bounds = mask.frame
    let layersNeedingMask = layers.filter({ layer in
      if layer.frame.top < bounds.top || layer.frame.bottom > bounds.bottom || layer.frame.left < bounds.left || layer.frame.right > bounds.right { // do a simple sanity check first before trying the more expensive approach
        return true
      } else {
        let path: CGPath = {
          if let shape = layer as? Shape {
            return shape.path.cgPath
          } else {
            return CGPath(rect: layer.frame, transform: nil)
          }
        }()
        return !mask.path.cgPath.contains(path: path)
      }
    })
    // If there are layers that require a mask then we return self
    guard layersNeedingMask.count == 0 else { return self }

    // nothing draws outside the mask so the mask is not needed, filter out the mask
    let newLayers = layers.filter {
      if let mask = $0 as? Shape, mask.isMask == true {
        return false
      }
      return true
    }
    return Group(frame: frame, layers: newLayers, alpha: alpha, name: name, shadow: shadow)
  }
}

