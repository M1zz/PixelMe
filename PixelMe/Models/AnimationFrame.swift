//
//  AnimationFrame.swift
//  PixelMe
//
//  Created by hyunho lee on 2026/03/01.
//

import Foundation

/// 애니메이션 프레임
struct AnimationFrame: Identifiable, Codable, Equatable {
    let id: UUID
    var layers: [PixelLayer]
    var durationMs: Int  // 프레임 지속 시간 (밀리초)
    
    init(layers: [PixelLayer], durationMs: Int = 100) {
        self.id = UUID()
        self.layers = layers
        self.durationMs = durationMs
    }
    
    /// 빈 프레임 생성
    init(width: Int, height: Int, durationMs: Int = 100) {
        self.id = UUID()
        self.layers = [PixelLayer(name: "레이어 1", width: width, height: height)]
        self.durationMs = durationMs
    }
}

/// 프레임 재생 방향
enum PlaybackDirection: String, CaseIterable, Codable {
    case forward = "정방향"
    case reverse = "역방향"
    case pingPong = "핑퐁"
}

/// 스프라이트 시트 레이아웃
enum SpriteSheetLayout: String, CaseIterable {
    case horizontal = "가로"
    case vertical = "세로"
    case grid = "격자"
}
