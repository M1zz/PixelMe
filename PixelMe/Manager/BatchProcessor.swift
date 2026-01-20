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
            for (index, result) in results.enumerated() where result.success {
                guard let image = result.processedImage else { continue }
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
