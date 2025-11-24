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
