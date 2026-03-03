//
//  LayerManager.swift
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
//
//  DataManager.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/01.
//

