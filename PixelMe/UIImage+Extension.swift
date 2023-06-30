//
//  UIImage+Extension.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/01.
//

import UIKit

// MARK: - Crop the image to a square even if the user select a rectangular image
extension UIImage {
    var crop: UIImage? {
        let refWidth = CGFloat((self.cgImage!.width))
        let refHeight = CGFloat((self.cgImage!.height))
        let cropSize = refWidth > refHeight ? refHeight : refWidth
        let x = (refWidth - cropSize) / 2.0
        let y = (refHeight - cropSize) / 2.0
        let cropRect = CGRect(x: x, y: y, width: cropSize, height: cropSize)
        let imageRef = self.cgImage?.cropping(to: cropRect)
        let cropped = UIImage(cgImage: imageRef!, scale: 0.0, orientation: self.imageOrientation)
        return cropped
    }
    
    /// Crop any transparent pixels after applying any filters
    func cropTransparentPixels() -> UIImage {
        guard let cgImageObject = cgImage else { return self }
        guard let width = cgImage?.width, let height = cgImage?.height else { return self }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo),
              let ptr = context.data?.assumingMemoryBound(to: UInt8.self) else { return self }
        context.draw(cgImageObject, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var minX = width
        var minY = height
        var maxX: Int = 0
        var maxY: Int = 0
        
        for x in 1..<width {
            for y in 1..<height {
                let i = bytesPerRow * Int(y) + bytesPerPixel * Int(x)
                let a = CGFloat(ptr[i + 3]) / 255.0
                if a > 0 {
                    if (x < minX) { minX = x }
                    if (x > maxX) { maxX = x }
                    if (y < minY) { minY = y }
                    if (y > maxY) { maxY = y }
                }
            }
        }
        
        let rect = CGRect(x: CGFloat(minX),y: CGFloat(minY), width: CGFloat(maxX-minX), height: CGFloat(maxY-minY))
        let imageScale = scale
        guard let croppedImage = cgImageObject.cropping(to: rect) else { return self }
        return UIImage(cgImage: croppedImage, scale: imageScale, orientation: imageOrientation)
    }
}
