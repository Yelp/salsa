//
//  UIImageView+SketchFactory.swift
//  Salsa
//
//  Created by Max Rabiciuc on 9/19/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

import UIKit

// MARK: Overrides
extension UIImageView {
  @objc override open var sketchName: String { return "Image" }

  /// Overrides contentLayers to provide a `Bitmap` representing the `self.image`
  @objc override func contentLayers() -> [Layer] {
    return [makeSketchBitmap()].compactMap { $0 }
  }

  private func makeSketchBitmap() -> Bitmap? {
    guard frame != .zero && self.image != nil else { return nil }
    guard let image: UIImage = {
      if isHighlighted {
        return highlightedImage ?? image
      } else {
        return image
      }
    }() else { return nil }


    if image.capInsets != .zero { // no way to do a 9-slice image in sketch so we're forced to just take a screenshot
      guard let fileName = screenshotImage?.saveToDisk() else { return nil }
      return Bitmap(fileName: fileName, frame: CGRect(origin: .zero, size: frame.size))
    }

    let tintColor: Color? = {
      // Check to see if we need to set a tintColor
      // We need to special case nav bar buttons because they get tinted even though their rendering mode isn't .alwaysTemplate. Thanks apple.
      guard image.renderingMode == .alwaysTemplate || hasSuperview(withName: "_UIModernBarButton") else { return nil }
      return self.tintColor.makeSketchColor()
    }()

    guard let fileName = image.saveToDisk() else { return nil }
    return Bitmap(fileName: fileName, frame: imageFrame(), tintColor: tintColor)
  }
}

// MARK: Writing image to disk
@objc public extension UIImage {
  @objc public func saveToDisk() -> String? {
    if !FileManager.default.fileExists(atPath: SalsaConfig.imageExportDirectory) {
      do {
        try FileManager.default.createDirectory(at: NSURL.fileURL(withPath: SalsaConfig.imageExportDirectory), withIntermediateDirectories: true, attributes: nil)
      } catch {
        return nil
      }
    }
    guard let data = UIImagePNGRepresentation(self) else { return nil }

    // We hash the image using md5 to create a name for the image
    // This allows us to make sure we don't waste space by saving the same image multiple times
    let filename = (data as NSData).md5()
    let filepath = SalsaConfig.imageExportDirectory.appending(filename.appending(".png"))
    if !FileManager.default.fileExists(atPath: filepath) {
      do {
        let url = NSURL.fileURL(withPath: filepath)
        try data.write(to: url, options: .atomic)
      } catch {
        return nil
      }
    }
    return filename
  }
}


// MARK: Image Frame Helpers
fileprivate extension UIImageView {
  func imageFrame() -> CGRect {
    let bounds = CGRect(origin: .zero, size: frame.size)
    guard let size = image?.size else { return .zero }
    switch contentMode {
    case .scaleToFill:
      return bounds
    case .scaleAspectFit:
      return bounds.scaleAspectFitInSelf(size: size)
    case .scaleAspectFill:
      return bounds.scaleAspectFillInSelf(size: size)
    case .bottom:
      return CGRect(x: (frame.size.width - size.width) / 2 , y: frame.size.height - size.height, width: size.width, height: size.height)
    case .bottomLeft:
      return CGRect(x: 0 , y: frame.size.height - size.height, width: size.width, height: size.height)
    case .bottomRight:
      return CGRect(x: frame.size.width - size.width , y: frame.size.height - size.height, width: size.width, height: size.height)
    case .center:
      return CGRect(x: (frame.size.width - size.width) / 2 , y: (frame.size.height - size.height) / 2, width: size.width, height: size.height)
    case .left:
      return CGRect(x: 0 , y: (frame.size.height - size.height) / 2, width: size.width, height: size.height)
    case .right:
      return CGRect(x: frame.size.width - size.width , y: (frame.size.height - size.height) / 2, width: size.width, height: size.height)
    case .top:
      return CGRect(x: (frame.size.width - size.width) / 2 , y: 0, width: size.width, height: size.height)
    case .topLeft:
      return CGRect(x: 0 , y: 0, width: size.width, height: size.height)
    case .topRight:
      return CGRect(x: frame.size.width - size.width , y: 0, width: size.width, height: size.height)
    case .redraw:
      return bounds
    }
  }
}

fileprivate extension CGRect {
  func scaleAspectFitInSelf(size: CGSize) -> CGRect {
    let imageViewSize = self.size
    let imageSize = size

    let scaleWidth = imageViewSize.width / imageSize.width
    let scaleHeight = imageViewSize.height / imageSize.height
    let aspect = fmin(scaleWidth, scaleHeight)

    var imageRect = CGRect(x: 0, y: 0, width: imageSize.width * aspect, height: imageSize.height * aspect)
    // Center image
    imageRect.origin.x = (imageViewSize.width - imageRect.size.width) / 2
    imageRect.origin.y = (imageViewSize.height - imageRect.size.height) / 2


    return imageRect
  }

  func scaleAspectFillInSelf(size: CGSize) -> CGRect {
    let imageViewSize = self.size
    let imageSize = size

    let scaleWidth = imageViewSize.width / imageSize.width
    let scaleHeight = imageViewSize.height / imageSize.height
    let aspect = fmax(scaleWidth, scaleHeight)

    var imageRect = CGRect(x: 0, y: 0, width: imageSize.width * aspect, height: imageSize.height * aspect)
    // Center image
    imageRect.origin.x = (imageViewSize.width - imageRect.size.width) / 2
    imageRect.origin.y = (imageViewSize.height - imageRect.size.height) / 2

    return imageRect
  }
}

