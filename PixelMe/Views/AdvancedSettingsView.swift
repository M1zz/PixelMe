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
                description: "NFT avatars, game sprites & more",
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
