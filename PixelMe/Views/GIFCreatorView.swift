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
