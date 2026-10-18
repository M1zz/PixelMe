//
//  HantamHomeSections.swift
//  Hantam
//
//  홈 맨 위 — 도안 만들기와 내 도안. 픽셀 아트 도구는 그 아래에 둔다.
//

import SwiftUI
import LeeoKit

/// 로고 · 이름 · 설정 버튼.
struct HantamHomeHeader: View {
    let onSettings: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            BeadHeartMark(size: 34)
            Text("Hantam")
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(Color.hantamInk)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Button(action: onSettings) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.hantamInk.opacity(0.7))
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(Text("Settings"))
        }
    }
}

/// 가장 큰 버튼 — 사진으로 도안 만들기.
struct PatternHeroCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Turn a photo into a pattern")
                            .font(.system(size: 22, weight: .bold))
                            .multilineTextAlignment(.leading)
                        Text("Fuse beads or cross-stitch, matched to real colors.")
                            .font(.subheadline)
                            .opacity(0.85)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer(minLength: 8)
                    BeadHeartMark(size: 64)
                        .padding(8)
                        .background(Color.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 14))
                }
                HStack(spacing: 6) {
                    Image(systemName: "photo.badge.plus")
                    Text("Choose a photo")
                }
                .font(.headline)
                .foregroundStyle(Color.hantamAccent)
                .padding(.horizontal, 16)
                .frame(minHeight: 44)
                .background(Color.white, in: Capsule())
            }
            .foregroundStyle(.white)
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.hantamAccent)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.6), style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))
                            .padding(6)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

/// 세 걸음 안내 — 처음 쓰는 사람에게 무엇을 하는 앱인지.
struct PatternStepsRow: View {
    var body: some View {
        HStack(spacing: 8) {
            step("1", "Pick a photo")
            step("2", "Choose beads or thread")
            step("3", "Print and make")
        }
    }

    private func step(_ n: String, _ text: LocalizedStringKey) -> some View {
        VStack(spacing: 6) {
            Text(n)
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(Color.hantamTeal, in: Circle())
            Text(text)
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.hantamInk)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: 74)
        .padding(.vertical, 8)
        .background(Color.hantamCard, in: RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
    }
}

/// 내 도안 — 가로로 넘겨 보는 썸네일.
struct MyPatternsSection: View {
    @ObservedObject var store = PatternStore.shared
    let onOpen: (BeadPattern) -> Void

    var body: some View {
        if !store.patterns.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("My patterns")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.hantamInk)
                    .accessibilityAddTraits(.isHeader)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(store.patterns) { p in
                            Button { onOpen(p) } label: { PatternThumb(pattern: p) }
                                .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

struct PatternThumb: View {
    let pattern: BeadPattern
    @State private var image: UIImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(Color.white)
                if let image {
                    Image(uiImage: image).resizable().aspectRatio(contentMode: .fit).padding(8)
                }
            }
            .frame(width: 130, height: 130)
            Text(pattern.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.hantamInk)
                .lineLimit(1)
            Text("\(pattern.material.brandName) · \(pattern.width)×\(pattern.height)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: 130)
        .task(id: pattern) {
            let p = pattern
            let cell = max(2, (260 / CGFloat(p.longestSide)).rounded())
            image = await Task.detached { PatternRenderer.image(for: p, cell: cell, style: .preview, showGrid: false) }.value
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - 설정

struct HantamSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var subscription = SubscriptionManager.shared
    @State private var showPaywall = false
    @State private var restoreMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if subscription.isProUser {
                        Label("Pro is active", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(Color.hantamTeal)
                    } else {
                        Button { showPaywall = true } label: {
                            Label("Get Hantam Pro", systemImage: "sparkles")
                        }
                    }
                    Button {
                        Task {
                            await subscription.restorePurchases()
                            restoreMessage = subscription.isProUser
                                ? NSLocalizedString("Your purchase has been restored.", comment: "Restore success")
                                : (subscription.errorMessage ?? NSLocalizedString("No previous purchases found.", comment: ""))
                        }
                    } label: {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                    }
                } header: { Text("Hantam Pro") }

                Section {
                    LeeoSupportSection<PixelMeSpec>()
                    NavigationLink { RoadmapScreen() } label: {
                        Label(LeeoRoadmapText.entry, systemImage: "map")
                    }
                } header: { Text("Support") }

                Section {
                    Link(destination: URL(string: "mailto:\(AppConfig.emailSupport)")!) {
                        Label("Contact via Email", systemImage: "envelope")
                    }
                    Link(destination: URL(string: "https://instagram.com/lee25_ios")!) {
                        Label("Instagram DM (@lee25_ios)", systemImage: "message")
                    }
                } header: { Text("Contact") }

                Section {
                    Text("Perler, Hama, Artkal and DMC are trademarks of their owners. Hantam is not affiliated with them.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    LabeledContent("Version", value: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "")
                } header: { Text("About") }
            }
            .navigationTitle(Text("Settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(isProUser: .constant(false), reason: .settings)
            }
            .alert(restoreMessage ?? "", isPresented: Binding(
                get: { restoreMessage != nil }, set: { if !$0 { restoreMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            }
        }
        .tint(.hantamAccent)
    }
}
