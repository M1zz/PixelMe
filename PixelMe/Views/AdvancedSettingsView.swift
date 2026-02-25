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
    @State private var showPaywall = false

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
        .sheet(isPresented: $showPaywall) {
            PaywallView(isProUser: .constant(false))
        }
    }

    // MARK: - Dithering Section
    private var DitheringSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Dithering Algorithm")
                    .font(.headline)
                    .foregroundColor(.white)
                
                if !FeatureGating.shared.canUseDithering {
                    Spacer()
                    Image(systemName: "lock.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 16))
                }
            }

            ForEach(DitheringType.allCases) { dithering in
                let isLocked = !FeatureGating.shared.canUseDithering && dithering != .none
                
                Button {
                    if isLocked {
                        // Show paywall
                        showPaywall = true
                    } else {
                        manager.ditheringType = dithering
                        manager.applyPixelEffect(showFilterFlow: false)
                    }
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

                        if isLocked {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 14))
                        } else if manager.ditheringType == dithering {
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
                isLocked: !FeatureGating.shared.canUseBatchProcessing,
                action: { 
                    if FeatureGating.shared.canUseBatchProcessing {
                        showBatchPicker = true
                    } else {
                        showPaywall = true
                    }
                }
            )

            // GIF Creator
            FeatureButton(
                icon: "film",
                title: "GIF Animation",
                description: "Create animated pixel art GIFs",
                isLocked: !FeatureGating.shared.canUseGIF,
                action: { 
                    if FeatureGating.shared.canUseGIF {
                        showGIFCreator = true
                    } else {
                        showPaywall = true
                    }
                }
            )

            // Layer Editor
            FeatureButton(
                icon: "square.3.layers.3d",
                title: "Layer Editor",
                description: "Professional multi-layer editing",
                isLocked: !FeatureGating.shared.canUseLayers,
                action: { 
                    if FeatureGating.shared.canUseLayers {
                        showLayerEditor = true
                    } else {
                        showPaywall = true
                    }
                }
            )

            // Template Gallery
            FeatureButton(
                icon: "square.grid.3x3",
                title: "Templates",
                description: "Pixel avatars, game sprites & more",
                isLocked: false, // Templates have mixed access
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
    let isLocked: Bool
    let action: () -> Void
    
    init(icon: String, title: String, description: String, isLocked: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.description = description
        self.isLocked = isLocked
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(isLocked ? Color.gray.opacity(0.2) : Color.blue.opacity(0.2))
                        .frame(width: 50, height: 50)

                    if isLocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 18))
                    } else {
                        Image(systemName: icon)
                            .foregroundColor(.blue)
                            .font(.system(size: 22))
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold))
                        
                        if isLocked {
                            Spacer()
                            Text("Pro")
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.yellow)
                                .foregroundColor(.black)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .foregroundColor(.white)

                Spacer()

                Image(systemName: isLocked ? "lock.fill" : "chevron.right")
                    .foregroundColor(isLocked ? .yellow : .gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(AppConfig.toolBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isLocked ? Color.yellow.opacity(0.3) : Color.clear,
                                lineWidth: 1
                            )
                    )
            )
            .opacity(isLocked ? 0.7 : 1.0)
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
