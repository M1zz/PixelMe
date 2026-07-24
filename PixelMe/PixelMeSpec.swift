//
//  PixelMeSpec.swift
//  PixelMe
//

import Foundation
import LeeoKit

enum PixelMeSpec: LeeoAppSpec {
    static let appName = "PixelMe"
    static let developerEmail = "mizzking75@gmail.com"
    static let feedback = LeeoFeedbackConfig(containerIdentifier: "iCloud.com.Ysoup.FeedbackHub", appIdentifier: "com.leeo.PixelMe")

    /// Pro 구독/평생 엔타이틀먼트 설정 (공용 LeeoStore 가 로드·구매·복원·권한추적을 담당).
    /// - productIDs: 페이월에서 판매/노출하는 구독·평생 상품 (기존 SubscriptionManager 와 동일 순서/ID).
    /// - entitlementIDs: "Pro 로 인정"할 ID. 판매하지 않지만 소유 시 평생 Pro 로 인정하는 레거시
    ///   일회성 구매(`PixelNFT.Premium`)를 포함시켜, 기존 checkSubscriptionStatus 의 그랜드파더링을 대체한다.
    /// - cacheSuiteName: LeeoStore 권한 캐시 전용 suite (다른 매니저의 LeeoStore 와 캐시 키가 겹치지 않도록 분리).
    static let paywall: LeeoPaywallConfig? = LeeoPaywallConfig(
        productIDs: [
            AppConfig.weeklyProductID,
            AppConfig.monthlyProductID,
            AppConfig.yearlyProductID,
            AppConfig.lifetimeProductID
        ],
        entitlementIDs: [
            AppConfig.weeklyProductID,
            AppConfig.monthlyProductID,
            AppConfig.yearlyProductID,
            AppConfig.lifetimeProductID,
            AppConfig.premiumVersion // 레거시 일회성 구매 → 평생 Pro 인정
        ],
        termsURL: AppConfig.termsAndConditionsURL,
        privacyURL: AppConfig.privacyURL,
        cacheSuiteName: "com.pixelme.leeostore.pro"
    )
}
