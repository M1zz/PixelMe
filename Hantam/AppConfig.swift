//
//  AppConfig.swift
//  Hantam
//
//  Created by hyunho lee on 2023/06/01.
//

import UIKit
import SwiftUI
import Foundation

/// Generic configurations for the app
class AppConfig {
    
    // MARK: - Version (Single source of truth)
    /// 앱 버전 - 여기서만 관리. pbxproj의 MARKETING_VERSION과 일치시킬 것.
    static let appVersion: String = "2.1.0"
    static let buildNumber: String = "1"
    
    // MARK: - Settings flow items
    static let emailSupport = "leeo@kakao.com"
    static let privacyURL: URL = URL(string: "https://m1zz.github.io/PixelMe/privacy.html")!
    static let termsAndConditionsURL: URL = URL(string: "https://m1zz.github.io/PixelMe/terms.html")!
    static let yourAppURL: URL = URL(string: "https://apps.apple.com/app/id6449769987")!
    
    // MARK: - UI Styles
    static let backgroundColor: UIColor = UIColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
    static let toolBackgroundColor: UIColor = UIColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
    static let continueButtonColor: UIColor = UIColor(#colorLiteral(red: 0.1895111597, green: 0.6577079403, blue: 0.9686274529, alpha: 1))
    
    // MARK: - In App Purchases
    static let premiumVersion: String = "PixelNFT.Premium" // 기존 호환성 유지
    
    // 판매 상품 Product IDs — 무료 · Plus · Pro (2026-11 요금제 개편, 유료 다운로드 → 무료 다운로드)
    // 유료 칸마다 주 · 월 · 연 자동 갱신 구독과 평생(비소모성). 구독은 모두 '한땀 Pro' 구독 그룹 하나에 두고
    // Pro 를 위 단계로 둔다. 같은 그룹이라 Plus ↔ Pro 를 갈아탈 때 App Store 가 남은 기간을 정산한다.
    // ⚠️ 상품 ID 는 App Store Connect · Hantam.storekit 과 글자 하나까지 같아야 한다. 한 번 판 ID 는 지우지 않는다.

    // Plus — 큰 도안 · 도안 무제한 보관 · 표시 없는 이미지 · 픽셀 아트 도구 전부
    static let plusWeeklyProductID: String = "com.leeo.PixelMe.plus.weekly"
    static let plusMonthlyProductID: String = "com.leeo.PixelMe.plus.monthly"
    static let plusYearlyProductID: String = "com.leeo.PixelMe.plus.yearly"
    static let plusLifetimeProductID: String = "com.leeo.PixelMe.plus.lifetime"

    // Pro — Plus 전부 + 인쇄용 PDF 도안 · 문구 없는 전후 영상 · 필터 팩
    // 월 · 연 · 평생은 2.1.x 까지 '한땀 Pro' 로 팔던 그 상품을 그대로 잇는다(산 사람 · 구독자는 그대로 Pro).
    // 월간·연간은 '한땀 Pro' 구독 그룹의 자동 갱신 구독이다. 예전 com.pixelme.pro.monthly/yearly 는
    // App Store Connect 에 일회성 구매로 잘못 만들어져 종류를 바꿀 수 없어 새 ID 를 쓴다(2.1.0).
    static let proWeeklyProductID: String = "com.leeo.PixelMe.pro.weekly"
    static let monthlyProductID: String = "com.hantam.pro.monthly"
    static let yearlyProductID: String = "com.hantam.pro.yearly"
    static let lifetimeProductID: String = "com.pixelme.pro.lifetime"  // 일회성(비소모성) — Pro 평생
    /// Plus 평생을 산 사람이 Pro 평생으로 올리는 값(비소모성). Plus 평생 소유자에게만 판다.
    static let proUpgradeProductID: String = "com.leeo.PixelMe.pro.upgrade"
    /// 구독 졸업 — 구독 중인 사람에게만 파는 Pro 평생(비소모성, LeeoGraduation).
    static let proGraduateProductID: String = "com.leeo.PixelMe.pro.graduate"

    /// 유료 다운로드(₩6,600)였던 마지막 빌드 번호. `AppTransaction.originalAppVersion` 이 이 이하이면
    /// 앱을 산 사람이라 Pro 평생으로 본다. 2.1.0 전에는 버전마다 빌드 1(가끔 2)이었고 2.1.0~2.1.3 은 2~5 라
    /// 유료 시절 빌드는 모두 5 이하다. ⚠️ 무료로 나가는 빌드는 6 이상이어야 하고, 앱 가격은 그 빌드가 나갈 때 무료로 바꾼다.
    static let lastPaidDownloadBuild: Int = 5

    // Pro 선물(소모성). 산 사람이 아니라 코드를 받은 사람이 평생 Pro 가 된다(HantamSpec.monetization 의 gift).
    // ⚠️ productIDs · entitlementIDs 에 넣지 않는다.
    static let giftProductID: String = "com.pixelme.gift.pro"

    // 팁(소모성, 작은 것부터). 기능을 열지 않는다(HantamSpec.monetization 의 tipJar).
    // ⚠️ productIDs · entitlementIDs 에 넣지 않는다.
    static let tipProductIDs: [String] = ["com.pixelme.tip.small", "com.pixelme.tip.medium", "com.pixelme.tip.large"]

    // 팔지 않지만 이미 산 사람은 Pro 로 인정하는 예전 ID
    static let legacyWeeklyProductID: String = "com.pixelme.pro.weekly"
    static let legacyMonthlyProductID: String = "com.pixelme.pro.monthly"
    static let legacyYearlyProductID: String = "com.pixelme.pro.yearly"

    // 필터 팩 Product IDs
    static let filterPackArcade90sID: String = "com.pixelme.filterpack.arcade90s"
    static let filterPackSpringID: String = "com.pixelme.filterpack.spring"
    static let filterPackCyberNightID: String = "com.pixelme.filterpack.cybernight"
    
    // MARK: - Image export size at 2x
    static let exportSize: CGFloat = 500 /// this will export the image at 1000x1000 resolution

    // MARK: - Animation Timing Constants
    /// Delay for sheet dismissal before showing next view
    static let sheetTransitionDelay: TimeInterval = 0.5
    /// Delay for view controller dismissal animations
    static let dismissAnimationDelay: TimeInterval = 0.3
    /// Delay after subscription success before auto-dismissing paywall
    static let subscriptionSuccessDelay: TimeInterval = 1.0
}
