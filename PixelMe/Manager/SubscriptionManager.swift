//
//  SubscriptionManager.swift
//  PixelMe
//
//  Created by Claude on 2026/02/25.
//  StoreKit 2.0 기반 구독 시스템 관리자
//

import StoreKit
import SwiftUI

/// StoreKit 2.0 기반 구독 시스템 관리자
@MainActor
class SubscriptionManager: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 사용 가능한 구독 상품들
    @Published private(set) var subscriptionProducts: [Product] = []
    
    /// 프리미엄 구독 상태
    @Published private(set) var isProUser: Bool = false
    
    /// 현재 구독 상품
    @Published private(set) var currentSubscription: Product?
    
    /// 로딩 상태
    @Published private(set) var isLoading: Bool = false
    
    /// 에러 메시지
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    /// 구독 상품 ID들
    private let monthlyProductID = AppConfig.monthlyProductID
    private let yearlyProductID = AppConfig.yearlyProductID
    private let lifetimeProductID = AppConfig.lifetimeProductID
    
    /// Transaction update listener task
    private var updateListenerTask: Task<Void, Error>?
    
    // MARK: - Singleton
    
    static let shared = SubscriptionManager()
    
    // MARK: - Initialization
    
    private init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
        
        // Load products and check subscription status
        Task {
            await loadProducts()
            await checkSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Management
    
    /// App Store에서 사용 가능한 구독 상품들을 로드
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let productIDs = [monthlyProductID, yearlyProductID, lifetimeProductID]
            let products = try await Product.products(for: productIDs)
            
            // 상품을 가격 순으로 정렬 (월간 < 연간 < 평생)
            self.subscriptionProducts = products.sorted { product1, product2 in
                if product1.id == monthlyProductID { return true }
                if product2.id == monthlyProductID { return false }
                if product1.id == yearlyProductID { return true }
                if product2.id == yearlyProductID { return false }
                return false
            }
            
            print("✅ [SubscriptionManager] 로드된 구독 상품 \(products.count)개")
            for product in subscriptionProducts {
                print("  📦 \(product.displayName): \(product.displayPrice)")
            }
        } catch {
            print("❌ [SubscriptionManager] 상품 로드 실패: \(error.localizedDescription)")
            errorMessage = "Failed to load products. Please try again."
        }
        
        isLoading = false
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
    func purchaseSubscription(_ product: Product) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            print("🛒 [SubscriptionManager] 구독 시작: \(product.displayName)")
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                
                // 구독 상태 업데이트
                await updateSubscriptionStatus()
                
                // Transaction 완료 처리
                await transaction.finish()
                
                print("✅ [SubscriptionManager] 구독 성공!")
                isLoading = false
                return true
                
            case .userCancelled:
                print("⚠️ [SubscriptionManager] 사용자가 취소함")
                errorMessage = nil
                isLoading = false
                return false
                
            case .pending:
                print("⏳ [SubscriptionManager] 구독 승인 대기 중")
                errorMessage = "Waiting for subscription approval. Please check again later."
                isLoading = false
                return false
                
            @unknown default:
                print("❌ [SubscriptionManager] 알 수 없는 구매 결과")
                errorMessage = "An unexpected error occurred. Please try again."
                isLoading = false
                return false
            }
        } catch {
            print("❌ [SubscriptionManager] 구독 실패: \(error.localizedDescription)")
            errorMessage = "Subscription failed: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    /// 구매 내역 복원
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        print("🔄 [SubscriptionManager] 구매 내역 복원 중...")
        
        do {
            // App Store와 동기화
            try await AppStore.sync()
            
            // 구독 상태 확인
            await checkSubscriptionStatus()
            
            if isProUser {
                print("✅ [SubscriptionManager] 구매 내역 복원 성공")
            } else {
                print("⚠️ [SubscriptionManager] 복원할 구매 내역이 없음")
                errorMessage = "No previous purchases found."
            }
        } catch {
            print("❌ [SubscriptionManager] 복원 실패: \(error.localizedDescription)")
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Subscription Status
    
    /// 구독 상태 확인
    func checkSubscriptionStatus() async {
        var hasActiveSubscription = false
        var activeProduct: Product?
        
        // 현재 활성 구독 확인
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // 기존 일회성 구매(PixelNFT.Premium) → 평생 Pro로 인정
                if transaction.productID == AppConfig.premiumVersion {
                    hasActiveSubscription = true
                    activeProduct = getLifetimeProduct()
                    print("✅ [SubscriptionManager] 기존 구매자 감지 → 평생 Pro 적용")
                    break
                }
                
                // 새 구독 상품 확인
                if [monthlyProductID, yearlyProductID, lifetimeProductID].contains(transaction.productID) {
                    // 평생 구매는 항상 활성
                    if transaction.productID == lifetimeProductID {
                        hasActiveSubscription = true
                        activeProduct = getLifetimeProduct()
                        break
                    }
                    
                    // 구독의 경우 만료일 확인
                    if let expirationDate = transaction.expirationDate {
                        if expirationDate > Date() {
                            hasActiveSubscription = true
                            activeProduct = subscriptionProducts.first { $0.id == transaction.productID }
                        }
                    }
                }
            } catch {
                print("❌ [SubscriptionManager] Transaction 검증 실패: \(error)")
            }
        }
        
        // 상태 업데이트
        isProUser = hasActiveSubscription
        currentSubscription = activeProduct
        
        // UserDefaults 동기화 (기존 코드 호환성)
        UserDefaults.standard.set(hasActiveSubscription, forKey: AppConfig.premiumVersion)
        
        print("📊 [SubscriptionManager] 프리미엄 상태: \(isProUser)")
        if let subscription = currentSubscription {
            print("📊 [SubscriptionManager] 현재 구독: \(subscription.displayName)")
        }
    }
    
    /// 구독 상태 업데이트 (구매 후)
    private func updateSubscriptionStatus() async {
        await checkSubscriptionStatus()
    }
    
    /// Transaction 검증
    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Transaction Listener
    
    /// Transaction 업데이트 감지
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    // 구독 상태 업데이트
                    await self.updateSubscriptionStatus()
                    
                    // Transaction 완료
                    await transaction.finish()
                    
                    print("✅ [SubscriptionManager] Transaction 업데이트 처리 완료")
                } catch {
                    print("❌ [SubscriptionManager] Transaction 업데이트 실패: \(error)")
                }
            }
        }
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
        return getMonthlyProduct()?.displayPrice ?? "₩6,900"
    }
    
    /// 연간 구독 가격 반환
    func getYearlyPrice() -> String {
        return getYearlyProduct()?.displayPrice ?? "₩39,900"
    }
    
    /// 평생 구매 가격 반환
    func getLifetimePrice() -> String {
        return getLifetimeProduct()?.displayPrice ?? "₩79,900"
    }
    
    /// 연간 구독의 월 환산 가격 반환
    func getYearlyMonthlyPrice() -> String {
        guard let yearlyProduct = getYearlyProduct() else { return "₩3,325" }
        
        let yearlyPrice = yearlyProduct.price
        let monthlyPrice = yearlyPrice / 12
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = yearlyProduct.priceFormatStyle.locale
        
        return formatter.string(from: monthlyPrice as NSNumber) ?? "₩3,325"
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