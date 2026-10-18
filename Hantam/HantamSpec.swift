//
//  HantamSpec.swift
//  Hantam
//

import Foundation
import LeeoKit

enum HantamSpec: LeeoAppSpec {
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

    /// 수익모델 — 무료로 쓰다가 Pro 구독(월간·연간) 또는 평생 상품으로 해제.
    /// 페이월 구성(`paywall`)은 여기서 자동으로 유도된다 (SubscriptionManager 가 사용).
    /// - productIDs: 페이월에서 판매/노출하는 구독·평생 상품.
    /// - entitlementIDs: "Pro 로 인정"할 ID. 판매하지 않는 예전 ID(주간, 일회성으로 잘못 만든 월간·연간,
    ///   레거시 `PixelNFT.Premium`)도 소유하면 Pro 로 인정한다.
    /// - cacheSuiteName: LeeoStore 권한 캐시 전용 suite (다른 매니저의 LeeoStore 와 캐시 키가 겹치지 않도록 분리).
    /// ⚠️ 상품 ID 는 App Store Connect·기존 사용자 영수증과의 계약이다 — 한 번 판 ID 는 지우지 않는다.
    static let monetization = LeeoMonetization.freemiumSubscription(
        LeeoSubscriptionConfig(
            productIDs: [
                AppConfig.monthlyProductID,
                AppConfig.yearlyProductID,
                AppConfig.lifetimeProductID
            ],
            termsURL: URL(string: "https://m1zz.github.io/PixelMe/terms.html")!,
            entitlementIDs: [
                AppConfig.monthlyProductID,
                AppConfig.yearlyProductID,
                AppConfig.lifetimeProductID,
                AppConfig.weeklyProductID,
                AppConfig.legacyMonthlyProductID,
                AppConfig.legacyYearlyProductID,
                AppConfig.premiumVersion // 레거시 일회성 구매 → 평생 Pro 인정
            ],
            cacheSuiteName: "com.pixelme.leeostore.pro"
        )
    )

    /// 익명 사용 통계 → FeedbackHub. 없으면 bootstrap 이 스냅샷·app_open 을 건너뛴다.
    static let analytics: any LeeoAnalytics = HantamAnalytics(spec: HantamSpec.self)
}
