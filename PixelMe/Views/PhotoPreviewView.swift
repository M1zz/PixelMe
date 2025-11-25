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
            Color(AppConfig.backgroundColor)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                HeaderView
                    .padding(.top, 70)

                ScrollView {
                    VStack(spacing: 25) {
                        // Selected Image Preview
                        ImagePreview

                        // Title
                        VStack(spacing: 8) {
                            Text("선택된 이미지")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)

                            Text("옵션을 선택하여 픽셀 아트로 변환하세요")
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

            // Loading overlay
            if manager.showLoading {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()

                VStack(spacing: 15) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)

                    Text("처리 중...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
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
        .onChange(of: manager.fullScreenMode) { newValue in
            print("🔄 [PhotoPreviewView] fullScreenMode changed to: \(String(describing: newValue))")
            // When fullScreenMode is set to applyFilter, dismiss this preview
            if newValue == .applyFilter {
                print("✅ [PhotoPreviewView] Dismissing preview to show PixelatedPhotoView")
                presentationMode.wrappedValue.dismiss()
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

            Text("사진 미리보기")
                .font(.system(size: 20, weight: .bold))

            Spacer()

            // Invisible spacer for center alignment
            Image(systemName: "xmark")
                .font(.system(size: 22))
                .opacity(0)
        }
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
            print("🎨 [PhotoPreviewView] Pixelize button tapped")
            // Set image and apply pixelation
            manager.selectedImage = selectedImage
            print("🎨 [PhotoPreviewView] Calling applyPixelEffect()")
            manager.applyPixelEffect()
            print("🎨 [PhotoPreviewView] applyPixelEffect() called, waiting for fullScreenMode change...")
            // Don't dismiss here - let onChange handler dismiss when fullScreenMode changes
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
