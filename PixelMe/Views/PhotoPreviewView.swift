//
//  PhotoPreviewView.swift
//  PixelMe
//
//  Photo preview — immersive visual with clear action cards
//

import SwiftUI
import Vision

struct PhotoPreviewView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.presentationMode) var presentationMode

    let selectedImage: UIImage
    @State private var showRemoveBackgroundResult = false
    @State private var removedBackgroundImage: UIImage?
    @State private var isProcessing = false
    @State private var showSizeSheet = false
    @State private var showPixelEditor = false
    @State private var selectedPreset: CanvasPreset = .small

    // Profile Pixel states
    @State private var isDetectingFace = false
    @State private var croppedFaceImage: UIImage?
    @State private var showFaceSizeSheet = false
    @State private var showFacePixelEditor = false
    @State private var facePreset: CanvasPreset = .small
    @State private var showNoFaceAlert = false

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.02, blue: 0.10),
                    Color(red: 0.08, green: 0.05, blue: 0.18)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.top, 60)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Image preview — hero
                        imagePreview
                            .padding(.top, 16)

                        // Action cards
                        VStack(spacing: 12) {
                            pixelizeCard
                            profilePixelCard
                            removeBackgroundCard
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }

            // Loading overlay
            if manager.showLoading || isDetectingFace {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)

                    Text(isDetectingFace ? "Detecting face..." : "Pixelating...")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
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
        .sheet(isPresented: $showSizeSheet) {
            canvasSizePickerSheet(title: "Select Size") { preset in
                selectedPreset = preset
                showSizeSheet = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showPixelEditor = true
                }
            }
        }
        .sheet(isPresented: $showFaceSizeSheet) {
            canvasSizePickerSheet(title: "Select Size") { preset in
                facePreset = preset
                showFaceSizeSheet = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showFacePixelEditor = true
                }
            }
        }
        .fullScreenCover(isPresented: $showPixelEditor) {
            PixelEditorView(fromImage: selectedImage, targetSize: selectedPreset.size.width)
        }
        .fullScreenCover(isPresented: $showFacePixelEditor) {
            if let faceImage = croppedFaceImage {
                PixelEditorView(fromImage: faceImage, targetSize: facePreset.size.width)
            }
        }
        .alert("No Face Detected", isPresented: $showNoFaceAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Could not detect a face in this photo. Try another photo or use Pixelize instead.")
        }
        .onChange(of: manager.fullScreenMode) { newValue in
            if newValue == .applyFilter {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    // MARK: - Reusable Canvas Size Picker Sheet

    private func canvasSizePickerSheet(title: String, onSelect: @escaping (CanvasPreset) -> Void) -> some View {
        NavigationStack {
            List {
                Section("Canvas Size") {
                    ForEach(CanvasPreset.allCases, id: \.self) { preset in
                        Button {
                            onSelect(preset)
                        } label: {
                            HStack {
                                Text(preset.rawValue)
                                Spacer()
                            }
                        }
                        .tint(.primary)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        showSizeSheet = false
                        showFaceSizeSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 40, height: 40)
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            Spacer()

            Text("Transform")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            Spacer()

            // Invisible spacer for center alignment
            Circle()
                .fill(Color.clear)
                .frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Image Preview

    private var imagePreview: some View {
        VStack(spacing: 16) {
            Image(uiImage: selectedImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: min(UIScreen.main.bounds.width - 48, 340))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)

            // Hint text
            Text("Choose how to transform your photo")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.4))
        }
    }

    // MARK: - Pixelize Card

    private var pixelizeCard: some View {
        Button {
            showSizeSheet = true
        } label: {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [Color.cyan.opacity(0.2), Color.blue.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)

                    Image(systemName: "square.grid.3x3.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.cyan)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Pixelize")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Text("Create pixel art instantly")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.45))
                }

                Spacer()

                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.cyan.opacity(0.6))
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.cyan.opacity(0.15), lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Profile Pixel Card

    private var profilePixelCard: some View {
        Button {
            detectFaceAndCrop()
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 52, height: 52)

                    Image(systemName: "person.crop.square.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.orange)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Profile Pixel")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Text("Face detect → pixel profile")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.45))
                }

                Spacer()

                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.orange.opacity(0.5))
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.orange.opacity(0.12), lineWidth: 1)
                    )
            )
        }
        .disabled(isDetectingFace)
    }

    // MARK: - Remove Background Card

    private var removeBackgroundCard: some View {
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
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.purple.opacity(0.15))
                        .frame(width: 52, height: 52)

                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                    } else {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 22))
                            .foregroundColor(.purple)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Remove Background")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Text(isProcessing ? "Processing..." : "Keep only the subject")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.45))
                }

                Spacer()

                if !isProcessing {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.purple.opacity(0.5))
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.purple.opacity(0.12), lineWidth: 1)
                    )
            )
        }
        .disabled(isProcessing)
    }

    // MARK: - Face Detection

    private func detectFaceAndCrop() {
        guard let cgImage = selectedImage.cgImage else {
            showNoFaceAlert = true
            return
        }

        isDetectingFace = true

        let request = VNDetectFaceRectanglesRequest { request, error in
            DispatchQueue.main.async {
                self.isDetectingFace = false

                guard let results = request.results as? [VNFaceObservation],
                      let face = results.first else {
                    self.showNoFaceAlert = true
                    return
                }

                // Face bounding box is normalized (0-1), origin at bottom-left
                let imageWidth = CGFloat(cgImage.width)
                let imageHeight = CGFloat(cgImage.height)

                let faceBounds = face.boundingBox

                // Convert to image coordinates
                let centerX = faceBounds.midX * imageWidth
                let centerY = (1 - faceBounds.midY) * imageHeight  // Flip Y
                let faceWidth = faceBounds.width * imageWidth
                let faceHeight = faceBounds.height * imageHeight

                // Apply 1.3x padding and make square
                let maxDim = max(faceWidth, faceHeight) * 1.3
                let squareSize = min(maxDim, min(imageWidth, imageHeight))

                let cropX = max(0, centerX - squareSize / 2)
                let cropY = max(0, centerY - squareSize / 2)
                let adjustedX = min(cropX, imageWidth - squareSize)
                let adjustedY = min(cropY, imageHeight - squareSize)

                let cropRect = CGRect(
                    x: max(0, adjustedX),
                    y: max(0, adjustedY),
                    width: min(squareSize, imageWidth),
                    height: min(squareSize, imageHeight)
                )

                if let croppedCG = cgImage.cropping(to: cropRect) {
                    self.croppedFaceImage = UIImage(cgImage: croppedCG)
                    self.showFaceSizeSheet = true
                } else {
                    self.showNoFaceAlert = true
                }
            }
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
}
