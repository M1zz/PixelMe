//
//  FilterPackStoreView.swift
//  PixelMe
//
//  필터 팩 스토어 UI
//

import SwiftUI

/// 필터 팩 스토어 메인 뷰
struct FilterPackStoreView: View {
    @StateObject private var packManager = FilterPackManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPack: FilterPack?
    @State private var isPurchasing = false
    @State private var showPurchaseSuccess = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(AppConfig.backgroundColor).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        StoreHeaderView()

                        // Pack cards
                        ForEach(packManager.availablePacks) { pack in
                            FilterPackCard(
                                pack: pack,
                                isOwned: packManager.hasAccess(to: pack),
                                price: packManager.displayPrice(for: pack),
                                onTap: { selectedPack = pack }
                            )
                        }

                        // Restore
                        Button {
                            Task { await packManager.restorePurchases() }
                        } label: {
                            Text("Restore Purchases")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("Filter Packs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.white)
                }
            }
            .sheet(item: $selectedPack) { pack in
                FilterPackDetailView(
                    pack: pack,
                    isOwned: packManager.hasAccess(to: pack),
                    price: packManager.displayPrice(for: pack)
                )
            }
        }
    }
}

// MARK: - Store Header

private struct StoreHeaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 40))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .pink, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Filter Packs")
                .font(.title2.bold())
                .foregroundColor(.white)

            Text("Unique filter + palette combos for every style")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 16)
    }
}

// MARK: - Pack Card

private struct FilterPackCard: View {
    let pack: FilterPack
    let isOwned: Bool
    let price: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Top row: icon + name + badge
                HStack(spacing: 12) {
                    Image(systemName: pack.iconName)
                        .font(.title2)
                        .foregroundColor(Color(pack.accentColor))
                        .frame(width: 44, height: 44)
                        .background(Color(pack.accentColor).opacity(0.15))
                        .cornerRadius(10)

                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(pack.name)
                                .font(.headline)
                                .foregroundColor(.white)

                            if isOwned {
                                Text("OWNED")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }

                        Text(pack.description)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }

                    Spacer()

                    if !isOwned {
                        Text(price)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(pack.accentColor))
                    }
                }

                // Filter preview strip
                HStack(spacing: 6) {
                    ForEach(pack.filters.prefix(5)) { filter in
                        FilterPreviewChip(
                            name: filter.name,
                            accentColor: Color(pack.accentColor)
                        )
                    }
                    if pack.filters.count > 5 {
                        Text("+\(pack.filters.count - 5)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }

                // Palette preview
                if !pack.customPalettes.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(pack.customPalettes) { palette in
                            HStack(spacing: 0) {
                                ForEach(palette.colors.prefix(8), id: \.self) { hex in
                                    Rectangle()
                                        .fill(Color(UIColor(hexString: hex) ?? .gray))
                                        .frame(width: 12, height: 12)
                                }
                            }
                            .cornerRadius(3)
                        }
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(AppConfig.toolBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(pack.accentColor).opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

private struct FilterPreviewChip: View {
    let name: String
    let accentColor: Color

    var body: some View {
        Text(name)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(accentColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(accentColor.opacity(0.12))
            .cornerRadius(6)
    }
}

// MARK: - Pack Detail View

struct FilterPackDetailView: View {
    let pack: FilterPack
    let isOwned: Bool
    let price: String
    @Environment(\.dismiss) private var dismiss
    @StateObject private var packManager = FilterPackManager.shared
    @State private var isPurchasing = false
    @State private var purchaseSuccess = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(AppConfig.backgroundColor).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Pack header
                        VStack(spacing: 12) {
                            Image(systemName: pack.iconName)
                                .font(.system(size: 50))
                                .foregroundColor(Color(pack.accentColor))

                            Text(pack.name)
                                .font(.title.bold())
                                .foregroundColor(.white)

                            Text(pack.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)

                        // Included filters
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Included Filters")
                                .font(.headline)
                                .foregroundColor(.white)

                            ForEach(pack.filters) { filter in
                                FilterDetailRow(filter: filter, accentColor: Color(pack.accentColor))
                            }
                        }
                        .padding(.horizontal)

                        // Custom palettes
                        if !pack.customPalettes.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Exclusive Palettes")
                                    .font(.headline)
                                    .foregroundColor(.white)

                                ForEach(pack.customPalettes) { palette in
                                    PaletteDetailRow(palette: palette)
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Purchase button
                        if !isOwned {
                            Button {
                                Task {
                                    isPurchasing = true
                                    let success = await packManager.purchasePack(pack)
                                    isPurchasing = false
                                    if success {
                                        purchaseSuccess = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                            dismiss()
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    if isPurchasing {
                                        ProgressView()
                                            .tint(.white)
                                    } else if purchaseSuccess {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("Purchased!")
                                    } else {
                                        Image(systemName: "cart.fill")
                                        Text("Buy for \(price)")
                                    }
                                }
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(
                                            purchaseSuccess
                                            ? Color.green
                                            : Color(pack.accentColor)
                                        )
                                )
                            }
                            .disabled(isPurchasing || purchaseSuccess)
                            .padding(.horizontal)
                        } else {
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                Text("You own this pack")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.green.opacity(0.15))
                            )
                            .padding(.horizontal)
                        }

                        if let error = packManager.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
}

private struct FilterDetailRow: View {
    let filter: PackFilter
    let accentColor: Color

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(accentColor.opacity(0.3))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 14))
                        .foregroundColor(accentColor)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(filter.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Text(filter.description)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(AppConfig.toolBackgroundColor))
        )
    }
}

private struct PaletteDetailRow: View {
    let palette: PackPalette

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(palette.name)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)

            HStack(spacing: 0) {
                ForEach(palette.colors, id: \.self) { hex in
                    Rectangle()
                        .fill(Color(UIColor(hexString: hex) ?? .gray))
                        .frame(height: 24)
                }
            }
            .cornerRadius(6)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(AppConfig.toolBackgroundColor))
        )
    }
}
