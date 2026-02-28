//
//  PaywallView.swift
//  PixelMe
//
//  Created by Claude on 2026/02/25.
//  프리미엄 구독 시스템 Paywall
//

import SwiftUI
import StoreKit

/// 프리미엄 구독을 위한 Paywall 화면
struct PaywallView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @Binding var isProUser: Bool
    
    @State private var selectedPlan: SubscriptionPlan = .yearly
    @State private var showingError = false
    @State private var isProcessing = false
    
    var body: some View {
        ZStack {
            Color(AppConfig.backgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HeaderView
                    .padding(.top, 50)
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Title Section
                        TitleSection
                        
                        // Subscription Plans
                        SubscriptionPlansSection
                        
                        // Purchase Button
                        PurchaseButtonSection
                        
                        // Features Comparison
                        FeaturesComparisonSection
                        
                        // Terms & Restore
                        BottomSection
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .onChange(of: isProUser) { newValue in
            if newValue {
                // 구독 성공 시 Paywall 닫기
                DispatchQueue.main.asyncAfter(deadline: .now() + AppConfig.subscriptionSuccessDelay) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {
                subscriptionManager.errorMessage = nil
            }
        } message: {
            Text(subscriptionManager.errorMessage ?? "An unknown error occurred")
        }
    }
    
    // MARK: - Header
    
    private var HeaderView: some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 22))
            }
            
            Spacer()
            
            Text("PixelMe Pro")
                .font(.system(size: 20, weight: .bold))
            
            Spacer()
            
            // Invisible spacer for center alignment
            Image(systemName: "xmark")
                .font(.system(size: 22))
                .opacity(0)
        }
        .padding(.horizontal)
        .foregroundColor(.white)
    }
    
    // MARK: - Title Section
    
    private var TitleSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Unlock Pro Features")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Create professional-level pixel art")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Subscription Plans Section
    
    private var SubscriptionPlansSection: some View {
        VStack(spacing: 15) {
            Text("Choose Your Plan")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 10)
            
            // Monthly Plan
            PlanOptionView(
                plan: .monthly,
                price: subscriptionManager.getMonthlyPrice(),
                isSelected: selectedPlan == .monthly
            ) {
                selectedPlan = .monthly
            }
            
            // Yearly Plan (Best Value)
            PlanOptionView(
                plan: .yearly,
                price: subscriptionManager.getYearlyPrice(),
                monthlyPrice: subscriptionManager.getYearlyMonthlyPrice(),
                badge: "Best Value",
                isSelected: selectedPlan == .yearly
            ) {
                selectedPlan = .yearly
            }
            
            // Lifetime Plan (Limited)
            PlanOptionView(
                plan: .lifetime,
                price: subscriptionManager.getLifetimePrice(),
                badge: "Limited Time",
                badgeColor: .purple,
                isSelected: selectedPlan == .lifetime
            ) {
                selectedPlan = .lifetime
            }
        }
    }
    
    // MARK: - Purchase Button Section
    
    private var PurchaseButtonSection: some View {
        VStack(spacing: 15) {
            if subscriptionManager.isLoading || isProcessing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                Text("Processing...")
                    .foregroundColor(.white)
            } else if subscriptionManager.isProUser {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    Text("Pro Subscription Active")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            } else {
                Button {
                    Task {
                        await purchaseSelectedPlan()
                    }
                } label: {
                    VStack(spacing: 8) {
                        if selectedPlan == .lifetime {
                            Text("Purchase Lifetime")
                                .font(.system(size: 20, weight: .bold))
                        } else {
                            Text("Start 3-Day Free Trial")
                                .font(.system(size: 20, weight: .bold))
                        }
                        
                        Text(selectedPlan.description)
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(AppConfig.continueButtonColor))
                    )
                }
                .disabled(!subscriptionManager.hasLoadedProducts)
                
                if selectedPlan != .lifetime {
                    Text("• After 3-day free trial: \(selectedPlan == .monthly ? subscriptionManager.getMonthlyPrice() : subscriptionManager.getYearlyPrice())")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
    
    // MARK: - Features Comparison Section
    
    private var FeaturesComparisonSection: some View {
        VStack(spacing: 20) {
            Text("Feature Comparison")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Feature")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Free")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 60)
                    
                    Text("Pro")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.yellow)
                        .frame(width: 60)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
                .background(Color(AppConfig.toolBackgroundColor))
                
                // Features
                FeatureComparisonRow(feature: "Pixelize", free: "Unlimited", pro: "Unlimited")
                FeatureComparisonRow(feature: "Pixel Size", free: "3 levels", pro: "6 levels")
                FeatureComparisonRow(feature: "Color Palette", free: "3", pro: "9")
                FeatureComparisonRow(feature: "Filter Effects", free: "1", pro: "6")
                FeatureComparisonRow(feature: "Dithering", free: "❌", pro: "✅")
                FeatureComparisonRow(feature: "Batch Processing", free: "❌", pro: "✅")
                FeatureComparisonRow(feature: "Create GIF", free: "❌", pro: "✅")
                FeatureComparisonRow(feature: "Layers", free: "❌", pro: "✅")
                FeatureComparisonRow(feature: "Export", free: "PNG, 1080p", pro: "PNG/SVG/PDF, 4K")
                FeatureComparisonRow(feature: "Watermark", free: "Yes", pro: "Removed")
                FeatureComparisonRow(feature: "Templates", free: "5", pro: "15+")
            }
            .background(Color.black.opacity(0.3))
            .cornerRadius(10)
        }
    }
    
    // MARK: - Bottom Section
    
    private var BottomSection: some View {
        VStack(spacing: 15) {
            Button {
                Task {
                    await subscriptionManager.restorePurchases()
                    isProUser = subscriptionManager.isProUser
                    if let error = subscriptionManager.errorMessage {
                        showingError = true
                    }
                }
            } label: {
                Text("Restore Purchases")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            
            VStack(spacing: 8) {
                Text("You can cancel your subscription anytime")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                HStack(spacing: 20) {
                    Button("Terms of Service") {
                        // Terms of Service link
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    
                    Button("Privacy Policy") {
                        // Privacy Policy link
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func purchaseSelectedPlan() async {
        isProcessing = true
        
        let product: Product?
        switch selectedPlan {
        case .monthly:
            product = subscriptionManager.getMonthlyProduct()
        case .yearly:
            product = subscriptionManager.getYearlyProduct()
        case .lifetime:
            product = subscriptionManager.getLifetimeProduct()
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
        } else if let error = subscriptionManager.errorMessage {
            showingError = true
        }
        
        isProcessing = false
    }
}

// MARK: - Supporting Views

/// 요금제 옵션 뷰
struct PlanOptionView: View {
    let plan: SubscriptionPlan
    let price: String
    let monthlyPrice: String?
    let badge: String?
    let badgeColor: Color
    let isSelected: Bool
    let action: () -> Void
    
    init(
        plan: SubscriptionPlan,
        price: String,
        monthlyPrice: String? = nil,
        badge: String? = nil,
        badgeColor: Color = .green,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.plan = plan
        self.price = price
        self.monthlyPrice = monthlyPrice
        self.badge = badge
        self.badgeColor = badgeColor
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(AppConfig.continueButtonColor).opacity(0.2) : Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color(AppConfig.continueButtonColor) : Color.gray.opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                
                VStack(spacing: 8) {
                    HStack {
                        Text(plan.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        if let badge = badge {
                            Text(badge)
                                .font(.system(size: 12, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(badgeColor)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(price)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            if let monthlyPrice = monthlyPrice {
                                Text("per month \(monthlyPrice)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(AppConfig.continueButtonColor))
                        } else {
                            Image(systemName: "circle")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    if plan != .lifetime {
                        Text("Includes 3-day free trial")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(16)
            }
        }
    }
}

/// 기능 비교 행
struct FeatureComparisonRow: View {
    let feature: String
    let free: String
    let pro: String
    
    var body: some View {
        HStack {
            Text(feature)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(free)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .frame(width: 60)
                .multilineTextAlignment(.center)
            
            Text(pro)
                .font(.system(size: 14))
                .foregroundColor(.yellow)
                .frame(width: 60)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.1))
    }
}

// MARK: - Supporting Enums

enum SubscriptionPlan: String, CaseIterable {
    case monthly = "Monthly"
    case yearly = "Yearly"
    case lifetime = "Lifetime"
    
    var title: String {
        return rawValue
    }
    
    var description: String {
        switch self {
        case .monthly:
            return "Monthly billing"
        case .yearly:
            return "Yearly billing"
        case .lifetime:
            return "One-time payment for lifetime access"
        }
    }
}
// MARK: - Preview

#Preview {
    PaywallView(isProUser: .constant(false))
}
