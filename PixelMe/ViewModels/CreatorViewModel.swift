//
//  CreatorViewModel.swift
//  PixelMe
//
//  Extracted ViewModel for CreatorContentView (Task 3)
//

import SwiftUI

@MainActor
class CreatorViewModel: ObservableObject {
    // MARK: - Drawing State
    @Published var filledPixels: [String] = []
    @Published var filledColors: [String: Color] = [:]
    @Published var currentColor: Color = .black
    @Published var backgroundColor: Color = .white
    @Published var eraserToolEnabled: Bool = false

    // MARK: - Color Palette
    @Published var customPalette: [Color] = [
        .black, .white, .red, .orange, .yellow,
        .green, .blue, .purple, .pink, .brown
    ]
    @Published var selectedPaletteIndex: Int = 0
    @Published var editingColorIndex: Int = 0
    @Published var editingColor: Color = .black
    @Published var showColorEditor: Bool = false

    // MARK: - Display Options
    @Published var showGridView: Bool = true
    @Published var showLogoWatermark: Bool = true
    @Published var shouldHideLogoWatermark: Bool = false
    @Published var invertGridLinesColor: Bool = false

    // MARK: - Navigation State
    @Published var didSelectBoardSize: Bool = false
    @Published var didShowInterstitial: Bool = false
    @Published var showPhotoPicker: Bool = false
    @Published var showPhotoPreview: Bool = false
    @Published var showBoardSizeChanger: Bool = false
    @Published var showWatermarkPicker: Bool = false
    @Published var showSettingsSheet: Bool = false
    @Published var showPaywall: Bool = false

    // MARK: - Home Screen
    @Published var showHomeScreen: Bool = true
    @Published var showOnboarding: Bool = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @Published var showSampleGallery: Bool = false
    @Published var selectedSample: SamplePixelArt? = nil
    @Published var referenceSample: SamplePixelArt? = nil
    @Published var showReferenceImage: Bool = true

    // MARK: - Preset Colors
    let presetColors: [Color] = [
        .black, .white, .gray,
        .red, .orange, .yellow,
        .green, .mint, .teal,
        .cyan, .blue, .indigo,
        .purple, .pink, .brown
    ]

    // MARK: - Actions
    func resetCanvas() {
        filledPixels.removeAll()
        filledColors.removeAll()
        backgroundColor = .white
    }

    func selectColor(at index: Int) {
        selectedPaletteIndex = index
        currentColor = customPalette[index]
        eraserToolEnabled = false
    }

    func startFollowAlongDrawing(_ sample: SamplePixelArt, manager: DataManager) {
        referenceSample = sample
        manager.pixelBoardSize = sample.boardSize
        filledPixels.removeAll()
        filledColors.removeAll()
        backgroundColor = sample.backgroundColor
        showHomeScreen = false
        didSelectBoardSize = true
    }

    func loadSampleArt(_ sample: SamplePixelArt, manager: DataManager) {
        showSampleGallery = false
        manager.pixelBoardSize = sample.boardSize
        filledColors.removeAll()
        filledPixels.removeAll()
        backgroundColor = sample.backgroundColor
        referenceSample = sample
        setupPaletteFromSample(sample)
        showHomeScreen = false
        didSelectBoardSize = true
        print("🎨 [CreatorViewModel] Loaded sample: \(sample.name)")
    }

    func goHome() {
        showHomeScreen = true
        didSelectBoardSize = false
        referenceSample = nil
    }

    func selectBoardSize(_ type: PixelBoardSize, manager: DataManager) {
        manager.pixelBoardSize = type
        withAnimation(.easeInOut(duration: 0.3)) {
            didSelectBoardSize = true
        }
    }

    func changeBoardSize(_ type: PixelBoardSize, manager: DataManager) {
        manager.pixelBoardSize = type
        filledPixels.removeAll()
        filledColors.removeAll()
        showBoardSizeChanger = false
    }

    func handleDrag(at point: CGPoint, boardSize: PixelBoardSize, height: CGFloat) {
        let pixelSize = UIScreen.main.bounds.width / CGFloat(boardSize.count)
        let y = Int(point.y / pixelSize)
        let x = Int(point.x / pixelSize)
        let maxCount = Int(height)
        guard y < maxCount && x < maxCount && y >= 0 && x >= 0 else { return }
        filledColors["\(x)_\(y)"] = currentColor
        if eraserToolEnabled {
            filledPixels.removeAll(where: { $0 == "\(x)_\(y)" })
        } else {
            filledPixels.append("\(x)_\(y)")
        }
    }

    // MARK: - Palette Setup
    func setupPaletteFromSample(_ sample: SamplePixelArt) {
        var uniqueColors: [Color] = []
        var seenColors: Set<String> = []

        for (_, color) in sample.pixels {
            let colorKey = colorToString(color)
            if !seenColors.contains(colorKey) {
                seenColors.insert(colorKey)
                uniqueColors.append(color)
            }
        }

        let bgColorKey = colorToString(sample.backgroundColor)
        if !seenColors.contains(bgColorKey) {
            uniqueColors.insert(sample.backgroundColor, at: 0)
        }

        var newPalette: [Color] = []
        let defaultColors: [Color] = [.black, .white, .red, .orange, .yellow, .green, .blue, .purple, .pink, .brown]
        for i in 0..<10 {
            newPalette.append(i < uniqueColors.count ? uniqueColors[i] : defaultColors[i])
        }

        customPalette = newPalette
        selectedPaletteIndex = 0
        currentColor = customPalette[0]
        print("🎨 [CreatorViewModel] Palette set with \(uniqueColors.count) colors from sample")
    }

    func colorToString(_ color: Color) -> String {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "%.2f-%.2f-%.2f", r, g, b)
    }

    func updateEditingColor(_ newValue: Color) {
        customPalette[editingColorIndex] = newValue
        if selectedPaletteIndex == editingColorIndex {
            currentColor = newValue
        }
    }

    func loadPixelData(from manager: DataManager) {
        guard let pixelData = manager.pixelGridData else { return }
        print("🎨 [CreatorViewModel] Loading pixel data from PixelatedPhotoView")
        didSelectBoardSize = true
        filledColors = pixelData
        filledPixels = Array(pixelData.keys)
        manager.shouldLoadPixelGrid = false
        print("🎨 [CreatorViewModel] Loaded \(filledPixels.count) pixels")
    }
}
