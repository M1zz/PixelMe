//
//  ExportPaywallView.swift
//  PixelMe
//
//  Created by Claude on 2026/02/25.
//  내보내기 시점 결제 유도 뷰
//

import SwiftUI

/// 내보내기 시점에서 프리미엄 기능을 유도하는 뷰
struct ExportPaywallView: View {
    let currentImage: UIImage
    let exportAction: () -> Void
    let upgradeAction: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedExportOption: ExportOption = .freeWithWatermark
    
    var body: some View {
        ZStack {
            Color(AppConfig.backgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HeaderView
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Preview Section
                        ExportPreviewSection
                        
                        // Export Options
                        ExportOptionsSection
                        
                        // Action Buttons
                        ActionButtonsSection
                        
                        // Features Highlight
                        ProFeaturesSection
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var HeaderView: some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Cancel")
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text("Export Options")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Text("Cancel")
                .opacity(0) // For center alignment
        }
        .padding(.horizontal)
        .padding(.top, 50)
        .padding(.bottom, 20)
    }
    
    // MARK: - Preview Section
    
    private var ExportPreviewSection: some View {
        VStack(spacing: 15) {
            Text("Export Preview")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 15) {
                // Free version with watermark
                ExportPreviewCard(
                    title: "Free Version",
                    subtitle: "With watermark, 1080p",
                    image: currentImage,
                    hasWatermark: true,
                    isSelected: selectedExportOption == .freeWithWatermark
                ) {
                    selectedExportOption = .freeWithWatermark
                }
                
                // Pro version without watermark
                ExportPreviewCard(
                    title: "Pro Version",
                    subtitle: "No watermark, 4K",
                    image: currentImage,
                    hasWatermark: false,
                    isSelected: selectedExportOption == .proWithoutWatermark,
                    isProOnly: true
                ) {
                    selectedExportOption = .proWithoutWatermark
                }
            }
        }
    }
    
    // MARK: - Export Options Section
    
    private var ExportOptionsSection: some View {
        VStack(spacing: 15) {
            Text("Choose Save Format")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 10) {
                ForEach(ExportFormat.allCases, id: \.rawValue) { format in
                    ExportFormatRow(
                        format: format,
                        isAvailable: FeatureGating.shared.canUseExportFormat(format)
                    )
                }
            }
        }
    }
    
    // MARK: - Action Buttons Section
    
    private var ActionButtonsSection: some View {
        VStack(spacing: 15) {
            if selectedExportOption == .freeWithWatermark {
                // Free export button
                Button {
                    exportAction()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    VStack(spacing: 8) {
                        Text("Save for Free")
                            .font(.system(size: 18, weight: .bold))
                        Text("With watermark, PNG, 1080p")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray)
                    )
                }
                
                // Upgrade button
                Button {
                    upgradeAction()
                } label: {
                    VStack(spacing: 8) {
                        Text("Upgrade to Pro")
                            .font(.system(size: 18, weight: .bold))
                        Text("Start with 3-day free trial")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(AppConfig.continueButtonColor))
                    )
                }
            } else {
                // Pro export button (if already subscribed)
                if SubscriptionManager.shared.isProUser {
                    Button {
                        exportAction()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        VStack(spacing: 8) {
                            Text("Save in High Quality")
                                .font(.system(size: 18, weight: .bold))
                            Text("No watermark, chosen format, 4K")
                                .font(.system(size: 14))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(AppConfig.continueButtonColor))
                        )
                    }
                } else {
                    Button {
                        upgradeAction()
                    } label: {
                        VStack(spacing: 8) {
                            Text("Upgrade to Pro to Save")
                                .font(.system(size: 18, weight: .bold))
                            Text("Start with 3-day free trial")
                                .font(.system(size: 14))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(AppConfig.continueButtonColor))
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Pro Features Section
    
    private var ProFeaturesSection: some View {
        VStack(spacing: 15) {
            Text("With Pro you get...")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                ProFeatureRow(
                    icon: "photo",
                    title: "Remove Watermark",
                    description: "Clean results"
                )
                
                ProFeatureRow(
                    icon: "4k.tv",
                    title: "4K High Resolution",
                    description: "Up to 4096x4096 pixels"
                )
                
                ProFeatureRow(
                    icon: "doc.text",
                    title: "Multiple Formats",
                    description: "PNG, SVG, PDF support"
                )
                
                ProFeatureRow(
                    icon: "star.fill",
                    title: "All Pro Features",
                    description: "9 palettes, 6 filters, dithering & more"
                )
            }
            .padding()
            .background(Color.black.opacity(0.3))
            .cornerRadius(12)
        }
    }
}

// MARK: - Supporting Views

/// 내보내기 미리보기 카드
struct ExportPreviewCard: View {
    let title: String
    let subtitle: String
    let image: UIImage
    let hasWatermark: Bool
    let isSelected: Bool
    let isProOnly: Bool
    let action: () -> Void
    
    init(
        title: String,
        subtitle: String,
        image: UIImage,
        hasWatermark: Bool,
        isSelected: Bool,
        isProOnly: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.hasWatermark = hasWatermark
        self.isSelected = isSelected
        self.isProOnly = isProOnly
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .cornerRadius(8)
                        .clipped()
                    
                    if hasWatermark {
                        VStack {
                            Spacer()
                            Text("PixelMe")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(4)
                        }
                        .padding(8)
                    }
                    
                    if isProOnly && !SubscriptionManager.shared.isProUser {
                        Color.black.opacity(0.5)
                            .cornerRadius(8)
                        
                        Image(systemName: "lock.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.yellow)
                    }
                    
                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(AppConfig.continueButtonColor))
                            }
                            Spacer()
                        }
                        .padding(8)
                    }
                }
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color(AppConfig.continueButtonColor) : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
    }
}

/// 내보내기 형식 행
struct ExportFormatRow: View {
    let format: ExportFormat
    let isAvailable: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: formatIcon(format))
                .font(.system(size: 20))
                .foregroundColor(isAvailable ? .white : .gray)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(format.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isAvailable ? .white : .gray)
                
                Text(formatDescription(format))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if !isAvailable {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.yellow)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.2))
        )
    }
    
    private func formatIcon(_ format: ExportFormat) -> String {
        switch format {
        case .png: return "photo"
        case .jpeg: return "photo.fill"
        case .svg: return "doc.text"
        case .pdf: return "doc.richtext"
        }
    }
    
    private func formatDescription(_ format: ExportFormat) -> String {
        switch format {
        case .png: return "Raster image, transparency support"
        case .jpeg: return "Compressed image, smaller size"
        case .svg: return "Vector image, scalable"
        case .pdf: return "Document format, high quality"
        }
    }
}

/// Pro 기능 행
struct ProFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.yellow)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

// MARK: - Supporting Types

enum ExportOption {
    case freeWithWatermark
    case proWithoutWatermark
}

// MARK: - Preview

struct ExportPaywallView_Previews: PreviewProvider {
    static var previews: some View {
        ExportPaywallView(
            currentImage: UIImage(systemName: "photo")!,
            exportAction: {},
            upgradeAction: {}
        )
    }
}