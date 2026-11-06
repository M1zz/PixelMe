//
//  HantamSpec.swift
//  Hantam
//

import Foundation
import LeeoKit

enum HantamSpec: LeeoAppSpec {
    static let appName = "PixelMe"
    static let developerEmail = "leeo@kakao.com"
    static let feedback = LeeoFeedbackConfig(containerIdentifier: "iCloud.com.Ysoup.FeedbackHub", appIdentifier: "com.leeo.PixelMe")

    /// 개인정보 처리방침·지원·약관 페이지 (README 에 공개된 링크, docs/ 를 GitHub Pages 로 서빙).
    /// 지원 페이지는 따로 없어 Contact(메일) 섹션이 있는 랜딩 페이지를 쓴다.
    static let legal = LeeoLegalConfig(
        privacyURL: URL(string: "https://m1zz.github.io/PixelMe/privacy.html")!,
        supportURL: URL(string: "https://m1zz.github.io/PixelMe/")!,
        termsURL: URL(string: "https://m1zz.github.io/PixelMe/terms.html")!,
        marketingURL: URL(string: "https://m1zz.github.io/PixelMe/")!
    )

    /// 수익모델 — 무료 다운로드 + 무료 · Plus · Pro (2026-11, 그 전에는 유료 다운로드 안에 Pro 한 칸).
    /// 칸마다 무엇이 열리는지는 `HantamTier` · `HantamPlan` 한 곳에 있다(SubscriptionManager.swift).
    /// - productIDs: 페이월이 불러와 파는 상품(구독 · 평생 · 올리기 · 졸업).
    /// - entitlementIDs: 유료 칸을 여는 모든 ID. 판매하지 않는 예전 ID(주간, 일회성으로 잘못 만든 월간·연간,
    ///   레거시 `PixelNFT.Premium`)도 소유하면 Pro 로 인정한다. 어느 칸인지는 `HantamPlan.tierByProduct`.
    /// - grandfather: 유료 다운로드 시절에 앱을 산 사람은 Pro 평생(SubscriptionManager).
    /// - cacheSuiteName: LeeoStore 권한 캐시 전용 suite (다른 매니저의 LeeoStore 와 캐시 키가 겹치지 않도록 분리).
    /// ⚠️ 상품 ID 는 App Store Connect·기존 사용자 영수증과의 계약이다 — 한 번 판 ID 는 지우지 않는다.
    static let monetization = LeeoMonetization.freemiumSubscription(
        LeeoSubscriptionConfig(
            productIDs: HantamPlan.productIDs,
            termsURL: URL(string: "https://m1zz.github.io/PixelMe/terms.html")!,
            entitlementIDs: HantamPlan.entitlementIDs,
            // 계약에 적는 경계(Preflight · 포트폴리오가 읽는다). 실제 판정은 SubscriptionManager.allows(_:).
            gate: LeeoGatePolicy(freeLimits: [HantamFeature.keepPatterns.rawValue: HantamPlan.freeSaveLimit],
                                 proOnly: Set(HantamFeature.allCases.map(\.rawValue))),
            cacheSuiteName: "com.pixelme.leeostore.pro",
            // Pro 선물하기. 보내는 사람은 소모성 선물 상품을 사고, 받는 사람은 평생 Pro 를 산 것과 같아진다.
            // 선물 기록은 피드백과 같은 허브 컨테이너의 공개 DB 에 둔다. Hantam.entitlements 에 이미 있다.
            // ⚠️ 선물 상품은 productIDs · entitlementIDs 에 넣지 않는다. 넣으면 선물을 산 사람이 Pro 가 된다.
            gift: LeeoGiftConfig(
                productID: AppConfig.giftProductID,
                grantsProductID: AppConfig.lifetimeProductID,
                containerIdentifier: "iCloud.com.Ysoup.FeedbackHub"
            ),
            // 개발자 응원하기(팁). 이미 Pro 인 사람이 조금 더 내고 싶을 때.
            tipJar: LeeoTipJarConfig(productIDs: AppConfig.tipProductIDs)
        )
    )

    /// 익명 사용 통계 → FeedbackHub. 없으면 bootstrap 이 스냅샷·app_open 을 건너뛴다.
    static let analytics: any LeeoAnalytics = HantamAnalytics(spec: HantamSpec.self)
}
