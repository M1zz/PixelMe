//
//  SubscriptionManager.swift
//  Hantam
//
//  무료 · Plus · Pro 세 칸 요금제 — LeeoKit 파사드
//
//  StoreKit 2 엔진(상품 로드·구매·복원·권한 추적·트랜잭션 리스너·오프라인 캐시)은
//  LeeoKit 의 LeeoStore 가 공용으로 담당한다. 이 파일은 그 위에 앱 고유의 것만 얹는다:
//   - 칸(`HantamTier`)과 칸마다 여는 기능(`HantamFeature`)
//   - 상품마다 여는 칸(`HantamPlan.tierByProduct`)
//   - 유료 다운로드 시절에 앱을 산 사람 → Pro 평생(grandfather)
//  결제 화면 · FeatureGating · 도안 화면이 칸을 여기서만 묻는다.
//
//  2.1.x 까지는 유료 다운로드(₩6,600) 안에 'Pro' 한 칸이었다. 그때의 월 · 연 · 평생 상품은 지금의 Pro 로 그대로 잇는다.
//

import StoreKit
import SwiftUI
import Combine
import LeeoKit

// MARK: - 칸

/// 칸. 값이 클수록 더 많이 연다. Pro 는 Plus 를 전부 포함한다.
enum HantamTier: Int, Comparable, CaseIterable, Identifiable {
    case free = 0
    case plus = 1
    case pro = 2

    var id: Int { rawValue }
    static func < (lhs: HantamTier, rhs: HantamTier) -> Bool { lhs.rawValue < rhs.rawValue }

    /// 비교표 머리의 짧은 이름.
    var shortName: LocalizedStringKey {
        switch self {
        case .free: return "Free"
        case .plus: return "Plus"
        case .pro:  return "Pro"
        }
    }

    var name: LocalizedStringKey {
        switch self {
        case .free: return "Free"
        case .plus: return "Hantam Plus"
        case .pro:  return "Hantam Pro"
        }
    }

    /// 칸 카드의 한 줄.
    var pitch: LocalizedStringKey {
        switch self {
        case .free: return "Make bead and cross-stitch patterns from photos"
        case .plus: return "Make big multi-board patterns and keep every pattern you make."
        case .pro:  return "Print and start beading right away, with board-by-board symbol charts and a color list."
        }
    }
}

/// 값을 받고 여는 것. **칸마다 무엇이 열리는지는 여기 `tier` 한 곳에 있다** — 페이월 카드도 이 목록을 읽는다.
///
/// ⚠️ 잠그지 않는 것: 도안 만들기(보드 1장 · 40칸), 색 번호 · 개수 보기, 칸 고치기, 구매 목록 복사,
///    이미 만든 도안 보기 · 고치기 · 지우기, 표시가 든 이미지 공유, 손쉬운 사용.
enum HantamFeature: String, CaseIterable, Identifiable {
    /// 보드 4 × 4장(116칸) · 십자수 200칸까지.
    case biggerPatterns
    /// 도안 무제한 보관 (무료는 `HantamPlan.freeSaveLimit`).
    case keepPatterns
    /// 한땀 표시 없는 이미지.
    case cleanImage
    /// 픽셀 아트의 모든 칸 크기 · 팔레트 · 디더링 · 필터.
    case pixelTools
    /// 인쇄용 PDF 도안 (보드마다 나눈 기호 도안과 색 목록).
    case printablePDF
    /// 한땀 문구 없는 전후 비교 영상.
    case cleanVideo
    /// 픽셀 아트 필터 팩 3종.
    case filterPacks

    var id: String { rawValue }

    /// 이 기능을 여는 가장 낮은 칸.
    var tier: HantamTier {
        switch self {
        case .biggerPatterns, .keepPatterns, .cleanImage, .pixelTools: return .plus
        case .printablePDF, .cleanVideo, .filterPacks:                 return .pro
        }
    }

    /// 그 칸에서 새로 열리는 것들 (페이월 카드 차례).
    static func opened(by tier: HantamTier) -> [HantamFeature] { allCases.filter { $0.tier == tier } }

    var title: LocalizedStringKey {
        switch self {
        case .biggerPatterns: return "Up to 4 × 4 pegboards, or 200 stitches across."
        case .keepPatterns:   return "Keep every pattern"
        case .cleanImage:     return "No Hantam mark"
        case .pixelTools:     return "All pixel art tools"
        case .printablePDF:   return "Printable PDF patterns"
        case .cleanVideo:     return "Before-and-after videos without the caption"
        case .filterPacks:    return "3 filter packs"
        }
    }

    var systemImage: String {
        switch self {
        case .biggerPatterns: return "square.grid.3x3.fill"
        case .keepPatterns:   return "tray.full.fill"
        case .cleanImage:     return "photo.fill"
        case .pixelTools:     return "paintpalette.fill"
        case .printablePDF:   return "printer.fill"
        case .cleanVideo:     return "film.fill"
        case .filterPacks:    return "sparkles"
        }
    }
}

/// 칸을 사는 길. 페이월은 연을 먼저 고르고, 월 · 주는 펼쳐 보인다.
enum PlanTerm: CaseIterable {
    case yearly, lifetime, monthly, weekly
}

// MARK: - 상품

/// 상품과 칸의 계약.
enum HantamPlan {
    /// 무료로 저장해 둘 수 있는 도안 수.
    static let freeSaveLimit = 3

    /// 칸 · 기간 → 상품 ID.
    static func productID(_ tier: HantamTier, _ term: PlanTerm) -> String? {
        switch (tier, term) {
        case (.plus, .weekly):   return AppConfig.plusWeeklyProductID
        case (.plus, .monthly):  return AppConfig.plusMonthlyProductID
        case (.plus, .yearly):   return AppConfig.plusYearlyProductID
        case (.plus, .lifetime): return AppConfig.plusLifetimeProductID
        case (.pro, .weekly):    return AppConfig.proWeeklyProductID
        case (.pro, .monthly):   return AppConfig.monthlyProductID
        case (.pro, .yearly):    return AppConfig.yearlyProductID
        case (.pro, .lifetime):  return AppConfig.lifetimeProductID
        case (.free, _):         return nil
        }
    }

    /// 페이월이 불러와 파는 상품. 언제나 평생 패스는 팔지 않는다.
    static let productIDs: [String] = [HantamTier.plus, .pro].flatMap { tier in
        PlanTerm.allCases.compactMap { productID(tier, $0) }
    } + [AppConfig.proUpgradeProductID, AppConfig.proGraduateProductID]

    /// **상품마다 여는 칸.** 판매를 멈춘 예전 상품도 빼지 않는다 — 산 사람의 권한은 그대로 둔다.
    /// ⚠️ 선물 · 팁 상품은 넣지 않는다. 넣으면 선물이나 팁을 산 사람이 Pro 가 된다.
    static let tierByProduct: [String: HantamTier] = {
        var map: [String: HantamTier] = [:]
        for tier in [HantamTier.plus, .pro] {
            for term in PlanTerm.allCases { if let id = productID(tier, term) { map[id] = tier } }
        }
        for id in [AppConfig.proUpgradeProductID, AppConfig.proGraduateProductID,
                   AppConfig.legacyWeeklyProductID, AppConfig.legacyMonthlyProductID,
                   AppConfig.legacyYearlyProductID, AppConfig.premiumVersion] {
            map[id] = .pro
        }
        return map
    }()

    /// 이 중 하나라도 있으면 유료 칸이 열린다.
    static var entitlementIDs: Set<String> { Set(tierByProduct.keys) }

    /// 자동 갱신 구독 (구독 졸업을 제안할 대상).
    static let subscriptionIDs: Set<String> = Set([HantamTier.plus, .pro].flatMap { tier in
        [PlanTerm.weekly, .monthly, .yearly].compactMap { productID(tier, $0) }
    })

    /// 가진 상품들이 여는 칸. 가장 높은 것을 쓴다.
    static func tier(owning productIDs: Set<String>) -> HantamTier {
        productIDs.compactMap { tierByProduct[$0] }.max() ?? .free
    }
}

// MARK: - 매니저

/// StoreKit 2.0 기반 요금제 관리자 (LeeoStore 파사드)
@MainActor
class SubscriptionManager: ObservableObject {

    /// 공용 StoreKit 엔진
    let store: LeeoStore
    private var cancellable: AnyCancellable?

    static let shared = SubscriptionManager()

    private init() {
        store = LeeoStore(config: HantamSpec.paywall!, grandfather: {
            await SubscriptionManager.boughtPaidDownload()
        })

        // 공용 스토어 상태 변화를 뷰에 전파한다.
        cancellable = store.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }

        // 상품 로드 (LeeoStore.init 은 상품을 자동 로드하지 않는다).
        Task { await loadProducts() }
    }

    // MARK: - 칸

    /// **산 것**으로 정해지는 칸. 페이월 · 설정이 보여 주는 것은 이것이다.
    /// 유료 다운로드 시절에 앱을 산 사람(grandfather)과 Pro 선물을 받은 사람은 Pro.
    var ownedTier: HantamTier {
        if store.isGrandfathered { return .pro }
        return HantamPlan.tier(owning: store.purchasedProductIDs)
    }

    /// **기능을 여는** 칸. 유료 칸 상품을 이 기기에서 한 번도 불러오지 못했으면 모두 열어 둔다 —
    /// 상품을 App Store Connect 에 만들기 전에 빌드가 나가도 살 수 없는데 막히는 사람이 없게.
    /// 한 번이라도 불러왔으면(`everSold`) 오프라인이어도 산 것대로 막는다.
    var tier: HantamTier { isSelling ? ownedTier : .pro }

    /// 이 기능을 써도 되는가.
    func allows(_ feature: HantamFeature) -> Bool { tier >= feature.tier }

    /// Pro 기능을 써도 되는가 (인쇄용 PDF · 문구 없는 영상 · 필터 팩).
    var isProUser: Bool { tier >= .pro }

    /// 유료 칸을 파는 중인가 — 상품을 지금 불러왔거나, 이 기기에서 한 번이라도 불러온 적이 있다.
    var isSelling: Bool { everSold || !store.products.isEmpty }

    private static let everSoldKey = "hantam.plan.everSold"
    private var everSold: Bool { UserDefaults.standard.bool(forKey: Self.everSoldKey) }

    // MARK: - 상품

    /// 불러온 상품 (불러온 것만 보인다 — 스토어에 아직 없는 상품의 단추는 서지 않는다).
    func product(_ id: String?) -> Product? {
        guard let id else { return nil }
        return store.products.first { $0.id == id }
    }

    /// 이 칸 · 기간에 지금 팔 상품. Plus 평생을 가진 사람의 Pro 평생은 올리기 값이다.
    func product(_ tier: HantamTier, _ term: PlanTerm) -> Product? {
        if tier == .pro, term == .lifetime, ownsPlusLifetime {
            return product(AppConfig.proUpgradeProductID) ?? product(HantamPlan.productID(tier, term))
        }
        return product(HantamPlan.productID(tier, term))
    }

    /// 이 칸을 살 상품이 하나라도 있는가.
    func sells(_ tier: HantamTier) -> Bool {
        PlanTerm.allCases.contains { product(tier, $0) != nil }
    }

    /// Plus 평생을 가졌는가 — Pro 평생을 올리기 값으로 판다.
    var ownsPlusLifetime: Bool { store.purchasedProductIDs.contains(AppConfig.plusLifetimeProductID) }

    /// 로딩/구매/복원 진행 상태
    var isLoading: Bool {
        store.isLoadingProducts || store.purchasingProductID != nil || store.isRestoring
    }

    var lastError: String? { store.lastError }

    /// Pro 선물하기 엔진. 받은 선물은 Pro 평생으로 이미 합쳐진다.
    /// ⚠️ 상품 로드처럼 엔진 안에서 바뀌는 것은 이 객체가 알리지 않는다 — 화면이 따로 관찰한다.
    var gift: LeeoGiftStore? { store.gift }

    /// 팁(응원) 엔진. 권한과 상관없다. 상품 로드는 `gift` 처럼 화면이 따로 관찰한다.
    var tipJar: LeeoTipJar? { store.tipJar }

    func loadProducts() async {
        await store.loadProducts()
        if !store.products.isEmpty { UserDefaults.standard.set(true, forKey: Self.everSoldKey) }
    }

    // MARK: - 구매 · 복원

    /// 결제 시트를 띄울 창을 아는 SwiftUI 의 `purchase` 로 산다. 칸이 열렸으면 true.
    @discardableResult
    func purchase(_ product: Product, using action: PurchaseAction) async -> Bool {
        await store.purchase(product) { try await action($0) }
        return ownedTier >= (HantamPlan.tierByProduct[product.id] ?? .pro)
    }

    /// 구매 내역 복원
    func restorePurchases() async {
        await store.restore()
    }

    /// 권한 다시 읽기 (구독 졸업 등 LeeoKit 화면이 산 뒤).
    func checkSubscriptionStatus() async {
        await store.refreshEntitlements()
    }

    // MARK: - 구독 졸업

    /// 지금 살아 있는 구독. 없으면 nil (설정의 '평생으로 바꾸기' 줄을 세운다).
    func currentSubscription() async -> LeeoGraduation.Subscription? {
        await LeeoGraduation.currentSubscription(among: HantamPlan.subscriptionIDs)
    }

    /// 구독 6개월째 · 갱신 7일 전에 한 번씩 졸업가를 보일 때인가. 보이면 표시해 둔다.
    func takeGraduationOffer() async -> Bool {
        if store.products.isEmpty { await loadProducts() }
        guard !hasLifetimePro,
              product(AppConfig.proGraduateProductID) != nil,
              let sub = await currentSubscription(),
              LeeoGraduation.isDue(sub, lastOffered: LeeoGraduation.lastOffered()) else { return false }
        LeeoGraduation.markOffered()
        return true
    }

    /// 평생 Pro 를 이미 가졌는가 (그러면 졸업을 권하지 않는다).
    private var hasLifetimePro: Bool {
        store.isGrandfathered || !store.purchasedProductIDs.isDisjoint(with: [
            AppConfig.lifetimeProductID, AppConfig.proUpgradeProductID, AppConfig.proGraduateProductID, AppConfig.premiumVersion
        ])
    }

    // MARK: - 유료 다운로드 시절 구매자

    /// 앱을 돈 내고 받았던 사람인가 — 처음 받은 빌드가 유료 시절(`AppConfig.lastPaidDownloadBuild` 이하)이면.
    /// 실제 App Store 에서 받은 것만 본다(TestFlight · Xcode 의 시험 영수증으로 Pro 가 열리지 않게).
    static func boughtPaidDownload() async -> Bool {
        guard let result = try? await AppTransaction.shared,
              case .verified(let app) = result,
              app.environment == .production,
              let build = Int(app.originalAppVersion.trimmingCharacters(in: .whitespaces)) else { return false }
        return build <= AppConfig.lastPaidDownloadBuild
    }

    private static let thankedKey = "hantam.plan.thankedPaidDownload"

    /// 앱을 샀던 사람에게 '이제 무료가 됐고 Pro 는 평생 당신 것' 이라고 한 번 알릴 때인가.
    var owesPaidDownloadThanks: Bool {
        store.isGrandfathered && !UserDefaults.standard.bool(forKey: Self.thankedKey)
    }

    func markPaidDownloadThanked() {
        UserDefaults.standard.set(true, forKey: Self.thankedKey)
    }
}
