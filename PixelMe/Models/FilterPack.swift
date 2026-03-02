//
//  FilterPack.swift
//  PixelMe
//
//  시즌 필터 팩 데이터 모델
//

import UIKit

/// 필터 팩에 포함되는 커스텀 필터 조합
struct PackFilter: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    /// 기반 필터 효과
    let baseFilter: String  // FilterEffectType rawValue
    /// 기반 팔레트
    let basePalette: String // ColorPaletteType rawValue
    /// 필터 강도 (0.0~1.0)
    let filterIntensity: CGFloat
    /// 추가 색상 보정 파라미터
    let brightnessAdjust: CGFloat
    let contrastAdjust: CGFloat
    let saturationAdjust: CGFloat

    var filterEffectType: FilterEffectType? {
        FilterEffectType(rawValue: baseFilter)
    }

    var colorPaletteType: ColorPaletteType? {
        ColorPaletteType(rawValue: basePalette)
    }
}

/// 시즌 필터 팩
struct FilterPack: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let productID: String
    let price: String // 표시용 가격 (예: "₩1,900")
    let iconName: String // SF Symbol name
    let accentColorHex: String
    let season: FilterPackSeason
    let filters: [PackFilter]
    /// 팩에 포함된 전용 팔레트 hex 색상 배열
    let customPalettes: [PackPalette]
    /// 출시일 (nil이면 항상 사용 가능)
    let availableFrom: String? // ISO8601 date string
    /// 종료일 (nil이면 무기한)
    let availableUntil: String? // ISO8601 date string

    var accentColor: UIColor {
        UIColor(hexString: accentColorHex) ?? .systemBlue
    }

    var isCurrentlyAvailable: Bool {
        let now = Date()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        if let fromStr = availableFrom, let from = formatter.date(from: fromStr) {
            if now < from { return false }
        }
        if let untilStr = availableUntil, let until = formatter.date(from: untilStr) {
            if now > until { return false }
        }
        return true
    }
}

/// 팩 전용 팔레트
struct PackPalette: Identifiable, Codable {
    let id: String
    let name: String
    let colors: [String] // Hex strings

    func getUIColors() -> [UIColor] {
        colors.compactMap { UIColor(hexString: $0) }
    }
}

/// 시즌 구분
enum FilterPackSeason: String, Codable, CaseIterable {
    case arcade = "90s Arcade"
    case spring = "Spring"
    case summer = "Summer"
    case autumn = "Autumn"
    case winter = "Winter"
    case halloween = "Halloween"
    case christmas = "Christmas"
    case special = "Special"

    var icon: String {
        switch self {
        case .arcade: return "gamecontroller.fill"
        case .spring: return "leaf.fill"
        case .summer: return "sun.max.fill"
        case .autumn: return "leaf.arrow.triangle.circlepath"
        case .winter: return "snowflake"
        case .halloween: return "moon.stars.fill"
        case .christmas: return "gift.fill"
        case .special: return "star.fill"
        }
    }
}
