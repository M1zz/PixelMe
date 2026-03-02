//
//  FreeUsageManager.swift
//  PixelMe
//
//  Created by Claude on 2026/03/01.
//  무료 사용자 일일 변환 제한 및 워터마크 관리
//

import UIKit
import SwiftUI

/// 무료 사용자 일일 변환 제한 관리
@MainActor
class FreeUsageManager: ObservableObject {
    
    // MARK: - Constants
    
    /// 무료 사용자 일일 변환 제한 횟수
    static let dailyFreeLimit = 3
    
    /// UserDefaults keys
    private static let dailyCountKey = "pixelme_daily_conversion_count"
    private static let lastResetDateKey = "pixelme_daily_reset_date"
    
    /// App Store URL
    static let appStoreURL = "https://apps.apple.com/app/pixel-meme/id6449769987"
    
    // MARK: - Published
    
    @Published private(set) var dailyConversionsUsed: Int = 0
    
    // MARK: - Singleton
    
    static let shared = FreeUsageManager()
    
    private init() {
        resetIfNewDay()
        dailyConversionsUsed = UserDefaults.standard.integer(forKey: Self.dailyCountKey)
    }
    
    // MARK: - Daily Limit
    
    /// 오늘 남은 무료 변환 횟수
    var remainingConversions: Int {
        if SubscriptionManager.shared.isProUser { return Int.max }
        return max(0, Self.dailyFreeLimit - dailyConversionsUsed)
    }
    
    /// 변환 가능 여부
    var canConvert: Bool {
        if SubscriptionManager.shared.isProUser { return true }
        resetIfNewDay()
        return dailyConversionsUsed < Self.dailyFreeLimit
    }
    
    /// 변환 사용 기록
    func recordConversion() {
        guard !SubscriptionManager.shared.isProUser else { return }
        resetIfNewDay()
        dailyConversionsUsed += 1
        UserDefaults.standard.set(dailyConversionsUsed, forKey: Self.dailyCountKey)
    }
    
    /// 자정 리셋 확인
    private func resetIfNewDay() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastReset = UserDefaults.standard.object(forKey: Self.lastResetDateKey) as? Date {
            let lastResetDay = calendar.startOfDay(for: lastReset)
            if today > lastResetDay {
                // 새로운 날 → 리셋
                dailyConversionsUsed = 0
                UserDefaults.standard.set(0, forKey: Self.dailyCountKey)
                UserDefaults.standard.set(today, forKey: Self.lastResetDateKey)
            }
        } else {
            // 첫 실행
            UserDefaults.standard.set(today, forKey: Self.lastResetDateKey)
        }
    }
    
    // MARK: - Watermark
    
    /// 워터마크 필요 여부
    var shouldApplyWatermark: Bool {
        return !SubscriptionManager.shared.isProUser
    }
    
    /// 이미지에 워터마크 추가 (thread-safe, no MainActor requirement)
    /// "Made with PixelMe" + 앱 링크를 하단에 표시하여 바이럴 효과 극대화
    nonisolated static func applyWatermark(to image: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)

        return renderer.image { context in
            image.draw(at: .zero)

            let mainFontSize: CGFloat = max(image.size.width * 0.028, 13)
            let linkFontSize: CGFloat = max(image.size.width * 0.02, 10)
            let padding: CGFloat = mainFontSize * 0.7

            // 메인 텍스트: "Made with PixelMe"
            let mainText = "Made with PixelMe"
            let mainAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: mainFontSize, weight: .semibold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.85)
            ]
            let mainSize = (mainText as NSString).size(withAttributes: mainAttributes)

            // 링크 텍스트: 앱스토어 단축 URL
            let linkText = "apps.apple.com/app/pixel-meme"
            let linkAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: linkFontSize, weight: .regular),
                .foregroundColor: UIColor.white.withAlphaComponent(0.55)
            ]
            let linkSize = (linkText as NSString).size(withAttributes: linkAttributes)

            let boxWidth = max(mainSize.width, linkSize.width) + padding * 2
            let lineSpacing: CGFloat = mainFontSize * 0.2
            let boxHeight = mainSize.height + linkSize.height + lineSpacing + padding * 2

            // 배경 박스 (우하단, 라운드 코너)
            let bgRect = CGRect(
                x: image.size.width - boxWidth - padding,
                y: image.size.height - boxHeight - padding,
                width: boxWidth,
                height: boxHeight
            )

            UIColor.black.withAlphaComponent(0.45).setFill()
            UIBezierPath(roundedRect: bgRect, cornerRadius: mainFontSize * 0.4).fill()

            // 메인 텍스트
            let mainPoint = CGPoint(
                x: bgRect.origin.x + (boxWidth - mainSize.width) / 2,
                y: bgRect.origin.y + padding
            )
            (mainText as NSString).draw(at: mainPoint, withAttributes: mainAttributes)

            // 링크 텍스트
            let linkPoint = CGPoint(
                x: bgRect.origin.x + (boxWidth - linkSize.width) / 2,
                y: mainPoint.y + mainSize.height + lineSpacing
            )
            (linkText as NSString).draw(at: linkPoint, withAttributes: linkAttributes)
        }
    }
    
    // MARK: - Share Helper
    
    /// 공유용 아이템 생성 (비Pro: 워터마크 + 앱링크, Pro: 클린 이미지만)
    nonisolated static func shareItems(for image: UIImage, isPro: Bool) -> [Any] {
        if isPro {
            return [image]
        } else {
            let watermarked = applyWatermark(to: image)
            let shareText = "Created with PixelMe 🎨\n\(appStoreURL)"
            return [watermarked, shareText] as [Any]
        }
    }
}
