//
//  PaywallView.swift
//  Hantam
//
//  한땀 Pro 결제 화면. 공예는 가끔 하는 취미라 평생 이용권을 맨 앞에 둔다.
//  - 무료 체험 문구는 App Store 에 실제로 걸린 체험(introductoryOffer)과 자격이 있을 때만 보인다.
//  - 평점·사용자 수 같은 숫자는 지어내지 않는다.
//  - 어디서 띄웠는지(reason)를 허브로 보낸다 — 어느 순간에 사려고 하는지 본다.
//  - 주간 상품은 더 팔지 않는다(기존 구독자의 권한은 PixelMeSpec.entitlementIDs 가 지킨다).
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @Binding var isProUser: Bool
    var reason: PaywallReason = .advanced

    @State private var selectedPlan: SubscriptionPlan = .lifetime
    @State private var showingError = false
    @State private var isProcessing = false
    /// 상품 ID → 무료 체험 일수 (자격이 있을 때만).
    @State private var trialDays: [String: Int] = [:]

    var body: some View {
        ZStack {
            Color.hantamBackground.ignoresSafeArea()
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 22) {
                    header
                    benefits
                    planSelector
                    ctaButton
                    trustSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)
                .padding(.bottom, 30)
            }
            closeButton
        }
        .tint(.hantamAccent)
        .onAppear { HantamEvent.paywallShown(reason) }
        .task { await loadTrials() }
        .onChange(of: subscriptionManager.isProUser) { _, pro in
            if pro {
                isProUser = true
                DispatchQueue.main.asyncAfter(deadline: .now() + AppConfig.subscriptionSuccessDelay) { dismiss() }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { subscriptionManager.errorMessage = nil }
        } message: {
            Text(subscriptionManager.errorMessage ?? NSLocalizedString("An unknown error occurred", comment: ""))
        }
    }

    // MARK: - 머리

    private var closeButton: some View {
        VStack {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.hantamInk.opacity(0.6))
                        .frame(width: 34, height: 34)
                        .background(Color.hantamCard, in: Circle())
                }
                .accessibilityLabel(Text("Close"))
                Spacer()
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private var header: some View {
        VStack(spacing: 12) {
            BeadHeartMark(size: 84)
            Text("Hantam Pro")
                .font(.system(size: 30, weight: .heavy))
                .foregroundStyle(Color.hantamInk)
            Text(headline)
                .font(.headline)
                .foregroundStyle(Color.hantamInk.opacity(0.75))
                .multilineTextAlignment(.center)
        }
    }

    private var headline: LocalizedStringKey {
        switch reason {
        case .patternPDF:        return "Print your pattern and start making"
        case .patternSize:       return "Make patterns as big as you like"
        case .patternSaveLimit:  return "Keep every pattern you make"
        case .patternCleanImage: return "Share patterns without the mark"
        default:                 return "Everything for bead and stitch patterns"
        }
    }

    // MARK: - 혜택 (앱에 실제로 있는 것만)

    private var benefits: some View {
        VStack(alignment: .leading, spacing: 12) {
            BenefitRow(icon: "printer.fill", title: "Printable PDF patterns",
                       detail: "Symbol charts split board by board, with a color list.")
            BenefitRow(icon: "square.grid.3x3.fill", title: "Bigger patterns",
                       detail: "Up to 4 × 4 pegboards, or 200 stitches across.")
            BenefitRow(icon: "tray.full.fill", title: "Keep every pattern",
                       detail: "Free keeps 3. Pro has no limit.")
            BenefitRow(icon: "photo.fill", title: "No Hantam mark",
                       detail: "Clean images of your patterns and pixel art.")
            BenefitRow(icon: "paintpalette.fill", title: "All pixel art tools",
                       detail: "Every grid size, palette, filter and dithering style, plus 4K export.")
        }
        .padding(16)
        .background(Color.hantamCard, in: RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - 요금제

    private var planSelector: some View {
        VStack(spacing: 10) {
            PlanRow(
                title: "Lifetime",
                price: subscriptionManager.getLifetimePrice(),
                detail: "Pay once, yours forever",
                badge: "Pay once",
                isSelected: selectedPlan == .lifetime
            ) { selectedPlan = .lifetime }

            PlanRow(
                title: "Yearly",
                price: subscriptionManager.getYearlyPrice(),
                detail: yearlyDetail,
                badge: yearlySavingsBadge,
                isSelected: selectedPlan == .yearly
            ) { selectedPlan = .yearly }

            PlanRow(
                title: "Monthly",
                price: subscriptionManager.getMonthlyPrice(),
                detail: trialText(for: subscriptionManager.getMonthlyProduct()) ?? LocalizedStringKey("Billed every month"),
                badge: nil,
                isSelected: selectedPlan == .monthly
            ) { selectedPlan = .monthly }
        }
    }

    private var yearlyDetail: LocalizedStringKey {
        if let t = trialText(for: subscriptionManager.getYearlyProduct()) { return t }
        return "\(subscriptionManager.getYearlyMonthlyPrice()) a month, billed yearly"
    }

    /// 연간이 월간 12개월보다 얼마나 싼지 — 상품이 둘 다 있을 때만.
    private var yearlySavingsBadge: LocalizedStringKey? {
        guard let y = subscriptionManager.getYearlyProduct()?.price,
              let m = subscriptionManager.getMonthlyProduct()?.price, m > 0 else { return nil }
        let ratio = NSDecimalNumber(decimal: y / (m * 12)).doubleValue
        let pct = Int(((1 - ratio) * 100).rounded())
        return pct >= 5 ? "Save \(pct)%" : nil
    }

    private func trialText(for product: Product?) -> LocalizedStringKey? {
        guard let id = product?.id, let days = trialDays[id] else { return nil }
        return "\(days)-day free trial"
    }

    private var selectedProduct: Product? {
        switch selectedPlan {
        case .weekly:   return subscriptionManager.getWeeklyProduct()
        case .monthly:  return subscriptionManager.getMonthlyProduct()
        case .yearly:   return subscriptionManager.getYearlyProduct()
        case .lifetime: return subscriptionManager.getLifetimeProduct()
        }
    }

    // MARK: - 결제 버튼

    private var ctaButton: some View {
        VStack(spacing: 10) {
            if subscriptionManager.isProUser {
                Label("Pro is active", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundStyle(Color.hantamTeal)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(Color.hantamTeal.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
            } else {
                Button {
                    Task { await purchaseSelectedPlan() }
                } label: {
                    ZStack {
                        if isProcessing || subscriptionManager.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text(ctaTitle)
                        }
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(Color.hantamAccent, in: RoundedRectangle(cornerRadius: 16))
                }
                .disabled(!subscriptionManager.hasLoadedProducts || isProcessing)

                Text(disclosure)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var ctaTitle: LocalizedStringKey {
        if selectedPlan == .lifetime { return "Buy once for \(subscriptionManager.getLifetimePrice())" }
        if let id = selectedProduct?.id, let days = trialDays[id] { return "Start \(days)-day free trial" }
        return "Continue"
    }

    private var disclosure: LocalizedStringKey {
        switch selectedPlan {
        case .lifetime:
            return "One-time purchase. No subscription."
        case .yearly:
            if let id = selectedProduct?.id, trialDays[id] != nil {
                return "Free during the trial, then \(subscriptionManager.getYearlyPrice()) a year. Renews automatically unless canceled at least 24 hours before the period ends."
            }
            return "\(subscriptionManager.getYearlyPrice()) a year. Renews automatically unless canceled at least 24 hours before the period ends."
        case .monthly, .weekly:
            if let id = selectedProduct?.id, trialDays[id] != nil {
                return "Free during the trial, then \(subscriptionManager.getMonthlyPrice()) a month. Renews automatically unless canceled at least 24 hours before the period ends."
            }
            return "\(subscriptionManager.getMonthlyPrice()) a month. Renews automatically unless canceled at least 24 hours before the period ends."
        }
    }

    // MARK: - 복원 · 약관

    private var trustSection: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await subscriptionManager.restorePurchases()
                    isProUser = subscriptionManager.isProUser
                    if subscriptionManager.errorMessage != nil { showingError = true }
                }
            } label: {
                Text("Restore Purchases")
                    .font(.subheadline.weight(.semibold))
            }
            HStack(spacing: 20) {
                Link("Terms of Use", destination: AppConfig.termsAndConditionsURL)
                Link("Privacy Policy", destination: AppConfig.privacyURL)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - 동작

    private func loadTrials() async {
        if !subscriptionManager.hasLoadedProducts { await subscriptionManager.loadProducts() }
        var found: [String: Int] = [:]
        for product in [subscriptionManager.getYearlyProduct(), subscriptionManager.getMonthlyProduct()].compactMap({ $0 }) {
            guard let sub = product.subscription,
                  let offer = sub.introductoryOffer,
                  offer.paymentMode == .freeTrial,
                  await sub.isEligibleForIntroOffer else { continue }
            let unitDays: Int
            switch offer.period.unit {
            case .day: unitDays = 1
            case .week: unitDays = 7
            case .month: unitDays = 30
            case .year: unitDays = 365
            @unknown default: unitDays = 1
            }
            found[product.id] = offer.period.value * unitDays
        }
        trialDays = found
    }

    private func purchaseSelectedPlan() async {
        guard let product = selectedProduct else {
            subscriptionManager.errorMessage = NSLocalizedString("Product not available. Please try again later.", comment: "")
            showingError = true
            return
        }
        isProcessing = true
        let success = await subscriptionManager.purchaseSubscription(product)
        isProcessing = false
        if success {
            isProUser = true
        } else if subscriptionManager.errorMessage != nil {
            showingError = true
        }
    }
}

// MARK: - 부품

private struct BenefitRow: View {
    let icon: String
    let title: LocalizedStringKey
    let detail: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.hantamAccent)
                .frame(width: 26)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(Color.hantamInk)
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct PlanRow: View {
    let title: LocalizedStringKey
    let price: String
    let detail: LocalizedStringKey
    let badge: LocalizedStringKey?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? Color.hantamAccent : Color.hantamInk.opacity(0.3))
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(title).font(.headline)
                        if let badge {
                            Text(badge)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 7).padding(.vertical, 2)
                                .background(Color.hantamMustard, in: Capsule())
                        }
                    }
                    Text(detail).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Text(price)
                    .font(.headline.monospacedDigit())
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }
            .foregroundStyle(Color.hantamInk)
            .padding(14)
            .background(Color.hantamCard, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.hantamAccent : Color.hantamInk.opacity(0.08), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// 한땀 로고 — 비즈로 만든 하트. 앱 아이콘과 같은 모양.
struct BeadHeartMark: View {
    var size: CGFloat = 80

    static let rows: [String] = [
        ".##.##.",
        "#######",
        "#######",
        ".#####.",
        "..###..",
        "...#...",
    ]

    /// 왼쪽 위 볼록한 곳의 겨자색 비즈 세 알 — 아이콘과 같은 자리.
    static func isAccent(_ r: Int, _ c: Int) -> Bool {
        (r == 1 && (c == 1 || c == 2)) || (r == 2 && c == 1)
    }

    var body: some View {
        let cols = Self.rows[0].count
        let cell = size / CGFloat(cols)
        VStack(spacing: 0) {
            ForEach(Array(Self.rows.enumerated()), id: \.offset) { r, row in
                HStack(spacing: 0) {
                    ForEach(Array(row.enumerated()), id: \.offset) { c, ch in
                        ZStack {
                            if ch == "#" {
                                Circle().fill(Self.isAccent(r, c) ? Color.hantamMustard : Color.hantamAccent)
                                Circle().fill(Color.white.opacity(0.92)).padding(cell * 0.32)
                            } else {
                                Circle().fill(Color.hantamInk.opacity(0.08)).padding(cell * 0.36)
                            }
                        }
                        .frame(width: cell, height: cell)
                    }
                }
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Supporting Enums

enum SubscriptionPlan: String, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    case lifetime = "Lifetime"
}

// MARK: - Preview

#Preview {
    PaywallView(isProUser: .constant(false), reason: .patternPDF)
}
