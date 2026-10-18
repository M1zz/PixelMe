//
//  SubscriptionManager.swift
//  Hantam
//
//  Created by Claude on 2026/02/25.
//  StoreKit 2.0 기반 구독 시스템 관리자 — LeeoKit 파사드
//
//  StoreKit 2 엔진(상품 로드·구매·복원·권한 추적·트랜잭션 리스너·오프라인 캐시)은
//  이제 LeeoKit 의 LeeoStore 가 공용으로 담당한다. 이 파일은 그 위에 앱 고유의
//  공개 API(플랜별 가격 헬퍼, 기능 접근 판정, 레거시 UserDefaults 미러)를 얹은
//  얇은 파사드로, 결제 화면 · FeatureGating · 도안 화면이 Pro 여부를 여기서만 묻는다.
//
//  권한 규칙(기존 checkSubscriptionStatus 와 동치):
//   - 주간/월간/연간 구독이 활성(currentEntitlements) 이거나
//   - 평생 상품을 보유했거나
//   - 레거시 일회성 구매(PixelNFT.Premium)를 보유하면  → Pro
//  위 규칙은 HantamSpec.paywall 의 entitlementIDs 로 표현된다.
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
        store = LeeoStore(config: HantamSpec.paywall!)

        // 공용 스토어 상태 변화를 뷰에 전파한다.
        cancellable = store.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }

        // 상품 로드 (LeeoStore.init 은 상품을 자동 로드하지 않는다).
        Task { await store.loadProducts() }
    }

    // MARK: - Product Management

    /// 판매 상품 (월간 < 연간 < 평생 — Spec.productIDs 순서를 그대로 따른다)
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

    /// 월간 구독 가격 반환
    func getMonthlyPrice() -> String {
        #if DEBUG
        if let p = ScreenshotScene.reviewPrice("monthly") { return p }
        #endif
        return getMonthlyProduct()?.displayPrice ?? "₩4,900"
    }

    /// 연간 구독 가격 반환
    func getYearlyPrice() -> String {
        #if DEBUG
        if let p = ScreenshotScene.reviewPrice("yearly") { return p }
        #endif
        return getYearlyProduct()?.displayPrice ?? "₩29,900"
    }

    /// 평생 구매 가격 반환
    func getLifetimePrice() -> String {
        #if DEBUG
        if let p = ScreenshotScene.reviewPrice("lifetime") { return p }
        #endif
        return getLifetimeProduct()?.displayPrice ?? "₩59,000"
    }

    /// 연간 구독의 월 환산 가격 반환
    func getYearlyMonthlyPrice() -> String {
        #if DEBUG
        if let p = ScreenshotScene.reviewPrice("yearlyMonthly") { return p }
        #endif
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

}

// MARK: - Feature Access Enum

/// Feature access level
enum FeatureAccess {
    case free   // Free user
    case pro    // Premium subscriber
}
