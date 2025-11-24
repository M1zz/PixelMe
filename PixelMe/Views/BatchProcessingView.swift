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
