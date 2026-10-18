//
//  FeatureGating.swift
//  Hantam
//
//  픽셀 아트 도구의 무료 / Pro 경계. 도안의 경계는 PatternMaterial(크기) · PatternStore(저장 수)에 있다.
//

import SwiftUI

@MainActor
final class FeatureGating {
    static let shared = FeatureGating()
    private init() {}

    private var isPro: Bool { SubscriptionManager.shared.isProUser }

    /// 무료: 작은 칸 수 세 가지.
    func canUsePixelSize(_ size: PixelBoardSize) -> Bool {
        [.extraLow, .low, .normal].contains(size) || isPro
    }

    /// 무료: 원래 색 그대로(.none) 만.
    func canUsePalette(_ palette: ColorPaletteType) -> Bool {
        palette == .none || isPro
    }

    /// 디더링은 Pro.
    var canUseDithering: Bool { isPro }
}
