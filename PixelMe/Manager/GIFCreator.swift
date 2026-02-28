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

/// GIF creation error types
enum GIFCreationError: LocalizedError {
    case noFrames
    case destinationCreationFailed
    case finalizationFailed
    case imageConversionFailed(frameIndex: Int)
    case fileWriteFailed(underlying: Error)
    case readFailed

    var errorDescription: String? {
        switch self {
        case .noFrames:
            return "No frames provided for GIF creation."
        case .destinationCreationFailed:
            return "Failed to create GIF file. Please check available storage."
        case .finalizationFailed:
            return "Failed to finalize GIF. The file may be corrupted."
        case .imageConversionFailed(let index):
            return "Failed to process frame \(index + 1)."
        case .fileWriteFailed(let error):
            return "Failed to save GIF: \(error.localizedDescription)"
        case .readFailed:
            return "Failed to read GIF data."
        }
    }
}

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
    @Published var lastError: GIFCreationError?

    /// Create GIF from multiple images
    func createGIF(
        from frames: [GIFFrame],
        loopCount: Int = 0,
        quality: GIFQuality = .medium,
        completion: @escaping (Result<URL, GIFCreationError>) -> Void
    ) {
        guard !frames.isEmpty else {
            completion(.failure(.noFrames))
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isProcessing = true
                self.progress = 0.0
                self.lastError = nil
            }

            let tempDirectory = FileManager.default.temporaryDirectory
            let filename = "pixelme_\(Date().timeIntervalSince1970).gif"
            let fileURL = tempDirectory.appendingPathComponent(filename)

            guard let destination = CGImageDestinationCreateWithURL(
                fileURL as CFURL,
                UTType.gif.identifier as CFString,
                frames.count,
                nil
            ) else {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.lastError = .destinationCreationFailed
                    completion(.failure(.destinationCreationFailed))
                }
                return
            }

            let fileProperties: [String: Any] = [
                kCGImagePropertyGIFDictionary as String: [
                    kCGImagePropertyGIFLoopCount as String: loopCount
                ]
            ]
            CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)

            var skippedFrames = 0
            for (index, frame) in frames.enumerated() {
                DispatchQueue.main.async {
                    self.progress = Double(index) / Double(frames.count)
                }

                let resizedImage = self.resizeImageForGIF(frame.image, maxSize: quality.maxSize)

                guard let cgImage = resizedImage.cgImage else {
                    print("⚠️ [GIFCreator] Skipping frame \(index) - CGImage conversion failed")
                    skippedFrames += 1
                    continue
                }

                let frameProperties: [String: Any] = [
                    kCGImagePropertyGIFDictionary as String: [
                        kCGImagePropertyGIFDelayTime as String: frame.duration
                    ]
                ]

                CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
            }

            // If all frames were skipped, report error
            if skippedFrames == frames.count {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.lastError = .imageConversionFailed(frameIndex: 0)
                    completion(.failure(.imageConversionFailed(frameIndex: 0)))
                }
                return
            }

            let success = CGImageDestinationFinalize(destination)

            DispatchQueue.main.async {
                self.isProcessing = false
                self.progress = 1.0

                if success {
                    completion(.success(fileURL))
                } else {
                    self.lastError = .finalizationFailed
                    completion(.failure(.finalizationFailed))
                }
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
        completion: @escaping (Result<URL, GIFCreationError>) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                completion(.failure(.noFrames))
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

            let allSizes = PixelBoardSize.allCases.reversed()
            let step = max(1, allSizes.count / frameCount)

            for i in stride(from: 0, to: allSizes.count, by: step) {
                let pixelSize = allSizes[i]

                if let pixelatedImage = self.applyPixelation(to: image, pixelSize: pixelSize) {
                    frames.append(GIFFrame(image: pixelatedImage, duration: frameDuration))
                }
            }

            self.createGIF(from: frames, loopCount: 0, quality: quality) { result in
                switch result {
                case .success(let url):
                    completion(url)
                case .failure(let error):
                    print("❌ [GIFCreator] Progressive pixelation GIF failed: \(error.localizedDescription)")
                    completion(nil)
                }
            }
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
            frames.append(GIFFrame(image: image, duration: frameDuration))

            for _ in 0..<frameCount {
                if let glitchedImage = FilterEffectsEngine.applyFilter(
                    to: image,
                    type: .glitch,
                    intensity: glitchIntensity
                ) {
                    frames.append(GIFFrame(image: glitchedImage, duration: frameDuration))
                }
            }

            self.createGIF(from: frames, loopCount: 0, quality: quality) { result in
                switch result {
                case .success(let url):
                    completion(url)
                case .failure(let error):
                    print("❌ [GIFCreator] Glitch GIF failed: \(error.localizedDescription)")
                    completion(nil)
                }
            }
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

            self.createGIF(from: frames, loopCount: 0, quality: quality) { result in
                switch result {
                case .success(let url):
                    completion(url)
                case .failure(let error):
                    print("❌ [GIFCreator] Color cycle GIF failed: \(error.localizedDescription)")
                    completion(nil)
                }
            }
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

        let widthRatio = maxSize.width / size.width
        let heightRatio = maxSize.height / size.height
        let ratio = min(widthRatio, heightRatio)

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
        do {
            let gifData = try Data(contentsOf: url)
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp.gif")
            try gifData.write(to: tempURL)
            completion(true, nil)
        } catch {
            completion(false, GIFCreationError.fileWriteFailed(underlying: error))
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
