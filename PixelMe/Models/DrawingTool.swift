//
//  DrawingTool.swift
//  PixelMe
//
//  Created by hyunho lee on 2026/03/01.
//

import SwiftUI

/// 드로잉 도구 타입
enum DrawingToolType: String, CaseIterable, Identifiable {
    case pencil = "연필"
    case eraser = "지우개"
    case fill = "채우기"
    case eyedropper = "스포이드"
    case line = "직선"
    case rectangle = "사각형"
    case circle = "원"
    case select = "선택"
    case dither = "디더링"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .pencil: return "pencil"
        case .eraser: return "eraser"
        case .fill: return "drop.fill"
        case .eyedropper: return "eyedropper"
        case .line: return "line.diagonal"
        case .rectangle: return "rectangle"
        case .circle: return "circle"
        case .select: return "selection.pin.in.out"
        case .dither: return "checkerboard.rectangle"
        }
    }

    /// 픽셀 아이콘 정의 (해당하는 도구만)
    var pixelIconDefinition: PixelIconDefinition? {
        switch self {
        case .pencil: return PixelIconCatalog.pencil
        case .eraser: return PixelIconCatalog.eraser
        case .fill: return PixelIconCatalog.paintDrop
        default: return nil
        }
    }
}

/// 대칭 모드
enum MirrorMode: String, CaseIterable {
    case none = "없음"
    case horizontal = "좌우"
    case vertical = "상하"
    case both = "4방향"
    
    /// 원본 포인트에서 미러링된 포인트들 반환
    func mirroredPoints(from point: PixelPoint, canvasWidth: Int, canvasHeight: Int) -> [PixelPoint] {
        var points = [point]
        let mx = canvasWidth - 1 - point.x
        let my = canvasHeight - 1 - point.y
        
        switch self {
        case .none: break
        case .horizontal:
            points.append(PixelPoint(x: mx, y: point.y))
        case .vertical:
            points.append(PixelPoint(x: point.x, y: my))
        case .both:
            points.append(PixelPoint(x: mx, y: point.y))
            points.append(PixelPoint(x: point.x, y: my))
            points.append(PixelPoint(x: mx, y: my))
        }
        return points
    }
}
