//
//  PurchaseManager.swift
//  PixelMe
//
//  Created by Claude on 2026/01/20.
//  StoreKit 2.0 In-App Purchase Manager
//

import StoreKit
import SwiftUI

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

/// Manages all in-app purchases using StoreKit 2.0
@MainActor
class PurchaseManager: ObservableObject {

    // MARK: - Constants

    /// Maximum number of retry attempts for failed operations
    private static let maxRetryAttempts = 3

    /// Base delay for exponential backoff (in nanoseconds)
    private static let baseRetryDelay: UInt64 = 1_000_000_000 // 1 second

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

    // MARK: - Retry Logic

    /// Execute an async operation with exponential backoff retry
    private func withRetry<T>(
        maxAttempts: Int = PurchaseManager.maxRetryAttempts,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var lastError: Error?

        for attempt in 0..<maxAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error

                // Don't retry on user cancellation or verification failures
                if error is StoreKit.Product.PurchaseError {
                    throw error
                }

                // Don't retry on last attempt
                if attempt < maxAttempts - 1 {
                    let delay = Self.baseRetryDelay * UInt64(pow(2.0, Double(attempt)))
                    print("⏳ [PurchaseManager] Retry \(attempt + 1)/\(maxAttempts) after \(delay / 1_000_000_000)s...")
                    try await Task.sleep(nanoseconds: delay)
                }
            }
        }

        throw lastError ?? PurchaseError.maxRetriesExceeded
    }

    // MARK: - Product Management

    /// Load available products from App Store
    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            let products = try await withRetry {
                try await Product.products(for: [self.premiumProductID])
            }

            self.products = products.sorted { $0.price < $1.price }

            print("✅ [PurchaseManager] Loaded \(products.count) product(s)")
            for product in products {
                print("  📦 \(product.displayName): \(product.displayPrice)")
            }
        } catch {
            print("❌ [PurchaseManager] Failed to load products: \(error.localizedDescription)")
            errorMessage = PurchaseError.networkError.errorDescription
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
            errorMessage = PurchaseError.productNotFound.errorDescription
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
            // Start purchase (no retry on the purchase call itself — StoreKit handles this)
            print("🛒 [PurchaseManager] Starting purchase for \(product.displayName)")
            let result = try await product.purchase()

            // Handle purchase result
            switch result {
            case .success(let verification):
                do {
                    let transaction = try checkVerified(verification)
                    await updatePurchaseStatus()
                    await transaction.finish()
                    print("✅ [PurchaseManager] Purchase successful!")
                    isLoading = false
                    return true
                } catch {
                    print("❌ [PurchaseManager] Verification failed: \(error)")
                    errorMessage = PurchaseError.verificationFailed.errorDescription
                    isLoading = false
                    return false
                }

            case .userCancelled:
                print("⚠️ [PurchaseManager] User cancelled purchase")
                errorMessage = nil
                isLoading = false
                return false

            case .pending:
                print("⏳ [PurchaseManager] Purchase pending approval")
                errorMessage = NSLocalizedString("Purchase is pending approval. Please check back later.", comment: "")
                isLoading = false
                return false

            @unknown default:
                print("❌ [PurchaseManager] Unknown purchase result")
                errorMessage = PurchaseError.unknown.errorDescription
                isLoading = false
                return false
            }
        } catch {
            print("❌ [PurchaseManager] Purchase failed: \(error.localizedDescription)")
            errorMessage = PurchaseError.purchaseFailed(underlying: error).errorDescription
            isLoading = false
            return false
        }
    }

    // MARK: - Restore Purchases

    /// Restore previous purchases with retry logic
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil

        print("🔄 [PurchaseManager] Restoring purchases...")

        do {
            try await withRetry {
                try await AppStore.sync()
            }

            await checkPurchaseStatus()

            if isPremiumUser {
                print("✅ [PurchaseManager] Purchases restored successfully")
            } else {
                print("⚠️ [PurchaseManager] No purchases to restore")
                errorMessage = NSLocalizedString("No previous purchases found.", comment: "")
            }
        } catch {
            print("❌ [PurchaseManager] Restore failed: \(error.localizedDescription)")
            errorMessage = PurchaseError.restoreFailed(underlying: error).errorDescription
        }

        isLoading = false
    }

    // MARK: - Transaction Verification

    /// Check if user has purchased premium
    func checkPurchaseStatus() async {
        var hasPremium = false

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                if transaction.productID == premiumProductID {
                    hasPremium = true
                    print("✅ [PurchaseManager] Found valid premium purchase")
                    break
                }
            } catch {
                print("❌ [PurchaseManager] Transaction verification failed: \(error)")
            }
        }

        isPremiumUser = hasPremium
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
            throw error
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Transaction Listener

    /// Listen for transaction updates
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updatePurchaseStatus()
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
