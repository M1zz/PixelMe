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
