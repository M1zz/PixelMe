//
//  PixelatedPhotoView.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/30.
//

import SwiftUI

/// Shows the pixelated photo effect with advanced options
struct PixelatedPhotoView: View {

    @EnvironmentObject var manager: DataManager
    @State private var didShowInterstitial: Bool = false
    @State private var showAdvancedSettings: Bool = false
    @State private var selectedTab: Int = 0

    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            Color(AppConfig.backgroundColor).ignoresSafeArea()

            VStack(spacing: 0) {
                HeaderView
                    .padding(.top, 50)
                    .padding(.bottom, 8)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Pixelated Image Preview
                        PixelatedImage()
                            .environmentObject(manager)
                            .padding(.top, 15)
                            .padding(.bottom, 5)

                        // Pixel density selector
                        VStack(spacing: 18) {
                            PixelBoardSizeSelector

                            // Action buttons
                            VStack(spacing: 12) {
                                EditButton
                                DownloadButton
                            }
                            .padding(.top, 15)
                            .padding(.bottom, 30)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }

            // Loading overlay
            if manager.showLoading {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()

                VStack(spacing: 15) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)

                    Text("Processing...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showAdvancedSettings) {
            AdvancedSettingsView()
                .environmentObject(manager)
        }
        .onAppear {
            if !manager.isPremiumUser && !didShowInterstitial {
                didShowInterstitial = true
            }
        }
    }

    // MARK: - Header View
    private var HeaderView: some View {
        ZStack {
            HStack {
                Button {
                    manager.savePixelatedImage()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 22))
                }
                .accessibilityLabel("저장")
                .accessibilityHint("픽셀화된 이미지를 저장합니다")
                Spacer()
                Button {
                    manager.fullScreenMode = nil
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 22))
                }
                .accessibilityLabel("닫기")
            }
            Text("Pixel Effect").font(.system(size: 20, weight: .bold))
                .accessibilityAddTraits(.isHeader)
        }
        .padding(.horizontal)
        .foregroundColor(.white)
    }

    // MARK: - Tab Selector
    private var TabSelector: some View {
        HStack(spacing: 8) {
            TabButton(title: "Size", index: 0, selected: $selectedTab)
            TabButton(title: "Palette", index: 1, selected: $selectedTab)
            TabButton(title: "Filters", index: 2, selected: $selectedTab)
            TabButton(title: "Presets", index: 3, selected: $selectedTab)
        }
    }

    // MARK: - Pixel Board Size Selector
    private var PixelBoardSizeSelector: some View {
        VStack(spacing: 18) {
            Text("Select Pixel Density")
                .foregroundColor(.white)
                .font(.headline)

            // Background color picker for transparent images
            if manager.isBackgroundRemovalEnabled {
                HStack {
                    Text("Background Color")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                    Spacer()
                    ColorPicker("", selection: $manager.pixelateBackgroundColor)
                        .labelsHidden()
                        .onChange(of: manager.pixelateBackgroundColor) { oldValue, newValue in
                            // Reapply pixel effect when background color changes
                            if manager.pixelBoardSize != nil {
                                manager.applyPixelEffect(showFilterFlow: false)
                            }
                        }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(AppConfig.toolBackgroundColor))
                )
            }

            LazyVGrid(columns: Array(repeating: GridItem(spacing: 12), count: 2), spacing: 12) {
                ForEach(PixelBoardSize.allCases) { type in
                    PixelBoardSizeItem(type)
                }
            }
        }
        .padding(.top, 5)
    }

    @ViewBuilder
    private func PixelBoardSizeItem(_ type: PixelBoardSize) -> some View {
        let isLocked = !FeatureGating.shared.canUsePixelSize(type)
        
        Button {
            if isLocked {
                // Show paywall for locked features
                showAdvancedSettings = true
            } else {
                manager.pixelBoardSize = type
                manager.applyPixelEffect(showFilterFlow: false)
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(manager.pixelBoardSize == type ? Color.white : Color(AppConfig.toolBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                isLocked ? Color.yellow.opacity(0.5) : Color.clear,
                                lineWidth: 1
                            )
                    )

                VStack(spacing: 4) {
                    HStack {
                        Text(LocalizedStringKey(type.rawValue))
                            .font(.system(size: 16, weight: .bold))
                        
                        if isLocked {
                            Spacer()
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                        }
                    }
                    Text(type.density)
                        .font(.caption)
                }
                .foregroundColor(manager.pixelBoardSize == type ? .black : .white)
            }
        }
        .frame(height: 70)
    }

    // MARK: - Color Palette Selector
    private var ColorPaletteSelector: some View {
        VStack(spacing: 18) {
            Text("Color Palette")
                .foregroundColor(.white)
                .font(.headline)

            VStack(spacing: 10) {
                ForEach(ColorPaletteType.allCases) { palette in
                    ColorPaletteItem(palette)
                }
            }
        }
        .padding(.top, 5)
    }

    @ViewBuilder
    private func ColorPaletteItem(_ palette: ColorPaletteType) -> some View {
        let isLocked = !FeatureGating.shared.canUsePalette(palette)
        
        Button {
            if isLocked {
                // Show paywall for locked palettes
                showAdvancedSettings = true
            } else {
                manager.selectedColorPalette = palette
                manager.applyPixelEffect(showFilterFlow: false)
            }
        } label: {
            HStack(spacing: 12) {
                // Color preview
                HStack(spacing: 3) {
                    ForEach(palette.colors.prefix(4).indices, id: \.self) { index in
                        if index < palette.colors.count {
                            Color(palette.colors[index])
                                .frame(width: 20, height: 50)
                        }
                    }
                }
                .cornerRadius(8)

                // Palette info
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedStringKey(palette.rawValue))
                        .font(.system(size: 16, weight: .semibold))
                    Text(LocalizedStringKey(palette.description))
                        .font(.caption)
                        .lineLimit(2)
                }
                .foregroundColor(.white)

                Spacer()

                if isLocked {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 16))
                } else if manager.selectedColorPalette == palette {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(manager.selectedColorPalette == palette ? Color.blue.opacity(0.3) : Color(AppConfig.toolBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isLocked ? Color.yellow.opacity(0.5) : Color.clear,
                                lineWidth: 1
                            )
                    )
            )
            .opacity(isLocked ? 0.7 : 1.0)
        }
    }

    // MARK: - Filter Effects Selector
    private var FilterEffectsSelector: some View {
        VStack(spacing: 18) {
            Text("Filter Effects")
                .foregroundColor(.white)
                .font(.headline)

            // Intensity slider if filter is selected
            if manager.filterEffect != .none {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Intensity: \(Int(manager.filterIntensity * 100))%")
                        .foregroundColor(.white)
                        .font(.subheadline)

                    Slider(value: $manager.filterIntensity, in: 0...1) { _ in
                        manager.applyPixelEffect(showFilterFlow: false)
                    }
                    .accentColor(.blue)
                }
                .padding(.bottom, 5)
            }

            LazyVGrid(columns: Array(repeating: GridItem(spacing: 12), count: 2), spacing: 12) {
                ForEach(FilterEffectType.allCases) { filter in
                    FilterEffectItem(filter)
                }
            }
        }
        .padding(.top, 5)
    }

    @ViewBuilder
    private func FilterEffectItem(_ filter: FilterEffectType) -> some View {
        // Note: FilterType in FeatureGating might be different, need to map
        let isLocked = !SubscriptionManager.shared.hasAccess(to: .pro) && filter != .crt
        
        Button {
            if isLocked {
                // Show paywall for locked filters
                showAdvancedSettings = true
            } else {
                manager.filterEffect = filter
                if filter != .none {
                    manager.filterIntensity = 0.8
                }
                manager.applyPixelEffect(showFilterFlow: false)
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(LocalizedStringKey(filter.rawValue))
                        .font(.system(size: 15, weight: .bold))
                    Spacer()
                    
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 14))
                    } else if manager.filterEffect == filter {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }

                Text(LocalizedStringKey(filter.description))
                    .font(.caption)
                    .lineLimit(2)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(manager.filterEffect == filter ? Color.blue.opacity(0.3) : Color(AppConfig.toolBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isLocked ? Color.yellow.opacity(0.5) : Color.clear,
                                lineWidth: 1
                            )
                    )
            )
            .opacity(isLocked ? 0.7 : 1.0)
        }
        .frame(height: 90)
    }

    // MARK: - Presets Selector
    private var PresetsSelector: some View {
        VStack(spacing: 18) {
            VStack(spacing: 8) {
                Text("Quick Presets")
                    .foregroundColor(.white)
                    .font(.headline)

                Text("One-tap perfect styles")
                    .foregroundColor(.gray)
                    .font(.caption)
            }

            VStack(spacing: 10) {
                ForEach(EffectPreset.presets) { preset in
                    PresetItem(preset)
                }
            }
        }
        .padding(.top, 5)
    }

    private func PresetItem(_ preset: EffectPreset) -> some View {
        Button {
            manager.applyPreset(preset)
        } label: {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: "sparkles")
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                }

                // Preset info
                VStack(alignment: .leading, spacing: 4) {
                    Text(preset.name)
                        .font(.system(size: 16, weight: .semibold))
                    Text(LocalizedStringKey(preset.description))
                        .font(.caption)
                        .lineLimit(2)
                }
                .foregroundColor(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(AppConfig.toolBackgroundColor))
            )
        }
    }

    // MARK: - Action Buttons
    private var AdvancedSettingsButton: some View {
        Button {
            showAdvancedSettings = true
        } label: {
            HStack {
                Image(systemName: "slider.horizontal.3")
                Text("Advanced")
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(AppConfig.toolBackgroundColor))
            )
        }
    }

    private var DownloadButton: some View {
        Button {
            manager.savePixelatedImage()
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.down")
                Text("Download")
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(AppConfig.continueButtonColor))
            )
        }
        .accessibilityLabel("다운로드")
        .accessibilityHint("픽셀 아트를 사진 앨범에 저장합니다")
    }

    private var EditButton: some View {
        Button {
            // Extract pixel data from pixelated image
            print("🎨 [PixelatedPhotoView] Extracting pixel data...")
            manager.extractPixelDataFromImage()
            // Signal to dismiss photo preview sheet
            manager.shouldDismissPhotoPreview = true
            // Close all modals and return to Pixel Creator
            manager.fullScreenMode = nil
        } label: {
            HStack {
                Image(systemName: "square.grid.3x3.fill.square")
                Text("Use this Pixel")
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(manager.pixelBoardSize == nil ? .gray : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(manager.pixelBoardSize == nil ? Color.gray.opacity(0.5) : Color.blue)
            )
        }
        .disabled(manager.pixelBoardSize == nil)
    }
}

// MARK: - Tab Button Component
struct TabButton: View {
    let title: String
    let index: Int
    @Binding var selected: Int

    var body: some View {
        Button {
            selected = index
        } label: {
            Text(title)
                .font(.system(size: 14, weight: selected == index ? .bold : .regular))
                .foregroundColor(selected == index ? .white : .gray)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(selected == index ? Color(AppConfig.continueButtonColor) : Color(AppConfig.toolBackgroundColor))
                )
        }
    }
}

// MARK: - Preview UI
struct PixelatedPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PixelatedPhotoView().environmentObject(DataManager())
    }
}
//
//  AdvancedSettingsView.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/30.
//

import SwiftUI

struct AdvancedSettingsView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showBatchPicker = false
    @State private var showGIFCreator = false
    @State private var showLayerEditor = false
    @State private var showTemplateGallery = false
    @State private var showExportOptions = false
    @State private var showWatermarkPicker = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(AppConfig.backgroundColor).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Dithering Section
                        DitheringSection

                        // Color Reduction Section
                        ColorReductionSection

                        // Watermark Section
                        WatermarkSection

                        // Export Options Section
                        ExportSection

                        // Advanced Features Section
                        AdvancedFeaturesSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Advanced Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showBatchPicker) {
            BatchProcessingView()
                .environmentObject(manager)
        }
        .sheet(isPresented: $showGIFCreator) {
            GIFCreatorView()
                .environmentObject(manager)
        }
        .sheet(isPresented: $showLayerEditor) {
            LayerEditorView()
                .environmentObject(manager)
        }
        .sheet(isPresented: $showTemplateGallery) {
            TemplateGalleryView()
                .environmentObject(manager)
        }
        .sheet(isPresented: $showExportOptions) {
            ExportOptionsView()
                .environmentObject(manager)
        }
        .sheet(isPresented: $showWatermarkPicker) {
            PhotoPicker { image in
                if let selectedImage = image {
                    manager.saveCustomWatermark(selectedImage)
                }
                showWatermarkPicker = false
            }
        }
    }

    // MARK: - Watermark Section
    private var WatermarkSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Custom Watermark")
                .font(.headline)
                .foregroundColor(.white)

            VStack(spacing: 10) {
                // Preview
                if let watermarkImage = manager.getWatermarkImage() {
                    HStack {
                        Text("Current:")
                            .foregroundColor(.gray)
                            .font(.subheadline)

                        Image(uiImage: watermarkImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )

                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(AppConfig.toolBackgroundColor))
                    )
                }

                // Select New Watermark
                Button {
                    showWatermarkPicker = true
                } label: {
                    HStack {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 20))
                        Text("Select Custom Watermark")
                            .font(.system(size: 16, weight: .semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(AppConfig.toolBackgroundColor))
                    )
                }

                // Remove Custom Watermark
                if manager.useCustomWatermark {
                    Button {
                        manager.removeCustomWatermark()
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                                .font(.system(size: 20))
                            Text("Remove Custom Watermark")
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                        }
                        .foregroundColor(.red)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(AppConfig.toolBackgroundColor))
                        )
                    }
                }
            }
        }
    }

    // MARK: - Dithering Section
    private var DitheringSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dithering Algorithm")
                .font(.headline)
                .foregroundColor(.white)

            ForEach(DitheringType.allCases) { dithering in
                Button {
                    manager.ditheringType = dithering
                    manager.applyPixelEffect(showFilterFlow: false)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(LocalizedStringKey(dithering.rawValue))
                                .font(.system(size: 16, weight: .semibold))
                            Text(LocalizedStringKey(dithering.description))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .foregroundColor(.white)

                        Spacer()

                        if manager.ditheringType == dithering {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(manager.ditheringType == dithering ? Color.blue.opacity(0.2) : Color(AppConfig.toolBackgroundColor))
                    )
                }
            }
        }
    }

    // MARK: - Color Reduction Section
    private var ColorReductionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Color Reduction")
                .font(.headline)
                .foregroundColor(.white)

            Text("Reduce the number of colors in the image")
                .font(.caption)
                .foregroundColor(.gray)

            ForEach(ColorReductionType.allCases) { reduction in
                Button {
                    manager.colorReduction = reduction
                    if reduction != .none {
                        manager.selectedColorPalette = .none
                    }
                    manager.applyPixelEffect(showFilterFlow: false)
                } label: {
                    HStack {
                        Text(LocalizedStringKey(reduction.rawValue))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)

                        Spacer()

                        if manager.colorReduction == reduction {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(manager.colorReduction == reduction ? Color.blue.opacity(0.2) : Color(AppConfig.toolBackgroundColor))
                    )
                }
            }
        }
    }

    // MARK: - Export Section
    private var ExportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Export Settings")
                .font(.headline)
                .foregroundColor(.white)

            Button {
                showExportOptions = true
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Advanced Export")
                            .font(.system(size: 16, weight: .semibold))
                        Text("PNG, SVG, PDF, 4K resolution")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .foregroundColor(.white)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(AppConfig.toolBackgroundColor))
                )
            }
        }
    }

    // MARK: - Advanced Features Section
    private var AdvancedFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Premium Features")
                .font(.headline)
                .foregroundColor(.white)

            // Batch Processing
            FeatureButton(
                icon: "photo.stack",
                title: "Batch Processing",
                description: "Process multiple images at once",
                action: { showBatchPicker = true }
            )

            // GIF Creator
            FeatureButton(
                icon: "film",
                title: "GIF Animation",
                description: "Create animated pixel art GIFs",
                action: { showGIFCreator = true }
            )

            // Layer Editor
            FeatureButton(
                icon: "square.3.layers.3d",
                title: "Layer Editor",
                description: "Professional multi-layer editing",
                action: { showLayerEditor = true }
            )

            // Template Gallery
            FeatureButton(
                icon: "square.grid.3x3",
                title: "Templates",
                description: "Pixel avatars, game sprites & more",
                action: { showTemplateGallery = true }
            )
        }
    }
}

// MARK: - Feature Button Component
struct FeatureButton: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .foregroundColor(.blue)
                        .font(.system(size: 22))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .foregroundColor(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(AppConfig.toolBackgroundColor))
            )
        }
    }
}

// MARK: - Preview
struct AdvancedSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedSettingsView()
            .environmentObject(DataManager())
    }
}
//
//  BatchProcessingView.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/30.
//

import SwiftUI
import PhotosUI

struct BatchProcessingView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    @State private var isProcessing = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(AppConfig.backgroundColor).ignoresSafeArea()

                VStack(spacing: 20) {
                    if selectedImages.isEmpty {
                        // Empty state
                        EmptyStateView
                    } else {
                        // Image grid
                        ImageGridView

                        // Current settings
                        CurrentSettingsView

                        // Progress
                        if isProcessing {
                            ProgressView
                        }

                        // Action buttons
                        ActionButtons
                    }
                }
                .padding()
            }
            .navigationTitle("Batch Processing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showImagePicker = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            MultipleImagePicker(images: $selectedImages)
        }
    }

    // MARK: - Empty State
    private var EmptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.stack")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Images Selected")
                .font(.title2)
                .bold()
                .foregroundColor(.white)

            Text("Tap the + button to select multiple images")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Button(action: { showImagePicker = true }) {
                Text("Select Images")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(AppConfig.continueButtonColor))
                    )
            }
            .padding(.top, 20)
        }
        .padding()
    }

    // MARK: - Image Grid
    private var ImageGridView: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 10), count: 3), spacing: 10) {
                ForEach(selectedImages.indices, id: \.self) { index in
                    Image(uiImage: selectedImages[index])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipped()
                        .cornerRadius(8)
                        .overlay(
                            Button(action: {
                                selectedImages.remove(at: index)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.black.opacity(0.5)))
                            }
                            .padding(4),
                            alignment: .topTrailing
                        )
                }
            }
        }
        .frame(maxHeight: 300)
    }

    // MARK: - Current Settings
    private var CurrentSettingsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Settings")
                .font(.headline)
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 8) {
                SettingRow(label: "Images", value: "\(selectedImages.count)")
                SettingRow(label: "Pixel Size", value: manager.pixelBoardSize?.rawValue ?? "16x16")
                SettingRow(label: "Palette", value: manager.selectedColorPalette.rawValue)
                SettingRow(label: "Filter", value: manager.filterEffect.rawValue)
                SettingRow(label: "Export Format", value: manager.exportFormat.rawValue)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(AppConfig.toolBackgroundColor))
            )
        }
    }

    // MARK: - Progress View
    private var ProgressView: some View {
        VStack(spacing: 12) {
            SwiftUI.ProgressView(value: manager.batchProcessor.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))

            Text("Processing \(manager.batchProcessor.currentImageIndex) of \(manager.batchProcessor.totalImages)")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    // MARK: - Action Buttons
    private var ActionButtons: some View {
        VStack(spacing: 12) {
            Button(action: startBatchProcessing) {
                HStack {
                    if isProcessing {
                        SwiftUI.ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    Text(isProcessing ? "Processing..." : "Start Processing")
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isProcessing ? Color.gray : Color(AppConfig.continueButtonColor))
                )
            }
            .disabled(isProcessing || selectedImages.isEmpty)

            if !isProcessing && !manager.batchProcessor.results.isEmpty {
                Button(action: saveResults) {
                    Text("Save All to Photos")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green)
                        )
                }
            }
        }
    }

    // MARK: - Actions
    private func startBatchProcessing() {
        isProcessing = true

        let config = BatchProcessingConfig(
            pixelSize: manager.pixelBoardSize ?? .normal,
            colorPalette: manager.selectedColorPalette,
            colorReduction: manager.colorReduction,
            ditheringType: manager.ditheringType,
            filterEffect: manager.filterEffect,
            filterIntensity: manager.filterIntensity,
            exportFormat: manager.exportFormat,
            exportSize: 1000
        )

        manager.batchProcessor.processBatch(images: selectedImages, config: config) { results in
            isProcessing = false
            presentAlert(
                title: "Batch Complete",
                message: "Processed \(results.filter { $0.success }.count) images successfully"
            )
        }
    }

    private func saveResults() {
        manager.batchProcessor.saveAllToPhotos(results: manager.batchProcessor.results) { success, message in
            presentAlert(title: success ? "Saved" : "Error", message: message)
            if success {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

// MARK: - Setting Row Component
struct SettingRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .foregroundColor(.white)
                .bold()
        }
        .font(.subheadline)
    }
}

// MARK: - Preview
struct BatchProcessingView_Previews: PreviewProvider {
    static var previews: some View {
        BatchProcessingView()
            .environmentObject(DataManager())
    }
}
//
//  ExportOptionsView.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/30.
//

import SwiftUI

struct ExportOptionsView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var customSize: String = "2000"
    @State private var customBackgroundColor: Color = .white
    @State private var isExporting = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(AppConfig.backgroundColor).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Preview
                        PreviewSection

                        // Format selection
                        FormatSection

                        // Size selection
                        SizeSection

                        // Background selection
                        BackgroundSection

                        // Export button
                        ExportButton
                    }
                    .padding()
                }
            }
            .navigationTitle("Export Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - Preview Section
    private var PreviewSection: some View {
        VStack(spacing: 12) {
            Text("Preview")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let image = manager.pixelatedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .overlay(
                        Text("No image to export")
                            .foregroundColor(.gray)
                    )
            }
        }
    }

    // MARK: - Format Section
    private var FormatSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Export Format")
                .font(.headline)
                .foregroundColor(.white)

            ForEach(ExportFormat.allCases) { format in
                Button {
                    manager.exportFormat = format
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(LocalizedStringKey(format.rawValue))
                                .font(.system(size: 16, weight: .semibold))
                            Text(LocalizedStringKey(format.description))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .foregroundColor(.white)

                        Spacer()

                        if manager.exportFormat == format {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(manager.exportFormat == format ? Color.blue.opacity(0.2) : Color(AppConfig.toolBackgroundColor))
                    )
                }
            }
        }
    }

    // MARK: - Size Section
    private var SizeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Export Size")
                .font(.headline)
                .foregroundColor(.white)

            ForEach(ExportSize.allCases) { size in
                Button {
                    manager.exportSize = size
                } label: {
                    HStack {
                        Text(LocalizedStringKey(size.rawValue))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)

                        Spacer()

                        if manager.exportSize == size {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(manager.exportSize == size ? Color.blue.opacity(0.2) : Color(AppConfig.toolBackgroundColor))
                    )
                }
            }

            // Custom size input
            if manager.exportSize == .custom {
                HStack {
                    Text("Custom Size:")
                        .foregroundColor(.white)
                    TextField("2000", text: $customSize)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                    Text("px")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(AppConfig.toolBackgroundColor))
                )
            }
        }
    }

    // MARK: - Background Section
    private var BackgroundSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Background")
                .font(.headline)
                .foregroundColor(.white)

            ForEach(ExportBackgroundType.allCases) { background in
                Button {
                    manager.exportBackground = background
                } label: {
                    HStack {
                        Text(LocalizedStringKey(background.rawValue))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)

                        Spacer()

                        if manager.exportBackground == background {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(manager.exportBackground == background ? Color.blue.opacity(0.2) : Color(AppConfig.toolBackgroundColor))
                    )
                }
            }

            // Custom color picker
            if manager.exportBackground == .custom {
                ColorPicker("Custom Color", selection: $customBackgroundColor)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(AppConfig.toolBackgroundColor))
                    )
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: - Export Button
    private var ExportButton: some View {
        Button(action: exportImage) {
            HStack {
                if isExporting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                Text(isExporting ? "Exporting..." : "Export Image")
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isExporting ? Color.gray : Color(AppConfig.continueButtonColor))
            )
        }
        .disabled(isExporting || manager.pixelatedImage == nil)
    }

    // MARK: - Export Action
    private func exportImage() {
        guard let image = manager.pixelatedImage else { return }

        isExporting = true

        // Parse custom size if needed
        let customSizeValue: CGFloat? = manager.exportSize == .custom ? CGFloat(Double(customSize) ?? 2000) : nil

        // Get custom background color if needed
        let customBG = manager.exportBackground == .custom ? UIColor(customBackgroundColor) : nil

        // Export image
        if let result = ExportManager.exportImage(
            image,
            format: manager.exportFormat,
            size: manager.exportSize,
            customSize: customSizeValue,
            background: manager.exportBackground,
            customBackgroundColor: customBG
        ), let data = result.data {
            // Save to files
            ExportManager.saveToFiles(data: data, filename: result.filename) { success, url in
                isExporting = false

                if success {
                    presentAlert(
                        title: "Exported",
                        message: "Image exported as \(result.filename)"
                    )
                    presentationMode.wrappedValue.dismiss()
                } else {
                    presentAlert(title: "Error", message: "Failed to export image")
                }
            }
        } else {
            isExporting = false
            presentAlert(title: "Error", message: "Failed to export image")
        }
    }
}

// MARK: - Preview
struct ExportOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        ExportOptionsView()
            .environmentObject(DataManager())
    }
}
//
//  GIFCreatorView.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/30.
//

import SwiftUI

struct GIFCreatorView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedMode: GIFMode = .progressive
    @State private var isCreating = false

    enum GIFMode: String, CaseIterable {
        case progressive = "Progressive Pixelation"
        case glitch = "Glitch Animation"
        case colorCycle = "Color Cycling"

        var icon: String {
            switch self {
            case .progressive: return "square.grid.3x2"
            case .glitch: return "bolt.fill"
            case .colorCycle: return "paintpalette"
            }
        }

        var description: String {
            switch self {
            case .progressive: return "Gradually increase pixelation"
            case .glitch: return "Digital glitch effect animation"
            case .colorCycle: return "Cycle through color palettes"
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(AppConfig.backgroundColor).ignoresSafeArea()

                VStack(spacing: 20) {
                    // Preview image
                    if let image = manager.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(12)
                    }

                    // Mode selector
                    ModeSelectorView

                    // Description
                    Text(LocalizedStringKey(selectedMode.description))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)

                    // Settings based on mode
                    SettingsView

                    Spacer()

                    // Create button
                    CreateButton
                }
                .padding()
            }
            .navigationTitle("GIF Creator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - Mode Selector
    private var ModeSelectorView: some View {
        VStack(spacing: 12) {
            Text("Animation Type")
                .font(.headline)
                .foregroundColor(.white)

            ForEach(GIFMode.allCases, id: \.self) { mode in
                Button {
                    selectedMode = mode
                } label: {
                    HStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(selectedMode == mode ? Color.blue : Color(AppConfig.toolBackgroundColor))
                                .frame(width: 40, height: 40)

                            Image(systemName: mode.icon)
                                .foregroundColor(.white)
                        }

                        Text(LocalizedStringKey(mode.rawValue))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)

                        Spacer()

                        if selectedMode == mode {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedMode == mode ? Color.blue.opacity(0.2) : Color(AppConfig.toolBackgroundColor))
                    )
                }
            }
        }
    }

    // MARK: - Settings View
    private var SettingsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.headline)
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 8) {
                switch selectedMode {
                case .progressive:
                    Text("Frames: 10")
                    Text("Duration: 0.1s per frame")
                case .glitch:
                    Text("Frames: 8")
                    Text("Intensity: High")
                case .colorCycle:
                    Text("Palettes: Vaporwave, Cyberpunk, Pastel")
                    Text("Duration: 0.5s per palette")
                }
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(AppConfig.toolBackgroundColor))
            )
        }
    }

    // MARK: - Create Button
    private var CreateButton: some View {
        Button(action: createGIF) {
            HStack {
                if isCreating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                Text(isCreating ? "Creating GIF..." : "Create GIF")
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isCreating ? Color.gray : Color(AppConfig.continueButtonColor))
            )
        }
        .disabled(isCreating || manager.selectedImage == nil)
    }

    // MARK: - Create GIF Action
    private func createGIF() {
        guard let image = manager.selectedImage else { return }

        isCreating = true

        switch selectedMode {
        case .progressive:
            manager.gifCreator.createProgressivePixelationGIF(
                from: image,
                startPixelSize: .extraLarge,
                endPixelSize: .extraLow,
                frameCount: 10,
                frameDuration: 0.1,
                quality: .medium
            ) { url in
                handleGIFCreated(url: url)
            }

        case .glitch:
            manager.gifCreator.createGlitchAnimationGIF(
                from: image,
                frameCount: 8,
                frameDuration: 0.1,
                glitchIntensity: 0.8,
                quality: .medium
            ) { url in
                handleGIFCreated(url: url)
            }

        case .colorCycle:
            let palettes: [ColorPaletteType] = [.vaporwave, .cyberpunk, .pastel]
            manager.gifCreator.createColorCycleGIF(
                from: image,
                palettes: palettes,
                frameDuration: 0.5,
                quality: .medium
            ) { url in
                handleGIFCreated(url: url)
            }
        }
    }

    private func handleGIFCreated(url: URL?) {
        isCreating = false

        if let url = url {
            // Save GIF
            GIFCreator.saveGIFToPhotos(url: url) { success, error in
                if success {
                    presentAlert(title: "Success", message: "GIF saved to Photos")
                    presentationMode.wrappedValue.dismiss()
                } else {
                    presentAlert(title: "Error", message: error?.localizedDescription ?? "Failed to save GIF")
                }
            }
        } else {
            presentAlert(title: "Error", message: "Failed to create GIF")
        }
    }
}

// MARK: - Preview
struct GIFCreatorView_Previews: PreviewProvider {
    static var previews: some View {
        GIFCreatorView()
            .environmentObject(DataManager())
    }
}
//
//  LayerEditorView.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/30.
//

import SwiftUI

struct LayerEditorView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                Color(AppConfig.backgroundColor).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Canvas preview
                    CanvasPreview

                    Divider()
                        .background(Color.gray)

                    // Layer list
                    LayerList

                    // Control buttons
                    ControlButtons
                }
            }
            .navigationTitle("Layers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveComposite()
                    }
                    .foregroundColor(.blue)
                    .bold()
                }
            }
        }
    }

    // MARK: - Canvas Preview
    private var CanvasPreview: some View {
        ZStack {
            Color.gray.opacity(0.3)

            if let compositeImage = manager.layerManager.renderFinalImage() {
                Image(uiImage: compositeImage)
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(height: 300)
    }

    // MARK: - Layer List
    private var LayerList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(manager.layerManager.layers.indices.reversed(), id: \.self) { index in
                    LayerRow(index: index)
                }
            }
            .padding()
        }
    }

    // MARK: - Layer Row
    private func LayerRow(index: Int) -> some View {
        let layer = manager.layerManager.layers[index]

        return HStack(spacing: 12) {
            // Visibility toggle
            Button {
                manager.layerManager.toggleLayerVisibility(at: index)
            } label: {
                Image(systemName: layer.isVisible ? "eye" : "eye.slash")
                    .foregroundColor(layer.isVisible ? .blue : .gray)
                    .frame(width: 30)
            }

            // Thumbnail
            if let image = layer.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipped()
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
            }

            // Layer info
            VStack(alignment: .leading, spacing: 4) {
                Text(layer.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Text("\(Int(layer.opacity * 100))%")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text(layer.blendMode.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)

                    if layer.isLocked {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }

            Spacer()

            // Selection indicator
            if manager.layerManager.selectedLayerIndex == index {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(manager.layerManager.selectedLayerIndex == index ? Color.blue.opacity(0.2) : Color(AppConfig.toolBackgroundColor))
        )
        .onTapGesture {
            manager.layerManager.selectedLayerIndex = index
        }
    }

    // MARK: - Control Buttons
    private var ControlButtons: some View {
        HStack(spacing: 12) {
            // Add layer
            Button {
                if let image = manager.selectedImage {
                    manager.layerManager.addLayer(name: "Layer \(manager.layerManager.layers.count + 1)", image: image)
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "plus.square")
                    Text("Add")
                        .font(.caption)
                }
            }

            Divider()
                .frame(height: 30)

            // Duplicate layer
            Button {
                if let index = manager.layerManager.selectedLayerIndex {
                    manager.layerManager.duplicateLayer(at: index)
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "doc.on.doc")
                    Text("Duplicate")
                        .font(.caption)
                }
            }
            .disabled(manager.layerManager.selectedLayerIndex == nil)

            Divider()
                .frame(height: 30)

            // Delete layer
            Button {
                if let index = manager.layerManager.selectedLayerIndex {
                    manager.layerManager.removeLayer(at: index)
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "trash")
                    Text("Delete")
                        .font(.caption)
                }
            }
            .disabled(manager.layerManager.selectedLayerIndex == nil || manager.layerManager.layers.count <= 1)
            .foregroundColor(.red)

            Divider()
                .frame(height: 30)

            // Merge
            Button {
                manager.layerManager.flattenLayers()
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "square.3.layers.3d.down.right")
                    Text("Merge")
                        .font(.caption)
                }
            }
        }
        .foregroundColor(.white)
        .padding()
        .background(Color(AppConfig.toolBackgroundColor))
    }

    // MARK: - Actions
    private func saveComposite() {
        if let finalImage = manager.layerManager.renderFinalImage() {
            manager.pixelatedImage = finalImage
            presentAlert(title: "Success", message: "Layers merged successfully")
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Preview
struct LayerEditorView_Previews: PreviewProvider {
    static var previews: some View {
        LayerEditorView()
            .environmentObject(DataManager())
    }
}
//
//  TemplateGalleryView.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/30.
//

import SwiftUI

struct TemplateGalleryView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedCategory: TemplateCategory = .profile

    var body: some View {
        NavigationView {
            ZStack {
                Color(AppConfig.backgroundColor).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Category selector
                    CategorySelector

                    // Template grid
                    TemplateGrid
                }
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - Category Selector
    private var CategorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TemplateCategory.allCases) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Text(LocalizedStringKey(category.rawValue))
                            .font(.system(size: 14, weight: selectedCategory == category ? .bold : .regular))
                            .foregroundColor(selectedCategory == category ? .white : .gray)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedCategory == category ? Color.blue : Color(AppConfig.toolBackgroundColor))
                            )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(AppConfig.backgroundColor))
    }

    // MARK: - Template Grid
    private var TemplateGrid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 15), count: 2), spacing: 15) {
                ForEach(selectedCategory.templates) { template in
                    TemplateCard(template: template)
                }
            }
            .padding()
        }
    }

    // MARK: - Template Card
    private func TemplateCard(template: Template) -> some View {
        Button {
            applyTemplate(template)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Template preview
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(template.aspectRatio, contentMode: .fit)

                    VStack(spacing: 4) {
                        Image(systemName: "photo")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)

                        Text("\(Int(template.size.width))x\(Int(template.size.height))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                // Template info
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)

                    Text(LocalizedStringKey(template.description))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        Label("\(template.pixelSize)px", systemImage: "square.grid.3x3")
                        if template.hasBorder {
                            Label("Border", systemImage: "rectangle.dashed")
                        }
                    }
                    .font(.caption2)
                    .foregroundColor(.blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(AppConfig.toolBackgroundColor))
            )
        }
    }

    // MARK: - Apply Template
    private func applyTemplate(_ template: Template) {
        guard let image = manager.selectedImage else {
            presentAlert(title: "No Image", message: "Please select an image first")
            return
        }

        // Apply template
        if let processedImage = manager.templateManager.applyTemplate(to: image, template: template) {
            manager.selectedImage = processedImage

            // Apply recommended palette if available
            if let paletteName = template.recommendedPalette,
               let palette = ColorPaletteType.allCases.first(where: { $0.rawValue.lowercased() == paletteName.lowercased() }) {
                manager.selectedColorPalette = palette
            }

            // Set pixel size based on template
            if let pixelSize = PixelBoardSize.allCases.first(where: { $0.count == template.pixelSize }) {
                manager.pixelBoardSize = pixelSize
            }

            // Apply effect
            manager.applyPixelEffect(showFilterFlow: false)

            presentAlert(title: "Template Applied", message: "Template '\(template.name)' has been applied")
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Preview
struct TemplateGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateGalleryView()
            .environmentObject(DataManager())
    }
}
//
//  PhotoPreviewView.swift
//  PixelMe
//
//  Photo preview with Pixelize and Remove Background options
//

import SwiftUI

struct PhotoPreviewView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.presentationMode) var presentationMode

    let selectedImage: UIImage
    @State private var showRemoveBackgroundResult = false
    @State private var removedBackgroundImage: UIImage?
    @State private var isProcessing = false

    var body: some View {
        ZStack {
            Color(AppConfig.backgroundColor).ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                HeaderView

                ScrollView {
                    VStack(spacing: 25) {
                        // Selected Image Preview
                        ImagePreview

                        // Title
                        VStack(spacing: 8) {
                            Text("Choose an option")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)

                            Text("Transform your photo into pixel art")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 10)

                        // Options
                        VStack(spacing: 15) {
                            PixelizeButton
                            RemoveBackgroundButton
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .sheet(isPresented: $showRemoveBackgroundResult) {
            if let bgRemovedImage = removedBackgroundImage {
                BackgroundRemovalResultView(
                    originalImage: selectedImage,
                    removedBackgroundImage: bgRemovedImage
                )
                .environmentObject(manager)
            }
        }
    }

    private var HeaderView: some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 22))
            }

            Spacer()

            Text("Photo Preview")
                .font(.system(size: 20, weight: .bold))

            Spacer()

            // Invisible spacer for center alignment
            Image(systemName: "xmark")
                .font(.system(size: 22))
                .opacity(0)
        }
        .padding(.top, 30)
        .padding(.horizontal)
        .foregroundColor(.white)
    }

    private var ImagePreview: some View {
        Image(uiImage: selectedImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: min(UIScreen.main.bounds.width - 40, 350))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }

    private var PixelizeButton: some View {
        Button {
            // Set image and apply pixelation
            manager.selectedImage = selectedImage
            manager.applyPixelEffect()
            presentationMode.wrappedValue.dismiss()
        } label: {
            HStack(spacing: 15) {
                Image(systemName: "square.grid.3x3.fill")
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Pixelize")
                        .font(.system(size: 18, weight: .bold))
                    Text("Create pixel art instantly")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(AppConfig.continueButtonColor))
            )
        }
    }

    private var RemoveBackgroundButton: some View {
        Button {
            isProcessing = true

            BackgroundRemovalManager.removeBackgroundSmart(from: selectedImage) { result in
                isProcessing = false

                if let removedBgImage = result {
                    removedBackgroundImage = removedBgImage
                    showRemoveBackgroundResult = true
                } else {
                    presentAlert(
                        title: "Error",
                        message: "Failed to remove background. This feature requires iOS 15 or later."
                    )
                }
            }
        } label: {
            HStack(spacing: 15) {
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 24))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Remove Background")
                        .font(.system(size: 18, weight: .bold))
                    Text(isProcessing ? "Processing..." : "Keep only the subject")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                Spacer()

                if !isProcessing {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(AppConfig.toolBackgroundColor))
            )
        }
        .disabled(isProcessing)
    }
}
//
//  BackgroundRemovalResultView.swift
//  PixelMe
//
//  Shows the result of background removal with option to choose or keep original
//

import SwiftUI

struct BackgroundRemovalResultView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.presentationMode) var presentationMode

    let originalImage: UIImage
    let removedBackgroundImage: UIImage

    @State private var showComparison = false

    var body: some View {
        ZStack {
            Color(AppConfig.backgroundColor).ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                HeaderView

                ScrollView {
                    VStack(spacing: 25) {
                        // Result Image Preview
                        ResultPreview

                        // Toggle Comparison
                        ComparisonToggle

                        // Title
                        VStack(spacing: 8) {
                            Text("Background Removed!")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)

                            Text("Choose the version you want to pixelize")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 10)

                        // Options
                        VStack(spacing: 15) {
                            ChooseButton
                            KeepBackgroundButton
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
    }

    private var HeaderView: some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22))
            }

            Spacer()

            Text("Result")
                .font(.system(size: 20, weight: .bold))

            Spacer()

            // Invisible spacer for center alignment
            Image(systemName: "chevron.left")
                .font(.system(size: 22))
                .opacity(0)
        }
        .padding(.horizontal)
        .padding(.top, 30)
        .foregroundColor(.white)
    }

    private var ResultPreview: some View {
        ZStack {
            // Checkered background to show transparency
            CheckeredBackground()
                .frame(maxWidth: min(UIScreen.main.bounds.width - 40, 350))
                .frame(height: min(UIScreen.main.bounds.width - 40, 350))
                .cornerRadius(12)

            Image(uiImage: showComparison ? originalImage : removedBackgroundImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: min(UIScreen.main.bounds.width - 40, 350))
                .cornerRadius(12)
        }
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }

    private var ComparisonToggle: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                showComparison.toggle()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: showComparison ? "eye.slash" : "eye")
                    .font(.system(size: 14))

                Text(showComparison ? "Original" : "Background Removed")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(AppConfig.toolBackgroundColor))
            )
        }
    }

    private var ChooseButton: some View {
        Button {
            // Use background removed image
            manager.selectedImage = removedBackgroundImage
            manager.isBackgroundRemovalEnabled = true
            manager.applyPixelEffect()

            // Dismiss all sheets
            presentationMode.wrappedValue.dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + AppConfig.dismissAnimationDelay) {
                // Dismiss the parent PhotoPreviewView too
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.dismiss(animated: true)
                }
            }
        } label: {
            HStack(spacing: 15) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Choose This")
                        .font(.system(size: 18, weight: .bold))
                    Text("Pixelize without background")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .foregroundColor(.white)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.green.opacity(0.7))
            )
        }
    }

    private var KeepBackgroundButton: some View {
        Button {
            // Use original image
            manager.selectedImage = originalImage
            manager.isBackgroundRemovalEnabled = false
            manager.applyPixelEffect()

            // Dismiss all sheets
            presentationMode.wrappedValue.dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + AppConfig.dismissAnimationDelay) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.dismiss(animated: true)
                }
            }
        } label: {
            HStack(spacing: 15) {
                Image(systemName: "photo")
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Keep Background")
                        .font(.system(size: 18, weight: .bold))
                    Text("Pixelize with original image")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .foregroundColor(.white)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(AppConfig.toolBackgroundColor))
            )
        }
    }
}

// Checkered background to show transparency
struct CheckeredBackground: View {
    var body: some View {
        GeometryReader { geometry in
            let size: CGFloat = 20
            let rows = Int(geometry.size.height / size) + 1
            let cols = Int(geometry.size.width / size) + 1

            VStack(spacing: 0) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<cols, id: \.self) { col in
                            Rectangle()
                                .fill((row + col) % 2 == 0 ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                                .frame(width: size, height: size)
                        }
                    }
                }
            }
        }
    }
}
