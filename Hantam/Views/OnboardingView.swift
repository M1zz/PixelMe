//
//  OnboardingView.swift
//  Hantam
//
//  첫 실행 — 한땀이 무엇을 하는지 세 장으로. 사진 → 실제 색 → 인쇄.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0

    private let totalPages = 3

    var body: some View {
        ZStack {
            Color.hantamBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    if currentPage < totalPages - 1 {
                        Button("Skip") { completeOnboarding() }
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                    }
                }
                .frame(height: 44)

                TabView(selection: $currentPage) {
                    OnboardingPage(
                        title: "One photo becomes a pattern",
                        detail: "Pick a photo of your pet, your face or a favorite character. Hantam turns it into a bead or cross-stitch pattern.",
                        visual: AnyView(PhotoToPatternVisual())
                    ).tag(0)
                    OnboardingPage(
                        title: "Matched to colors you can buy",
                        detail: "Perler, Hama, Artkal beads and DMC thread. See the color number and how many you need of each.",
                        visual: AnyView(SwatchVisual())
                    ).tag(1)
                    OnboardingPage(
                        title: "Print it and start making",
                        detail: "Symbol charts split board by board, with a shopping list you can copy.",
                        visual: AnyView(PrintVisual())
                    ).tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { i in
                        Capsule()
                            .fill(currentPage == i ? Color.hantamAccent : Color.hantamInk.opacity(0.15))
                            .frame(width: currentPage == i ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 24)
                .accessibilityHidden(true)

                Button {
                    if currentPage < totalPages - 1 {
                        withAnimation(.easeInOut) { currentPage += 1 }
                    } else {
                        completeOnboarding()
                    }
                } label: {
                    Text(currentPage < totalPages - 1 ? "Next" : "Make my first pattern")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.hantamAccent, in: RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        HantamEvent.track(currentPage == totalPages - 1 ? "onboarding_done" : "onboarding_skipped")
        withAnimation { isPresented = false }
    }
}

private struct OnboardingPage: View {
    let title: LocalizedStringKey
    let detail: LocalizedStringKey
    let visual: AnyView

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            visual
                .frame(height: 280)
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundStyle(Color.hantamInk)
                    .multilineTextAlignment(.center)
                Text(detail)
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }
            Spacer()
        }
    }
}

// MARK: - 그림

private struct PhotoToPatternVisual: View {
    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(LinearGradient(colors: [Color(red: 0.98, green: 0.75, blue: 0.62), Color(red: 0.86, green: 0.45, blue: 0.40)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .frame(width: 120, height: 150)

            Image(systemName: "arrow.right")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.hantamAccent)

            BeadHeartMark(size: 130)
                .padding(10)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 18))
        }
        .accessibilityHidden(true)
    }
}

private struct SwatchVisual: View {
    private let samples: [PatternColor] = PatternColor.perler
        .filter { [ "Red", "Yellow", "Light Blue", "Kiwi Lime", "Bubblegum" ].contains($0.name) }

    var body: some View {
        VStack(spacing: 10) {
            ForEach(Array(samples.prefix(4).enumerated()), id: \.offset) { i, c in
                HStack(spacing: 12) {
                    Circle().fill(c.color).frame(width: 34, height: 34)
                        .overlay(Circle().fill(Color.white.opacity(0.85)).padding(11))
                    VStack(alignment: .leading, spacing: 1) {
                        Text(c.code).font(.subheadline.weight(.semibold))
                        Text(c.name).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("×\([212, 148, 97, 41][i % 4])")
                        .font(.headline.monospacedDigit())
                }
                .foregroundStyle(Color.hantamInk)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.hantamCard, in: RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(.horizontal, 40)
        .accessibilityHidden(true)
    }
}

private struct PrintVisual: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white)
                .frame(width: 190, height: 250)
                .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
                .rotationEffect(.degrees(-6))
                .offset(x: -24)
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white)
                .frame(width: 190, height: 250)
                .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
                .overlay(
                    VStack(spacing: 6) {
                        BeadHeartMark(size: 120)
                        ForEach(0..<3, id: \.self) { _ in
                            Capsule().fill(Color.hantamInk.opacity(0.12)).frame(width: 130, height: 6)
                        }
                    }
                )
                .rotationEffect(.degrees(4))
                .offset(x: 18)
            Image(systemName: "printer.fill")
                .font(.system(size: 30))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(Color.hantamAccent, in: Circle())
                .offset(x: 90, y: 100)
        }
        .accessibilityHidden(true)
    }
}
