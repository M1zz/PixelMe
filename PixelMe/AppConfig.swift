//
//  AppConfig.swift
//  PixelMe
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
    static let appVersion: String = "2.0.0"
    static let buildNumber: String = "1"
    
    // MARK: - Settings flow items
    static let emailSupport = "leeo@kakao.com"
    static let privacyURL: URL = URL(string: "https://www.google.com/")!
    static let termsAndConditionsURL: URL = URL(string: "https://www.google.com/")!
    static let yourAppURL: URL = URL(string: "https://apps.apple.com/app/pixel-meme/id6449769987")!
    
    // MARK: - UI Styles
    static let backgroundColor: UIColor = UIColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
    static let toolBackgroundColor: UIColor = UIColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
    static let continueButtonColor: UIColor = UIColor(#colorLiteral(red: 0.1895111597, green: 0.6577079403, blue: 0.9686274529, alpha: 1))
    
    // MARK: - In App Purchases
    static let premiumVersion: String = "PixelNFT.Premium" // 기존 호환성 유지
    
    // 구독 시스템 Product IDs
    static let weeklyProductID: String = "com.pixelme.pro.weekly"
    static let monthlyProductID: String = "com.pixelme.pro.monthly"
    static let yearlyProductID: String = "com.pixelme.pro.yearly"
    static let lifetimeProductID: String = "com.pixelme.pro.lifetime"

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
