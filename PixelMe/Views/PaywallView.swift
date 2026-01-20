//
//  PaywallView.swift
//  PixelMe
//
//  Created by Claude on 2026/01/20.
//  Premium feature paywall
//

import SwiftUI

/// Paywall screen for premium features
struct PaywallView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var purchaseManager = PurchaseManager.shared
    @Binding var isPremiumUser: Bool

    var body: some View {
        ZStack {
            Color(AppConfig.backgroundColor)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HeaderView
                    .padding(.top, 50)

                ScrollView {
                    VStack(spacing: 30) {
                        // Title
                        TitleSection

                        // Features
                        FeaturesSection

                        // Purchase Button
                        PremiumPurchaseButton(isPremiumUser: $isPremiumUser)
                            .padding(.top, 20)

                        // Features comparison
                        ComparisonSection

                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .onChange(of: isPremiumUser) { newValue in
            if newValue {
                // Dismiss paywall when premium is activated
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    presentationMode.wrappedValue.dismiss()
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
                Image(systemName: "xmark")
                    .font(.system(size: 22))
            }

            Spacer()

            Text("Premium")
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

    // MARK: - Title Section

    private var TitleSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)

            Text("Unlock Premium")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            Text("Get access to all 8 professional features")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Features Section

    private var FeaturesSection: some View {
        VStack(spacing: 15) {
            FeatureRow(
                icon: "paintpalette.fill",
                title: "9 Color Palettes",
                description: "GameBoy, NES, SNES, Vaporwave, Cyberpunk & more"
            )

            FeatureRow(
                icon: "wand.and.stars",
                title: "AI Color Reduction",
                description: "3 professional dithering algorithms"
            )

            FeatureRow(
                icon: "tv.fill",
                title: "6 Retro Filters",
                description: "CRT, Scanlines, Glitch, VHS, Arcade, Vintage"
            )

            FeatureRow(
                icon: "square.stack.3d.up.fill",
                title: "Batch Processing",
                description: "Process unlimited images at once"
            )

            FeatureRow(
                icon: "photo.stack.fill",
                title: "GIF Animation",
                description: "Create animated pixel art GIFs"
            )

            FeatureRow(
                icon: "square.3.layers.3d",
                title: "Layer System",
                description: "12 professional blend modes"
            )

            FeatureRow(
                icon: "square.grid.3x3.fill",
                title: "15+ Templates",
                description: "Pixel avatars, game sprites & more"
            )

            FeatureRow(
                icon: "arrow.down.doc.fill",
                title: "Advanced Export",
                description: "PNG, SVG, PDF up to 4K resolution"
            )
        }
    }

    // MARK: - Comparison Section

    private var ComparisonSection: some View {
        VStack(spacing: 20) {
            Text("Why Premium?")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)

            VStack(spacing: 12) {
                ComparisonRow(
                    feature: "Basic Pixelation",
                    free: true,
                    premium: true
                )
                ComparisonRow(
                    feature: "Color Palettes",
                    free: false,
                    premium: true
                )
                ComparisonRow(
                    feature: "Retro Filters",
                    free: false,
                    premium: true
                )
                ComparisonRow(
                    feature: "Batch Processing",
                    free: false,
                    premium: true
                )
                ComparisonRow(
                    feature: "GIF Creation",
                    free: false,
                    premium: true
                )
                ComparisonRow(
                    feature: "Layer System",
                    free: false,
                    premium: true
                )
                ComparisonRow(
                    feature: "Templates",
                    free: false,
                    premium: true
                )
                ComparisonRow(
                    feature: "Advanced Export",
                    free: false,
                    premium: true
                )
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(AppConfig.toolBackgroundColor))
            )

            // Value proposition
            VStack(spacing: 8) {
                Text("One-Time Purchase")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Text("No subscription. No ads. All features forever.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 30)
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.green)
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(AppConfig.toolBackgroundColor))
        )
    }
}

// MARK: - Comparison Row

struct ComparisonRow: View {
    let feature: String
    let free: Bool
    let premium: Bool

    var body: some View {
        HStack {
            Text(feature)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Free column
            Image(systemName: free ? "checkmark" : "xmark")
                .font(.system(size: 14))
                .foregroundColor(free ? .green : .red)
                .frame(width: 60)

            // Premium column
            Image(systemName: premium ? "checkmark" : "xmark")
                .font(.system(size: 14))
                .foregroundColor(premium ? .green : .red)
                .frame(width: 60)
        }
    }
}

// MARK: - Preview

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView(isPremiumUser: .constant(false))
    }
}
