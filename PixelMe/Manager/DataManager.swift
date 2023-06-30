//
//  DataManager.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/01.
//

import UIKit
import SwiftUI
import Foundation

/// Full Screen flow
enum FullScreenMode: Int, Identifiable {
    case createNFT, applyFilter, settings
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
    @Published var pixelBoardSize: PixelBoardSize = .low
    
    /// Dynamic properties that the UI will react to AND store values in UserDefaults
    @AppStorage(AppConfig.premiumVersion) var isPremiumUser: Bool = false
}

// MARK: - Apply Pixel effect to existing images
extension DataManager {
    /// Apply pixel effect
    func applyPixelEffect(showFilterFlow: Bool = true) {
        guard let currentCGImage = selectedImage?.cgImage else { return }
        let width = UIScreen.main.bounds.width
        let currentCIImage = CIImage(cgImage: currentCGImage)
        let filter = CIFilter(name: "CIPixellate")
        filter?.setValue(currentCIImage, forKey: kCIInputImageKey)
        filter?.setValue(width/CGFloat(pixelBoardSize.count), forKey: kCIInputScaleKey)
        guard let outputImage = filter?.outputImage else { return }
        let context = CIContext()
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let processedImage = UIImage(cgImage: cgimg).cropTransparentPixels()
            DispatchQueue.main.async {
                self.pixelatedImage = processedImage
                if showFilterFlow { self.fullScreenMode = .applyFilter}
            }
        }
    }
}

// MARK: - Save pixel NFT image
extension DataManager {
    /// Save pixelated board as NFT/image
    func savePixelatedNFT() {
        let nftImage = PixelatedImage(exportMode: true).environmentObject(self)
            .image(size: CGSize(width: AppConfig.exportSize, height: AppConfig.exportSize))
        UIImageWriteToSavedPhotosAlbum(nftImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func savePixelGrid(view: AnyView) {
        let nftImage = view.image(size: CGSize(width: AppConfig.exportSize, height: AppConfig.exportSize))
        UIImageWriteToSavedPhotosAlbum(nftImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let errorMessage = error?.localizedDescription {
            presentAlert(title: "Oops!", message: errorMessage, primaryAction: .ok)
        } else {
            presentAlert(title: "Image Saved", message: "Your image has been saved into the Photos app", primaryAction: .ok)
        }
    }
}
