//
//  OnboardingView.swift
//  PixelMe
//
//  Created by Claude on 2026/01/20.
//  결과물 중심 온보딩 — 첫인상에서 "이 앱 좋은데?" 유도
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0

    private let totalPages = 4

    var body: some View {
        ZStack {
            // 페이지별 배경색 전환
            backgroundForPage(currentPage)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.4), value: currentPage)

            VStack(spacing: 0) {
                // Skip
                HStack {
                    Spacer()
                    if currentPage < totalPages - 1 {
                        Button("Skip") { completeOnboarding() }
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                    }
                }

                // Pages
                TabView(selection: $currentPage) {
                    OnboardingPage1().tag(0)
                    OnboardingPage2().tag(1)
                    OnboardingPage3().tag(2)
                    OnboardingPage4().tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { i in
                        Capsule()
                            .fill(currentPage == i ? Color.white : Color.white.opacity(0.25))
                            .frame(width: currentPage == i ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 24)

                // CTA Button
                Button {
                    if currentPage < totalPages - 1 {
                        withAnimation(.easeInOut) { currentPage += 1 }
                    } else {
                        completeOnboarding()
                    }
                } label: {
                    Text(currentPage < totalPages - 1 ? "Next" : "Start Creating")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(currentPage < totalPages - 1 ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(currentPage < totalPages - 1
                                      ? Color.white.opacity(0.15)
                                      : Color.yellow)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
    }

    private func backgroundForPage(_ page: Int) -> some View {
        let colors: [(Color, Color)] = [
            (Color(red: 0.05, green: 0.03, blue: 0.12), Color(red: 0.10, green: 0.05, blue: 0.20)),
            (Color(red: 0.03, green: 0.08, blue: 0.15), Color(red: 0.05, green: 0.12, blue: 0.22)),
            (Color(red: 0.08, green: 0.03, blue: 0.10), Color(red: 0.15, green: 0.05, blue: 0.15)),
            (Color(red: 0.02, green: 0.02, blue: 0.08), Color(red: 0.08, green: 0.06, blue: 0.18)),
        ]
        let pair = colors[min(page, colors.count - 1)]
        return LinearGradient(colors: [pair.0, pair.1], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation { isPresented = false }
    }
}

// MARK: - Page 1: "사진이 이렇게 바뀐다" (Before/After)

private struct OnboardingPage1: View {
    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            // Before → After 비주얼
            HStack(spacing: 0) {
                // Before
                ZStack {
                    LinearGradient(
                        colors: [Color(red: 0.85, green: 0.7, blue: 0.6), Color(red: 0.6, green: 0.4, blue: 0.35)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white.opacity(0.3))
                    VStack {
                        Spacer()
                        Text("PHOTO")
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(6)
                    }
                }
                .frame(width: 130, height: 170)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Arrow
                VStack(spacing: 4) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.yellow)
                    Text("1 tap")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.yellow.opacity(0.7))
                }
                .padding(.horizontal, 16)

                // After — 실제 픽셀아트 샘플
                ZStack {
                    let samples = SamplePixelArtCollection.all
                    if let sample = samples.first {
                        SampleArtPreview(sample: sample)
                    } else {
                        Color.cyan.opacity(0.3)
                    }
                    VStack {
                        Spacer()
                        Text("PIXEL ART")
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(6)
                    }
                }
                .frame(width: 130, height: 170)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )
            }

            VStack(spacing: 12) {
                Text("Photo → Pixel Art")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundColor(.white)

                Text("Turn any photo into pixel art\nwith just one tap")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Page 2: "이런 스타일이 가능하다" (갤러리 쇼케이스)

private struct OnboardingPage2: View {
    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            // 샘플 그리드 — 실제 결과물을 크게
            let samples = Array(SamplePixelArtCollection.all.prefix(9))
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(Array(samples.prefix(9).enumerated()), id: \.offset) { _, sample in
                    SampleArtPreview(sample: sample)
                        .frame(height: 95)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 30)

            VStack(spacing: 12) {
                Text("100+ Pixel Art Styles")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundColor(.white)

                Text("Flowers, animals, characters, food\nand much more to explore")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Page 3: "에디터가 이 정도다" (기능 미리보기)

private struct OnboardingPage3: View {
    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            // 기능 카드 3개
            VStack(spacing: 12) {
                OnboardingFeatureCard(
                    icon: "square.3.layers.3d",
                    color: .cyan,
                    title: "Layers & Animation",
                    subtitle: "Create frame-by-frame pixel animation"
                )

                OnboardingFeatureCard(
                    icon: "paintpalette.fill",
                    color: .green,
                    title: "9 Retro Palettes",
                    subtitle: "GameBoy, NES, SNES, Cyberpunk and more"
                )

                OnboardingFeatureCard(
                    icon: "square.and.arrow.up",
                    color: .purple,
                    title: "Export Anywhere",
                    subtitle: "PNG, SVG, GIF, Sprite Sheet, Aseprite"
                )
            }
            .padding(.horizontal, 24)

            VStack(spacing: 12) {
                Text("Pro Pixel Editor")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundColor(.white)

                Text("Everything you need to create\nprofessional pixel art")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Page 4: "시작하자" (CTA)

private struct OnboardingPage4: View {
    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            // 큰 스파클 아이콘
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.yellow.opacity(0.2), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)

                Image(systemName: "sparkles")
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(.yellow)
            }

            VStack(spacing: 12) {
                Text("Ready to Create?")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundColor(.white)

                Text("Start with a photo or draw from scratch\nYour pixel art journey begins now")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }

            // 기능 태그
            HStack(spacing: 8) {
                ForEach(["Free to Start", "No Account", "100+ Samples"], id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                }
            }

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Feature Card

private struct OnboardingFeatureCard: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.06))
        .cornerRadius(14)
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(isPresented: .constant(true))
}
