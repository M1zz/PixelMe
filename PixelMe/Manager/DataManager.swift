//
//  DataManager.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/01.
//

import SwiftUI
import UIKit
import PhotosUI
import Photos
import Vision
import CoreImage

/// Full Screen flow
enum FullScreenMode: Int, Identifiable {
    case createPixelArt, applyFilter, settings
    var id: Int { hashValue }
}

/// Pixels board size
enum PixelBoardSize: String, CaseIterable, Identifiable {
    case extraLow = "8x8"
    case low = "12x12"
    case normal = "16x16"
    case medium = "22x22"
    case large = "32x32"
    case extraLarge = "40x40"
    var count: Int { Int(rawValue.components(separatedBy: "x").first!)! }
    var density: String { "\(self)".camelCaseToWords().capitalized }
    var id: Int { hashValue }
}

/// Main data manager for the app
class DataManager: NSObject, ObservableObject {

    /// Dynamic properties that the UI will react to
    @Published var showLoading: Bool = false
    @Published var fullScreenMode: FullScreenMode?
    @Published var selectedImage: UIImage?
    @Published var pixelatedImage: UIImage?
    @Published var pixelBoardSize: PixelBoardSize? = nil
    @Published var tempPhotoForPreview: UIImage?

    /// New advanced features
    @Published var selectedColorPalette: ColorPaletteType = .none
    @Published var colorReduction: ColorReductionType = .none
    @Published var ditheringType: DitheringType = .none
    @Published var filterEffect: FilterEffectType = .none
    @Published var filterIntensity: CGFloat = 1.0
    @Published var exportFormat: ExportFormat = .png
    @Published var exportSize: ExportSize = .original
    @Published var exportBackground: ExportBackgroundType = .transparent
    @Published var isBackgroundRemovalEnabled: Bool = false
    @Published var pixelateBackgroundColor: Color = .white  // Background color for transparent areas when pixelating

    /// Pixel grid data for Creator mode
    @Published var pixelGridData: [String: Color]? = nil
    @Published var shouldLoadPixelGrid: Bool = false
    @Published var shouldDismissPhotoPreview: Bool = false
    @Published var pixelatedImageForGrid: UIImage? = nil  // Store pixelated image to display as background

    /// Watermark settings
    @Published var customWatermarkImage: UIImage?
    @Published var useCustomWatermark: Bool = false

    /// Aseprite 파일 가져오기
    @Published var importedAsepriteFrames: [AnimationFrame]?
    @Published var shouldOpenPixelEditor: Bool = false

    /// Managers for advanced features
    @Published var batchProcessor: BatchProcessor = BatchProcessor()
    @Published var layerManager: LayerManager = LayerManager()
    @Published var templateManager: TemplateManager = TemplateManager()
    @Published var gifCreator: GIFCreator = GIFCreator()

    /// Active async tasks for cancellation support (Task 4)
    private var activeProcessingTasks: [String: Task<Void, Never>] = [:]

    /// Cancel all active processing tasks
    func cancelAllTasks() {
        activeProcessingTasks.values.forEach { $0.cancel() }
        activeProcessingTasks.removeAll()
        batchProcessor.cancelProcessing()
    }

    /// Track a named task for later cancellation
    func trackTask(_ name: String, task: Task<Void, Never>) {
        activeProcessingTasks[name]?.cancel()
        activeProcessingTasks[name] = task
    }

    /// Remove completed task
    func removeTask(_ name: String) {
        activeProcessingTasks.removeValue(forKey: name)
    }

    /// Dynamic properties that the UI will react to AND store values in UserDefaults
    @AppStorage(AppConfig.premiumVersion) var isPremiumUser: Bool = false
    
    /// Computed property for premium status using new subscription system
    @MainActor var isProUser: Bool {
        return SubscriptionManager.shared.isProUser
    }

    override init() {
        super.init()
        loadCustomWatermark()
    }
}

// MARK: - Apply Pixel effect to existing images
extension DataManager {
    /// Apply pixel effect with all advanced features
    func applyPixelEffect(showFilterFlow: Bool = true) {
        print("🎯 [DataManager] applyPixelEffect called with showFilterFlow: \(showFilterFlow)")

        // Show loading indicator
        showLoading = true

        guard var sourceImage = selectedImage else {
            print("⚠️ [DataManager] selectedImage is nil, returning early")
            showLoading = false
            return
        }

        print("🎯 [DataManager] Processing image...")
        print("🎯 [DataManager] Original image size: \(sourceImage.size)")

        // If background was removed, fill transparent areas with selected background color
        if isBackgroundRemovalEnabled {
            print("🎯 [DataManager] Filling transparent areas with background color")
            sourceImage = fillTransparentAreas(in: sourceImage, with: pixelateBackgroundColor) ?? sourceImage
        }

        // Make the image square to match the grid exactly
        let gridSize = CGFloat(pixelBoardSize?.count ?? 16)
        sourceImage = makeSquareImage(sourceImage, gridSize: gridSize) ?? sourceImage
        print("🎯 [DataManager] Square image size: \(sourceImage.size)")

        guard let currentCGImage = sourceImage.cgImage else {
            print("⚠️ [DataManager] Failed to get cgImage after processing")
            showLoading = false
            return
        }

        // Use image width for accurate pixel scaling
        let imageWidth = CGFloat(currentCGImage.width)
        let currentCIImage = CIImage(cgImage: currentCGImage)
        let filter = CIFilter(name: "CIPixellate")
        filter?.setValue(currentCIImage, forKey: kCIInputImageKey)
        let pixelScale = imageWidth / gridSize
        filter?.setValue(pixelScale, forKey: kCIInputScaleKey)
        // Set center to half pixel size so grid aligns exactly with image edges
        filter?.setValue(CIVector(x: pixelScale / 2, y: pixelScale / 2), forKey: kCIInputCenterKey)
        print("🎯 [DataManager] Image width: \(imageWidth), Grid: \(gridSize), Pixel scale: \(pixelScale)")
        guard let outputImage = filter?.outputImage else { return }

        // Use the original image's color space to preserve colors
        let colorSpace = currentCGImage.colorSpace ?? CGColorSpaceCreateDeviceRGB()
        let context = CIContext(options: [.workingColorSpace: colorSpace])

        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent, format: .RGBA8, colorSpace: colorSpace) {
            var processedImage = UIImage(cgImage: cgimg)

            // Apply color palette if selected
            if selectedColorPalette != .none {
                let palette = selectedColorPalette.colors
                if !palette.isEmpty {
                    if ditheringType != .none {
                        processedImage = ColorReductionEngine.applyDithering(
                            to: processedImage,
                            type: ditheringType,
                            palette: palette
                        ) ?? processedImage
                    } else {
                        processedImage = ColorReductionEngine.applyColorReduction(
                            to: processedImage,
                            colorCount: 0,
                            palette: palette
                        ) ?? processedImage
                    }
                }
            }

            // Apply color reduction if selected
            if colorReduction != .none && selectedColorPalette == .none {
                processedImage = ColorReductionEngine.applyColorReduction(
                    to: processedImage,
                    colorCount: colorReduction.colorCount
                ) ?? processedImage
            }

            // Apply filter effect if selected
            if filterEffect != .none {
                processedImage = FilterEffectsEngine.applyFilter(
                    to: processedImage,
                    type: filterEffect,
                    intensity: filterIntensity
                ) ?? processedImage
            }

            DispatchQueue.main.async {
                print("✅ [DataManager] Image processed successfully")
                self.pixelatedImage = processedImage
                print("✅ [DataManager] pixelatedImage set")

                // Log preview colors immediately after pixelation
                if let cgImage = processedImage.cgImage {
                    print("🎨 [PREVIEW] === Pixelated Image Colors ===")
                    print("🎨 [PREVIEW] Image size: \(cgImage.width)x\(cgImage.height)")

                    // Sample center pixel
                    let centerX = cgImage.width / 2
                    let centerY = cgImage.height / 2
                    if let pixelData = cgImage.dataProvider?.data,
                       let data = CFDataGetBytePtr(pixelData) {
                        let bytesPerPixel = 4
                        let bytesPerRow = cgImage.bytesPerRow
                        let pixelOffset = centerY * bytesPerRow + centerX * bytesPerPixel

                        if pixelOffset + 3 < CFDataGetLength(pixelData) {
                            let r = data[pixelOffset]
                            let g = data[pixelOffset + 1]
                            let b = data[pixelOffset + 2]
                            let a = data[pixelOffset + 3]
                            print("🎨 [PREVIEW] Center[\(centerX),\(centerY)] RGB: (\(r), \(g), \(b)) Alpha: \(a)")
                        }

                        // Sample a few more pixels for comparison
                        let samples = [(cgImage.width/4, cgImage.height/4),
                                     (cgImage.width*3/4, cgImage.height/4),
                                     (cgImage.width/4, cgImage.height*3/4),
                                     (cgImage.width*3/4, cgImage.height*3/4)]

                        for (x, y) in samples {
                            let offset = y * bytesPerRow + x * bytesPerPixel
                            if offset + 3 < CFDataGetLength(pixelData) {
                                let r = data[offset]
                                let g = data[offset + 1]
                                let b = data[offset + 2]
                                let a = data[offset + 3]
                                print("🎨 [PREVIEW] Sample[\(x),\(y)] RGB: (\(r), \(g), \(b)) Alpha: \(a)")
                            }
                        }
                    }
                    print("🎨 [PREVIEW] ============================")
                }

                // Hide loading indicator
                self.showLoading = false

                if showFilterFlow {
                    print("✅ [DataManager] Setting fullScreenMode = .applyFilter")
                    self.fullScreenMode = .applyFilter
                    print("✅ [DataManager] fullScreenMode set to .applyFilter")
                }
            }
        }
    }

    /// Fill transparent areas in an image with a solid color
    private func fillTransparentAreas(in image: UIImage, with color: Color) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let width = cgImage.width
        let height = cgImage.height

        // Convert SwiftUI Color to UIColor
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // Create bitmap context
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        var pixelData = [UInt32](repeating: 0, count: width * height)

        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        ) else { return nil }

        // Fill with background color
        context.setFillColor(red: red, green: green, blue: blue, alpha: 1.0)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Draw the original image on top
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Create new image
        guard let newCGImage = context.makeImage() else { return nil }
        return UIImage(cgImage: newCGImage)
    }

    /// Make an image square by adding padding to match the grid size
    private func makeSquareImage(_ image: UIImage, gridSize: CGFloat) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let width = cgImage.width
        let height = cgImage.height
        let maxDimension = max(width, height)

        // Calculate size to be exact multiple of gridSize for perfect grid alignment
        let pixelSize = Int(ceil(CGFloat(maxDimension) / gridSize))
        let squareSize = Int(gridSize) * pixelSize

        print("🎯 [makeSquareImage] Original: \(width)x\(height), Max: \(maxDimension)")
        print("🎯 [makeSquareImage] GridSize: \(Int(gridSize)), PixelSize: \(pixelSize), Square: \(squareSize)x\(squareSize)")

        // Create square canvas with background color
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * squareSize
        let bitsPerComponent = 8

        // Convert background color to fill the canvas
        let uiColor = UIColor(pixelateBackgroundColor)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        guard let context = CGContext(
            data: nil,
            width: squareSize,
            height: squareSize,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        ) else { return nil }

        // Fill with background color
        context.setFillColor(red: red, green: green, blue: blue, alpha: 1.0)
        context.fill(CGRect(x: 0, y: 0, width: squareSize, height: squareSize))

        // Calculate centering offsets
        let offsetX = (squareSize - width) / 2
        let offsetY = (squareSize - height) / 2

        print("🎯 [makeSquareImage] Offset: (\(offsetX), \(offsetY))")

        // Draw image centered
        context.draw(cgImage, in: CGRect(x: offsetX, y: offsetY, width: width, height: height))

        // Create new image
        guard let newCGImage = context.makeImage() else { return nil }
        return UIImage(cgImage: newCGImage)
    }

    /// Apply preset to current image
    func applyPreset(_ preset: EffectPreset) {
        // Show loading indicator immediately
        showLoading = true

        // Parse preset values
        if let paletteType = ColorPaletteType.allCases.first(where: { $0.rawValue.lowercased() == preset.colorPalette.lowercased() }) {
            selectedColorPalette = paletteType
        }

        if let reductionType = ColorReductionType.allCases.first(where: { $0.rawValue.lowercased().contains(preset.colorReduction.lowercased()) }) {
            colorReduction = reductionType
        }

        if let ditherType = DitheringType.allCases.first(where: { $0.rawValue.lowercased().contains(preset.ditheringType.lowercased()) }) {
            ditheringType = ditherType
        }

        if let filterType = FilterEffectType.allCases.first(where: { $0.rawValue.lowercased().contains(preset.filterEffect.lowercased()) }) {
            filterEffect = filterType
        }

        filterIntensity = CGFloat(preset.filterIntensity)

        // Apply the effect
        applyPixelEffect(showFilterFlow: true)
    }

    /// Extract pixel data from pixelated image for Creator mode
    func extractPixelDataFromImage() {
        guard let image = pixelatedImage,
              let cgImage = image.cgImage,
              let boardSize = pixelBoardSize else {
            return
        }

        let gridSize = boardSize.count
        print("🎨 [DataManager] === EXTRACTING PIXEL DATA ===")
        print("🎨 Grid size: \(gridSize)x\(gridSize)")
        print("🎨 Image size: \(cgImage.width)x\(cgImage.height)")

        // Verify image is square and matches expected size
        let expectedPixelSize = cgImage.width / gridSize
        print("🎨 Expected pixel block size: \(expectedPixelSize)x\(expectedPixelSize)")

        // Read pixel data directly from the pixelated image
        guard let pixelData = cgImage.dataProvider?.data,
              let data = CFDataGetBytePtr(pixelData) else {
            print("⚠️ Failed to get pixel data")
            return
        }

        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let bytesPerRow = cgImage.bytesPerRow
        let alphaInfo = cgImage.alphaInfo
        let byteOrder = cgImage.bitmapInfo

        print("🎨 BitmapInfo: alphaInfo=\(alphaInfo.rawValue), byteOrder=Big:\(byteOrder.contains(.byteOrder32Big)) Little:\(byteOrder.contains(.byteOrder32Little))")

        // Helper function to extract RGB from pixel bytes based on format
        func extractRGB(byte0: UInt8, byte1: UInt8, byte2: UInt8, byte3: UInt8) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
            var r: UInt8, g: UInt8, b: UInt8, a: UInt8

            if byteOrder.contains(.byteOrder32Big) {
                // Big endian
                if alphaInfo == .premultipliedFirst || alphaInfo == .first {
                    // ARGB
                    a = byte0; r = byte1; g = byte2; b = byte3
                } else {
                    // RGBA
                    r = byte0; g = byte1; b = byte2; a = byte3
                }
            } else {
                // Little endian (default) or no byte order specified
                if alphaInfo == .premultipliedFirst || alphaInfo == .first {
                    // BGRA
                    b = byte0; g = byte1; r = byte2; a = byte3
                } else if alphaInfo == .premultipliedLast || alphaInfo == .last {
                    // RGBA
                    r = byte0; g = byte1; b = byte2; a = byte3
                } else {
                    // No alpha - assume RGB
                    r = byte0; g = byte1; b = byte2; a = 255
                }
            }

            return (CGFloat(r) / 255.0, CGFloat(g) / 255.0, CGFloat(b) / 255.0, CGFloat(a) / 255.0)
        }

        // Calculate pixel block size (should be exact multiple)
        let pixelBlockSize = CGFloat(cgImage.width) / CGFloat(gridSize)
        print("🎨 Calculated pixel block size: \(pixelBlockSize)")

        // Create a dictionary to store pixel colors
        var colors: [String: Color] = [:]

        // Extract color for each grid cell by sampling from center of each block
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                // Sample from the center of each pixel block
                let x = Int(CGFloat(col) * pixelBlockSize + pixelBlockSize / 2)
                let y = Int(CGFloat(row) * pixelBlockSize + pixelBlockSize / 2)

                // Make sure we're within bounds
                guard x >= 0 && x < cgImage.width && y >= 0 && y < cgImage.height else {
                    print("⚠️ Out of bounds: [\(col),\(row)] -> (\(x),\(y))")
                    continue
                }

                // Calculate byte offset
                let pixelOffset = y * bytesPerRow + x * bytesPerPixel
                guard pixelOffset + 3 < CFDataGetLength(pixelData) else {
                    print("⚠️ Invalid offset: [\(col),\(row)] offset=\(pixelOffset)")
                    continue
                }

                // Read the bytes
                let byte0 = data[pixelOffset]
                let byte1 = data[pixelOffset + 1]
                let byte2 = data[pixelOffset + 2]
                let byte3 = data[pixelOffset + 3]

                // Extract RGB using the helper function
                let (r, g, b, a) = extractRGB(byte0: byte0, byte1: byte1, byte2: byte2, byte3: byte3)

                // Always include all pixels (no transparency check since we filled background)
                let color = Color(red: r, green: g, blue: b, opacity: a)
                colors["\(col)_\(row)"] = color

                // Log some sample pixels for verification
                if col == gridSize / 2 && row == gridSize / 2 {
                    print("🎨 CENTER pixel[\(col),\(row)] at (\(x),\(y)) RGB: (\(Int(r*255)), \(Int(g*255)), \(Int(b*255)))")
                }
                if col == 0 && row == 0 {
                    print("🎨 TOP-LEFT pixel[\(col),\(row)] at (\(x),\(y)) RGB: (\(Int(r*255)), \(Int(g*255)), \(Int(b*255)))")
                }
                if col == gridSize-1 && row == gridSize-1 {
                    print("🎨 BOTTOM-RIGHT pixel[\(col),\(row)] at (\(x),\(y)) RGB: (\(Int(r*255)), \(Int(g*255)), \(Int(b*255)))")
                }
            }
        }

        print("🎨 [DataManager] Extracted \(colors.count) pixels out of \(gridSize * gridSize) grid cells")
        print("🎨 ===================================")

        self.pixelGridData = colors
        self.shouldLoadPixelGrid = true
    }
}

// MARK: - Save pixel art image
extension DataManager {
    /// Save pixelated board as image (with watermark for non-Pro users)
    func savePixelatedImage() {
        var nftImage = PixelatedImage(exportMode: true).environmentObject(self)
            .image(size: CGSize(width: AppConfig.exportSize, height: AppConfig.exportSize))
        let isPro = UserDefaults.standard.bool(forKey: AppConfig.premiumVersion)
        if !isPro {
            nftImage = FreeUsageManager.applyWatermark(to: nftImage)
        }
        UIImageWriteToSavedPhotosAlbum(nftImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func savePixelGrid(view: AnyView) {
        var nftImage = view.image(size: CGSize(width: AppConfig.exportSize, height: AppConfig.exportSize))
        let isPro = UserDefaults.standard.bool(forKey: AppConfig.premiumVersion)
        if !isPro {
            nftImage = FreeUsageManager.applyWatermark(to: nftImage)
        }
        UIImageWriteToSavedPhotosAlbum(nftImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let errorMessage = error?.localizedDescription {
            presentAlert(title: "Oops!", message: errorMessage, primaryAction: .ok)
        } else {
            presentAlert(title: "Image Saved", message: "Your image has been saved into the Photos app", primaryAction: .ok)
            ReviewManager.shared.trackCompletedAction()
        }
    }
}

// MARK: - Background Removal Manager

/// Background removal using Vision framework
class BackgroundRemovalManager {

    /// Remove background from image (iOS 17+)
    @available(iOS 17.0, *)
    static func removeBackground(from image: UIImage, completion: @escaping (UIImage?) -> Void) {
        guard let inputImage = CIImage(image: image) else {
            completion(nil)
            return
        }

        // Create subject masking request (iOS 17+)
        let request = VNGenerateForegroundInstanceMaskRequest()

        let handler = VNImageRequestHandler(ciImage: inputImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])

                guard let result = request.results?.first else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }

                // Get all instances (people, objects, etc.)
                let allInstances = result.allInstances

                // Generate mask for all detected instances
                guard let maskPixelBuffer = try? result.generateMaskedImage(
                    ofInstances: allInstances,
                    from: handler,
                    croppedToInstancesExtent: false
                ) else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }

                // Convert mask to CIImage
                let maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)

                // Create output with transparent background
                let outputImage = self.applyMask(inputImage, mask: maskImage)

                // Convert to UIImage
                let context = CIContext()
                guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }

                let resultImage = UIImage(cgImage: cgImage)

                DispatchQueue.main.async {
                    completion(resultImage)
                }

            } catch {
                print("Background removal error: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }

    /// Remove background using legacy API (iOS 15+)
    @available(iOS 15.0, *)
    static func removeBackgroundLegacy(from image: UIImage, completion: @escaping (UIImage?) -> Void) {
        guard let inputImage = CIImage(image: image) else {
            completion(nil)
            return
        }

        let request = VNGeneratePersonSegmentationRequest { request, error in
            if let error = error {
                print("Segmentation error: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            guard let result = request.results?.first as? VNPixelBufferObservation else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            let maskImage = CIImage(cvPixelBuffer: result.pixelBuffer)
            let outputImage = self.applyMask(inputImage, mask: maskImage)

            let context = CIContext()
            guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            let resultImage = UIImage(cgImage: cgImage)

            DispatchQueue.main.async {
                completion(resultImage)
            }
        }

        request.qualityLevel = .balanced
        request.outputPixelFormat = kCVPixelFormatType_OneComponent8

        let handler = VNImageRequestHandler(ciImage: inputImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform request: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }

    /// Apply mask to image to remove background
    private static func applyMask(_ image: CIImage, mask: CIImage) -> CIImage {
        // Scale mask to match image size
        let scaleX = image.extent.width / mask.extent.width
        let scaleY = image.extent.height / mask.extent.height
        let scaledMask = mask.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        // Blend using mask filter
        guard let filter = CIFilter(name: "CIBlendWithMask") else {
            return image
        }

        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(CIImage(color: .clear).cropped(to: image.extent), forKey: kCIInputBackgroundImageKey)
        filter.setValue(scaledMask, forKey: kCIInputMaskImageKey)

        return filter.outputImage ?? image
    }

    /// Smart remove background (tries iOS 17 API first, falls back to iOS 15)
    static func removeBackgroundSmart(from image: UIImage, completion: @escaping (UIImage?) -> Void) {
        if #available(iOS 17.0, *) {
            removeBackground(from: image, completion: completion)
        } else if #available(iOS 15.0, *) {
            removeBackgroundLegacy(from: image, completion: completion)
        } else {
            // iOS 14 or earlier - not supported
            completion(nil)
        }
    }
}

// MARK: - DataManager Extension for Background Removal

extension DataManager {

    /// Remove background and apply pixelation
    func removeBackgroundAndPixelate() {
        guard let selectedImage = self.selectedImage else { return }

        // Toggle the state
        isBackgroundRemovalEnabled = true

        BackgroundRemovalManager.removeBackgroundSmart(from: selectedImage) { [weak self] result in
            guard let self = self, let removedBgImage = result else {
                self?.isBackgroundRemovalEnabled = false
                presentAlert(title: "Error", message: "Failed to remove background. This feature requires iOS 15 or later.")
                return
            }

            // Update selected image with background removed
            self.selectedImage = removedBgImage

            // Apply pixelation to the new image and show the flow
            self.applyPixelEffect(showFilterFlow: true)
        }
    }
}

// MARK: - Custom Watermark Management

extension DataManager {

    /// Save custom watermark image
    func saveCustomWatermark(_ image: UIImage) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let watermarkPath = documentsPath.appendingPathComponent("customWatermark.png")

        guard let pngData = image.pngData() else {
            print("⚠️ [DataManager] Failed to convert watermark image to PNG data")
            presentAlert(title: "Error", message: "Failed to process watermark image. Please try a different image.")
            return
        }

        do {
            try pngData.write(to: watermarkPath)
            customWatermarkImage = image
            useCustomWatermark = true
            UserDefaults.standard.set(true, forKey: "useCustomWatermark")
            print("✅ [DataManager] Custom watermark saved successfully to \(watermarkPath.path)")
        } catch {
            print("⚠️ [DataManager] Failed to save custom watermark: \(error.localizedDescription)")
            presentAlert(title: "Save Error", message: "Failed to save watermark image: \(error.localizedDescription)")
        }
    }

    /// Load custom watermark image asynchronously
    func loadCustomWatermark() {
        Task { @MainActor in
            await loadCustomWatermarkAsync()
        }
    }

    /// Async implementation for loading custom watermark
    private func loadCustomWatermarkAsync() async {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let watermarkPath = documentsPath.appendingPathComponent("customWatermark.png")

        guard FileManager.default.fileExists(atPath: watermarkPath.path) else {
            print("ℹ️ [DataManager] No custom watermark file found at \(watermarkPath.path)")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: watermarkPath)
            guard let image = UIImage(data: data) else {
                print("⚠️ [DataManager] Failed to create UIImage from watermark data at \(watermarkPath.path)")
                return
            }
            await MainActor.run {
                self.customWatermarkImage = image
                self.useCustomWatermark = UserDefaults.standard.bool(forKey: "useCustomWatermark")
            }
            print("✅ [DataManager] Custom watermark loaded successfully")
        } catch {
            print("⚠️ [DataManager] Failed to read custom watermark file: \(error.localizedDescription)")
        }
    }

    /// Remove custom watermark
    func removeCustomWatermark() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let watermarkPath = documentsPath.appendingPathComponent("customWatermark.png")

        do {
            try FileManager.default.removeItem(at: watermarkPath)
            print("✅ [DataManager] Custom watermark file removed successfully")
        } catch {
            print("⚠️ [DataManager] Failed to remove custom watermark file: \(error.localizedDescription)")
        }

        customWatermarkImage = nil
        useCustomWatermark = false
        UserDefaults.standard.set(false, forKey: "useCustomWatermark")
    }

    /// Get watermark image (custom or default)
    func getWatermarkImage() -> UIImage? {
        if useCustomWatermark, let customImage = customWatermarkImage {
            return customImage
        }
        return UIImage(named: "watermark")
    }
}
