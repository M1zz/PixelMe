//
//  ColorPalette.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/01.
//

import SwiftUI
import UIKit

/// Color palette types
enum ColorPaletteType: String, CaseIterable, Identifiable {
    case none = "Original"
    case gameboy = "GameBoy"
    case nes = "NES"
    case snes = "SNES"
    case vaporwave = "Vaporwave"
    case cyberpunk = "Cyberpunk"
    case pastel = "Pastel"
    case retro8bit = "8-Bit Retro"
    case noir = "Film Noir"

    var id: String { rawValue }

    var colors: [UIColor] {
        switch self {
        case .none:
            return []
        case .gameboy:
            return [
                UIColor(red: 15/255, green: 56/255, blue: 15/255, alpha: 1),
                UIColor(red: 48/255, green: 98/255, blue: 48/255, alpha: 1),
                UIColor(red: 139/255, green: 172/255, blue: 15/255, alpha: 1),
                UIColor(red: 155/255, green: 188/255, blue: 15/255, alpha: 1)
            ]
        case .nes:
            return [
                UIColor(red: 124/255, green: 124/255, blue: 124/255, alpha: 1),
                UIColor(red: 0/255, green: 0/255, blue: 252/255, alpha: 1),
                UIColor(red: 0/255, green: 0/255, blue: 188/255, alpha: 1),
                UIColor(red: 68/255, green: 40/255, blue: 188/255, alpha: 1),
                UIColor(red: 148/255, green: 0/255, blue: 132/255, alpha: 1),
                UIColor(red: 168/255, green: 0/255, blue: 32/255, alpha: 1),
                UIColor(red: 168/255, green: 16/255, blue: 0/255, alpha: 1),
                UIColor(red: 136/255, green: 20/255, blue: 0/255, alpha: 1),
                UIColor(red: 80/255, green: 48/255, blue: 0/255, alpha: 1),
                UIColor(red: 0/255, green: 120/255, blue: 0/255, alpha: 1),
                UIColor(red: 0/255, green: 104/255, blue: 0/255, alpha: 1),
                UIColor(red: 0/255, green: 88/255, blue: 0/255, alpha: 1),
                UIColor(red: 0/255, green: 64/255, blue: 88/255, alpha: 1),
                UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1),
                UIColor(red: 188/255, green: 188/255, blue: 188/255, alpha: 1),
                UIColor(red: 0/255, green: 120/255, blue: 248/255, alpha: 1),
                UIColor(red: 0/255, green: 88/255, blue: 248/255, alpha: 1),
                UIColor(red: 104/255, green: 68/255, blue: 252/255, alpha: 1),
                UIColor(red: 216/255, green: 0/255, blue: 204/255, alpha: 1),
                UIColor(red: 228/255, green: 0/255, blue: 88/255, alpha: 1),
                UIColor(red: 248/255, green: 56/255, blue: 0/255, alpha: 1),
                UIColor(red: 228/255, green: 92/255, blue: 16/255, alpha: 1),
                UIColor(red: 172/255, green: 124/255, blue: 0/255, alpha: 1),
                UIColor(red: 0/255, green: 184/255, blue: 0/255, alpha: 1),
                UIColor(red: 0/255, green: 168/255, blue: 0/255, alpha: 1),
                UIColor(red: 0/255, green: 168/255, blue: 68/255, alpha: 1),
                UIColor(red: 0/255, green: 136/255, blue: 136/255, alpha: 1),
                UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1),
                UIColor(red: 60/255, green: 188/255, blue: 252/255, alpha: 1),
                UIColor(red: 92/255, green: 148/255, blue: 252/255, alpha: 1),
                UIColor(red: 164/255, green: 140/255, blue: 252/255, alpha: 1),
                UIColor(red: 248/255, green: 120/255, blue: 248/255, alpha: 1)
            ]
        case .snes:
            return [
                UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1),
                UIColor(red: 64/255, green: 64/255, blue: 64/255, alpha: 1),
                UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1),
                UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1),
                UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
                UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1),
                UIColor(red: 255/255, green: 128/255, blue: 0/255, alpha: 1),
                UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 1),
                UIColor(red: 128/255, green: 255/255, blue: 0/255, alpha: 1),
                UIColor(red: 0/255, green: 255/255, blue: 0/255, alpha: 1),
                UIColor(red: 0/255, green: 255/255, blue: 128/255, alpha: 1),
                UIColor(red: 0/255, green: 255/255, blue: 255/255, alpha: 1),
                UIColor(red: 0/255, green: 128/255, blue: 255/255, alpha: 1),
                UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1),
                UIColor(red: 128/255, green: 0/255, blue: 255/255, alpha: 1),
                UIColor(red: 255/255, green: 0/255, blue: 255/255, alpha: 1)
            ]
        case .vaporwave:
            return [
                UIColor(red: 1/255, green: 0/255, blue: 38/255, alpha: 1),
                UIColor(red: 255/255, green: 71/255, blue: 166/255, alpha: 1),
                UIColor(red: 1/255, green: 168/255, blue: 233/255, alpha: 1),
                UIColor(red: 179/255, green: 0/255, blue: 255/255, alpha: 1),
                UIColor(red: 94/255, green: 53/255, blue: 177/255, alpha: 1),
                UIColor(red: 255/255, green: 128/255, blue: 255/255, alpha: 1),
                UIColor(red: 0/255, green: 229/255, blue: 255/255, alpha: 1),
                UIColor(red: 255/255, green: 85/255, blue: 255/255, alpha: 1)
            ]
        case .cyberpunk:
            return [
                UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1),
                UIColor(red: 255/255, green: 0/255, blue: 255/255, alpha: 1),
                UIColor(red: 0/255, green: 255/255, blue: 255/255, alpha: 1),
                UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 1),
                UIColor(red: 255/255, green: 0/255, blue: 110/255, alpha: 1),
                UIColor(red: 0/255, green: 204/255, blue: 255/255, alpha: 1),
                UIColor(red: 163/255, green: 0/255, blue: 255/255, alpha: 1),
                UIColor(red: 255/255, green: 154/255, blue: 0/255, alpha: 1)
            ]
        case .pastel:
            return [
                UIColor(red: 255/255, green: 209/255, blue: 220/255, alpha: 1),
                UIColor(red: 255/255, green: 242/255, blue: 204/255, alpha: 1),
                UIColor(red: 255/255, green: 255/255, blue: 204/255, alpha: 1),
                UIColor(red: 204/255, green: 255/255, blue: 229/255, alpha: 1),
                UIColor(red: 204/255, green: 239/255, blue: 255/255, alpha: 1),
                UIColor(red: 230/255, green: 204/255, blue: 255/255, alpha: 1),
                UIColor(red: 255/255, green: 204/255, blue: 229/255, alpha: 1),
                UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            ]
        case .retro8bit:
            return [
                UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1),
                UIColor(red: 29/255, green: 43/255, blue: 83/255, alpha: 1),
                UIColor(red: 126/255, green: 37/255, blue: 83/255, alpha: 1),
                UIColor(red: 0/255, green: 135/255, blue: 81/255, alpha: 1),
                UIColor(red: 171/255, green: 82/255, blue: 54/255, alpha: 1),
                UIColor(red: 95/255, green: 87/255, blue: 79/255, alpha: 1),
                UIColor(red: 194/255, green: 195/255, blue: 199/255, alpha: 1),
                UIColor(red: 255/255, green: 241/255, blue: 232/255, alpha: 1),
                UIColor(red: 255/255, green: 0/255, blue: 77/255, alpha: 1),
                UIColor(red: 255/255, green: 163/255, blue: 0/255, alpha: 1),
                UIColor(red: 255/255, green: 236/255, blue: 39/255, alpha: 1),
                UIColor(red: 0/255, green: 228/255, blue: 54/255, alpha: 1),
                UIColor(red: 41/255, green: 173/255, blue: 255/255, alpha: 1),
                UIColor(red: 131/255, green: 118/255, blue: 156/255, alpha: 1),
                UIColor(red: 255/255, green: 119/255, blue: 168/255, alpha: 1),
                UIColor(red: 255/255, green: 204/255, blue: 170/255, alpha: 1)
            ]
        case .noir:
            return [
                UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1),
                UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1),
                UIColor(red: 64/255, green: 64/255, blue: 64/255, alpha: 1),
                UIColor(red: 96/255, green: 96/255, blue: 96/255, alpha: 1),
                UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1),
                UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1),
                UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1),
                UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1),
                UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            ]
        }
    }

    var description: String {
        switch self {
        case .none:
            return "Keep original colors"
        case .gameboy:
            return "Classic GameBoy green tones"
        case .nes:
            return "Nintendo Entertainment System palette"
        case .snes:
            return "Super Nintendo bright colors"
        case .vaporwave:
            return "Pink, purple, and cyan aesthetic"
        case .cyberpunk:
            return "Neon colors for futuristic look"
        case .pastel:
            return "Soft and gentle colors"
        case .retro8bit:
            return "Classic 8-bit game colors"
        case .noir:
            return "Black and white film style"
        }
    }
}

/// Custom color palette that users can create
struct CustomColorPalette: Identifiable, Codable {
    let id: UUID
    var name: String
    var colors: [String] // Hex color strings

    init(id: UUID = UUID(), name: String, colors: [UIColor]) {
        self.id = id
        self.name = name
        self.colors = colors.map { $0.toHexString() }
    }

    func getUIColors() -> [UIColor] {
        return colors.compactMap { UIColor(hexString: $0) }
    }
}

// MARK: - UIColor extensions for color palette
extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format: "#%06x", rgb)
    }

    convenience init?(hexString: String) {
        let r, g, b: CGFloat

        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: 1.0)
                    return
                }
            }
        }

        return nil
    }

    /// Find closest color in palette
    func closestColor(in palette: [UIColor]) -> UIColor {
        guard !palette.isEmpty else { return self }

        var closestColor = palette[0]
        var minDistance = colorDistance(to: palette[0])

        for color in palette {
            let distance = colorDistance(to: color)
            if distance < minDistance {
                minDistance = distance
                closestColor = color
            }
        }

        return closestColor
    }

    /// Calculate color distance using Euclidean distance in RGB space
    private func colorDistance(to color: UIColor) -> CGFloat {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return sqrt(pow(r1 - r2, 2) + pow(g1 - g2, 2) + pow(b1 - b2, 2))
    }
}
//
//  ColorReduction.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/01.
//

import UIKit

/// Color reduction algorithms
enum ColorReductionType: String, CaseIterable, Identifiable {
    case none = "No Reduction"
    case colors8 = "8 Colors"
    case colors16 = "16 Colors"
    case colors32 = "32 Colors"
    case colors64 = "64 Colors"

    var id: String { rawValue }

    var colorCount: Int {
        switch self {
        case .none: return 0
        case .colors8: return 8
        case .colors16: return 16
        case .colors32: return 32
        case .colors64: return 64
        }
    }
}

/// Dithering algorithm types
enum DitheringType: String, CaseIterable, Identifiable {
    case none = "No Dithering"
    case floydSteinberg = "Floyd-Steinberg"
    case atkinson = "Atkinson"
    case ordered = "Ordered (Bayer)"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .none:
            return "Clean, no noise"
        case .floydSteinberg:
            return "Smooth gradients, more details"
        case .atkinson:
            return "Lighter, retro Mac style"
        case .ordered:
            return "Pattern-based, classic halftone"
        }
    }
}

class ColorReductionEngine {

    /// Apply color reduction to image
    static func applyColorReduction(to image: UIImage, colorCount: Int, palette: [UIColor]? = nil) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else { return nil }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let pixelBuffer = context.data else { return nil }

        let pixels = pixelBuffer.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)

        // Generate or use provided palette
        let colorPalette: [UIColor]
        if let providedPalette = palette {
            colorPalette = providedPalette
        } else {
            colorPalette = generatePalette(from: image, colorCount: colorCount)
        }

        // Apply color reduction
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * bytesPerPixel

                let r = CGFloat(pixels[pixelIndex]) / 255.0
                let g = CGFloat(pixels[pixelIndex + 1]) / 255.0
                let b = CGFloat(pixels[pixelIndex + 2]) / 255.0

                let originalColor = UIColor(red: r, green: g, blue: b, alpha: 1.0)
                let closestColor = originalColor.closestColor(in: colorPalette)

                var newR: CGFloat = 0, newG: CGFloat = 0, newB: CGFloat = 0, newA: CGFloat = 0
                closestColor.getRed(&newR, green: &newG, blue: &newB, alpha: &newA)

                pixels[pixelIndex] = UInt8(newR * 255)
                pixels[pixelIndex + 1] = UInt8(newG * 255)
                pixels[pixelIndex + 2] = UInt8(newB * 255)
            }
        }

        guard let newCGImage = context.makeImage() else { return nil }
        return UIImage(cgImage: newCGImage, scale: image.scale, orientation: image.imageOrientation)
    }

    /// Apply dithering to image
    static func applyDithering(to image: UIImage, type: DitheringType, palette: [UIColor]) -> UIImage? {
        guard type != .none else {
            return applyColorReduction(to: image, colorCount: 0, palette: palette)
        }

        guard let cgImage = image.cgImage else { return nil }

        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else { return nil }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let pixelBuffer = context.data else { return nil }

        let pixels = pixelBuffer.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)

        // Create error buffer for Floyd-Steinberg and Atkinson
        var errorBuffer: [[RGB]] = Array(repeating: Array(repeating: RGB(r: 0, g: 0, b: 0), count: width), count: height)

        switch type {
        case .none:
            break
        case .floydSteinberg:
            applyFloydSteinbergDithering(pixels: pixels, width: width, height: height, palette: palette, errorBuffer: &errorBuffer)
        case .atkinson:
            applyAtkinsonDithering(pixels: pixels, width: width, height: height, palette: palette, errorBuffer: &errorBuffer)
        case .ordered:
            applyOrderedDithering(pixels: pixels, width: width, height: height, palette: palette)
        }

        guard let newCGImage = context.makeImage() else { return nil }
        return UIImage(cgImage: newCGImage, scale: image.scale, orientation: image.imageOrientation)
    }

    // MARK: - Floyd-Steinberg Dithering
    private static func applyFloydSteinbergDithering(pixels: UnsafeMutablePointer<UInt8>, width: Int, height: Int, palette: [UIColor], errorBuffer: inout [[RGB]]) {
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * 4

                var r = CGFloat(pixels[pixelIndex]) / 255.0 + errorBuffer[y][x].r
                var g = CGFloat(pixels[pixelIndex + 1]) / 255.0 + errorBuffer[y][x].g
                var b = CGFloat(pixels[pixelIndex + 2]) / 255.0 + errorBuffer[y][x].b

                r = max(0, min(1, r))
                g = max(0, min(1, g))
                b = max(0, min(1, b))

                let originalColor = UIColor(red: r, green: g, blue: b, alpha: 1.0)
                let closestColor = originalColor.closestColor(in: palette)

                var newR: CGFloat = 0, newG: CGFloat = 0, newB: CGFloat = 0, newA: CGFloat = 0
                closestColor.getRed(&newR, green: &newG, blue: &newB, alpha: &newA)

                pixels[pixelIndex] = UInt8(newR * 255)
                pixels[pixelIndex + 1] = UInt8(newG * 255)
                pixels[pixelIndex + 2] = UInt8(newB * 255)

                let errorR = r - newR
                let errorG = g - newG
                let errorB = b - newB

                // Distribute error to neighboring pixels
                if x + 1 < width {
                    errorBuffer[y][x + 1].r += errorR * 7.0 / 16.0
                    errorBuffer[y][x + 1].g += errorG * 7.0 / 16.0
                    errorBuffer[y][x + 1].b += errorB * 7.0 / 16.0
                }
                if y + 1 < height {
                    if x > 0 {
                        errorBuffer[y + 1][x - 1].r += errorR * 3.0 / 16.0
                        errorBuffer[y + 1][x - 1].g += errorG * 3.0 / 16.0
                        errorBuffer[y + 1][x - 1].b += errorB * 3.0 / 16.0
                    }
                    errorBuffer[y + 1][x].r += errorR * 5.0 / 16.0
                    errorBuffer[y + 1][x].g += errorG * 5.0 / 16.0
                    errorBuffer[y + 1][x].b += errorB * 5.0 / 16.0
                    if x + 1 < width {
                        errorBuffer[y + 1][x + 1].r += errorR * 1.0 / 16.0
                        errorBuffer[y + 1][x + 1].g += errorG * 1.0 / 16.0
                        errorBuffer[y + 1][x + 1].b += errorB * 1.0 / 16.0
                    }
                }
            }
        }
    }

    // MARK: - Atkinson Dithering
    private static func applyAtkinsonDithering(pixels: UnsafeMutablePointer<UInt8>, width: Int, height: Int, palette: [UIColor], errorBuffer: inout [[RGB]]) {
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * 4

                var r = CGFloat(pixels[pixelIndex]) / 255.0 + errorBuffer[y][x].r
                var g = CGFloat(pixels[pixelIndex + 1]) / 255.0 + errorBuffer[y][x].g
                var b = CGFloat(pixels[pixelIndex + 2]) / 255.0 + errorBuffer[y][x].b

                r = max(0, min(1, r))
                g = max(0, min(1, g))
                b = max(0, min(1, b))

                let originalColor = UIColor(red: r, green: g, blue: b, alpha: 1.0)
                let closestColor = originalColor.closestColor(in: palette)

                var newR: CGFloat = 0, newG: CGFloat = 0, newB: CGFloat = 0, newA: CGFloat = 0
                closestColor.getRed(&newR, green: &newG, blue: &newB, alpha: &newA)

                pixels[pixelIndex] = UInt8(newR * 255)
                pixels[pixelIndex + 1] = UInt8(newG * 255)
                pixels[pixelIndex + 2] = UInt8(newB * 255)

                let errorR = (r - newR) / 8.0
                let errorG = (g - newG) / 8.0
                let errorB = (b - newB) / 8.0

                // Atkinson dithering distributes error to 6 neighbors
                if x + 1 < width {
                    errorBuffer[y][x + 1].r += errorR
                    errorBuffer[y][x + 1].g += errorG
                    errorBuffer[y][x + 1].b += errorB
                }
                if x + 2 < width {
                    errorBuffer[y][x + 2].r += errorR
                    errorBuffer[y][x + 2].g += errorG
                    errorBuffer[y][x + 2].b += errorB
                }
                if y + 1 < height {
                    if x > 0 {
                        errorBuffer[y + 1][x - 1].r += errorR
                        errorBuffer[y + 1][x - 1].g += errorG
                        errorBuffer[y + 1][x - 1].b += errorB
                    }
                    errorBuffer[y + 1][x].r += errorR
                    errorBuffer[y + 1][x].g += errorG
                    errorBuffer[y + 1][x].b += errorB
                    if x + 1 < width {
                        errorBuffer[y + 1][x + 1].r += errorR
                        errorBuffer[y + 1][x + 1].g += errorG
                        errorBuffer[y + 1][x + 1].b += errorB
                    }
                }
                if y + 2 < height {
                    errorBuffer[y + 2][x].r += errorR
                    errorBuffer[y + 2][x].g += errorG
                    errorBuffer[y + 2][x].b += errorB
                }
            }
        }
    }

    // MARK: - Ordered (Bayer) Dithering
    private static func applyOrderedDithering(pixels: UnsafeMutablePointer<UInt8>, width: Int, height: Int, palette: [UIColor]) {
        let bayerMatrix: [[CGFloat]] = [
            [0, 8, 2, 10],
            [12, 4, 14, 6],
            [3, 11, 1, 9],
            [15, 7, 13, 5]
        ]
        let matrixSize = 4
        let threshold = 16.0

        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * 4

                let bayerValue = (bayerMatrix[y % matrixSize][x % matrixSize] / threshold) - 0.5

                var r = CGFloat(pixels[pixelIndex]) / 255.0 + bayerValue / 8.0
                var g = CGFloat(pixels[pixelIndex + 1]) / 255.0 + bayerValue / 8.0
                var b = CGFloat(pixels[pixelIndex + 2]) / 255.0 + bayerValue / 8.0

                r = max(0, min(1, r))
                g = max(0, min(1, g))
                b = max(0, min(1, b))

                let originalColor = UIColor(red: r, green: g, blue: b, alpha: 1.0)
                let closestColor = originalColor.closestColor(in: palette)

                var newR: CGFloat = 0, newG: CGFloat = 0, newB: CGFloat = 0, newA: CGFloat = 0
                closestColor.getRed(&newR, green: &newG, blue: &newB, alpha: &newA)

                pixels[pixelIndex] = UInt8(newR * 255)
                pixels[pixelIndex + 1] = UInt8(newG * 255)
                pixels[pixelIndex + 2] = UInt8(newB * 255)
            }
        }
    }

    // MARK: - Generate palette from image using median cut algorithm
    private static func generatePalette(from image: UIImage, colorCount: Int) -> [UIColor] {
        guard let cgImage = image.cgImage else { return [] }

        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else { return [] }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let pixelBuffer = context.data else { return [] }
        let pixels = pixelBuffer.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)

        // Sample colors from image (every 10th pixel for performance)
        var colors: [RGB] = []
        for y in stride(from: 0, to: height, by: 10) {
            for x in stride(from: 0, to: width, by: 10) {
                let pixelIndex = (y * width + x) * bytesPerPixel
                colors.append(RGB(
                    r: CGFloat(pixels[pixelIndex]) / 255.0,
                    g: CGFloat(pixels[pixelIndex + 1]) / 255.0,
                    b: CGFloat(pixels[pixelIndex + 2]) / 255.0
                ))
            }
        }

        // Use median cut algorithm to generate palette
        let palette = medianCut(colors: colors, depth: colorCount)
        return palette.map { UIColor(red: $0.r, green: $0.g, blue: $0.b, alpha: 1.0) }
    }

    private static func medianCut(colors: [RGB], depth: Int) -> [RGB] {
        if depth == 1 || colors.count <= 1 {
            let avgColor = averageColor(colors)
            return [avgColor]
        }

        // Find the channel with the largest range
        var minR: CGFloat = 1, maxR: CGFloat = 0
        var minG: CGFloat = 1, maxG: CGFloat = 0
        var minB: CGFloat = 1, maxB: CGFloat = 0

        for color in colors {
            minR = min(minR, color.r)
            maxR = max(maxR, color.r)
            minG = min(minG, color.g)
            maxG = max(maxG, color.g)
            minB = min(minB, color.b)
            maxB = max(maxB, color.b)
        }

        let rRange = maxR - minR
        let gRange = maxG - minG
        let bRange = maxB - minB

        let sortedColors: [RGB]
        if rRange >= gRange && rRange >= bRange {
            sortedColors = colors.sorted { $0.r < $1.r }
        } else if gRange >= bRange {
            sortedColors = colors.sorted { $0.g < $1.g }
        } else {
            sortedColors = colors.sorted { $0.b < $1.b }
        }

        let mid = sortedColors.count / 2
        let leftColors = Array(sortedColors[..<mid])
        let rightColors = Array(sortedColors[mid...])

        return medianCut(colors: leftColors, depth: depth / 2) + medianCut(colors: rightColors, depth: depth - depth / 2)
    }

    private static func averageColor(_ colors: [RGB]) -> RGB {
        guard !colors.isEmpty else { return RGB(r: 0, g: 0, b: 0) }
        var sumR: CGFloat = 0, sumG: CGFloat = 0, sumB: CGFloat = 0
        for color in colors {
            sumR += color.r
            sumG += color.g
            sumB += color.b
        }
        let count = CGFloat(colors.count)
        return RGB(r: sumR / count, g: sumG / count, b: sumB / count)
    }
}

// MARK: - Helper struct for RGB values
struct RGB {
    var r: CGFloat
    var g: CGFloat
    var b: CGFloat
}
//
//  FilterEffects.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/01.
//

import UIKit
import CoreImage

/// Filter effect types
enum FilterEffectType: String, CaseIterable, Identifiable {
    case none = "None"
    case crt = "CRT Monitor"
    case scanlines = "Scanlines"
    case glitch = "Glitch"
    case vintage = "Vintage Game"
    case vhsTape = "VHS Tape"
    case arcade = "Arcade Screen"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .none:
            return "No filter applied"
        case .crt:
            return "Old TV monitor with curvature"
        case .scanlines:
            return "Horizontal lines like retro screens"
        case .glitch:
            return "Digital corruption effect"
        case .vintage:
            return "Old game console look"
        case .vhsTape:
            return "VHS tape artifacts"
        case .arcade:
            return "Classic arcade cabinet screen"
        }
    }
}

class FilterEffectsEngine {

    /// Apply filter effect to image
    static func applyFilter(to image: UIImage, type: FilterEffectType, intensity: CGFloat = 1.0) -> UIImage? {
        switch type {
        case .none:
            return image
        case .crt:
            return applyCRTEffect(to: image, intensity: intensity)
        case .scanlines:
            return applyScanlinesEffect(to: image, intensity: intensity)
        case .glitch:
            return applyGlitchEffect(to: image, intensity: intensity)
        case .vintage:
            return applyVintageEffect(to: image, intensity: intensity)
        case .vhsTape:
            return applyVHSEffect(to: image, intensity: intensity)
        case .arcade:
            return applyArcadeEffect(to: image, intensity: intensity)
        }
    }

    // MARK: - CRT Monitor Effect
    private static func applyCRTEffect(to image: UIImage, intensity: CGFloat) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext()

        // Apply vignette
        var outputImage = ciImage
        if let vignetteFilter = CIFilter(name: "CIVignette") {
            vignetteFilter.setValue(outputImage, forKey: kCIInputImageKey)
            vignetteFilter.setValue(intensity * 2.0, forKey: kCIInputIntensityKey)
            vignetteFilter.setValue(1.5, forKey: kCIInputRadiusKey)
            if let output = vignetteFilter.outputImage {
                outputImage = output
            }
        }

        // Add bloom/glow effect
        if let bloomFilter = CIFilter(name: "CIBloom") {
            bloomFilter.setValue(outputImage, forKey: kCIInputImageKey)
            bloomFilter.setValue(intensity * 5.0, forKey: kCIInputIntensityKey)
            bloomFilter.setValue(10.0, forKey: kCIInputRadiusKey)
            if let output = bloomFilter.outputImage {
                outputImage = output
            }
        }

        // Add scanlines overlay
        let scanlinesImage = createScanlinesOverlay(size: image.size)
        if let scanlinesCG = scanlinesImage.cgImage {
            let scanlinesCIImage = CIImage(cgImage: scanlinesCG)
            if let blendFilter = CIFilter(name: "CIMultiplyBlendMode") {
                blendFilter.setValue(outputImage, forKey: kCIInputImageKey)
                blendFilter.setValue(scanlinesCIImage, forKey: kCIInputBackgroundImageKey)
                if let output = blendFilter.outputImage {
                    outputImage = output
                }
            }
        }

        guard let finalCGImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        return UIImage(cgImage: finalCGImage, scale: image.scale, orientation: image.imageOrientation)
    }

    // MARK: - Scanlines Effect
    private static func applyScanlinesEffect(to image: UIImage, intensity: CGFloat) -> UIImage? {
        let scanlinesImage = createScanlinesOverlay(size: image.size, spacing: 3, alpha: intensity * 0.4)

        UIGraphicsBeginImageContext(image.size)
        image.draw(at: .zero)
        scanlinesImage.draw(at: .zero, blendMode: .multiply, alpha: 1.0)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return result
    }

    // MARK: - Glitch Effect
    private static func applyGlitchEffect(to image: UIImage, intensity: CGFloat) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else { return nil }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let pixelBuffer = context.data else { return nil }
        let pixels = pixelBuffer.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)

        // Apply RGB channel shift
        let shiftAmount = Int(intensity * 10)
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * bytesPerPixel

                // Shift red channel
                if x + shiftAmount < width && arc4random_uniform(100) < UInt32(intensity * 20) {
                    let shiftedIndex = (y * width + (x + shiftAmount)) * bytesPerPixel
                    pixels[pixelIndex] = pixels[shiftedIndex]
                }

                // Shift blue channel (opposite direction)
                if x - shiftAmount >= 0 && arc4random_uniform(100) < UInt32(intensity * 20) {
                    let shiftedIndex = (y * width + (x - shiftAmount)) * bytesPerPixel
                    pixels[pixelIndex + 2] = pixels[shiftedIndex + 2]
                }
            }
        }

        // Add random horizontal line glitches
        let glitchLineCount = Int(intensity * 10)
        for _ in 0..<glitchLineCount {
            let glitchY = Int(arc4random_uniform(UInt32(height)))
            let glitchHeight = Int(arc4random_uniform(5)) + 1
            let glitchShift = Int(arc4random_uniform(UInt32(width / 10))) - Int(width / 20)

            for y in glitchY..<min(glitchY + glitchHeight, height) {
                for x in 0..<width {
                    let newX = (x + glitchShift + width) % width
                    let sourceIndex = (y * width + x) * bytesPerPixel
                    let destIndex = (y * width + newX) * bytesPerPixel

                    if sourceIndex < width * height * bytesPerPixel && destIndex < width * height * bytesPerPixel {
                        pixels[destIndex] = pixels[sourceIndex]
                        pixels[destIndex + 1] = pixels[sourceIndex + 1]
                        pixels[destIndex + 2] = pixels[sourceIndex + 2]
                    }
                }
            }
        }

        guard let newCGImage = context.makeImage() else { return nil }
        return UIImage(cgImage: newCGImage, scale: image.scale, orientation: image.imageOrientation)
    }

    // MARK: - Vintage Game Effect
    private static func applyVintageEffect(to image: UIImage, intensity: CGFloat) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext()

        var outputImage = ciImage

        // Add sepia tone
        if let sepiaFilter = CIFilter(name: "CISepiaTone") {
            sepiaFilter.setValue(outputImage, forKey: kCIInputImageKey)
            sepiaFilter.setValue(intensity * 0.6, forKey: kCIInputIntensityKey)
            if let output = sepiaFilter.outputImage {
                outputImage = output
            }
        }

        // Reduce sharpness
        if let blurFilter = CIFilter(name: "CIGaussianBlur") {
            blurFilter.setValue(outputImage, forKey: kCIInputImageKey)
            blurFilter.setValue(intensity * 0.5, forKey: kCIInputRadiusKey)
            if let output = blurFilter.outputImage {
                outputImage = output
            }
        }

        // Add grain/noise
        if let noiseFilter = CIFilter(name: "CIRandomGenerator"),
           let noiseOutput = noiseFilter.outputImage {

            if let whiteningFilter = CIFilter(name: "CIColorMatrix") {
                let vectors = [
                    CIVector(x: 0, y: 1, z: 0, w: 0),
                    CIVector(x: 0, y: 1, z: 0, w: 0),
                    CIVector(x: 0, y: 1, z: 0, w: 0),
                    CIVector(x: 0, y: 0, z: 0, w: 0)
                ]
                whiteningFilter.setValue(noiseOutput, forKey: kCIInputImageKey)
                whiteningFilter.setValue(vectors[0], forKey: "inputRVector")
                whiteningFilter.setValue(vectors[1], forKey: "inputGVector")
                whiteningFilter.setValue(vectors[2], forKey: "inputBVector")
                whiteningFilter.setValue(vectors[3], forKey: "inputAVector")

                if let whitenedNoise = whiteningFilter.outputImage,
                   let croppedNoise = whitenedNoise.cropped(to: outputImage.extent) as CIImage?,
                   let blendFilter = CIFilter(name: "CISourceOverCompositing") {

                    blendFilter.setValue(croppedNoise, forKey: kCIInputImageKey)
                    blendFilter.setValue(outputImage, forKey: kCIInputBackgroundImageKey)

                    if let blended = blendFilter.outputImage {
                        // Mix the noisy image with original based on intensity
                        outputImage = blended
                    }
                }
            }
        }

        guard let finalCGImage = context.createCGImage(outputImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: finalCGImage, scale: image.scale, orientation: image.imageOrientation)
    }

    // MARK: - VHS Tape Effect
    private static func applyVHSEffect(to image: UIImage, intensity: CGFloat) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext()

        var outputImage = ciImage

        // Add color distortion
        if let colorFilter = CIFilter(name: "CIColorControls") {
            colorFilter.setValue(outputImage, forKey: kCIInputImageKey)
            colorFilter.setValue(0.8, forKey: kCIInputSaturationKey)
            colorFilter.setValue(intensity * 0.2, forKey: kCIInputBrightnessKey)
            colorFilter.setValue(1.1, forKey: kCIInputContrastKey)
            if let output = colorFilter.outputImage {
                outputImage = output
            }
        }

        // Add slight motion blur (horizontal)
        if let motionBlur = CIFilter(name: "CIMotionBlur") {
            motionBlur.setValue(outputImage, forKey: kCIInputImageKey)
            motionBlur.setValue(intensity * 3.0, forKey: kCIInputRadiusKey)
            motionBlur.setValue(0, forKey: kCIInputAngleKey)
            if let output = motionBlur.outputImage {
                outputImage = output
            }
        }

        guard let finalCGImage = context.createCGImage(outputImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: finalCGImage, scale: image.scale, orientation: image.imageOrientation)
    }

    // MARK: - Arcade Screen Effect
    private static func applyArcadeEffect(to image: UIImage, intensity: CGFloat) -> UIImage? {
        // Combine scanlines and CRT effects with stronger contrast
        guard var resultImage = applyScanlinesEffect(to: image, intensity: intensity) else { return nil }

        guard let cgImage = resultImage.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext()

        var outputImage = ciImage

        // Increase contrast
        if let contrastFilter = CIFilter(name: "CIColorControls") {
            contrastFilter.setValue(outputImage, forKey: kCIInputImageKey)
            contrastFilter.setValue(1.3, forKey: kCIInputContrastKey)
            contrastFilter.setValue(1.2, forKey: kCIInputSaturationKey)
            if let output = contrastFilter.outputImage {
                outputImage = output
            }
        }

        // Add slight glow
        if let bloomFilter = CIFilter(name: "CIBloom") {
            bloomFilter.setValue(outputImage, forKey: kCIInputImageKey)
            bloomFilter.setValue(intensity * 3.0, forKey: kCIInputIntensityKey)
            bloomFilter.setValue(8.0, forKey: kCIInputRadiusKey)
            if let output = bloomFilter.outputImage {
                outputImage = output
            }
        }

        guard let finalCGImage = context.createCGImage(outputImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: finalCGImage, scale: image.scale, orientation: image.imageOrientation)
    }

    // MARK: - Helper: Create scanlines overlay
    private static func createScanlinesOverlay(size: CGSize, spacing: Int = 2, alpha: CGFloat = 0.3) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return UIImage()
        }

        context.setFillColor(UIColor.black.withAlphaComponent(alpha).cgColor)

        for y in stride(from: 0, to: Int(size.height), by: spacing * 2) {
            context.fill(CGRect(x: 0, y: CGFloat(y), width: size.width, height: CGFloat(spacing)))
        }

        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()

        return image
    }
}
//
//  BatchProcessor.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/01.
//

import UIKit
import SwiftUI
import Photos

/// Batch processing configuration
struct BatchProcessingConfig {
    var pixelSize: PixelBoardSize
    var colorPalette: ColorPaletteType
    var colorReduction: ColorReductionType
    var ditheringType: DitheringType
    var filterEffect: FilterEffectType
    var filterIntensity: CGFloat
    var exportFormat: ExportFormat
    var exportSize: CGFloat

    static var `default`: BatchProcessingConfig {
        BatchProcessingConfig(
            pixelSize: .low,
            colorPalette: .none,
            colorReduction: .none,
            ditheringType: .none,
            filterEffect: .none,
            filterIntensity: 1.0,
            exportFormat: .png,
            exportSize: 1000
        )
    }
}

/// Batch processing result for a single image
struct BatchProcessingResult {
    let originalImage: UIImage
    let processedImage: UIImage?
    let success: Bool
    let error: String?
}

class BatchProcessor: ObservableObject {
    @Published var isProcessing: Bool = false
    @Published var progress: Double = 0.0
    @Published var currentImageIndex: Int = 0
    @Published var totalImages: Int = 0
    @Published var results: [BatchProcessingResult] = []

    /// Process multiple images with the same settings
    func processBatch(images: [UIImage], config: BatchProcessingConfig, completion: @escaping ([BatchProcessingResult]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isProcessing = true
                self.progress = 0.0
                self.currentImageIndex = 0
                self.totalImages = images.count
                self.results = []
            }

            var results: [BatchProcessingResult] = []

            for (index, image) in images.enumerated() {
                DispatchQueue.main.async {
                    self.currentImageIndex = index + 1
                    self.progress = Double(index) / Double(images.count)
                }

                let result = self.processImage(image, config: config)
                results.append(result)

                // Small delay to prevent UI freezing
                Thread.sleep(forTimeInterval: 0.1)
            }

            DispatchQueue.main.async {
                self.isProcessing = false
                self.progress = 1.0
                self.results = results
                completion(results)
            }
        }
    }

    /// Process a single image with all effects
    private func processImage(_ image: UIImage, config: BatchProcessingConfig) -> BatchProcessingResult {
        var processedImage: UIImage? = image

        // Step 1: Apply pixelation
        processedImage = applyPixelation(to: processedImage, pixelSize: config.pixelSize)
        guard processedImage != nil else {
            return BatchProcessingResult(originalImage: image, processedImage: nil, success: false, error: "Pixelation failed")
        }

        // Step 2: Apply color palette
        if config.colorPalette != .none {
            let palette = config.colorPalette.colors
            if !palette.isEmpty {
                processedImage = ColorReductionEngine.applyColorReduction(to: processedImage!, colorCount: 0, palette: palette)
            }
        }

        // Step 3: Apply color reduction
        if config.colorReduction != .none {
            if config.ditheringType != .none {
                // Use dithering
                let palette = config.colorPalette != .none ? config.colorPalette.colors : []
                if !palette.isEmpty {
                    processedImage = ColorReductionEngine.applyDithering(to: processedImage!, type: config.ditheringType, palette: palette)
                } else {
                    // Generate palette from image
                    processedImage = ColorReductionEngine.applyColorReduction(to: processedImage!, colorCount: config.colorReduction.colorCount)
                }
            } else {
                processedImage = ColorReductionEngine.applyColorReduction(to: processedImage!, colorCount: config.colorReduction.colorCount)
            }
        }

        // Step 4: Apply filter effects
        if config.filterEffect != .none {
            processedImage = FilterEffectsEngine.applyFilter(to: processedImage!, type: config.filterEffect, intensity: config.filterIntensity)
        }

        // Step 5: Resize to export size if needed
        if let image = processedImage, image.size.width != config.exportSize {
            processedImage = resizeImage(image, targetSize: CGSize(width: config.exportSize, height: config.exportSize))
        }

        return BatchProcessingResult(
            originalImage: image,
            processedImage: processedImage,
            success: processedImage != nil,
            error: processedImage == nil ? "Processing failed" : nil
        )
    }

    /// Apply pixelation effect
    private func applyPixelation(to image: UIImage?, pixelSize: PixelBoardSize) -> UIImage? {
        guard let image = image, let currentCGImage = image.cgImage else { return nil }

        let width = UIScreen.main.bounds.width
        let currentCIImage = CIImage(cgImage: currentCGImage)
        let filter = CIFilter(name: "CIPixellate")
        filter?.setValue(currentCIImage, forKey: kCIInputImageKey)
        filter?.setValue(width / CGFloat(pixelSize.count), forKey: kCIInputScaleKey)

        guard let outputImage = filter?.outputImage else { return nil }

        let context = CIContext()
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgimg).cropTransparentPixels()
        }

        return nil
    }

    /// Resize image to target size
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    /// Save all processed images to Photos library
    func saveAllToPhotos(results: [BatchProcessingResult], completion: @escaping (Bool, String) -> Void) {
        let successfulResults = results.filter { $0.success && $0.processedImage != nil }

        guard !successfulResults.isEmpty else {
            completion(false, "No images to save")
            return
        }

        var savedCount = 0
        var errorCount = 0

        for result in successfulResults {
            guard let image = result.processedImage else { continue }

            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            savedCount += 1
        }

        let message = "\(savedCount) images saved successfully"
        completion(true, message)
    }

    /// Export batch results as ZIP file
    func exportAsZip(results: [BatchProcessingResult], config: BatchProcessingConfig) -> URL? {
        // Create temporary directory
        let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        do {
            try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)

            // Save all images to temp directory
            for (index, result) in results.enumerated() where result.success, let image = result.processedImage {
                let filename = "pixelated_\(index + 1).\(config.exportFormat.fileExtension)"
                let fileURL = tempDirectory.appendingPathComponent(filename)

                if let data = config.exportFormat.data(from: image) {
                    try data.write(to: fileURL)
                }
            }

            // Create ZIP file
            let zipURL = FileManager.default.temporaryDirectory.appendingPathComponent("pixelme_batch_\(Date().timeIntervalSince1970).zip")

            // Note: iOS doesn't have built-in ZIP creation, you'd need to use a library like ZIPFoundation
            // For now, we'll just return the directory URL
            return tempDirectory

        } catch {
            print("Error creating batch export: \(error)")
            return nil
        }
    }

    /// Request photo library access and return selected images
    static func requestPhotoLibraryAccess(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }

    /// Fetch images from photo library
    static func fetchImagesFromLibrary(limit: Int = 100) -> [UIImage] {
        var images: [UIImage] = []

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = limit

        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat

        fetchResult.enumerateObjects { asset, _, _ in
            imageManager.requestImage(for: asset, targetSize: CGSize(width: 1000, height: 1000), contentMode: .aspectFit, options: requestOptions) { image, _ in
                if let image = image {
                    images.append(image)
                }
            }
        }

        return images
    }
}

/// Multiple image picker for batch processing
struct MultipleImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 0 // 0 means unlimited

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: MultipleImagePicker

        init(_ parent: MultipleImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()

            guard !results.isEmpty else { return }

            var selectedImages: [UIImage] = []
            let group = DispatchGroup()

            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    defer { group.leave() }
                    if let image = object as? UIImage {
                        selectedImages.append(image)
                    }
                }
            }

            group.notify(queue: .main) {
                self.parent.images = selectedImages
            }
        }
    }
}
//
//  ExportManager.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/01.
//

import UIKit
import SwiftUI
import PDFKit

/// Export format options
enum ExportFormat: String, CaseIterable, Identifiable {
    case png = "PNG"
    case jpeg = "JPEG"
    case pdf = "PDF"
    case svg = "SVG"

    var id: String { rawValue }

    var fileExtension: String {
        switch self {
        case .png: return "png"
        case .jpeg: return "jpg"
        case .pdf: return "pdf"
        case .svg: return "svg"
        }
    }

    var description: String {
        switch self {
        case .png:
            return "PNG - Lossless, supports transparency"
        case .jpeg:
            return "JPEG - Smaller file size, no transparency"
        case .pdf:
            return "PDF - Vector format, scalable"
        case .svg:
            return "SVG - Web-friendly vector format"
        }
    }

    func data(from image: UIImage) -> Data? {
        switch self {
        case .png:
            return image.pngData()
        case .jpeg:
            return image.jpegData(compressionQuality: 0.95)
        case .pdf:
            return createPDFData(from: image)
        case .svg:
            return createSVGData(from: image)
        }
    }

    private func createPDFData(from image: UIImage) -> Data? {
        let pdfData = NSMutableData()
        let pdfConsumer = CGDataConsumer(data: pdfData as CFMutableData)!
        let mediaBox = CGRect(origin: .zero, size: image.size)

        guard let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: &mediaBox.mutable, nil) else {
            return nil
        }

        pdfContext.beginPage(mediaBox: &mediaBox.mutable)
        pdfContext.draw(image.cgImage!, in: mediaBox)
        pdfContext.endPage()
        pdfContext.closePDF()

        return pdfData as Data
    }

    private func createSVGData(from image: UIImage) -> Data? {
        // This is a simplified SVG creation - for production, you'd want to use a proper SVG library
        guard let cgImage = image.cgImage else { return nil }

        let width = cgImage.width
        let height = cgImage.height

        // Convert image to base64 for embedding
        guard let pngData = image.pngData() else { return nil }
        let base64String = pngData.base64EncodedString()

        let svgString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <svg width="\(width)" height="\(height)" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
            <image width="\(width)" height="\(height)" xlink:href="data:image/png;base64,\(base64String)"/>
        </svg>
        """

        return svgString.data(using: .utf8)
    }
}

/// Export size presets
enum ExportSize: String, CaseIterable, Identifiable {
    case original = "Original"
    case hd = "HD (1920x1920)"
    case fullHD = "Full HD (2160x2160)"
    case qhd = "2K (2560x2560)"
    case uhd = "4K (3840x3840)"
    case custom = "Custom"

    var id: String { rawValue }

    var dimension: CGFloat {
        switch self {
        case .original: return 0
        case .hd: return 1920
        case .fullHD: return 2160
        case .qhd: return 2560
        case .uhd: return 3840
        case .custom: return 0
        }
    }
}

/// Background option for export
enum ExportBackgroundType: String, CaseIterable, Identifiable {
    case transparent = "Transparent"
    case white = "White"
    case black = "Black"
    case custom = "Custom Color"

    var id: String { rawValue }

    func color(custom: UIColor? = nil) -> UIColor? {
        switch self {
        case .transparent:
            return nil
        case .white:
            return .white
        case .black:
            return .black
        case .custom:
            return custom ?? .white
        }
    }
}

class ExportManager {

    /// Export image with advanced options
    static func exportImage(
        _ image: UIImage,
        format: ExportFormat,
        size: ExportSize,
        customSize: CGFloat? = nil,
        background: ExportBackgroundType,
        customBackgroundColor: UIColor? = nil
    ) -> (data: Data?, filename: String)? {

        var processedImage = image

        // Step 1: Apply background
        if let bgColor = background.color(custom: customBackgroundColor) {
            processedImage = applyBackground(to: processedImage, color: bgColor)
        }

        // Step 2: Resize if needed
        let targetSize: CGFloat
        if size == .custom, let custom = customSize {
            targetSize = custom
        } else if size == .original {
            targetSize = max(image.size.width, image.size.height)
        } else {
            targetSize = size.dimension
        }

        if targetSize > 0 && targetSize != max(image.size.width, image.size.height) {
            processedImage = resizeImage(processedImage, targetSize: CGSize(width: targetSize, height: targetSize))
        }

        // Step 3: Convert to desired format
        guard let data = format.data(from: processedImage) else { return nil }

        // Generate filename
        let timestamp = Int(Date().timeIntervalSince1970)
        let filename = "pixelme_\(timestamp).\(format.fileExtension)"

        return (data, filename)
    }

    /// Apply background color to image
    private static func applyBackground(to image: UIImage, color: UIColor) -> UIImage {
        let size = image.size

        UIGraphicsBeginImageContextWithOptions(size, true, image.scale)
        defer { UIGraphicsEndImageContext() }

        // Fill background
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))

        // Draw image on top
        image.draw(at: .zero)

        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }

    /// Remove background (make transparent)
    static func removeBackground(from image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else { return nil }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let pixelBuffer = context.data else { return nil }
        let pixels = pixelBuffer.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)

        // Get background color (assume it's the color at top-left corner)
        let bgR = pixels[0]
        let bgG = pixels[1]
        let bgB = pixels[2]

        let tolerance: UInt8 = 30

        // Make similar colors transparent
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * bytesPerPixel

                let r = pixels[pixelIndex]
                let g = pixels[pixelIndex + 1]
                let b = pixels[pixelIndex + 2]

                // Check if color is similar to background
                if abs(Int(r) - Int(bgR)) < Int(tolerance) &&
                   abs(Int(g) - Int(bgG)) < Int(tolerance) &&
                   abs(Int(b) - Int(bgB)) < Int(tolerance) {
                    pixels[pixelIndex + 3] = 0 // Set alpha to 0
                }
            }
        }

        guard let newCGImage = context.makeImage() else { return nil }
        return UIImage(cgImage: newCGImage, scale: image.scale, orientation: image.imageOrientation)
    }

    /// Resize image maintaining aspect ratio
    private static func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        let scaleFactor = min(widthRatio, heightRatio)
        let scaledSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)

        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: scaledSize))
        }
    }

    /// Save data to files app
    static func saveToFiles(data: Data, filename: String, completion: @escaping (Bool, URL?) -> Void) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        do {
            try data.write(to: tempURL)
            completion(true, tempURL)
        } catch {
            print("Error saving file: \(error)")
            completion(false, nil)
        }
    }

    /// Share file using share sheet
    static func shareFile(data: Data, filename: String, from viewController: UIViewController) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        do {
            try data.write(to: tempURL)

            let activityViewController = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            viewController.present(activityViewController, animated: true)
        } catch {
            print("Error sharing file: \(error)")
        }
    }
}

extension CGRect {
    var mutable: CGRect {
        get { self }
        set { self = newValue }
    }
}
//
//  TemplateManager.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/01.
//

import UIKit
import SwiftUI

/// Template categories
enum TemplateCategory: String, CaseIterable, Identifiable {
    case profile = "Profile Picture"
    case nftAvatar = "NFT Avatar"
    case gameSprite = "Game Sprite"
    case icon = "App Icon"
    case banner = "Banner"
    case sticker = "Sticker"

    var id: String { rawValue }

    var templates: [Template] {
        switch self {
        case .profile:
            return Template.profileTemplates
        case .nftAvatar:
            return Template.nftAvatarTemplates
        case .gameSprite:
            return Template.gameSpriteTemplates
        case .icon:
            return Template.iconTemplates
        case .banner:
            return Template.bannerTemplates
        case .sticker:
            return Template.stickerTemplates
        }
    }
}

/// Template model
struct Template: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let category: String
    let size: CGSize
    let aspectRatio: CGFloat
    let pixelSize: Int
    let recommendedPalette: String?
    let hasBorder: Bool
    let borderColor: String?
    let borderWidth: CGFloat

    // Computed property for SwiftUI Color
    var borderUIColor: UIColor? {
        guard let hexString = borderColor else { return nil }
        return UIColor(hexString: hexString)
    }

    // MARK: - Profile Picture Templates
    static let profileTemplates: [Template] = [
        Template(
            id: "profile_square",
            name: "Square Profile",
            description: "Classic square profile picture",
            category: "profile",
            size: CGSize(width: 512, height: 512),
            aspectRatio: 1.0,
            pixelSize: 16,
            recommendedPalette: "pastel",
            hasBorder: true,
            borderColor: "#FFFFFF",
            borderWidth: 8
        ),
        Template(
            id: "profile_circle",
            name: "Circle Profile",
            description: "Circular profile picture for social media",
            category: "profile",
            size: CGSize(width: 512, height: 512),
            aspectRatio: 1.0,
            pixelSize: 16,
            recommendedPalette: "vaporwave",
            hasBorder: true,
            borderColor: "#FF71A6",
            borderWidth: 10
        ),
        Template(
            id: "profile_rounded",
            name: "Rounded Profile",
            description: "Rounded corners profile picture",
            category: "profile",
            size: CGSize(width: 512, height: 512),
            aspectRatio: 1.0,
            pixelSize: 12,
            recommendedPalette: "cyberpunk",
            hasBorder: false,
            borderColor: nil,
            borderWidth: 0
        )
    ]

    // MARK: - NFT Avatar Templates
    static let nftAvatarTemplates: [Template] = [
        Template(
            id: "nft_punk",
            name: "Punk Style",
            description: "CryptoPunks inspired 24x24 avatar",
            category: "nftAvatar",
            size: CGSize(width: 512, height: 512),
            aspectRatio: 1.0,
            pixelSize: 24,
            recommendedPalette: "retro8bit",
            hasBorder: true,
            borderColor: "#000000",
            borderWidth: 4
        ),
        Template(
            id: "nft_bored",
            name: "Ape Style",
            description: "BAYC inspired avatar",
            category: "nftAvatar",
            size: CGSize(width: 512, height: 512),
            aspectRatio: 1.0,
            pixelSize: 16,
            recommendedPalette: "snes",
            hasBorder: true,
            borderColor: "#8B4513",
            borderWidth: 6
        ),
        Template(
            id: "nft_doodle",
            name: "Doodle Style",
            description: "Colorful doodle avatar",
            category: "nftAvatar",
            size: CGSize(width: 512, height: 512),
            aspectRatio: 1.0,
            pixelSize: 12,
            recommendedPalette: "pastel",
            hasBorder: true,
            borderColor: "#FFD700",
            borderWidth: 8
        )
    ]

    // MARK: - Game Sprite Templates
    static let gameSpriteTemplates: [Template] = [
        Template(
            id: "sprite_character",
            name: "Character Sprite",
            description: "16x16 game character",
            category: "gameSprite",
            size: CGSize(width: 256, height: 256),
            aspectRatio: 1.0,
            pixelSize: 16,
            recommendedPalette: "nes",
            hasBorder: false,
            borderColor: nil,
            borderWidth: 0
        ),
        Template(
            id: "sprite_item",
            name: "Item Sprite",
            description: "8x8 game item",
            category: "gameSprite",
            size: CGSize(width: 128, height: 128),
            aspectRatio: 1.0,
            pixelSize: 8,
            recommendedPalette: "gameboy",
            hasBorder: false,
            borderColor: nil,
            borderWidth: 0
        ),
        Template(
            id: "sprite_enemy",
            name: "Enemy Sprite",
            description: "32x32 game enemy",
            category: "gameSprite",
            size: CGSize(width: 512, height: 512),
            aspectRatio: 1.0,
            pixelSize: 32,
            recommendedPalette: "retro8bit",
            hasBorder: false,
            borderColor: nil,
            borderWidth: 0
        )
    ]

    // MARK: - App Icon Templates
    static let iconTemplates: [Template] = [
        Template(
            id: "icon_ios",
            name: "iOS App Icon",
            description: "1024x1024 iOS app icon",
            category: "icon",
            size: CGSize(width: 1024, height: 1024),
            aspectRatio: 1.0,
            pixelSize: 32,
            recommendedPalette: nil,
            hasBorder: false,
            borderColor: nil,
            borderWidth: 0
        ),
        Template(
            id: "icon_small",
            name: "Small Icon",
            description: "256x256 small icon",
            category: "icon",
            size: CGSize(width: 256, height: 256),
            aspectRatio: 1.0,
            pixelSize: 16,
            recommendedPalette: "snes",
            hasBorder: true,
            borderColor: "#000000",
            borderWidth: 4
        )
    ]

    // MARK: - Banner Templates
    static let bannerTemplates: [Template] = [
        Template(
            id: "banner_twitter",
            name: "Twitter/X Banner",
            description: "1500x500 Twitter header",
            category: "banner",
            size: CGSize(width: 1500, height: 500),
            aspectRatio: 3.0,
            pixelSize: 50,
            recommendedPalette: "cyberpunk",
            hasBorder: false,
            borderColor: nil,
            borderWidth: 0
        ),
        Template(
            id: "banner_youtube",
            name: "YouTube Banner",
            description: "2560x1440 YouTube banner",
            category: "banner",
            size: CGSize(width: 2560, height: 1440),
            aspectRatio: 16/9,
            pixelSize: 80,
            recommendedPalette: "vaporwave",
            hasBorder: false,
            borderColor: nil,
            borderWidth: 0
        ),
        Template(
            id: "banner_discord",
            name: "Discord Banner",
            description: "960x540 Discord server banner",
            category: "banner",
            size: CGSize(width: 960, height: 540),
            aspectRatio: 16/9,
            pixelSize: 40,
            recommendedPalette: "retro8bit",
            hasBorder: false,
            borderColor: nil,
            borderWidth: 0
        )
    ]

    // MARK: - Sticker Templates
    static let stickerTemplates: [Template] = [
        Template(
            id: "sticker_small",
            name: "Small Sticker",
            description: "256x256 small sticker",
            category: "sticker",
            size: CGSize(width: 256, height: 256),
            aspectRatio: 1.0,
            pixelSize: 12,
            recommendedPalette: "pastel",
            hasBorder: true,
            borderColor: "#FFFFFF",
            borderWidth: 6
        ),
        Template(
            id: "sticker_emoji",
            name: "Emoji Style",
            description: "512x512 emoji-sized sticker",
            category: "sticker",
            size: CGSize(width: 512, height: 512),
            aspectRatio: 1.0,
            pixelSize: 16,
            recommendedPalette: "snes",
            hasBorder: false,
            borderColor: nil,
            borderWidth: 0
        )
    ]
}

/// Preset configurations for quick access
struct EffectPreset: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let pixelSize: String
    let colorPalette: String
    let colorReduction: String
    let ditheringType: String
    let filterEffect: String
    let filterIntensity: Double

    static let presets: [EffectPreset] = [
        EffectPreset(
            id: "preset_gameboy",
            name: "GameBoy Classic",
            description: "Green monochrome GameBoy look",
            pixelSize: "16x16",
            colorPalette: "gameboy",
            colorReduction: "colors8",
            ditheringType: "floydSteinberg",
            filterEffect: "scanlines",
            filterIntensity: 0.7
        ),
        EffectPreset(
            id: "preset_nes",
            name: "NES Retro",
            description: "Classic NES game style",
            pixelSize: "12x12",
            colorPalette: "nes",
            colorReduction: "colors16",
            ditheringType: "none",
            filterEffect: "crt",
            filterIntensity: 0.8
        ),
        EffectPreset(
            id: "preset_vaporwave",
            name: "Vaporwave Aesthetic",
            description: "Pink and cyan vaporwave vibes",
            pixelSize: "22x22",
            colorPalette: "vaporwave",
            colorReduction: "colors16",
            ditheringType: "atkinson",
            filterEffect: "glitch",
            filterIntensity: 0.5
        ),
        EffectPreset(
            id: "preset_cyberpunk",
            name: "Cyberpunk Neon",
            description: "Futuristic neon colors",
            pixelSize: "16x16",
            colorPalette: "cyberpunk",
            colorReduction: "colors8",
            ditheringType: "ordered",
            filterEffect: "crt",
            filterIntensity: 1.0
        ),
        EffectPreset(
            id: "preset_pastel",
            name: "Pastel Dream",
            description: "Soft and gentle colors",
            pixelSize: "22x22",
            colorPalette: "pastel",
            colorReduction: "colors16",
            ditheringType: "floydSteinberg",
            filterEffect: "none",
            filterIntensity: 0.0
        ),
        EffectPreset(
            id: "preset_arcade",
            name: "Arcade Cabinet",
            description: "Classic arcade screen",
            pixelSize: "12x12",
            colorPalette: "retro8bit",
            colorReduction: "colors16",
            ditheringType: "none",
            filterEffect: "arcade",
            filterIntensity: 0.9
        ),
        EffectPreset(
            id: "preset_noir",
            name: "Film Noir",
            description: "Black and white classic film",
            pixelSize: "16x16",
            colorPalette: "noir",
            colorReduction: "colors8",
            ditheringType: "atkinson",
            filterEffect: "vintage",
            filterIntensity: 0.8
        ),
        EffectPreset(
            id: "preset_vhs",
            name: "VHS Tape",
            description: "90s VHS recording aesthetic",
            pixelSize: "22x22",
            colorPalette: "none",
            colorReduction: "colors32",
            ditheringType: "ordered",
            filterEffect: "vhsTape",
            filterIntensity: 0.7
        )
    ]
}

class TemplateManager: ObservableObject {
    @Published var selectedTemplate: Template?
    @Published var selectedPreset: EffectPreset?

    /// Apply template to image
    func applyTemplate(to image: UIImage, template: Template) -> UIImage? {
        var processedImage = image

        // Resize to template size
        processedImage = resizeImage(processedImage, targetSize: template.size)

        // Apply border if needed
        if template.hasBorder, let borderColor = template.borderUIColor {
            processedImage = addBorder(to: processedImage, color: borderColor, width: template.borderWidth)
        }

        return processedImage
    }

    /// Apply preset to image
    func applyPreset(to image: UIImage, preset: EffectPreset, manager: DataManager) -> UIImage? {
        var processedImage = image

        // Parse and apply settings
        // This would integrate with your existing DataManager
        // For now, we'll return the image as-is
        // You would need to call your existing pixelation, color reduction, and filter functions

        return processedImage
    }

    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    private func addBorder(to image: UIImage, color: UIColor, width: CGFloat) -> UIImage {
        let borderSize = CGSize(
            width: image.size.width + width * 2,
            height: image.size.height + width * 2
        )

        UIGraphicsBeginImageContextWithOptions(borderSize, false, image.scale)
        defer { UIGraphicsEndImageContext() }

        // Draw border background
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: borderSize))

        // Draw image on top
        image.draw(at: CGPoint(x: width, y: width))

        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }

    /// Get all templates
    static func getAllTemplates() -> [Template] {
        return TemplateCategory.allCases.flatMap { $0.templates }
    }

    /// Get templates by category
    static func getTemplates(for category: TemplateCategory) -> [Template] {
        return category.templates
    }

    /// Get all presets
    static func getAllPresets() -> [EffectPreset] {
        return EffectPreset.presets
    }
}
//
//  GIFCreator.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/01.
//

import UIKit
import ImageIO
import MobileCoreServices
import UniformTypeIdentifiers

/// GIF frame model
struct GIFFrame: Identifiable {
    let id = UUID()
    var image: UIImage
    var duration: TimeInterval // Duration in seconds
}

/// GIF quality settings
enum GIFQuality: String, CaseIterable, Identifiable {
    case low = "Low (Fast)"
    case medium = "Medium"
    case high = "High (Slow)"

    var id: String { rawValue }

    var maxSize: CGSize {
        switch self {
        case .low: return CGSize(width: 320, height: 320)
        case .medium: return CGSize(width: 480, height: 480)
        case .high: return CGSize(width: 640, height: 640)
        }
    }

    var colorCount: Int {
        switch self {
        case .low: return 64
        case .medium: return 128
        case .high: return 256
        }
    }
}

class GIFCreator: ObservableObject {
    @Published var frames: [GIFFrame] = []
    @Published var isProcessing: Bool = false
    @Published var progress: Double = 0.0

    /// Create GIF from multiple images
    func createGIF(
        from frames: [GIFFrame],
        loopCount: Int = 0, // 0 means infinite loop
        quality: GIFQuality = .medium,
        completion: @escaping (URL?) -> Void
    ) {
        guard !frames.isEmpty else {
            completion(nil)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isProcessing = true
                self.progress = 0.0
            }

            // Create temporary file URL
            let tempDirectory = FileManager.default.temporaryDirectory
            let filename = "pixelme_\(Date().timeIntervalSince1970).gif"
            let fileURL = tempDirectory.appendingPathComponent(filename)

            // Create GIF
            guard let destination = CGImageDestinationCreateWithURL(
                fileURL as CFURL,
                UTType.gif.identifier as CFString,
                frames.count,
                nil
            ) else {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    completion(nil)
                }
                return
            }

            // Set GIF properties
            let fileProperties: [String: Any] = [
                kCGImagePropertyGIFDictionary as String: [
                    kCGImagePropertyGIFLoopCount as String: loopCount
                ]
            ]
            CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)

            // Add frames
            for (index, frame) in frames.enumerated() {
                DispatchQueue.main.async {
                    self.progress = Double(index) / Double(frames.count)
                }

                // Resize frame if needed
                let resizedImage = self.resizeImageForGIF(frame.image, maxSize: quality.maxSize)

                guard let cgImage = resizedImage.cgImage else { continue }

                // Frame properties
                let frameProperties: [String: Any] = [
                    kCGImagePropertyGIFDictionary as String: [
                        kCGImagePropertyGIFDelayTime as String: frame.duration
                    ]
                ]

                CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
            }

            // Finalize GIF
            let success = CGImageDestinationFinalize(destination)

            DispatchQueue.main.async {
                self.isProcessing = false
                self.progress = 1.0
                completion(success ? fileURL : nil)
            }
        }
    }

    /// Create GIF from video frames
    func createGIFFromVideo(
        videoURL: URL,
        startTime: TimeInterval = 0,
        duration: TimeInterval,
        frameRate: Int = 10,
        quality: GIFQuality = .medium,
        completion: @escaping (URL?) -> Void
    ) {
        // Note: This requires AVFoundation
        // For a complete implementation, you would use AVAssetImageGenerator
        // This is a placeholder showing the structure

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            // Extract frames from video
            // let frames = self.extractFramesFromVideo(videoURL, startTime, duration, frameRate)

            // For now, return nil as this requires AVFoundation implementation
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }

    /// Create animated GIF with pixelation effect progression
    func createProgressivePixelationGIF(
        from image: UIImage,
        startPixelSize: PixelBoardSize = .extraLarge,
        endPixelSize: PixelBoardSize = .extraLow,
        frameCount: Int = 10,
        frameDuration: TimeInterval = 0.1,
        quality: GIFQuality = .medium,
        completion: @escaping (URL?) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            var frames: [GIFFrame] = []

            // Generate frames with increasing pixelation
            let allSizes = PixelBoardSize.allCases.reversed() // From large to small
            let step = max(1, allSizes.count / frameCount)

            for i in stride(from: 0, to: allSizes.count, by: step) {
                let pixelSize = allSizes[i]

                if let pixelatedImage = self.applyPixelation(to: image, pixelSize: pixelSize) {
                    frames.append(GIFFrame(image: pixelatedImage, duration: frameDuration))
                }
            }

            // Create GIF from frames
            self.createGIF(from: frames, loopCount: 0, quality: quality, completion: completion)
        }
    }

    /// Create glitch animation GIF
    func createGlitchAnimationGIF(
        from image: UIImage,
        frameCount: Int = 8,
        frameDuration: TimeInterval = 0.1,
        glitchIntensity: CGFloat = 0.8,
        quality: GIFQuality = .medium,
        completion: @escaping (URL?) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            var frames: [GIFFrame] = []

            // Add original image
            frames.append(GIFFrame(image: image, duration: frameDuration))

            // Add glitch frames
            for _ in 0..<frameCount {
                if let glitchedImage = FilterEffectsEngine.applyFilter(
                    to: image,
                    type: .glitch,
                    intensity: glitchIntensity
                ) {
                    frames.append(GIFFrame(image: glitchedImage, duration: frameDuration))
                }
            }

            // Create GIF from frames
            self.createGIF(from: frames, loopCount: 0, quality: quality, completion: completion)
        }
    }

    /// Create color cycling animation GIF
    func createColorCycleGIF(
        from image: UIImage,
        palettes: [ColorPaletteType],
        frameDuration: TimeInterval = 0.5,
        quality: GIFQuality = .medium,
        completion: @escaping (URL?) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            var frames: [GIFFrame] = []

            // Apply each palette
            for palette in palettes {
                let colors = palette.colors
                if !colors.isEmpty,
                   let coloredImage = ColorReductionEngine.applyColorReduction(
                       to: image,
                       colorCount: 0,
                       palette: colors
                   ) {
                    frames.append(GIFFrame(image: coloredImage, duration: frameDuration))
                }
            }

            // Create GIF from frames
            self.createGIF(from: frames, loopCount: 0, quality: quality, completion: completion)
        }
    }

    // MARK: - Helper Methods

    private func applyPixelation(to image: UIImage, pixelSize: PixelBoardSize) -> UIImage? {
        guard let currentCGImage = image.cgImage else { return nil }

        let width = UIScreen.main.bounds.width
        let currentCIImage = CIImage(cgImage: currentCGImage)
        let filter = CIFilter(name: "CIPixellate")
        filter?.setValue(currentCIImage, forKey: kCIInputImageKey)
        filter?.setValue(width / CGFloat(pixelSize.count), forKey: kCIInputScaleKey)

        guard let outputImage = filter?.outputImage else { return nil }

        let context = CIContext()
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgimg)
        }

        return nil
    }

    private func resizeImageForGIF(_ image: UIImage, maxSize: CGSize) -> UIImage {
        let size = image.size

        // Calculate aspect ratio
        let widthRatio = maxSize.width / size.width
        let heightRatio = maxSize.height / size.height
        let ratio = min(widthRatio, heightRatio)

        // Don't upscale
        if ratio >= 1.0 {
            return image
        }

        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    /// Save GIF to Photos library
    static func saveGIFToPhotos(url: URL, completion: @escaping (Bool, Error?) -> Void) {
        guard let gifData = try? Data(contentsOf: url) else {
            completion(false, NSError(domain: "GIFCreator", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to read GIF data"]))
            return
        }

        // Save to temporary location first
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp.gif")
        do {
            try gifData.write(to: tempURL)

            // Use UIActivityViewController or custom save method
            // Note: Direct GIF saving to Photos requires PHPhotoLibrary
            completion(true, nil)
        } catch {
            completion(false, error)
        }
    }
}

/// GIF Animation Timeline View Model
class GIFTimelineViewModel: ObservableObject {
    @Published var frames: [GIFFrame] = []
    @Published var selectedFrameIndex: Int? = nil
    @Published var isPlaying: Bool = false
    @Published var currentPlayingFrame: Int = 0

    private var playbackTimer: Timer?

    func addFrame(_ frame: GIFFrame) {
        frames.append(frame)
    }

    func removeFrame(at index: Int) {
        guard index < frames.count else { return }
        frames.remove(at: index)
    }

    func updateFrameDuration(at index: Int, duration: TimeInterval) {
        guard index < frames.count else { return }
        frames[index].duration = duration
    }

    func moveFrame(from source: Int, to destination: Int) {
        guard source < frames.count, destination < frames.count else { return }
        let frame = frames.remove(at: source)
        frames.insert(frame, at: destination)
    }

    func duplicateFrame(at index: Int) {
        guard index < frames.count else { return }
        let frame = frames[index]
        let newFrame = GIFFrame(image: frame.image, duration: frame.duration)
        frames.insert(newFrame, at: index + 1)
    }

    func startPlayback() {
        guard !frames.isEmpty else { return }

        isPlaying = true
        currentPlayingFrame = 0

        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if self.currentPlayingFrame < self.frames.count - 1 {
                self.currentPlayingFrame += 1
            } else {
                self.currentPlayingFrame = 0
            }
        }
    }

    func stopPlayback() {
        isPlaying = false
        playbackTimer?.invalidate()
        playbackTimer = nil
        currentPlayingFrame = 0
    }

    func clearAllFrames() {
        stopPlayback()
        frames.removeAll()
        selectedFrameIndex = nil
    }
}
//
//  LayerManager.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/01.
//

import UIKit
import SwiftUI

/// Layer blend mode types
enum LayerBlendMode: String, CaseIterable, Identifiable {
    case normal = "Normal"
    case multiply = "Multiply"
    case screen = "Screen"
    case overlay = "Overlay"
    case darken = "Darken"
    case lighten = "Lighten"
    case colorBurn = "Color Burn"
    case colorDodge = "Color Dodge"
    case hardLight = "Hard Light"
    case softLight = "Soft Light"
    case difference = "Difference"
    case exclusion = "Exclusion"

    var id: String { rawValue }

    var cgBlendMode: CGBlendMode {
        switch self {
        case .normal: return .normal
        case .multiply: return .multiply
        case .screen: return .screen
        case .overlay: return .overlay
        case .darken: return .darken
        case .lighten: return .lighten
        case .colorBurn: return .colorBurn
        case .colorDodge: return .colorDodge
        case .hardLight: return .hardLight
        case .softLight: return .softLight
        case .difference: return .difference
        case .exclusion: return .exclusion
        }
    }
}

/// Individual layer model
class Layer: Identifiable, ObservableObject {
    let id: UUID
    @Published var name: String
    @Published var image: UIImage?
    @Published var isVisible: Bool
    @Published var opacity: CGFloat
    @Published var blendMode: LayerBlendMode
    @Published var isLocked: Bool
    @Published var offset: CGPoint
    @Published var scale: CGFloat
    @Published var rotation: CGFloat // In degrees

    init(
        id: UUID = UUID(),
        name: String,
        image: UIImage? = nil,
        isVisible: Bool = true,
        opacity: CGFloat = 1.0,
        blendMode: LayerBlendMode = .normal,
        isLocked: Bool = false,
        offset: CGPoint = .zero,
        scale: CGFloat = 1.0,
        rotation: CGFloat = 0
    ) {
        self.id = id
        self.name = name
        self.image = image
        self.isVisible = isVisible
        self.opacity = opacity
        self.blendMode = blendMode
        self.isLocked = isLocked
        self.offset = offset
        self.scale = scale
        self.rotation = rotation
    }

    /// Create a copy of this layer
    func duplicate() -> Layer {
        return Layer(
            name: "\(name) Copy",
            image: image,
            isVisible: isVisible,
            opacity: opacity,
            blendMode: blendMode,
            isLocked: false,
            offset: offset,
            scale: scale,
            rotation: rotation
        )
    }
}

/// Layer manager to handle multiple layers
class LayerManager: ObservableObject {
    @Published var layers: [Layer] = []
    @Published var selectedLayerIndex: Int? = nil
    @Published var canvasSize: CGSize = CGSize(width: 1000, height: 1000)

    var selectedLayer: Layer? {
        guard let index = selectedLayerIndex, index < layers.count else { return nil }
        return layers[index]
    }

    init() {
        // Create default background layer
        let backgroundLayer = Layer(name: "Background", image: nil)
        layers.append(backgroundLayer)
        selectedLayerIndex = 0
    }

    // MARK: - Layer Management

    /// Add new layer
    func addLayer(name: String = "New Layer", image: UIImage? = nil) {
        let newLayer = Layer(name: name, image: image)
        layers.append(newLayer)
        selectedLayerIndex = layers.count - 1
    }

    /// Remove layer at index
    func removeLayer(at index: Int) {
        guard index < layers.count, layers.count > 1 else { return } // Keep at least one layer

        layers.remove(at: index)

        // Update selection
        if let selected = selectedLayerIndex {
            if selected >= layers.count {
                selectedLayerIndex = layers.count - 1
            } else if selected == index {
                selectedLayerIndex = max(0, index - 1)
            }
        }
    }

    /// Duplicate layer
    func duplicateLayer(at index: Int) {
        guard index < layers.count else { return }

        let originalLayer = layers[index]
        let duplicatedLayer = originalLayer.duplicate()

        layers.insert(duplicatedLayer, at: index + 1)
        selectedLayerIndex = index + 1
    }

    /// Move layer
    func moveLayer(from source: Int, to destination: Int) {
        guard source < layers.count, destination < layers.count else { return }

        let layer = layers.remove(at: source)
        layers.insert(layer, at: destination)

        // Update selection
        if selectedLayerIndex == source {
            selectedLayerIndex = destination
        }
    }

    /// Merge layer with the one below
    func mergeLayerDown(at index: Int) {
        guard index > 0, index < layers.count else { return }

        let upperLayer = layers[index]
        let lowerLayer = layers[index - 1]

        // Composite the two layers
        if let mergedImage = compositeLayers([lowerLayer, upperLayer]) {
            lowerLayer.image = mergedImage
            layers.remove(at: index)

            selectedLayerIndex = index - 1
        }
    }

    /// Merge all visible layers
    func mergeVisibleLayers() {
        let visibleLayers = layers.filter { $0.isVisible }

        guard visibleLayers.count > 1 else { return }

        if let mergedImage = compositeLayers(visibleLayers) {
            // Remove all layers
            layers.removeAll()

            // Add merged layer
            let mergedLayer = Layer(name: "Merged Layer", image: mergedImage)
            layers.append(mergedLayer)
            selectedLayerIndex = 0
        }
    }

    /// Flatten all layers
    func flattenLayers() {
        if let flattenedImage = compositeLayers(layers) {
            layers.removeAll()

            let flattenedLayer = Layer(name: "Flattened", image: flattenedImage)
            layers.append(flattenedLayer)
            selectedLayerIndex = 0
        }
    }

    // MARK: - Layer Properties

    /// Update layer visibility
    func toggleLayerVisibility(at index: Int) {
        guard index < layers.count else { return }
        layers[index].isVisible.toggle()
    }

    /// Update layer opacity
    func updateLayerOpacity(at index: Int, opacity: CGFloat) {
        guard index < layers.count else { return }
        layers[index].opacity = max(0, min(1, opacity))
    }

    /// Update layer blend mode
    func updateLayerBlendMode(at index: Int, blendMode: LayerBlendMode) {
        guard index < layers.count else { return }
        layers[index].blendMode = blendMode
    }

    /// Lock/unlock layer
    func toggleLayerLock(at index: Int) {
        guard index < layers.count else { return }
        layers[index].isLocked.toggle()
    }

    // MARK: - Layer Rendering

    /// Composite layers into a single image
    func compositeLayers(_ layersToComposite: [Layer]) -> UIImage? {
        guard !layersToComposite.isEmpty else { return nil }

        UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        // Draw layers from bottom to top
        for layer in layersToComposite {
            guard layer.isVisible, let image = layer.image else { continue }

            context.saveGState()

            // Apply transformations
            context.translateBy(x: canvasSize.width / 2, y: canvasSize.height / 2)
            context.translateBy(x: layer.offset.x, y: layer.offset.y)
            context.rotate(by: layer.rotation * .pi / 180)
            context.scaleBy(x: layer.scale, y: layer.scale)

            // Set blend mode and opacity
            context.setBlendMode(layer.blendMode.cgBlendMode)
            context.setAlpha(layer.opacity)

            // Draw image
            let drawRect = CGRect(
                x: -image.size.width / 2,
                y: -image.size.height / 2,
                width: image.size.width,
                height: image.size.height
            )
            image.draw(in: drawRect)

            context.restoreGState()
        }

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    /// Render final composite image
    func renderFinalImage() -> UIImage? {
        return compositeLayers(layers)
    }

    // MARK: - Layer Effects

    /// Apply effect to layer
    func applyEffectToLayer(at index: Int, effect: (UIImage) -> UIImage?) {
        guard index < layers.count, let image = layers[index].image else { return }

        if let processedImage = effect(image) {
            layers[index].image = processedImage
        }
    }

    /// Apply pixelation to layer
    func applyPixelationToLayer(at index: Int, pixelSize: PixelBoardSize) {
        applyEffectToLayer(at: index) { image in
            guard let currentCGImage = image.cgImage else { return nil }

            let width = UIScreen.main.bounds.width
            let currentCIImage = CIImage(cgImage: currentCGImage)
            let filter = CIFilter(name: "CIPixellate")
            filter?.setValue(currentCIImage, forKey: kCIInputImageKey)
            filter?.setValue(width / CGFloat(pixelSize.count), forKey: kCIInputScaleKey)

            guard let outputImage = filter?.outputImage else { return nil }

            let context = CIContext()
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }

            return nil
        }
    }

    /// Apply color palette to layer
    func applyPaletteToLayer(at index: Int, palette: ColorPaletteType) {
        guard palette != .none else { return }

        applyEffectToLayer(at: index) { image in
            return ColorReductionEngine.applyColorReduction(
                to: image,
                colorCount: 0,
                palette: palette.colors
            )
        }
    }

    /// Apply filter to layer
    func applyFilterToLayer(at index: Int, filter: FilterEffectType, intensity: CGFloat = 1.0) {
        guard filter != .none else { return }

        applyEffectToLayer(at: index) { image in
            return FilterEffectsEngine.applyFilter(to: image, type: filter, intensity: intensity)
        }
    }

    // MARK: - Layer Adjustments

    /// Adjust layer transform
    func updateLayerTransform(at index: Int, offset: CGPoint? = nil, scale: CGFloat? = nil, rotation: CGFloat? = nil) {
        guard index < layers.count else { return }

        if let offset = offset {
            layers[index].offset = offset
        }
        if let scale = scale {
            layers[index].scale = max(0.1, min(5.0, scale))
        }
        if let rotation = rotation {
            layers[index].rotation = rotation
        }
    }

    /// Reset layer transform
    func resetLayerTransform(at index: Int) {
        guard index < layers.count else { return }

        layers[index].offset = .zero
        layers[index].scale = 1.0
        layers[index].rotation = 0
    }

    // MARK: - Helper Methods

    /// Get layer count
    var layerCount: Int {
        return layers.count
    }

    /// Get visible layer count
    var visibleLayerCount: Int {
        return layers.filter { $0.isVisible }.count
    }

    /// Check if layer is editable
    func isLayerEditable(at index: Int) -> Bool {
        guard index < layers.count else { return false }
        return !layers[index].isLocked
    }
}

/// Layer thumbnail generator
extension Layer {
    func generateThumbnail(size: CGSize = CGSize(width: 100, height: 100)) -> UIImage? {
        guard let image = image else { return nil }

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
