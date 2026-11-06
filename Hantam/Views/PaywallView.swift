//
//  PaywallView.swift
//  Hantam
//
//  한땀 Plus · Pro 결제 화면 — 무료 · Plus · Pro 세 칸.
//  - 칸 카드 두 장(Plus · Pro)에서 고르고, 그 칸의 연 구독 · 평생을 먼저, 월 · 주는 펼쳐서 고른다.
//  - 띄운 자리(reason)에 맞는 칸을 먼저 고른다: 인쇄용 PDF · 필터 팩은 Pro, 크기 · 저장 · 표시는 Plus.
//  - Plus 평생을 가진 사람에게 Pro 평생은 올리기 값으로 판다.
//  - 불러온 상품만 보인다. 스토어에 아직 없는 상품의 단추는 서지 않는다.
//  - 첫 해 할인 문구는 App Store 에 실제로 걸린 할인과 자격이 있을 때만 보인다. 숫자를 지어내지 않는다.
//  - 어디서 띄웠는지(reason)를 허브로 보낸다 — 어느 순간에 사려고 하는지 본다.
//

import SwiftUI
import StoreKit
import LeeoKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.purchase) private var purchase
    @ObservedObject private var subscription = SubscriptionManager.shared
    let reason: PaywallReason

    @State private var selectedTier: HantamTier
    @State private var term: PlanTerm = .yearly
    @State private var showsMoreTerms = false
    @State private var isProcessing = false
    @State private var showingError = false
    /// 첫 구독 할인을 받을 수 있는 연 구독 상품.
    @State private var introEligible: Set<String> = []

    init(reason: PaywallReason = .advanced) {
        self.reason = reason
        _selectedTier = State(initialValue: reason.suggestedTier)
    }

    var body: some View {
        ZStack {
            Color.hantamBackground.ignoresSafeArea()
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 22) {
                    header
                    if subscription.ownedTier == .pro {
                        activeBadge
                    } else if offeredTiers.isEmpty {
                        unavailable
                    } else {
                        tierCards
                        termOptions
                        ctaButton
                    }
                    comparison
                    trustSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)
                .padding(.bottom, 30)
                .frame(maxWidth: 640)
                .frame(maxWidth: .infinity)
            }
            closeButton
        }
        .tint(.hantamAccent)
        .onAppear {
            HantamEvent.paywallShown(reason)
            fitSelection()
        }
        .task {
            if subscription.store.products.count < HantamPlan.productIDs.count { await subscription.loadProducts() }
            fitSelection()
            await loadIntroEligibility()
        }
        .onChange(of: subscription.ownedTier) { _, owned in
            fitSelection()
            if owned >= selectedTier {
                DispatchQueue.main.asyncAfter(deadline: .now() + AppConfig.subscriptionSuccessDelay) { dismiss() }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(subscription.lastError ?? NSLocalizedString("An unknown error occurred", comment: ""))
        }
    }

    // MARK: - 머리

    private var closeButton: some View {
        VStack {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.hantamInk.opacity(0.6))
                        .frame(width: 34, height: 34)
                        .background(Color.hantamCard, in: Circle())
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
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
            Text("Hantam Plus · Pro")
                .font(.title.weight(.heavy))
                .accessibilityAddTraits(.isHeader)
                .foregroundStyle(Color.hantamInk)
                .multilineTextAlignment(.center)
            if let headline {
                Text(headline)
                    .font(.headline)
                    .foregroundStyle(Color.hantamInk)
                    .multilineTextAlignment(.center)
            }
            Text("Bigger patterns, and printable charts you can start beading from. Choose yearly or lifetime.")
                .font(.body)
                .foregroundStyle(Color.hantamInk.opacity(0.75))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// 띄운 자리에 맞는 한 줄. 일반 진입이면 없다.
    private var headline: LocalizedStringKey? {
        switch reason {
        case .patternPDF:        return "Print your pattern and start making"
        case .patternSize:       return "Make patterns as big as you like"
        case .patternSaveLimit:  return "Keep every pattern you make"
        case .patternCleanImage: return "Share patterns without the mark"
        case .filterPack:        return "Every filter pack comes with Pro"
        default:                 return nil
        }
    }

    private var activeBadge: some View {
        Label("Pro is active", systemImage: "checkmark.seal.fill")
            .font(.headline)
            .foregroundStyle(Color.hantamTeal)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(Color.hantamTeal.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
    }

    /// 상품을 하나도 못 불러왔을 때. 막힌 단추 대신 다시 불러오는 길을 둔다.
    @ViewBuilder
    private var unavailable: some View {
        if subscription.isLoading {
            ProgressView().controlSize(.large).frame(minHeight: 120)
        } else {
            VStack(spacing: 12) {
                Text("Couldn’t load the plans. Check your connection and try again.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Try again") { Task { await subscription.loadProducts(); fitSelection() } }
                    .font(.headline)
                    .frame(minHeight: 44)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color.hantamCard, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - 칸

    /// 지금 고를 수 있는 칸 — 상품이 있고, 가진 칸보다 높은 것.
    private var offeredTiers: [HantamTier] {
        [HantamTier.plus, .pro].filter { $0 > subscription.ownedTier && subscription.sells($0) }
    }

    private var tierCards: some View {
        VStack(spacing: 12) {
            ForEach([HantamTier.plus, .pro]) { tier in
                if tier == subscription.ownedTier || offeredTiers.contains(tier) {
                    TierCard(tier: tier,
                             isOwned: tier == subscription.ownedTier,
                             isSelected: tier == selectedTier) {
                        guard tier != subscription.ownedTier else { return }
                        selectedTier = tier
                        fitSelection()
                    }
                }
            }
        }
    }

    // MARK: - 기간

    private var termOptions: some View {
        VStack(spacing: 10) {
            ForEach([PlanTerm.yearly, .lifetime], id: \.self) { t in termRow(t) }
            if hasShortTerms {
                if showsMoreTerms {
                    ForEach([PlanTerm.monthly, .weekly], id: \.self) { t in termRow(t) }
                } else {
                    Button { withAnimation { showsMoreTerms = true } } label: {
                        Label("More options", systemImage: "chevron.down")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                }
            }
        }
    }

    private var hasShortTerms: Bool {
        subscription.product(selectedTier, .monthly) != nil || subscription.product(selectedTier, .weekly) != nil
    }

    @ViewBuilder
    private func termRow(_ t: PlanTerm) -> some View {
        if let product = subscription.product(selectedTier, t) {
            PlanRow(title: title(of: t),
                    price: price(of: t, product),
                    detail: detail(of: t, product),
                    isSelected: term == t) { term = t }
        }
    }

    private func title(of t: PlanTerm) -> String {
        switch t {
        case .yearly:   return LeeoLadderText.yearly
        case .lifetime: return LeeoLadderText.lifetime
        case .monthly:  return String(localized: "Monthly")
        case .weekly:   return String(localized: "Weekly")
        }
    }

    private func price(of t: PlanTerm, _ product: Product) -> String {
        t == .yearly ? String(format: LeeoLadderText.perYearFormat, product.displayPrice) : product.displayPrice
    }

    private func detail(of t: PlanTerm, _ product: Product) -> String? {
        switch t {
        case .yearly:
            if let intro = introPrice(product) { return String(format: LeeoLadderText.introFormat, intro) }
            let perMonth = (product.price / 12).formatted(product.priceFormatStyle)
            return String(localized: "\(perMonth) a month, billed yearly")
        case .lifetime:
            if product.id == AppConfig.proUpgradeProductID { return String(localized: "Upgrade price for Plus lifetime owners") }
            let yearly = subscription.product(selectedTier, .yearly)
            if let yearly, yearly.price > 0 {
                let years = Int(NSDecimalNumber(decimal: product.price / yearly.price).doubleValue.rounded(.down))
                if years >= 2 { return String(format: LeeoLadderText.lifetimeWorthFormat, years) }
            }
            return String(localized: "Pay once, yours forever")
        case .monthly:
            return String(localized: "Billed every month")
        case .weekly:
            return nil
        }
    }

    /// 첫 해 할인가 — App Store 에 걸려 있고 이 사람이 받을 수 있을 때만.
    private func introPrice(_ product: Product) -> String? {
        guard introEligible.contains(product.id),
              let offer = product.subscription?.introductoryOffer,
              offer.paymentMode == .payUpFront || offer.paymentMode == .payAsYouGo else { return nil }
        return offer.displayPrice
    }

    private var selectedProduct: Product? { subscription.product(selectedTier, term) }

    // MARK: - 결제 단추

    private var ctaButton: some View {
        VStack(spacing: 10) {
            Button {
                Task { await buy() }
            } label: {
                ZStack {
                    if isProcessing {
                        ProgressView().tint(.white)
                    } else {
                        Text(ctaTitle)
                    }
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(Color.hantamAccentFill, in: RoundedRectangle(cornerRadius: 16))
            }
            .disabled(selectedProduct == nil || isProcessing)

            if let disclosure {
                Text(disclosure)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var ctaTitle: String {
        if term == .lifetime, let p = selectedProduct { return String(localized: "Buy once for \(p.displayPrice)") }
        return String(localized: "Continue")
    }

    private var disclosure: String? {
        guard let p = selectedProduct else { return nil }
        switch term {
        case .lifetime:
            return String(localized: "One-time purchase. No subscription.")
        case .yearly:
            if let intro = introPrice(p) {
                return String(localized: "First year \(intro), then \(p.displayPrice) a year. Renews automatically unless canceled at least 24 hours before the period ends.")
            }
            return String(localized: "\(p.displayPrice) a year. Renews automatically unless canceled at least 24 hours before the period ends.")
        case .monthly:
            return String(localized: "\(p.displayPrice) a month. Renews automatically unless canceled at least 24 hours before the period ends.")
        case .weekly:
            return String(localized: "\(p.displayPrice) a week. Renews automatically unless canceled at least 24 hours before the period ends.")
        }
    }

    // MARK: - 비교표

    private var comparison: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Compare plans")
                .font(.headline)
                .foregroundStyle(Color.hantamInk)
                .accessibilityAddTraits(.isHeader)
            ForEach(ComparisonRow.all) { row in
                VStack(alignment: .leading, spacing: 6) {
                    Text(row.title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.hantamInk)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(alignment: .top, spacing: 8) {
                        ForEach(HantamTier.allCases) { tier in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(tier.shortName)
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                row.value(for: tier)
                                    .font(.body)
                                    .foregroundStyle(Color.hantamInk)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .accessibilityElement(children: .combine)
                if row.id != ComparisonRow.all.last?.id { Divider() }
            }
        }
        .padding(16)
        .background(Color.hantamCard, in: RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - 복원 · 약관

    private var trustSection: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await subscription.restorePurchases()
                    if subscription.ownedTier == .free {
                        if subscription.lastError == nil {
                            subscription.store.lastError = NSLocalizedString("No previous purchases found.", comment: "")
                        }
                        showingError = true
                    }
                }
            } label: {
                Text("Restore Purchases")
                    .font(.body.weight(.semibold))
                    .frame(minHeight: 44)
            }
            HStack(spacing: 20) {
                Link("Terms of Use", destination: AppConfig.termsAndConditionsURL)
                Link("Privacy Policy", destination: AppConfig.privacyURL)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - 동작

    /// 고른 칸 · 기간을 지금 팔 수 있는 것으로 맞춘다.
    private func fitSelection() {
        let tiers = offeredTiers
        if !tiers.contains(selectedTier), let first = tiers.last(where: { $0 == reason.suggestedTier }) ?? tiers.last {
            selectedTier = first
        }
        if subscription.product(selectedTier, term) == nil,
           let t = PlanTerm.allCases.first(where: { subscription.product(selectedTier, $0) != nil }) {
            term = t
            if t == .monthly || t == .weekly { showsMoreTerms = true }
        }
    }

    private func loadIntroEligibility() async {
        var found: Set<String> = []
        for tier in [HantamTier.plus, .pro] {
            guard let p = subscription.product(tier, .yearly), let sub = p.subscription,
                  sub.introductoryOffer != nil, await sub.isEligibleForIntroOffer else { continue }
            found.insert(p.id)
        }
        introEligible = found
    }

    private func buy() async {
        guard let product = selectedProduct else { return }
        isProcessing = true
        let success = await subscription.purchase(product, using: purchase)
        isProcessing = false
        if !success, subscription.lastError != nil { showingError = true }
    }
}

// MARK: - 띄운 자리 → 먼저 고를 칸

extension PaywallReason {
    /// 인쇄용 PDF · 필터 팩 · 홈 배너 · 설정은 Pro 카드를, 크기 · 저장 · 표시 · 픽셀 아트 도구는 Plus 카드를 앞에.
    var suggestedTier: HantamTier {
        switch self {
        case .patternPDF, .filterPack, .homeBanner, .settings: return .pro
        default: return .plus
        }
    }
}

// MARK: - 비교표 줄 (요청서의 표 그대로)

private struct ComparisonRow: Identifiable {
    enum Cell {
        case yes, no
        case text(LocalizedStringKey)
        case number(Int)
    }

    let id: Int
    let title: LocalizedStringKey
    let free: Cell
    let plus: Cell
    let pro: Cell

    @ViewBuilder
    func value(for tier: HantamTier) -> some View {
        switch tier == .free ? free : tier == .plus ? plus : pro {
        case .yes:             Text(verbatim: "✓").accessibilityLabel(Text("Included"))
        case .no:              Text(verbatim: "–").accessibilityLabel(Text("Not included"))
        case .text(let key):   Text(key)
        case .number(let n):   Text(verbatim: "\(n)")
        }
    }

    static let all: [ComparisonRow] = [
        ComparisonRow(id: 0, title: "Make bead and cross-stitch patterns from photos", free: .yes, plus: .yes, pro: .yes),
        ComparisonRow(id: 1, title: "See color numbers and counts, copy the shopping list", free: .yes, plus: .yes, pro: .yes),
        ComparisonRow(id: 2, title: "Pattern size", free: .text("1 board · 40 stitches"),
                      plus: .text("4 × 4 boards · 200 stitches"), pro: .text("4 × 4 boards · 200 stitches")),
        ComparisonRow(id: 3, title: "Saved patterns", free: .number(HantamPlan.freeSaveLimit), plus: .text("Unlimited"), pro: .text("Unlimited")),
        ComparisonRow(id: 4, title: "Images without the mark", free: .no, plus: .yes, pro: .yes),
        ComparisonRow(id: 5, title: "Pixel art grid sizes, palettes and dithering", free: .text("Basic 3"), plus: .text("All"), pro: .text("All")),
        ComparisonRow(id: 6, title: "Printable PDF patterns", free: .no, plus: .no, pro: .yes),
        ComparisonRow(id: 7, title: "Before-and-after videos without the caption", free: .no, plus: .no, pro: .yes),
        ComparisonRow(id: 8, title: "3 filter packs", free: .no, plus: .no, pro: .yes),
    ]
}

// MARK: - 부품

private struct TierCard: View {
    let tier: HantamTier
    let isOwned: Bool
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: isOwned ? "checkmark.seal.fill" : isSelected ? "largecircle.fill.circle" : "circle")
                        .font(.title2)
                        .foregroundStyle(isOwned ? Color.hantamTeal : isSelected ? Color.hantamAccent : Color.hantamInk.opacity(0.3))
                        .accessibilityHidden(true)
                    Text(tier.name)
                        .font(.title3.weight(.bold))
                    Spacer(minLength: 0)
                    if isOwned {
                        Text("Your plan")
                            .font(.footnote.bold())
                            .foregroundStyle(Color.black.opacity(0.85))
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Color.hantamMustard, in: Capsule())
                    }
                }
                Text(tier.pitch)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                VStack(alignment: .leading, spacing: 6) {
                    if tier == .pro {
                        featureLine("Everything in Plus", icon: "checkmark")
                    }
                    ForEach(HantamFeature.opened(by: tier)) { f in
                        featureLine(f.title, icon: f.systemImage)
                    }
                }
            }
            .foregroundStyle(Color.hantamInk)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.hantamCard, in: RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected && !isOwned ? Color.hantamAccent : Color.hantamInk.opacity(0.08),
                            lineWidth: isSelected && !isOwned ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func featureLine(_ title: LocalizedStringKey, icon: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.hantamAccent)
                .frame(width: 24)
                .accessibilityHidden(true)
            Text(title)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct PlanRow: View {
    let title: String
    let price: String
    let detail: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.title2)
                    .accessibilityHidden(true)
                    .foregroundStyle(isSelected ? Color.hantamAccent : Color.hantamInk.opacity(0.3))
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.headline)
                    if let detail {
                        Text(detail)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer()
                Text(price)
                    .font(.headline.monospacedDigit())
                    .multilineTextAlignment(.trailing)
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
        .accessibilityElement(children: .combine)
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

// MARK: - Preview

#Preview {
    PaywallView(reason: .patternPDF)
}
