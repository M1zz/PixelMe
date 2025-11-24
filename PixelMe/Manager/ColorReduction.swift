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
