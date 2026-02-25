//
//  PreviewWallView.swift
//  PixelMe
//
//  Created by Claude on 2026/02/25.
//  잠긴 기능 미리보기 뷰
//

import SwiftUI

/// 잠긴 기능에 대한 미리보기와 업그레이드 유도 뷰
struct PreviewWallView: View {
    let feature: PremiumFeature
    let previewContent: AnyView
    @State private var showPaywall = false
    
    var body: some View {
        ZStack {
            // 블러 처리된 미리보기 컨텐츠
            previewContent
                .blur(radius: 8)
                .overlay(
                    Color.black.opacity(0.5)
                )
            
            // 업그레이드 유도 오버레이
            VStack(spacing: 20) {
                // 자물쇠 아이콘
                Image(systemName: "lock.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)
                
                // 기능 설명
                VStack(spacing: 8) {
                    Text(feature.rawValue)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(FeatureGating.shared.getFeatureDescription(for: feature))
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // 업그레이드 버튼
                Button {
                    showPaywall = true
                } label: {
                    VStack(spacing: 4) {
                        Text("3-Day Free Trial")
                            .font(.system(size: 18, weight: .bold))
                        
                        Text("Unlock Pro Features")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(AppConfig.continueButtonColor))
                    )
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(isProUser: .constant(false))
        }
    }
}

/// 잠긴 기능 미리보기를 위한 ViewModifier
struct LockedFeatureModifier: ViewModifier {
    let feature: PremiumFeature
    let isLocked: Bool
    
    func body(content: Content) -> some View {
        if isLocked {
            PreviewWallView(
                feature: feature,
                previewContent: AnyView(content)
            )
        } else {
            content
        }
    }
}

/// View extension for easy usage
extension View {
    /// 기능이 잠겨있을 때 미리보기 벽을 표시하는 modifier
    func lockedFeaturePreview(feature: PremiumFeature, isLocked: Bool) -> some View {
        self.modifier(LockedFeatureModifier(feature: feature, isLocked: isLocked))
    }
    
    /// FeatureGating을 사용한 간편 버전
    func proFeatureGate(feature: PremiumFeature) -> some View {
        let isLocked = !SubscriptionManager.shared.hasAccess(to: .pro)
        return self.lockedFeaturePreview(feature: feature, isLocked: isLocked)
    }
}

/// 간단한 잠금 표시 뷰
struct LockOverlayView: View {
    let size: CGFloat
    let showUpgradeButton: Bool
    @State private var showPaywall = false
    
    init(size: CGFloat = 24, showUpgradeButton: Bool = true) {
        self.size = size
        self.showUpgradeButton = showUpgradeButton
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.fill")
                .font(.system(size: size))
                .foregroundColor(.yellow)
            
            if showUpgradeButton {
                Button {
                    showPaywall = true
                } label: {
                    Text("Pro")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(AppConfig.continueButtonColor))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(isProUser: .constant(false))
        }
    }
}

/// 기능별 미리보기 표시를 위한 헬퍼 뷰들
struct LockedFeatureCard: View {
    let feature: PremiumFeature
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                    .blur(radius: 1)
                
                LockOverlayView(size: 20)
            }
            
            Text(feature.rawValue)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(FeatureGating.shared.getFeatureDescription(for: feature))
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}

// MARK: - Preview

struct PreviewWallView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Preview of locked feature
            Rectangle()
                .fill(Color.blue)
                .frame(height: 200)
                .proFeatureGate(feature: .allColorPalettes)
            
            // Locked feature card
            LockedFeatureCard(
                feature: .dithering,
                icon: "waveform.path.ecg"
            )
            
            // Lock overlay
            Rectangle()
                .fill(Color.green)
                .frame(width: 100, height: 100)
                .overlay(LockOverlayView())
        }
        .padding()
        .background(Color(AppConfig.backgroundColor))
    }
}