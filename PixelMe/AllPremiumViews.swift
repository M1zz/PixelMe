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
                            Text(dithering.rawValue)
                                .font(.system(size: 16, weight: .semibold))
                            Text(dithering.description)
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
                        Text(reduction.rawValue)
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
                SettingRow(label: "Pixel Size", value: manager.pixelBoardSize.rawValue)
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
            pixelSize: manager.pixelBoardSize,
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
                            Text(format.rawValue)
                                .font(.system(size: 16, weight: .semibold))
                            Text(format.description)
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
                        Text(size.rawValue)
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
                        Text(background.rawValue)
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
        ) {
            // Save to files
            ExportManager.saveToFiles(data: result.data, filename: result.filename) { success, url in
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
                    Text(selectedMode.description)
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

                        Text(mode.rawValue)
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
                        Text(category.rawValue)
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

                    Text(template.description)
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
