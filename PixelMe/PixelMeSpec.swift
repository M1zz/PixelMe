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

    /// 개인정보 처리방침·지원·약관 페이지 (README 에 공개된 링크, docs/ 를 GitHub Pages 로 서빙).
    /// 지원 페이지는 따로 없어 Contact(메일) 섹션이 있는 랜딩 페이지를 쓴다.
    static let legal = LeeoLegalConfig(
        privacyURL: URL(string: "https://m1zz.github.io/PixelMe/privacy.html")!,
        supportURL: URL(string: "https://m1zz.github.io/PixelMe/")!,
        termsURL: URL(string: "https://m1zz.github.io/PixelMe/terms.html")!,
        marketingURL: URL(string: "https://m1zz.github.io/PixelMe/")!
    )

    /// 수익모델 — 무료로 쓰다가 Pro 구독(주간·월간·연간) 또는 평생 상품으로 해제.
    /// 페이월 구성(`paywall`)은 여기서 자동으로 유도된다 (SubscriptionManager 가 사용).
    /// - productIDs: 페이월에서 판매/노출하는 구독·평생 상품 (기존 SubscriptionManager 와 동일 순서/ID).
    /// - entitlementIDs: "Pro 로 인정"할 ID. 판매하지 않지만 소유 시 평생 Pro 로 인정하는 레거시
    ///   일회성 구매(`PixelNFT.Premium`)를 포함시켜, 기존 checkSubscriptionStatus 의 그랜드파더링을 대체한다.
    /// - cacheSuiteName: LeeoStore 권한 캐시 전용 suite (다른 매니저의 LeeoStore 와 캐시 키가 겹치지 않도록 분리).
    /// ⚠️ 상품 ID 는 App Store Connect·기존 사용자 영수증과의 계약이다 — 변경 금지.
    static let monetization = LeeoMonetization.freemiumSubscription(
        LeeoSubscriptionConfig(
            productIDs: [
                AppConfig.weeklyProductID,
                AppConfig.monthlyProductID,
                AppConfig.yearlyProductID,
                AppConfig.lifetimeProductID
            ],
            termsURL: URL(string: "https://m1zz.github.io/PixelMe/terms.html")!,
            entitlementIDs: [
                AppConfig.weeklyProductID,
                AppConfig.monthlyProductID,
                AppConfig.yearlyProductID,
                AppConfig.lifetimeProductID,
                AppConfig.premiumVersion // 레거시 일회성 구매 → 평생 Pro 인정
            ],
            cacheSuiteName: "com.pixelme.leeostore.pro"
        )
    )
}
