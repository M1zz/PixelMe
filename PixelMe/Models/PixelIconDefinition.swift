//
//  PixelIconDefinition.swift
//  PixelMe
//
//  Created by hyunho lee on 2026/03/02.
//

import SwiftUI

/// 픽셀 아이콘의 단일 프레임
struct PixelIconFrame {
    /// "x_y" → PixelColor (SamplePixelArt와 동일한 포맷)
    let pixels: [String: PixelColor]
}

/// 픽셀 애니메이션 아이콘 정의
struct PixelIconDefinition {
    let name: String
    let gridSize: Int
    let frames: [PixelIconFrame]
    let fps: Double
}
