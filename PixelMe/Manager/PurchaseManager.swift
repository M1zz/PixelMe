//
//  PurchaseManager.swift
//  PixelMe
//
//  Created by Claude on 2026/01/20.
//  StoreKit 2.0 In-App Purchase Manager
//

import StoreKit
import SwiftUI
import Combine
import LeeoKit

// MARK: - Purchase Error Types

/// User-friendly purchase error descriptions
enum PurchaseError: LocalizedError {
    case productNotFound
    case purchaseFailed(underlying: Error)
    case verificationFailed
    case networkError
    case restoreFailed(underlying: Error)
    case maxRetriesExceeded
    case unknown

    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return NSLocalizedString("Product not available. Please try again later.", comment: "")
        case .purchaseFailed(let error):
            if (error as NSError).domain == NSURLErrorDomain {
                return NSLocalizedString("Network error. Please check your connection and try again.", comment: "")
            }
            return NSLocalizedString("Purchase failed. Please try again.", comment: "")
        case .verificationFailed:
            return NSLocalizedString("Could not verify purchase. Please contact support.", comment: "")
        case .networkError:
            return NSLocalizedString("Network error. Please check your connection and try again.", comment: "")
        case .restoreFailed:
            return NSLocalizedString("Failed to restore purchases. Please check your connection and try again.", comment: "")
        case .maxRetriesExceeded:
            return NSLocalizedString("Operation failed after multiple attempts. Please try again later.", comment: "")
        case .unknown:
            return NSLocalizedString("An unexpected error occurred. Please try again.", comment: "")
        }
    }
}

/// Manages all in-app purchases using StoreKit 2.0 — LeeoKit 파사드
///
/// 레거시 일회성 프리미엄(`PixelNFT.Premium`) 전용 매니저. StoreKit 2 플러밍은 공용
/// LeeoStore 로 위임한다. 현재 앱의 Pro 판정은 SubscriptionManager 가 담당하며, 이 매니저는
/// 하위 호환(PremiumPurchaseButton 등)을 위해 API/동작을 그대로 유지한다.
@MainActor
class PurchaseManager: ObservableObject {

    // MARK: - Published Properties

    /// Error message
    @Published var errorMessage: String?

    // MARK: - Private Properties

    /// Product ID for premium version
    private let premiumProductID = AppConfig.premiumVersion

    /// 공용 StoreKit 엔진 (레거시 프리미엄 비소비성 상품 전용)
    private let store: LeeoStore
    private var cancellable: AnyCancellable?

    // MARK: - Singleton

    static let shared = PurchaseManager()

    // MARK: - Initialization

    private init() {
        store = LeeoStore(config: LeeoPaywallConfig(
            productIDs: [AppConfig.premiumVersion],
            autoLoad: false,
            cacheSuiteName: "com.pixelme.leeostore.premium"
        ))

        cancellable = store.objectWillChange.sink { [weak self] in
            guard let self else { return }
            self.objectWillChange.send()
            DispatchQueue.main.async { self.mirrorPremiumState() }
        }

        Task { await store.loadProducts() }
    }

    // MARK: - Published Accessors

    /// Available products for purchase
    var products: [Product] { store.products }

    /// Premium purchase status
    var isPremiumUser: Bool { store.hasPro }

    /// Loading state
    var isLoading: Bool {
        store.isLoadingProducts || store.purchasingProductID != nil || store.isRestoring
    }

    // MARK: - Product Management

    /// Load available products from App Store
    func loadProducts() async {
        await store.loadProducts()
        if store.products.isEmpty {
            errorMessage = PurchaseError.networkError.errorDescription
        }
    }

    /// Get the premium product
    func getPremiumProduct() -> Product? {
        return store.products.first { $0.id == premiumProductID }
    }

    // MARK: - Purchase Flow

    /// Purchase the premium version
    func purchasePremium() async -> Bool {
        guard let product = getPremiumProduct() else {
            print("❌ [PurchaseManager] Premium product not found")
            errorMessage = PurchaseError.productNotFound.errorDescription
            return false
        }

        errorMessage = nil
        let success = await store.purchase(product)
        if !success { errorMessage = store.lastError }
        return success
    }

    // MARK: - Restore Purchases

    /// Restore previous purchases
    func restorePurchases() async {
        errorMessage = nil
        await store.restore()
        mirrorPremiumState()
        if !isPremiumUser {
            errorMessage = store.lastError ?? NSLocalizedString("No previous purchases found.", comment: "")
        }
    }

    // MARK: - Purchase Status

    /// Check if user has purchased premium (공용 스토어에 위임)
    func checkPurchaseStatus() async {
        await store.refreshEntitlements()
        mirrorPremiumState()
    }

    /// 레거시 프리미엄 상태를 기존 코드가 읽는 UserDefaults 키에 반영한다.
    private func mirrorPremiumState() {
        UserDefaults.standard.set(store.hasPro, forKey: AppConfig.premiumVersion)
    }

    // MARK: - Helper Methods

    /// Get formatted price for premium product
    func getPremiumPrice() -> String {
        guard let product = getPremiumProduct() else {
            return "$4.99"
        }
        return product.displayPrice
    }

    /// Get premium product display name
    func getPremiumDisplayName() -> String {
        guard let product = getPremiumProduct() else {
            return "Premium Version"
        }
        return product.displayName
    }

    /// Get premium product description
    func getPremiumDescription() -> String {
        guard let product = getPremiumProduct() else {
            return "Unlock all 8 premium features"
        }
        return product.description
    }

    /// Check if products are loaded
    var hasLoadedProducts: Bool {
        return !products.isEmpty
    }
}

// MARK: - Purchase Button View

/// Premium purchase button with loading state
struct PremiumPurchaseButton: View {
    @ObservedObject var purchaseManager = PurchaseManager.shared
    @State private var showingError = false
    @Binding var isPremiumUser: Bool

    var body: some View {
        VStack(spacing: 15) {
            if purchaseManager.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                Text("Processing...")
                    .foregroundColor(.white)
            } else if purchaseManager.isPremiumUser {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    Text("Premium Active")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            } else {
                Button {
                    Task {
                        let success = await purchaseManager.purchasePremium()
                        if success {
                            isPremiumUser = true
                        } else if purchaseManager.errorMessage != nil {
                            showingError = true
                        }
                    }
                } label: {
                    VStack(spacing: 8) {
                        Text("Unlock Premium")
                            .font(.system(size: 20, weight: .bold))

                        if purchaseManager.hasLoadedProducts {
                            Text(purchaseManager.getPremiumPrice())
                                .font(.system(size: 16, weight: .semibold))
                        } else {
                            Text("Loading...")
                                .font(.system(size: 16))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(AppConfig.continueButtonColor))
                    )
                }
                .disabled(!purchaseManager.hasLoadedProducts)

                Button {
                    Task {
                        await purchaseManager.restorePurchases()
                        isPremiumUser = purchaseManager.isPremiumUser
                        if purchaseManager.errorMessage != nil {
                            showingError = true
                        }
                    }
                } label: {
                    Text("Restore Purchases")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 20)
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {
                purchaseManager.errorMessage = nil
            }
        } message: {
            Text(purchaseManager.errorMessage ?? "An unknown error occurred")
        }
    }
}
