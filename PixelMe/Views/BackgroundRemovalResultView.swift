//
//  BackgroundRemovalResultView.swift
//  PixelMe
//
//  Shows the result of background removal with option to choose or keep original
//

import SwiftUI

struct BackgroundRemovalResultView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.presentationMode) var presentationMode

    let originalImage: UIImage
    let removedBackgroundImage: UIImage

    @State private var showComparison = false

    var body: some View {
        ZStack {
            Color(AppConfig.backgroundColor).ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                HeaderView

                ScrollView {
                    VStack(spacing: 25) {
                        // Result Image Preview
                        ResultPreview

                        // Toggle Comparison
                        ComparisonToggle

                        // Title
                        VStack(spacing: 8) {
                            Text("Background Removed!")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)

                            Text("Choose the version you want to pixelize")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 10)

                        // Options
                        VStack(spacing: 15) {
                            ChooseButton
                            KeepBackgroundButton
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
    }

    private var HeaderView: some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22))
            }

            Spacer()

            Text("Result")
                .font(.system(size: 20, weight: .bold))

            Spacer()

            // Invisible spacer for center alignment
            Image(systemName: "chevron.left")
                .font(.system(size: 22))
                .opacity(0)
        }
        .padding(.horizontal)
        .foregroundColor(.white)
    }

    private var ResultPreview: some View {
        ZStack {
            // Checkered background to show transparency
            CheckeredBackground()
                .frame(maxWidth: min(UIScreen.main.bounds.width - 40, 350))
                .frame(height: min(UIScreen.main.bounds.width - 40, 350))
                .cornerRadius(12)

            Image(uiImage: showComparison ? originalImage : removedBackgroundImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: min(UIScreen.main.bounds.width - 40, 350))
                .cornerRadius(12)
        }
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }

    private var ComparisonToggle: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                showComparison.toggle()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: showComparison ? "eye.slash" : "eye")
                    .font(.system(size: 14))

                Text(showComparison ? "Original" : "Background Removed")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(AppConfig.toolBackgroundColor))
            )
        }
    }

    private var ChooseButton: some View {
        Button {
            // Use background removed image
            manager.selectedImage = removedBackgroundImage
            manager.isBackgroundRemovalEnabled = true

            // Dismiss this sheet first
            presentationMode.wrappedValue.dismiss()

            // Wait for sheet to dismiss, then apply pixel effect and close preview
            DispatchQueue.main.asyncAfter(deadline: .now() + AppConfig.sheetTransitionDelay) {
                manager.applyPixelEffect()
            }
        } label: {
            HStack(spacing: 15) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Choose This")
                        .font(.system(size: 18, weight: .bold))
                    Text("Pixelize without background")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .foregroundColor(.white)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.green.opacity(0.7))
            )
        }
    }

    private var KeepBackgroundButton: some View {
        Button {
            // Use original image
            manager.selectedImage = originalImage
            manager.isBackgroundRemovalEnabled = false

            // Dismiss this sheet first
            presentationMode.wrappedValue.dismiss()

            // Wait for sheet to dismiss, then apply pixel effect and close preview
            DispatchQueue.main.asyncAfter(deadline: .now() + AppConfig.sheetTransitionDelay) {
                manager.applyPixelEffect()
            }
        } label: {
            HStack(spacing: 15) {
                Image(systemName: "photo")
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Keep Background")
                        .font(.system(size: 18, weight: .bold))
                    Text("Pixelize with original image")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .foregroundColor(.white)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(AppConfig.toolBackgroundColor))
            )
        }
    }
}

// Checkered background to show transparency
struct CheckeredBackground: View {
    var body: some View {
        GeometryReader { geometry in
            let size: CGFloat = 20
            let rows = Int(geometry.size.height / size) + 1
            let cols = Int(geometry.size.width / size) + 1

            VStack(spacing: 0) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<cols, id: \.self) { col in
                            Rectangle()
                                .fill((row + col) % 2 == 0 ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                                .frame(width: size, height: size)
                        }
                    }
                }
            }
        }
    }
}
