//
//  ProfilePixelateView.swift
//  PixelMe
//
//  Profile pixelation mode - auto-detect face, crop, open in pixel editor
//

import SwiftUI
import Vision

struct ProfilePixelateView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.presentationMode) var presentationMode

    @State private var showPhotoPicker = false
    @State private var selectedImage: UIImage?
    @State private var croppedFaceImage: UIImage?
    @State private var isProcessing = false
    @State private var showNoFaceAlert = false
    @State private var selectedPreset: CanvasPreset = .small
    @State private var showPixelEditor = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(AppConfig.backgroundColor).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        if let cropped = croppedFaceImage {
                            // Cropped face preview — choose size & open editor
                            CroppedPreview(image: cropped)
                        } else if let selected = selectedImage {
                            // Selected image with face detection in progress
                            SelectedImageView(image: selected)
                        } else {
                            // Empty state
                            EmptyStateView
                        }
                    }
                    .padding()
                }

                if isProcessing {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    VStack(spacing: 15) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        Text("Detecting face...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationTitle("Profile Pixel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if croppedFaceImage != nil {
                        Button {
                            resetState()
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPicker { image in
                if let image = image {
                    selectedImage = image
                    detectFaceAndCrop(image: image)
                }
            }
        }
        .fullScreenCover(isPresented: $showPixelEditor) {
            if let faceImage = croppedFaceImage {
                PixelEditorView(fromImage: faceImage, targetSize: selectedPreset.size.width)
            }
        }
        .alert("No Face Detected", isPresented: $showNoFaceAlert) {
            Button("Select Again") {
                showPhotoPicker = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Could not detect a face in this photo. Please try another photo or use manual crop.")
        }
    }

    // MARK: - Empty State
    private var EmptyStateView: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 60)

            Image(systemName: "person.crop.square")
                .font(.system(size: 70))
                .foregroundColor(.gray)

            Text("Profile Pixel")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)

            Text("Auto-detect your face and create a pixelated profile picture")
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Button {
                showPhotoPicker = true
            } label: {
                HStack {
                    Image(systemName: "photo.fill")
                    Text("Select Photo")
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
            .padding(.top, 20)
        }
    }

    // MARK: - Selected Image View
    private func SelectedImageView(image: UIImage) -> some View {
        VStack(spacing: 15) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 300)
                .cornerRadius(12)

            Text("Processing...")
                .foregroundColor(.gray)
        }
    }

    // MARK: - Cropped Preview
    private func CroppedPreview(image: UIImage) -> some View {
        VStack(spacing: 20) {
            Text("Face Detected!")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 250, height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            // Canvas size selector
            VStack(spacing: 10) {
                Text("Canvas Size")
                    .font(.headline)
                    .foregroundColor(.white)

                HStack(spacing: 10) {
                    ForEach(CanvasPreset.allCases, id: \.self) { preset in
                        Button {
                            selectedPreset = preset
                        } label: {
                            Text(preset.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(selectedPreset == preset ? .black : .white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedPreset == preset ? Color.white : Color(AppConfig.toolBackgroundColor))
                                )
                        }
                    }
                }
            }

            Button {
                showPixelEditor = true
            } label: {
                HStack {
                    Image(systemName: "pencil.and.outline")
                    Text("Open in Editor")
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
        }
    }

    // MARK: - Face Detection
    private func detectFaceAndCrop(image: UIImage) {
        isProcessing = true

        guard let cgImage = image.cgImage else {
            isProcessing = false
            showNoFaceAlert = true
            return
        }

        let request = VNDetectFaceRectanglesRequest { request, error in
            DispatchQueue.main.async {
                self.isProcessing = false

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

    private func resetState() {
        selectedImage = nil
        croppedFaceImage = nil
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
