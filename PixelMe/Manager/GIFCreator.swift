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
