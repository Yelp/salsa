//
//  Salsa+Utils.swift
//  Salsa
//
//  Created by Wirawit Rueopas on 3/6/18.
//  Copyright © 2018 Yelp. All rights reserved.
//

import UIKit

public struct SalsaUtils {

  /**
   Make Artboard from arranged groups, keeping their relative frames.

   - parameter name:    Name of the Artboard as it appears in Sketch
   - parameter groups:  Layers displayed inside the Artboard.
   - parameter insets:  Insets of the Artboard to the groups it displays.
   - parameter color:   The Artboard's color.
   */
  public static func makeArtboard(name: String,
                                  groups: [Group],
                                  insets: UIEdgeInsets,
                                  color: UIColor = UIColor(white: 245/255.0, alpha: 1.0)) -> Artboard {
    // First shift every groups with left/top insets
    groups.forEach { (g) in
      g.frame = g.frame.offsetBy(dx: insets.left, dy: insets.top)
    }


    // Calculate the size of the result Artboard in 2 steps:
    var width: CGFloat = 0
    var height: CGFloat = 0

    // 1. Get right/bottom-most positions of the shifted groups
    groups.forEach { g in
      height = max(height, g.frame.bottom)
      width = max(width, g.frame.right)
    }

    // 2. Add right/bottom insets
    width += insets.right
    height += insets.bottom

    let artboardColor = color.makeSketchColor()
    return Artboard(name: name, layers: groups, frame: CGRect(x: 0, y: 0, width: width, height: height), color: artboardColor)
  }

  /// Make a `Group` from view.
  public static func makeGroup(name: String, view: UIView) -> Group {
    let group = view.makeSketchGroup()
    return Group(frame: group.frame, layers: group.layers, alpha: group.alpha, name: name, shadow: group.shadow)
  }

  /**
   Lay out `layers` in 2d space starting from `(0,0)` treating the input `layers` as vertical stacks.
   To arrange all vertically: `[[1, 2, 3, ...]]`
   To arrange all horizontally: `[[1], [2], [3], ...]`

   Usually used to arrange `[[Artboard]]` and `[[Group]]`.

   - parameter layers:            Layers to arrange.
   - parameter verticalSpace:     Vertical space between `Groups`. Default is `20`.
   - parameter horizontalSpace:   Horizontal space between two vertical stacks of `Groups`. Default is 20. The stack width is determined by maximum `Group`'s width in that stack. Default is `20`.

   - Returns: The array of `LayerContainers` with their frames modified.
   */
  public static func arrange<T: LayerContainer>(layers: [[T]],
                                                verticalSpace: CGFloat = 20.0,
                                                horizontalSpace: CGFloat = 20.0) -> [T] {
    var x: CGFloat = 0

    // Lay out horizontally
    layers.forEach { (gs) in
      var y: CGFloat = 0
      var nextStackX = x

      // Lay out vertically
      gs.forEach({ (g) in
        let w = g.frame.width
        let h = g.frame.height
        g.frame = CGRect(x: x, y: y, width: w, height: h)
        y += (h + verticalSpace) // Next Group's y
        nextStackX = max(nextStackX, x + w) // Keep track of next vertical stack starting x.
      })
      x = nextStackX + horizontalSpace
    }
    return layers.flatMap { $0 }
  }
}
