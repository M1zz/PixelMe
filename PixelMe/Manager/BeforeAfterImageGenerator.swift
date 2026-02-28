//
//  BeforeAfterImageGenerator.swift
//  PixelMe
//
//  Before/After comparison image generator for sharing
//

import UIKit

class BeforeAfterImageGenerator {
    
    /// Generate a side-by-side before/after comparison image
    static func generate(original: UIImage, pixelated: UIImage, outputWidth: CGFloat = 1200) -> UIImage? {
        let padding: CGFloat = 20
        let dividerWidth: CGFloat = 2
        let brandingHeight: CGFloat = 40
        let arrowWidth: CGFloat = 40
        
        // Each image takes half the width minus padding and divider
        let imageSize = (outputWidth - padding * 3 - dividerWidth - arrowWidth) / 2
        let totalHeight = padding * 2 + imageSize + brandingHeight
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: outputWidth, height: totalHeight))
        
        return renderer.image { context in
            let ctx = context.cgContext
            
            // Background
            UIColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0).setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: outputWidth, height: totalHeight))
            
            // Draw original image (left)
            let leftRect = CGRect(x: padding, y: padding, width: imageSize, height: imageSize)
            
            // Rounded rect clip for left image
            let leftPath = UIBezierPath(roundedRect: leftRect, cornerRadius: 12)
            ctx.saveGState()
            leftPath.addClip()
            original.draw(in: leftRect)
            ctx.restoreGState()
            
            // Draw arrow in the middle
            let arrowX = padding + imageSize + padding / 2
            let arrowY = padding + imageSize / 2
            
            let arrowString = "→"
            let arrowAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.8)
            ]
            let arrowSize = arrowString.size(withAttributes: arrowAttributes)
            arrowString.draw(
                at: CGPoint(x: arrowX + (arrowWidth - arrowSize.width) / 2, y: arrowY - arrowSize.height / 2),
                withAttributes: arrowAttributes
            )
            
            // Draw divider line (thin vertical line)
            // Skip explicit divider since arrow serves as separator
            
            // Draw pixelated image (right)
            let rightRect = CGRect(
                x: padding + imageSize + padding + arrowWidth,
                y: padding,
                width: imageSize,
                height: imageSize
            )
            
            let rightPath = UIBezierPath(roundedRect: rightRect, cornerRadius: 12)
            ctx.saveGState()
            rightPath.addClip()
            pixelated.draw(in: rightRect)
            ctx.restoreGState()
            
            // Labels
            let labelAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 13, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(0.6)
            ]
            
            let beforeText = "Before"
            let beforeSize = beforeText.size(withAttributes: labelAttributes)
            beforeText.draw(
                at: CGPoint(x: padding + (imageSize - beforeSize.width) / 2, y: padding + imageSize + 4),
                withAttributes: labelAttributes
            )
            
            let afterText = "After"
            let afterSize = afterText.size(withAttributes: labelAttributes)
            afterText.draw(
                at: CGPoint(x: rightRect.minX + (imageSize - afterSize.width) / 2, y: padding + imageSize + 4),
                withAttributes: labelAttributes
            )
            
            // Branding at bottom
            let brandingAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.4)
            ]
            let brandingText = "PixelMe"
            let brandingSize = brandingText.size(withAttributes: brandingAttributes)
            brandingText.draw(
                at: CGPoint(
                    x: (outputWidth - brandingSize.width) / 2,
                    y: totalHeight - brandingHeight + (brandingHeight - brandingSize.height) / 2
                ),
                withAttributes: brandingAttributes
            )
        }
    }
}
