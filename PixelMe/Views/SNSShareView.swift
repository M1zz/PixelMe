//
//  SNSShareView.swift
//  PixelMe
//
//  Created by hyunho lee on 2026/03/01.
//

import SwiftUI

/// Sheet that shows SNS size presets, then opens the share sheet
struct SNSShareView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedPreset: SNSSizePreset = .instagramFeed
    @State private var showingShareSheet = false
    @State private var resizedImage: UIImage?

    var body: some View {
        NavigationView {
            ZStack {
                Color(AppConfig.backgroundColor).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Preview
                        if let image = resizedImage ?? manager.pixelatedImage {
                            Image(uiImage: image)
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                                .frame(maxHeight: 220)
                                .cornerRadius(12)
                        }

                        // Preset picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Choose Size")
                                .font(.headline)
                                .foregroundColor(.white)

                            ForEach(SNSSizePreset.allCases) { preset in
                                Button {
                                    selectedPreset = preset
                                    prepareImage()
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: preset.icon)
                                            .frame(width: 24)
                                            .foregroundColor(.blue)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(preset.rawValue)
                                                .font(.system(size: 16, weight: .semibold))
                                            Text(preset.sizeLabel)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        .foregroundColor(.white)
                                        Spacer()
                                        if selectedPreset == preset {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedPreset == preset ? Color.blue.opacity(0.2) : Color(AppConfig.toolBackgroundColor))
                                    )
                                }
                            }
                        }

                        // Share button
                        Button(action: shareImage) {
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
                                    .fill(Color(AppConfig.continueButtonColor))
                            )
                        }
                        .disabled(manager.pixelatedImage == nil)
                    }
                    .padding()
                }
            }
            .navigationTitle("Share to SNS")
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
        .onAppear { prepareImage() }
        .sheet(isPresented: $showingShareSheet) {
            if let image = resizedImage ?? manager.pixelatedImage {
                SNSShareSheet(image: image, isPremium: manager.isPremiumUser)
            }
        }
    }

    private func prepareImage() {
        guard let source = manager.pixelatedImage else { return }
        if selectedPreset == .original {
            resizedImage = source
        } else {
            resizedImage = SNSSizePreset.resizeImageNearestNeighbor(source, to: selectedPreset.size)
        }
    }

    private func shareImage() {
        prepareImage()
        showingShareSheet = true
        ReviewManager.shared.trackCompletedAction()
    }
}

// MARK: - UIActivityViewController wrapper
struct SNSShareSheet: UIViewControllerRepresentable {
    let image: UIImage
    let isPremium: Bool

    func makeUIViewController(context: Context) -> UIActivityViewController {
        var shareText = "Made with PixelMe 🎨"
        if !isPremium {
            shareText += "\nhttps://apps.apple.com/app/pixelme-pixel-art-creator/id6450535064"
        }
        let vc = UIActivityViewController(activityItems: [image, shareText], applicationActivities: nil)
        return vc
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

/// 비디오 공유용 시트 (릴스/틱톡 비디오 공유)
struct VideoShareSheet: UIViewControllerRepresentable {
    let videoURL: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        var items: [Any] = [videoURL]
        if !SubscriptionManager.shared.isProUser {
            let shareText = "Made with PixelMe 🎨\n\(FreeUsageManager.appStoreURL)"
            items.append(shareText)
        }
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return vc
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview
struct SNSShareView_Previews: PreviewProvider {
    static var previews: some View {
        SNSShareView()
            .environmentObject(DataManager())
    }
}
