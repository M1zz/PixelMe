//
//  HantamTheme.swift
//  Hantam
//
//  한땀 브랜드 색 — 따뜻한 면천 바탕에 빨간 실. 밝은·어두운 화면 모두.
//

import SwiftUI
import UIKit

extension Color {
    /// 빨간 실 — 주 버튼 · 강조.
    static let hantamAccent = Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
        ? UIColor(red: 1.00, green: 0.45, blue: 0.40, alpha: 1)
        : UIColor(red: 0.85, green: 0.27, blue: 0.24, alpha: 1) })

    /// 겨자색 — 뱃지 · 보조 강조.
    static let hantamMustard = Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
        ? UIColor(red: 0.98, green: 0.78, blue: 0.35, alpha: 1)
        : UIColor(red: 0.86, green: 0.62, blue: 0.13, alpha: 1) })

    /// 청록 실 — 세 번째 색.
    static let hantamTeal = Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
        ? UIColor(red: 0.36, green: 0.78, blue: 0.72, alpha: 1)
        : UIColor(red: 0.13, green: 0.55, blue: 0.50, alpha: 1) })

    /// 면천 바탕.
    static let hantamBackground = Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
        ? UIColor(red: 0.10, green: 0.09, blue: 0.08, alpha: 1)
        : UIColor(red: 0.98, green: 0.96, blue: 0.93, alpha: 1) })

    /// 카드.
    static let hantamCard = Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
        ? UIColor(red: 0.17, green: 0.15, blue: 0.14, alpha: 1)
        : UIColor.white })

    static let hantamInk = Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
        ? UIColor(white: 0.95, alpha: 1)
        : UIColor(red: 0.17, green: 0.13, blue: 0.11, alpha: 1) })
}

/// 앱 고유 이벤트 이름. 허브는 이름만 받으므로 갈래는 이름 안에 `.` 으로 붙인다.
enum HantamEvent {
    static func paywallShown(_ reason: PaywallReason) {
        LeeoAnalyticsBridge.track("paywall_shown.\(reason.rawValue)")
    }
    static func track(_ name: String) {
        LeeoAnalyticsBridge.track(name)
    }
}

/// 결제 화면을 띄운 계기 — 허브에서 "어디서 사려고 했나" 를 본다.
enum PaywallReason: String {
    case homeBanner = "home_banner"
    case onboarding
    case settings
    case patternSize = "pattern_size"
    case patternPDF = "pattern_pdf"
    case patternCleanImage = "pattern_clean_image"
    case patternSaveLimit = "pattern_save_limit"
    case pixelSize = "pixel_size"
    case palette
    case dithering
    case boardSize = "board_size"
    case advanced
}
