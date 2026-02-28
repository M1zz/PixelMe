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

        guard let pdfConsumer = CGDataConsumer(data: pdfData as CFMutableData) else {
            print("[ExportManager] Error: Failed to create PDF data consumer")
            return nil
        }

        guard let cgImage = image.cgImage else {
            print("[ExportManager] Error: Failed to get CGImage for PDF export")
            return nil
        }

        var mediaBox = CGRect(origin: .zero, size: image.size)

        guard let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: &mediaBox, nil) else {
            print("[ExportManager] Error: Failed to create PDF context")
            return nil
        }

        pdfContext.beginPage(mediaBox: &mediaBox)
        pdfContext.draw(cgImage, in: mediaBox)
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
