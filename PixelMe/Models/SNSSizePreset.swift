//
//  SNSSizePreset.swift
//  PixelMe
//
//  Created by hyunho lee on 2026/03/01.
//

import UIKit

/// SNS platform size presets for pixel art export
enum SNSSizePreset: String, CaseIterable, Identifiable {
    case original = "Original"
    case instagramStory = "Instagram Story"
    case instagramFeed = "Instagram Feed"
    case instagramReels = "Instagram Reels"
    case tiktok = "TikTok"
    case twitterX = "Twitter / X"
    case phoneWallpaper = "Phone Wallpaper"

    var id: String { rawValue }

    /// Target size in pixels (width x height)
    var size: CGSize {
        switch self {
        case .original:
            return .zero
        case .instagramStory, .instagramReels, .tiktok:
            return CGSize(width: 1080, height: 1920)
        case .instagramFeed:
            return CGSize(width: 1080, height: 1080)
        case .twitterX:
            return CGSize(width: 1200, height: 675)
        case .phoneWallpaper:
            return UIScreen.main.nativeBounds.size
        }
    }

    var icon: String {
        switch self {
        case .original: return "photo"
        case .instagramStory, .instagramFeed, .instagramReels: return "camera"
        case .tiktok: return "play.rectangle"
        case .twitterX: return "bubble.left"
        case .phoneWallpaper: return "iphone"
        }
    }

    var sizeLabel: String {
        switch self {
        case .original:
            return "As-is"
        case .phoneWallpaper:
            let s = size
            return "\(Int(s.width))×\(Int(s.height))"
        default:
            return "\(Int(size.width))×\(Int(size.height))"
        }
    }

    /// Resize image using nearest-neighbor interpolation to preserve pixel art quality
    static func resizeImageNearestNeighbor(_ image: UIImage, to targetSize: CGSize) -> UIImage {
        guard let cgImage = image.cgImage else { return image }

        let width = Int(targetSize.width)
        let height = Int(targetSize.height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return image }

        // Nearest neighbor – critical for pixel art
        context.interpolationQuality = .none

        // Calculate aspect-fit rect
        let sourceAspect = CGFloat(cgImage.width) / CGFloat(cgImage.height)
        let targetAspect = targetSize.width / targetSize.height

        var drawRect: CGRect
        if sourceAspect > targetAspect {
            // Source is wider – fit width
            let drawWidth = targetSize.width
            let drawHeight = drawWidth / sourceAspect
            let yOffset = (targetSize.height - drawHeight) / 2
            drawRect = CGRect(x: 0, y: yOffset, width: drawWidth, height: drawHeight)
        } else {
            // Source is taller – fit height
            let drawHeight = targetSize.height
            let drawWidth = drawHeight * sourceAspect
            let xOffset = (targetSize.width - drawWidth) / 2
            drawRect = CGRect(x: xOffset, y: 0, width: drawWidth, height: drawHeight)
        }

        // Fill background black
        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        context.draw(cgImage, in: drawRect)

        guard let outputCGImage = context.makeImage() else { return image }
        return UIImage(cgImage: outputCGImage)
    }
}
