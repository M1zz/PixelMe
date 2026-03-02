//
//  FeatureGating.swift
//  PixelMe
//
//  Created by Claude on 2026/02/25.
//  기능별 잠금/해제 관리 시스템
//

import SwiftUI

/// 기능별 잠금/해제 관리 클래스
@MainActor
class FeatureGating: ObservableObject {
    
    // MARK: - Singleton
    static let shared = FeatureGating()
    
    private init() {}
    
    // MARK: - Feature Access Methods
    
    /// 픽셀 크기 접근 권한 확인
    func canUsePixelSize(_ size: PixelBoardSize) -> Bool {
        let freePixelSizes: [PixelBoardSize] = [.extraLow, .low, .normal]
        
        if freePixelSizes.contains(size) {
            return true
        }
        
        return SubscriptionManager.shared.hasAccess(to: .pro)
    }
    
    /// 무료로 사용 가능한 픽셀 크기들
    var freePixelSizes: [PixelBoardSize] {
        return [.extraLow, .low, .normal]
    }
    
    /// 프리미엄 픽셀 크기들
    var premiumPixelSizes: [PixelBoardSize] {
        return [.medium, .large, .extraLarge]
    }
    
    /// 색상 팔레트 접근 권한 확인
    func canUsePalette(_ paletteType: ColorPaletteType) -> Bool {
        // Free: 1 palette only (none = original colors)
        let freePalettes: [ColorPaletteType] = [.none]
        
        if freePalettes.contains(paletteType) {
            return true
        }
        
        return SubscriptionManager.shared.hasAccess(to: .pro)
    }
    
    /// 무료로 사용 가능한 색상 팔레트들
    var freePalettes: [ColorPaletteType] {
        return [.none]
    }
    
    /// 프리미엄 색상 팔레트들
    var premiumPalettes: [ColorPaletteType] {
        return [.gameboy, .nes, .snes, .vaporwave, .cyberpunk, .pastel, .retro8bit, .noir]
    }
    
    /// 필터 효과 접근 권한 확인
    func canUseFilter(_ filterType: FilterEffectType) -> Bool {
        let freeFilters: [FilterEffectType] = [.crt]
        
        if freeFilters.contains(filterType) {
            return true
        }
        
        return SubscriptionManager.shared.hasAccess(to: .pro)
    }
    
    /// 무료로 사용 가능한 필터들
    var freeFilters: [FilterEffectType] {
        return [.crt]
    }
    
    /// 프리미엄 필터들
    var premiumFilters: [FilterEffectType] {
        return [.scanlines, .glitch, .vintage, .vhsTape, .arcade]
    }
    
    /// 디더링 사용 권한 확인
    var canUseDithering: Bool {
        return SubscriptionManager.shared.hasAccess(to: .pro)
    }
    
    /// 배치 처리 사용 권한 확인
    var canUseBatchProcessing: Bool {
        return SubscriptionManager.shared.hasAccess(to: .pro)
    }
    
    /// 배치 처리 최대 개수
    var maxBatchCount: Int {
        return canUseBatchProcessing ? 10 : 0
    }
    
    /// GIF 생성 사용 권한 확인
    var canUseGIF: Bool {
        return SubscriptionManager.shared.hasAccess(to: .pro)
    }
    
    /// 레이어 기능 사용 권한 확인
    var canUseLayers: Bool {
        return SubscriptionManager.shared.hasAccess(to: .pro)
    }
    
    /// 최대 레이어 개수
    var maxLayerCount: Int {
        return canUseLayers ? 5 : 0
    }
    
    // MARK: - Export Features
    
    /// 내보내기 형식 사용 권한 확인
    func canUseExportFormat(_ format: ExportFormat) -> Bool {
        switch format {
        case .png, .jpeg:
            return true  // PNG/JPEG는 무료로 제공
        case .svg, .pdf:
            return SubscriptionManager.shared.hasAccess(to: .pro)
        }
    }
    
    /// 무료로 사용 가능한 내보내기 형식들
    var freeExportFormats: [ExportFormat] {
        return [.png]
    }
    
    /// 프리미엄 내보내기 형식들
    var premiumExportFormats: [ExportFormat] {
        return [.svg, .pdf]
    }
    
    /// 4K 해상도 내보내기 권한 확인
    var canExport4K: Bool {
        return SubscriptionManager.shared.hasAccess(to: .pro)
    }
    
    /// 최대 내보내기 해상도
    var maxExportResolution: CGSize {
        if canExport4K {
            return CGSize(width: 4096, height: 4096)  // 4K
        } else {
            return CGSize(width: 1920, height: 1080)  // 1080p
        }
    }
    
    /// 워터마크 제거 권한 확인
    var canRemoveWatermark: Bool {
        return SubscriptionManager.shared.hasAccess(to: .pro)
    }
    
    // MARK: - Template Features
    
    /// 템플릿 사용 권한 확인
    func canUseTemplate(at index: Int, in templateType: TemplateCategory) -> Bool {
        switch templateType {
        case .profile:
            return index < freeProfileTemplateCount || SubscriptionManager.shared.hasAccess(to: .pro)
        case .pixelAvatar:
            return index < freeAvatarTemplateCount || SubscriptionManager.shared.hasAccess(to: .pro)
        default:
            return SubscriptionManager.shared.hasAccess(to: .pro)
        }
    }
    
    /// 무료 프로필 템플릿 개수
    private let freeProfileTemplateCount = 3
    
    /// 무료 아바타 템플릿 개수
    private let freeAvatarTemplateCount = 2
    
    /// 사용 가능한 프로필 템플릿 개수
    var availableProfileTemplateCount: Int {
        if SubscriptionManager.shared.hasAccess(to: .pro) {
            return 15  // 전체 템플릿
        } else {
            return freeProfileTemplateCount
        }
    }
    
    /// 사용 가능한 아바타 템플릿 개수
    var availableAvatarTemplateCount: Int {
        if SubscriptionManager.shared.hasAccess(to: .pro) {
            return 10  // 전체 템플릿
        } else {
            return freeAvatarTemplateCount
        }
    }
    
    // MARK: - Preset Features
    
    /// 프리셋 사용 권한 확인
    func canUsePreset(at index: Int) -> Bool {
        return index < freePresetCount || SubscriptionManager.shared.hasAccess(to: .pro)
    }
    
    /// 무료 프리셋 개수
    private let freePresetCount = 2
    
    /// 사용 가능한 프리셋 개수
    var availablePresetCount: Int {
        if SubscriptionManager.shared.hasAccess(to: .pro) {
            return 8  // 전체 프리셋
        } else {
            return freePresetCount
        }
    }
    
    // MARK: - Filter Pack Features

    /// 필터 팩의 특정 필터에 대한 접근 권한 확인
    func canUsePackFilter(_ filterId: String) -> Bool {
        return FilterPackManager.shared.hasAccessToFilter(filterId)
    }

    /// 특정 필터 팩에 대한 접근 권한 확인
    func hasFilterPack(_ packId: String) -> Bool {
        guard let pack = FilterPackManager.shared.allPacks.first(where: { $0.id == packId }) else {
            return false
        }
        return FilterPackManager.shared.hasAccess(to: pack)
    }

    // MARK: - Feature Description Methods
    
    /// 잠긴 기능에 대한 설명 메시지
    func getFeatureDescription(for feature: PremiumFeature) -> String {
        switch feature {
        case .unlimitedPixelSizes:
            return "Use all pixel sizes to create more detailed pixel art"
        case .allColorPalettes:
            return "Express various styles of pixel art with 9 color palettes"
        case .allFilters:
            return "Add unique feelings to pixel art with 6 filter effects"
        case .dithering:
            return "Express smooth color transitions with 3 dithering techniques"
        case .batchProcessing:
            return "Process up to 10 images at once to save time"
        case .gifCreation:
            return "Create animated pixel art GIFs for more vivid expression"
        case .layers:
            return "Compose complex pixel art with up to 5 layers"
        case .highQualityExport:
            return "High-quality 4K export, watermark removal, SVG/PDF support"
        case .allTemplates:
            return "Easily create pixel art with 15+ various templates"
        case .allPresets:
            return "Create high-quality pixel art at once with 8 expert presets"
        }
    }
    
    /// Upgrade prompt message
    var upgradeMessage: String {
        return "You can use this feature by upgrading to Pro"
    }
    
    /// Free trial prompt message
    var freeTrialMessage: String {
        return "Start with a 3-day free trial!"
    }
}

// MARK: - Supporting Enums
// Note: ExportFormat, PixelBoardSize are defined in DataManager.swift
// FilterEffectType, ColorPaletteType are defined in their respective files

/// Premium feature list
enum PremiumFeature: String, CaseIterable {
    case unlimitedPixelSizes = "Unlimited Pixel Sizes"
    case allColorPalettes = "All Color Palettes"
    case allFilters = "All Filter Effects"
    case dithering = "Dithering Techniques"
    case batchProcessing = "Batch Processing"
    case gifCreation = "Create GIF"
    case layers = "Layers System"
    case highQualityExport = "High Quality Export"
    case allTemplates = "All Templates"
    case allPresets = "All Presets"
}