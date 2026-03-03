//
//  PaywallView.swift
//  PixelMe
//
//  Created by Claude on 2026/02/25.
//  페르소나 기반 Paywall — 전환율 최적화 레이아웃
//

import SwiftUI
import StoreKit

// MARK: - Main Paywall

struct PaywallView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @Binding var isProUser: Bool

    @State private var selectedPlan: SubscriptionPlan = .yearly
    @State private var showingError = false
    @State private var isProcessing = false
    @State private var animateGradient = false
    @State private var showcasePage = 0
    @State private var floatOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Animated gradient background
            backgroundGradient
                .ignoresSafeArea()

            // Floating pixel icons (배경 장식)
            floatingPixelIcons

            VStack(spacing: 0) {
                // Close button
                closeButton

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Showcase carousel — 결과물로 "오 이거 좋은데?" 유도
                        showcaseCarousel

                        // Plan selector (compact horizontal)
                        planSelector

                        // CTA button
                        ctaButton

                        // Micro feature list (compact)
                        microFeatureList

                        // Trust & legal
                        trustSection

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { animateGradient = true }
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) { floatOffset = 12 }
        }
        .onChange(of: isProUser) { newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + AppConfig.subscriptionSuccessDelay) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { subscriptionManager.errorMessage = nil }
        } message: {
            Text(subscriptionManager.errorMessage ?? "An unknown error occurred")
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: animateGradient
                ? [Color(red: 0.06, green: 0.04, blue: 0.15), Color(red: 0.12, green: 0.06, blue: 0.25)]
                : [Color(red: 0.04, green: 0.02, blue: 0.10), Color(red: 0.08, green: 0.04, blue: 0.18)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Floating Pixel Icons (배경 장식 애니메이션)

    private var floatingPixelIcons: some View {
        GeometryReader { geo in
            // 여러 픽셀 아이콘이 느리게 떠다니는 효과
            PixelAnimatedIcon(icon: PixelIconCatalog.star, size: 32)
                .opacity(0.12)
                .position(x: geo.size.width * 0.1, y: geo.size.height * 0.15)
                .offset(y: floatOffset)

            PixelAnimatedIcon(icon: PixelIconCatalog.sparkle, size: 28)
                .opacity(0.1)
                .position(x: geo.size.width * 0.85, y: geo.size.height * 0.08)
                .offset(y: -floatOffset)

            PixelAnimatedIcon(icon: PixelIconCatalog.paintbrush, size: 24)
                .opacity(0.08)
                .position(x: geo.size.width * 0.92, y: geo.size.height * 0.35)
                .offset(y: floatOffset * 0.7)

            PixelAnimatedIcon(icon: PixelIconCatalog.camera, size: 26)
                .opacity(0.08)
                .position(x: geo.size.width * 0.08, y: geo.size.height * 0.45)
                .offset(y: -floatOffset * 0.8)

            PixelAnimatedIcon(icon: PixelIconCatalog.grid, size: 30)
                .opacity(0.06)
                .position(x: geo.size.width * 0.75, y: geo.size.height * 0.65)
                .offset(y: floatOffset * 0.5)

            PixelAnimatedIcon(icon: PixelIconCatalog.pencil, size: 22)
                .opacity(0.07)
                .position(x: geo.size.width * 0.15, y: geo.size.height * 0.75)
                .offset(y: -floatOffset * 0.6)

            PixelAnimatedIcon(icon: PixelIconCatalog.floppyDisk, size: 26)
                .opacity(0.06)
                .position(x: geo.size.width * 0.88, y: geo.size.height * 0.85)
                .offset(y: floatOffset * 0.9)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    // MARK: - Close Button

    private var closeButton: some View {
        HStack {
            Button { presentationMode.wrappedValue.dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 56)
    }

    // MARK: - Showcase Carousel (크리에이터 중심 — 에디터·애니메이션·내보내기)

    private var showcaseCarousel: some View {
        VStack(spacing: 14) {
            TabView(selection: $showcasePage) {
                // Slide 1: 레이어 + 애니메이션 (핵심 에디터 기능)
                showcaseSlideLayers
                    .tag(0)

                // Slide 2: 내보내기 (GIF, Sprite Sheet, Aseprite)
                showcaseSlideExport
                    .tag(1)

                // Slide 3: 크리에이티브 도구 (팔레트, 대칭, 필터)
                showcaseSlideTools
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 320)

            // Custom page indicator
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .fill(showcasePage == index ? Color.white : Color.white.opacity(0.25))
                        .frame(width: showcasePage == index ? 20 : 6, height: 6)
                        .animation(.easeInOut(duration: 0.25), value: showcasePage)
                }
            }

            // Social proof
            HStack(spacing: 6) {
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                    }
                }
                Text("4.8")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.yellow)
                Text("·")
                    .foregroundColor(.white.opacity(0.3))
                Text("10K+ creators")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }

    // MARK: Slide 1 — Layers & Animation (픽셀 아이콘 중심)

    private var showcaseSlideLayers: some View {
        VStack(spacing: 16) {
            Text("Layers & Animation")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
                .textCase(.uppercase)
                .tracking(1.5)

            HStack(spacing: 20) {
                // 레이어 — 겹친 픽셀 아이콘
                VStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.cyan.opacity(0.08))
                            .frame(width: 130, height: 150)

                        // 3장 겹친 레이어 효과 (뒤에서 앞으로)
                        PixelAnimatedIcon(icon: PixelIconCatalog.grid, size: 48)
                            .opacity(0.3)
                            .offset(x: 10, y: -10)
                        PixelAnimatedIcon(icon: PixelIconCatalog.pencil, size: 48)
                            .opacity(0.5)
                            .offset(x: 5, y: -5)
                        PixelAnimatedIcon(icon: PixelIconCatalog.paintbrush, size: 56)

                        // 레이어 뱃지
                        VStack {
                            Spacer()
                            Text("Unlimited Layers")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.cyan)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.cyan.opacity(0.15))
                                .cornerRadius(6)
                                .padding(.bottom, 10)
                        }
                        .frame(width: 130, height: 150)
                    }
                }

                // 애니메이션 — 스파클 + 타임라인
                VStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.pink.opacity(0.08))
                            .frame(width: 130, height: 150)

                        VStack(spacing: 8) {
                            PixelAnimatedIcon(icon: PixelIconCatalog.sparkle, size: 56)

                            // 미니 타임라인 프레임 스트립
                            HStack(spacing: 3) {
                                ForEach(0..<5, id: \.self) { i in
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.pink.opacity(Double(i + 1) * 0.15))
                                        .frame(width: 16, height: 20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 3)
                                                .stroke(Color.pink.opacity(i == 2 ? 0.6 : 0.15), lineWidth: 1)
                                        )
                                }
                            }
                        }

                        VStack {
                            Spacer()
                            Text("GIF · Onion Skin")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.pink)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.pink.opacity(0.15))
                                .cornerRadius(6)
                                .padding(.bottom, 10)
                        }
                        .frame(width: 130, height: 150)
                    }
                }
            }

            Text("Create frame-by-frame animations with full layer control")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: Slide 2 — Export Everything (픽셀 아이콘 + 포맷 카드)

    private var showcaseSlideExport: some View {
        VStack(spacing: 16) {
            Text("Export Anything")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
                .textCase(.uppercase)
                .tracking(1.5)

            // 중앙에 큰 내보내기 픽셀 아이콘
            ZStack {
                // 배경 글로우
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.purple.opacity(0.2), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 120, height: 120)

                PixelAnimatedIcon(icon: PixelIconCatalog.export, size: 72)
            }

            // 4가지 내보내기 포맷 카드
            HStack(spacing: 10) {
                exportFormatCard(icon: PixelIconCatalog.sparkle, label: "GIF", color: .green)
                exportFormatCard(icon: PixelIconCatalog.grid, label: "Sprite", color: .orange)
                exportFormatCard(icon: PixelIconCatalog.floppyDisk, label: ".ase", color: .indigo)
                exportFormatCard(icon: PixelIconCatalog.camera, label: "4K", color: .blue)
            }
            .padding(.horizontal, 8)

            Text("GIF · Sprite Sheet · Aseprite · 4K PNG")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
    }

    private func exportFormatCard(icon: PixelIconDefinition, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.12))
                    .frame(height: 56)

                PixelAnimatedIcon(icon: icon, size: 28)
            }
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(color.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Slide 3 — Creative Tools (픽셀 아이콘 중심)

    private var showcaseSlideTools: some View {
        VStack(spacing: 16) {
            Text("Creative Tools")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
                .textCase(.uppercase)
                .tracking(1.5)

            // 3개 기능 카드 — 픽셀 아이콘 사용
            HStack(spacing: 12) {
                // AI 팔레트
                VStack(spacing: 6) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.purple.opacity(0.12))
                            .frame(width: 95, height: 100)

                        VStack(spacing: 6) {
                            PixelAnimatedIcon(icon: PixelIconCatalog.sparkle, size: 36)

                            HStack(spacing: 2) {
                                ForEach([Color.red, Color.orange, Color.yellow, Color.green, Color.blue], id: \.self) { c in
                                    Circle().fill(c).frame(width: 8, height: 8)
                                }
                            }
                        }
                    }
                    Text("AI Palette")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                }

                // 그리기 도구
                VStack(spacing: 6) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.12))
                            .frame(width: 95, height: 100)

                        VStack(spacing: 6) {
                            HStack(spacing: 4) {
                                PixelAnimatedIcon(icon: PixelIconCatalog.pencil, size: 30)
                                PixelAnimatedIcon(icon: PixelIconCatalog.eraser, size: 30)
                            }
                            PixelAnimatedIcon(icon: PixelIconCatalog.paintDrop, size: 24)
                        }
                    }
                    Text("Pro Tools")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                }

                // 팔레트
                VStack(spacing: 6) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.yellow.opacity(0.12))
                            .frame(width: 95, height: 100)

                        VStack(spacing: 6) {
                            PixelAnimatedIcon(icon: PixelIconCatalog.star, size: 36)

                            Text("9 Palettes")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.yellow.opacity(0.8))
                        }
                    }
                    Text("Colors")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            // 태그들
            HStack(spacing: 8) {
                ForEach(["Symmetry", "6 Filters", "Batch", "All Sizes"], id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(8)
                }
            }
        }
    }

    // MARK: - Plan Selector (Compact Horizontal)

    private var planSelector: some View {
        VStack(spacing: 14) {
            // Top row: Yearly (hero) + Monthly (anchor)
            HStack(spacing: 10) {
                // Yearly — hero card
                CompactPlanCard(
                    label: "Yearly",
                    price: subscriptionManager.getYearlyPrice(),
                    detail: subscriptionManager.getYearlyWeeklyPrice() + "/wk",
                    badge: "Save 64%",
                    badgeColor: .green,
                    isSelected: selectedPlan == .yearly,
                    isRecommended: true
                ) { selectedPlan = .yearly }

                // Monthly — anchor
                CompactPlanCard(
                    label: "Monthly",
                    price: subscriptionManager.getMonthlyPrice(),
                    detail: "per month",
                    badge: nil,
                    badgeColor: .clear,
                    isSelected: selectedPlan == .monthly,
                    isRecommended: false
                ) { selectedPlan = .monthly }
            }

            // Bottom row: Weekly + Lifetime
            HStack(spacing: 10) {
                // Weekly — low commitment
                CompactPlanCard(
                    label: "Weekly",
                    price: subscriptionManager.getWeeklyPrice(),
                    detail: "per week",
                    badge: "Try It",
                    badgeColor: .blue,
                    isSelected: selectedPlan == .weekly,
                    isRecommended: false
                ) { selectedPlan = .weekly }

                // Lifetime
                CompactPlanCard(
                    label: "Lifetime",
                    price: subscriptionManager.getLifetimePrice(),
                    detail: "one-time",
                    badge: "Forever",
                    badgeColor: .purple,
                    isSelected: selectedPlan == .lifetime,
                    isRecommended: false
                ) { selectedPlan = .lifetime }
            }

            // Contextual hint below plans
            planHintText
        }
    }

    private var planHintText: some View {
        Group {
            switch selectedPlan {
            case .yearly:
                Label("Only \(subscriptionManager.getYearlyWeeklyPrice()) per week · 7-day free trial", systemImage: "checkmark.seal.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.green)
            case .monthly:
                Label("7-day free trial included", systemImage: "clock.fill")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            case .weekly:
                Label("No commitment · Cancel anytime", systemImage: "hand.thumbsup.fill")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.cyan)
            case .lifetime:
                Label("Pay once, use forever — save vs 3 yrs subscription", systemImage: "infinity")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.purple)
            }
        }
        .padding(.top, 2)
    }

    // MARK: - CTA Button

    private var ctaButton: some View {
        VStack(spacing: 10) {
            if subscriptionManager.isLoading || isProcessing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(height: 56)
            } else if subscriptionManager.isProUser {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.green)
                    Text("Pro Active")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.green.opacity(0.2))
                .cornerRadius(16)
            } else {
                Button {
                    Task { await purchaseSelectedPlan() }
                } label: {
                    HStack(spacing: 8) {
                        ctaIcon
                        ctaText
                    }
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [Color(AppConfig.continueButtonColor), Color(AppConfig.continueButtonColor).opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color(AppConfig.continueButtonColor).opacity(0.4), radius: 12, y: 4)
                }
                .disabled(!subscriptionManager.hasLoadedProducts)

                // Price disclosure
                ctaPriceDisclosure
            }
        }
    }

    @ViewBuilder
    private var ctaIcon: some View {
        switch selectedPlan {
        case .lifetime:
            Image(systemName: "crown.fill")
        case .weekly:
            Image(systemName: "bolt.fill")
        default:
            Image(systemName: "play.fill")
        }
    }

    @ViewBuilder
    private var ctaText: some View {
        switch selectedPlan {
        case .lifetime:
            Text("Get Lifetime Access")
        case .weekly:
            Text("Start Weekly — \(subscriptionManager.getWeeklyPrice())")
        default:
            Text("Start Free 7-Day Trial")
        }
    }

    @ViewBuilder
    private var ctaPriceDisclosure: some View {
        switch selectedPlan {
        case .monthly:
            Text("After trial: \(subscriptionManager.getMonthlyPrice())/month · Cancel anytime")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.4))
        case .yearly:
            Text("After trial: \(subscriptionManager.getYearlyPrice())/year · Cancel anytime")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.4))
        case .weekly:
            Text("Billed \(subscriptionManager.getWeeklyPrice()) every week · Cancel anytime")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.4))
        case .lifetime:
            Text("One-time payment · No subscription")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.4))
        }
    }

    // MARK: - Micro Feature List

    private var microFeatureList: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                PixelAnimatedIcon(icon: PixelIconCatalog.star, size: 20)
                Text("Everything in Pro")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.bottom, 12)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                MicroFeatureRow(icon: "square.3.layers.3d", text: "Unlimited Layers")
                MicroFeatureRow(icon: "film", text: "GIF Animation")
                MicroFeatureRow(icon: "square.grid.3x3", text: "Sprite Sheets")
                MicroFeatureRow(icon: "doc.badge.arrow.up", text: "Aseprite Import")
                MicroFeatureRow(icon: "wand.and.stars", text: "AI Palette")
                MicroFeatureRow(icon: "paintpalette.fill", text: "9 Color Palettes")
                MicroFeatureRow(icon: "square.resize", text: "4K PNG Export")
                MicroFeatureRow(icon: "xmark.circle", text: "No Watermark")
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }

    // MARK: - Trust Section

    private var trustSection: some View {
        VStack(spacing: 14) {
            Button {
                Task {
                    await subscriptionManager.restorePurchases()
                    isProUser = subscriptionManager.isProUser
                    if subscriptionManager.errorMessage != nil { showingError = true }
                }
            } label: {
                Text("Restore Purchases")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
            }

            HStack(spacing: 16) {
                Label("Cancel anytime", systemImage: "xmark.circle")
                Label("Secure payment", systemImage: "lock.fill")
            }
            .font(.system(size: 11))
            .foregroundColor(.white.opacity(0.3))

            HStack(spacing: 20) {
                Button("Terms of Service") {
                    if let url = URL(string: AppConfig.termsAndConditionsURL.absoluteString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Privacy Policy") {
                    if let url = URL(string: AppConfig.privacyURL.absoluteString) {
                        UIApplication.shared.open(url)
                    }
                }
            }
            .font(.system(size: 11))
            .foregroundColor(.white.opacity(0.25))
        }
    }

    // MARK: - Purchase Logic

    private func purchaseSelectedPlan() async {
        isProcessing = true

        let product: Product?
        switch selectedPlan {
        case .weekly:  product = subscriptionManager.getWeeklyProduct()
        case .monthly: product = subscriptionManager.getMonthlyProduct()
        case .yearly:  product = subscriptionManager.getYearlyProduct()
        case .lifetime: product = subscriptionManager.getLifetimeProduct()
        }

        guard let selectedProduct = product else {
            subscriptionManager.errorMessage = "Selected product not found"
            showingError = true
            isProcessing = false
            return
        }

        let success = await subscriptionManager.purchaseSubscription(selectedProduct)
        if success {
            isProUser = true
        } else if subscriptionManager.errorMessage != nil {
            showingError = true
        }

        isProcessing = false
    }
}

// MARK: - Compact Plan Card

struct CompactPlanCard: View {
    let label: String
    let price: String
    let detail: String
    let badge: String?
    let badgeColor: Color
    let isSelected: Bool
    let isRecommended: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Badge or spacer
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(badgeColor)
                        .cornerRadius(4)
                } else {
                    Text(" ")
                        .font(.system(size: 10))
                        .padding(.vertical, 3)
                }

                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))

                Text(price)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text(detail)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.4))

                // Selection indicator
                if isSelected {
                    Circle()
                        .fill(Color(AppConfig.continueButtonColor))
                        .frame(width: 8, height: 8)
                } else {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color(AppConfig.continueButtonColor).opacity(0.15) : Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected
                            ? Color(AppConfig.continueButtonColor)
                            : (isRecommended ? Color.white.opacity(0.15) : Color.white.opacity(0.08)),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
    }
}

// MARK: - Micro Feature Row

struct MicroFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.yellow)
                .frame(width: 18)

            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(1)

            Spacer()
        }
    }
}

// MARK: - Supporting Enums

enum SubscriptionPlan: String, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    case lifetime = "Lifetime"

    var title: String { rawValue }

    var description: String {
        switch self {
        case .weekly:   return "Weekly billing"
        case .monthly:  return "Monthly billing"
        case .yearly:   return "Yearly billing — best value"
        case .lifetime: return "One-time payment for lifetime access"
        }
    }
}

// MARK: - Preview

#Preview {
    PaywallView(isProUser: .constant(false))
}
