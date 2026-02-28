//
//  ProfilePixelateView.swift
//  PixelMe
//
//  Profile pixelation mode - auto-detect face, crop, pixelate
//

import SwiftUI
import Vision

struct ProfilePixelateView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showPhotoPicker = false
    @State private var selectedImage: UIImage?
    @State private var croppedFaceImage: UIImage?
    @State private var pixelatedResult: UIImage?
    @State private var isProcessing = false
    @State private var showNoFaceAlert = false
    @State private var selectedPixelSize: PixelBoardSize = .normal
    @State private var showShareSheet = false
    @State private var showBeforeAfterToggle = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(AppConfig.backgroundColor).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        if let result = pixelatedResult {
                            // Result view
                            ResultView(result: result)
                        } else if let cropped = croppedFaceImage {
                            // Cropped face preview before pixelation
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
                    if pixelatedResult != nil {
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
        .sheet(isPresented: $showShareSheet) {
            if let result = pixelatedResult {
                let baseImage: UIImage = {
                    if showBeforeAfterToggle, let original = croppedFaceImage {
                        return BeforeAfterImageGenerator.generate(original: original, pixelated: result) ?? result
                    }
                    return result
                }()
                let isPro = SubscriptionManager.shared.isProUser
                let finalImage = isPro ? baseImage : FreeUsageManager.applyWatermark(to: baseImage)
                if isPro {
                    ShareSheet(items: [finalImage])
                } else {
                    ShareSheet(items: [finalImage, "Created with PixelMe 🎨\n\(FreeUsageManager.appStoreURL)" as Any])
                }
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
            
            // Pixel size selector
            VStack(spacing: 10) {
                Text("Pixel Density")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 10) {
                    ForEach([PixelBoardSize.extraLow, .low, .normal, .medium]) { size in
                        Button {
                            selectedPixelSize = size
                        } label: {
                            Text(size.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(selectedPixelSize == size ? .black : .white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedPixelSize == size ? Color.white : Color(AppConfig.toolBackgroundColor))
                                )
                        }
                    }
                }
            }
            
            Button {
                applyPixelation(to: image)
            } label: {
                HStack {
                    Image(systemName: "square.grid.3x3.fill")
                    Text("Pixelate")
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
    
    // MARK: - Result View
    private func ResultView(result: UIImage) -> some View {
        VStack(spacing: 20) {
            Text("Profile Pixel Art")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Image(uiImage: result)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 280, height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Before/After toggle
            Toggle(isOn: $showBeforeAfterToggle) {
                HStack {
                    Image(systemName: "rectangle.split.2x1")
                    Text("비포/애프터로 공유")
                        .font(.system(size: 15))
                }
                .foregroundColor(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(AppConfig.toolBackgroundColor))
            )
            
            // Before/After preview
            if showBeforeAfterToggle, let original = croppedFaceImage {
                if let comparison = BeforeAfterImageGenerator.generate(original: original, pixelated: result) {
                    Image(uiImage: comparison)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .cornerRadius(12)
                }
            }
            
            HStack(spacing: 12) {
                Button {
                    UIImageWriteToSavedPhotosAlbum(result, nil, nil, nil)
                    presentAlert(title: "Saved", message: "Profile pixel art saved to Photos")
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save")
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
                
                Button {
                    showShareSheet = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                    )
                }
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
    
    // MARK: - Pixelation
    private func applyPixelation(to image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        isProcessing = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let imageWidth = CGFloat(cgImage.width)
            let ciImage = CIImage(cgImage: cgImage)
            let gridSize = CGFloat(self.selectedPixelSize.count)
            let pixelScale = imageWidth / gridSize
            
            let filter = CIFilter(name: "CIPixellate")
            filter?.setValue(ciImage, forKey: kCIInputImageKey)
            filter?.setValue(pixelScale, forKey: kCIInputScaleKey)
            filter?.setValue(CIVector(x: pixelScale / 2, y: pixelScale / 2), forKey: kCIInputCenterKey)
            
            guard let output = filter?.outputImage else {
                DispatchQueue.main.async { self.isProcessing = false }
                return
            }
            
            let context = CIContext()
            guard let resultCG = context.createCGImage(output, from: output.extent) else {
                DispatchQueue.main.async { self.isProcessing = false }
                return
            }
            
            DispatchQueue.main.async {
                self.pixelatedResult = UIImage(cgImage: resultCG)
                self.isProcessing = false
            }
        }
    }
    
    private func resetState() {
        selectedImage = nil
        croppedFaceImage = nil
        pixelatedResult = nil
        showBeforeAfterToggle = false
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
