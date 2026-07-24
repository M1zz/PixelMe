//
//  SubscriptionManager.swift
//  PixelMe
//
//  Created by Claude on 2026/02/25.
//  StoreKit 2.0 기반 구독 시스템 관리자 — LeeoKit 파사드
//
//  StoreKit 2 엔진(상품 로드·구매·복원·권한 추적·트랜잭션 리스너·오프라인 캐시)은
//  이제 LeeoKit 의 LeeoStore 가 공용으로 담당한다. 이 파일은 그 위에 앱 고유의
//  공개 API(플랜별 가격 헬퍼, 기능 접근 판정, 레거시 UserDefaults 미러)를 얹은
//  얇은 파사드로, 기존 호출부(PaywallView / ExportPaywallView / PreviewWallView /
//  FeatureGating / FreeUsageManager / DataManager 등)는 그대로 동작한다.
//
//  권한 규칙(기존 checkSubscriptionStatus 와 동치):
//   - 주간/월간/연간 구독이 활성(currentEntitlements) 이거나
//   - 평생 상품을 보유했거나
//   - 레거시 일회성 구매(PixelNFT.Premium)를 보유하면  → Pro
//  위 규칙은 PixelMeSpec.paywall 의 entitlementIDs 로 표현된다.
//

import StoreKit
import SwiftUI
import Combine
import LeeoKit

/// StoreKit 2.0 기반 구독 시스템 관리자 (LeeoStore 파사드)
@MainActor
class SubscriptionManager: ObservableObject {

    // MARK: - Private Properties

    /// 공용 StoreKit 엔진 (엔타이틀먼트: 구독/평생/레거시 프리미엄)
    private let store: LeeoStore
    private var cancellable: AnyCancellable?

    /// 구독 상품 ID들 (표시 순서 정렬용)
    private let weeklyProductID = AppConfig.weeklyProductID
    private let monthlyProductID = AppConfig.monthlyProductID
    private let yearlyProductID = AppConfig.yearlyProductID
    private let lifetimeProductID = AppConfig.lifetimeProductID

    // MARK: - Published Properties

    /// 에러 메시지 (뷰에서 설정/해제 가능하도록 stored 유지)
    @Published var errorMessage: String?

    // MARK: - Singleton

    static let shared = SubscriptionManager()

    // MARK: - Initialization

    private init() {
        store = LeeoStore(config: PixelMeSpec.paywall!)

        // 공용 스토어 상태 변화를 뷰에 전파하고, 레거시 UserDefaults 미러를 갱신한다.
        cancellable = store.objectWillChange.sink { [weak self] in
            guard let self else { return }
            self.objectWillChange.send()
            // objectWillChange 는 변경 "직전"에 발화하므로, 반영된 값을 읽기 위해 한 틱 뒤에 미러한다.
            DispatchQueue.main.async { self.mirrorProState() }
        }

        // 상품 로드 (LeeoStore.init 은 상품을 자동 로드하지 않는다).
        Task { await store.loadProducts() }
    }

    // MARK: - Product Management

    /// 사용 가능한 구독 상품들 (주간 < 월간 < 연간 < 평생 순서 — Spec.productIDs 순서를 그대로 따른다)
    var subscriptionProducts: [Product] { store.products }

    /// 프리미엄 구독 상태
    var isProUser: Bool { store.hasPro }

    /// 현재 활성 구독 상품 (보유 중인 상품 중 표시 우선순위가 가장 높은 것)
    var currentSubscription: Product? {
        store.products.first { store.purchasedProductIDs.contains($0.id) }
    }

    /// 로딩/구매/복원 진행 상태
    var isLoading: Bool {
        store.isLoadingProducts || store.purchasingProductID != nil || store.isRestoring
    }

    /// App Store에서 사용 가능한 구독 상품들을 로드
    func loadProducts() async {
        await store.loadProducts()
    }

    /// 주간 구독 상품 반환
    func getWeeklyProduct() -> Product? {
        return subscriptionProducts.first { $0.id == weeklyProductID }
    }

    /// 월간 구독 상품 반환
    func getMonthlyProduct() -> Product? {
        return subscriptionProducts.first { $0.id == monthlyProductID }
    }

    /// 연간 구독 상품 반환
    func getYearlyProduct() -> Product? {
        return subscriptionProducts.first { $0.id == yearlyProductID }
    }

    /// 평생 구매 상품 반환
    func getLifetimeProduct() -> Product? {
        return subscriptionProducts.first { $0.id == lifetimeProductID }
    }

    // MARK: - Subscription Management

    /// 구독 상품 구매
    @discardableResult
    func purchaseSubscription(_ product: Product) async -> Bool {
        errorMessage = nil
        let success = await store.purchase(product)
        if !success { errorMessage = store.lastError }
        return success
    }

    /// 구매 내역 복원
    func restorePurchases() async {
        errorMessage = nil
        await store.restore()
        if !isProUser {
            // 복원했지만 구매가 없을 때만 안내 (실패 메시지가 이미 있으면 그대로 둔다).
            errorMessage = store.lastError ?? "No previous purchases found."
        }
    }

    // MARK: - Subscription Status

    /// 구독 상태 확인 (공용 스토어에 위임)
    func checkSubscriptionStatus() async {
        await store.refreshEntitlements()
        mirrorProState()
    }

    // MARK: - Legacy Mirror

    private let cachedProStatusKey = "SubscriptionManager.cachedProStatus"
    private let cachedProDateKey = "SubscriptionManager.cachedProDate"

    /// Pro 상태를 기존 코드가 읽는 레거시 저장소에 반영한다.
    /// - UserDefaults[AppConfig.premiumVersion]: DataManager 의 @AppStorage, ExportManager, DataManager 가 직접 읽음.
    /// - cachedProStatus/Date: 과거 오프라인 캐시 키 (연속성 유지).
    private func mirrorProState() {
        let pro = store.hasPro
        UserDefaults.standard.set(pro, forKey: AppConfig.premiumVersion)
        UserDefaults.standard.set(pro, forKey: cachedProStatusKey)
        UserDefaults.standard.set(Date(), forKey: cachedProDateKey)
    }

    // MARK: - Feature Access

    /// 특정 기능에 대한 접근 권한 확인
    func hasAccess(to feature: FeatureAccess) -> Bool {
        switch feature {
        case .free:
            return true
        case .pro:
            return isProUser
        }
    }

    // MARK: - Helper Methods

    /// 주간 구독 가격 반환
    func getWeeklyPrice() -> String {
        return getWeeklyProduct()?.displayPrice ?? "₩2,500"
    }

    /// 월간 구독 가격 반환
    func getMonthlyPrice() -> String {
        return getMonthlyProduct()?.displayPrice ?? "₩6,900"
    }

    /// 연간 구독 가격 반환
    func getYearlyPrice() -> String {
        return getYearlyProduct()?.displayPrice ?? "₩29,900"
    }

    /// 평생 구매 가격 반환
    func getLifetimePrice() -> String {
        return getLifetimeProduct()?.displayPrice ?? "₩89,000"
    }

    /// 연간 구독의 주당 환산 가격 반환
    func getYearlyWeeklyPrice() -> String {
        guard let yearlyProduct = getYearlyProduct() else { return "₩575" }

        let yearlyPrice = yearlyProduct.price
        let weeklyPrice = yearlyPrice / 52

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = yearlyProduct.priceFormatStyle.locale

        return formatter.string(from: weeklyPrice as NSNumber) ?? "₩575"
    }

    /// 연간 구독의 월 환산 가격 반환
    func getYearlyMonthlyPrice() -> String {
        guard let yearlyProduct = getYearlyProduct() else { return "₩2,492" }

        let yearlyPrice = yearlyProduct.price
        let monthlyPrice = yearlyPrice / 12

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = yearlyProduct.priceFormatStyle.locale

        return formatter.string(from: monthlyPrice as NSNumber) ?? "₩2,492"
    }

    /// 상품들이 로드되었는지 확인
    var hasLoadedProducts: Bool {
        return !subscriptionProducts.isEmpty
    }

    /// 기존 PurchaseManager 호환성 유지
    var isPremiumUser: Bool {
        return isProUser
    }
}

// MARK: - Feature Access Enum

/// Feature access level
enum FeatureAccess {
    case free   // Free user
    case pro    // Premium subscriber
}
