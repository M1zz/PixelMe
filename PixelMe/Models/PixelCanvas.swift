//
//  PixelCanvas.swift
//  PixelMe
//
//  Created by hyunho lee on 2026/03/01.
//

import SwiftUI

/// 단일 픽셀 캔버스의 데이터 모델
struct PixelCanvas: Codable, Equatable {
    let width: Int
    let height: Int
    /// RGBA 픽셀 데이터 — [width * height] 크기, row-major
    var pixels: [PixelColor]
    
    init(width: Int, height: Int, fillColor: PixelColor = .clear) {
        self.width = width
        self.height = height
        self.pixels = Array(repeating: fillColor, count: width * height)
    }
    
    /// 범위 체크 후 픽셀 가져오기
    func pixel(at point: PixelPoint) -> PixelColor? {
        guard isValid(point) else { return nil }
        return pixels[point.y * width + point.x]
    }
    
    /// 범위 체크 후 픽셀 설정
    mutating func setPixel(at point: PixelPoint, color: PixelColor) {
        guard isValid(point) else { return }
        pixels[point.y * width + point.x] = color
    }
    
    func isValid(_ point: PixelPoint) -> Bool {
        point.x >= 0 && point.x < width && point.y >= 0 && point.y < height
    }
}

/// 정수 좌표
struct PixelPoint: Hashable, Codable, Equatable {
    let x: Int
    let y: Int
}

/// RGBA 색상 (0-255)
struct PixelColor: Codable, Equatable, Hashable {
    let r: UInt8
    let g: UInt8
    let b: UInt8
    let a: UInt8
    
    static let clear = PixelColor(r: 0, g: 0, b: 0, a: 0)
    static let black = PixelColor(r: 0, g: 0, b: 0, a: 255)
    static let white = PixelColor(r: 255, g: 255, b: 255, a: 255)
    
    var swiftUIColor: Color {
        Color(
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: Double(a) / 255.0
        )
    }
    
    var uiColor: UIColor {
        UIColor(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }
    
    init(r: UInt8, g: UInt8, b: UInt8, a: UInt8 = 255) {
        self.r = r; self.g = g; self.b = b; self.a = a
    }
    
    init(uiColor: UIColor) {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        self.r = UInt8(clamping: Int(red * 255))
        self.g = UInt8(clamping: Int(green * 255))
        self.b = UInt8(clamping: Int(blue * 255))
        self.a = UInt8(clamping: Int(alpha * 255))
    }
    
    var isTransparent: Bool { a == 0 }
}

/// 레이어
struct PixelLayer: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var canvas: PixelCanvas
    var isVisible: Bool
    var opacity: Double  // 0.0 ~ 1.0
    
    init(name: String, width: Int, height: Int) {
        self.id = UUID()
        self.name = name
        self.canvas = PixelCanvas(width: width, height: height)
        self.isVisible = true
        self.opacity = 1.0
    }
}

/// 프로젝트 자동 저장용 직렬화 모델
struct PixelProject: Codable {
    let canvasWidth: Int
    let canvasHeight: Int
    let layers: [PixelLayer]
    let selectedToolRaw: String
    let mirrorModeRaw: String
    let brushSize: Int
    let showGrid: Bool
    let savedAt: Date
}

/// 선택 영역
struct PixelSelection: Equatable {
    var origin: PixelPoint
    var size: (width: Int, height: Int)
    var pixels: [PixelColor]  // 복사된 픽셀 데이터

    var rect: (minX: Int, minY: Int, maxX: Int, maxY: Int) {
        (origin.x, origin.y, origin.x + size.width - 1, origin.y + size.height - 1)
    }

    static func == (lhs: PixelSelection, rhs: PixelSelection) -> Bool {
        lhs.origin == rhs.origin && lhs.size.width == rhs.size.width && lhs.size.height == rhs.size.height
    }
}

/// 캔버스 프리셋 사이즈
enum CanvasPreset: String, CaseIterable {
    case micro = "8×8"
    case tiny = "16×16"
    case small = "32×32"
    case medium = "64×64"
    case large = "128×128"

    var size: (width: Int, height: Int) {
        switch self {
        case .micro: return (8, 8)
        case .tiny: return (16, 16)
        case .small: return (32, 32)
        case .medium: return (64, 64)
        case .large: return (128, 128)
        }
    }
}
