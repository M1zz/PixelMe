//
//  PurchaseManager.swift
//  PixelMe
//
//  Created by Claude on 2026/01/20.
//  StoreKit 2.0 In-App Purchase Manager
//

import StoreKit
import SwiftUI

/// Manages all in-app purchases using StoreKit 2.0
@MainActor
class PurchaseManager: ObservableObject {

    // MARK: - Published Properties

    /// Available products for purchase
    @Published private(set) var products: [Product] = []

    /// Premium purchase status
    @Published private(set) var isPremiumUser: Bool = false

    /// Loading state
    @Published private(set) var isLoading: Bool = false

    /// Error message
    @Published var errorMessage: String?

    // MARK: - Private Properties

    /// Product ID for premium version
    private let premiumProductID = AppConfig.premiumVersion

    /// Transaction update listener task
    private var updateListenerTask: Task<Void, Error>?

    // MARK: - Singleton

    static let shared = PurchaseManager()

    // MARK: - Initialization

    private init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()

        // Load products and check purchase status
        Task {
            await loadProducts()
            await checkPurchaseStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Product Management

    /// Load available products from App Store
    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            // Fetch products from App Store
            let products = try await Product.products(for: [premiumProductID])

            // Update products on main thread
            self.products = products.sorted { $0.price < $1.price }

            print("✅ [PurchaseManager] Loaded \(products.count) product(s)")
            for product in products {
                print("  📦 \(product.displayName): \(product.displayPrice)")
            }
        } catch {
            print("❌ [PurchaseManager] Failed to load products: \(error.localizedDescription)")
            errorMessage = "Failed to load products. Please try again."
        }

        isLoading = false
    }

    /// Get the premium product
    func getPremiumProduct() -> Product? {
        return products.first { $0.id == premiumProductID }
    }

    // MARK: - Purchase Flow

    /// Purchase the premium version
    func purchasePremium() async -> Bool {
        guard let product = getPremiumProduct() else {
            print("❌ [PurchaseManager] Premium product not found")
            errorMessage = "Product not available. Please try again later."
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
            // Start purchase
            print("🛒 [PurchaseManager] Starting purchase for \(product.displayName)")
            let result = try await product.purchase()

            // Handle purchase result
            switch result {
            case .success(let verification):
                // Verify the transaction
                let transaction = try checkVerified(verification)

                // Update purchase status
                await updatePurchaseStatus()

                // Finish the transaction
                await transaction.finish()

                print("✅ [PurchaseManager] Purchase successful!")
                isLoading = false
                return true

            case .userCancelled:
                print("⚠️ [PurchaseManager] User cancelled purchase")
                errorMessage = nil // Don't show error for user cancellation
                isLoading = false
                return false

            case .pending:
                print("⏳ [PurchaseManager] Purchase pending approval")
                errorMessage = "Purchase is pending approval. Please check back later."
                isLoading = false
                return false

            @unknown default:
                print("❌ [PurchaseManager] Unknown purchase result")
                errorMessage = "An unexpected error occurred. Please try again."
                isLoading = false
                return false
            }
        } catch {
            print("❌ [PurchaseManager] Purchase failed: \(error.localizedDescription)")
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }

    // MARK: - Restore Purchases

    /// Restore previous purchases
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil

        print("🔄 [PurchaseManager] Restoring purchases...")

        do {
            // Sync with App Store
            try await AppStore.sync()

            // Check purchase status
            await checkPurchaseStatus()

            if isPremiumUser {
                print("✅ [PurchaseManager] Purchases restored successfully")
            } else {
                print("⚠️ [PurchaseManager] No purchases to restore")
                errorMessage = "No previous purchases found."
            }
        } catch {
            print("❌ [PurchaseManager] Restore failed: \(error.localizedDescription)")
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Transaction Verification

    /// Check if user has purchased premium
    func checkPurchaseStatus() async {
        var hasPremium = false

        // Check all transactions
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                // Check if this is the premium product
                if transaction.productID == premiumProductID {
                    hasPremium = true
                    print("✅ [PurchaseManager] Found valid premium purchase")
                    break
                }
            } catch {
                print("❌ [PurchaseManager] Transaction verification failed: \(error)")
            }
        }

        // Update premium status
        isPremiumUser = hasPremium

        // Sync with UserDefaults for backward compatibility
        UserDefaults.standard.set(hasPremium, forKey: AppConfig.premiumVersion)

        print("📊 [PurchaseManager] Premium status: \(isPremiumUser)")
    }

    /// Update purchase status after successful purchase
    private func updatePurchaseStatus() async {
        await checkPurchaseStatus()
    }

    /// Verify a transaction is valid
    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            // Transaction failed verification
            throw error
        case .verified(let safe):
            // Transaction is verified
            return safe
        }
    }

    // MARK: - Transaction Listener

    /// Listen for transaction updates
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Iterate through any transactions that don't come from a direct call to purchase()
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)

                    // Deliver content to the user
                    await self.updatePurchaseStatus()

                    // Always finish a transaction
                    await transaction.finish()

                    print("✅ [PurchaseManager] Transaction update processed")
                } catch {
                    print("❌ [PurchaseManager] Transaction update failed: \(error)")
                }
            }
        }
    }

    // MARK: - Helper Methods

    /// Get formatted price for premium product
    func getPremiumPrice() -> String {
        guard let product = getPremiumProduct() else {
            return "$4.99" // Fallback price
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
                        } else if let error = purchaseManager.errorMessage {
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
                        if let error = purchaseManager.errorMessage {
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
