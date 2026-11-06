//
//  FeatureGating.swift
//  Hantam
//
//  픽셀 아트 도구의 무료 / Plus 경계(칸은 SubscriptionManager 의 HantamFeature). 도안의 경계는 PatternMaterial(크기) · PatternStore(저장 수)에 있다.
//

import SwiftUI

@MainActor
final class FeatureGating {
    static let shared = FeatureGating()
    private init() {}

    private var isPlus: Bool { SubscriptionManager.shared.allows(.pixelTools) }

    /// 무료: 작은 칸 수 세 가지.
    func canUsePixelSize(_ size: PixelBoardSize) -> Bool {
        [.extraLow, .low, .normal].contains(size) || isPlus
    }

    /// 무료: 원래 색 그대로(.none) 만.
    func canUsePalette(_ palette: ColorPaletteType) -> Bool {
        palette == .none || isPlus
    }

    /// 디더링은 Plus.
    var canUseDithering: Bool { isPlus }
}
