//
//  OnboardingView.swift
//  PixelMe
//
//  Created by Claude on 2026/01/20.
//  First-time user onboarding experience
//

import SwiftUI

/// Onboarding view for first-time users
struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            image: "photo.on.rectangle.angled",
            title: "Transform Your Photos",
            description: "Turn any photo into stunning pixel art with just one tap. Apply retro filters, color palettes, and effects.",
            color: .blue
        ),
        OnboardingPage(
            image: "paintbrush.pointed.fill",
            title: "Create from Scratch",
            description: "Draw your own pixel art masterpiece. Choose your canvas size and start creating with our intuitive tools.",
            color: .purple
        ),
        OnboardingPage(
            image: "paintpalette.fill",
            title: "9 Retro Palettes",
            description: "GameBoy, NES, SNES, Vaporwave, Cyberpunk and more. Give your art that authentic retro look.",
            color: .green
        ),
        OnboardingPage(
            image: "sparkles",
            title: "Ready to Create?",
            description: "Start with a sample or create your own. Let's make some pixel art!",
            color: .orange
        )
    ]

    var body: some View {
        ZStack {
            Color(AppConfig.backgroundColor)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                    .padding()
                }

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.white : Color.gray.opacity(0.5))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.bottom, 30)

                // Next / Get Started button
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(AppConfig.continueButtonColor))
                        )
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation {
            isPresented = false
        }
    }
}

/// Single onboarding page data
struct OnboardingPage {
    let image: String
    let title: String
    let description: String
    let color: Color
}

/// Single onboarding page view
struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.2))
                    .frame(width: 160, height: 160)

                Image(systemName: page.image)
                    .font(.system(size: 70))
                    .foregroundColor(page.color)
            }

            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isPresented: .constant(true))
    }
}
