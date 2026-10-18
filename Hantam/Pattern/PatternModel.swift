//
//  PatternModel.swift
//  Hantam
//
//  비즈·십자수 도안의 데이터 모델 — 재료(브랜드 색표), 색, 도안 한 장.
//

import SwiftUI
import UIKit

// MARK: - 색

/// 실제로 살 수 있는 비즈 한 알 · 실 한 타래의 색.
struct PatternColor: Codable, Hashable, Identifiable {
    let code: String
    let name: String
    let r: UInt8
    let g: UInt8
    let b: UInt8

    var id: String { code }

    init(code: String, name: String, r: Int, g: Int, b: Int) {
        self.code = code
        self.name = name
        self.r = UInt8(clamping: r)
        self.g = UInt8(clamping: g)
        self.b = UInt8(clamping: b)
    }

    var color: Color { Color(uiColor: uiColor) }
    var uiColor: UIColor {
        UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1)
    }

    /// 이 색 위에 올릴 글자 색 (기호 도안용).
    var isLight: Bool {
        (0.299 * Double(r) + 0.587 * Double(g) + 0.114 * Double(b)) > 150
    }
}

// MARK: - 재료

/// 도안을 무엇으로 만들지 — 비즈 브랜드 또는 십자수 실.
enum PatternMaterial: String, CaseIterable, Codable, Identifiable {
    case perler
    case hama
    case artkalS
    case dmc

    var id: String { rawValue }

    enum Kind { case bead, thread }

    var kind: Kind { self == .dmc ? .thread : .bead }

    /// 브랜드 이름 (고유명사 — 번역하지 않는다).
    var brandName: String {
        switch self {
        case .perler:  return "Perler"
        case .hama:    return "Hama Midi"
        case .artkalS: return "Artkal S"
        case .dmc:     return "DMC"
        }
    }

    var kindName: LocalizedStringKey {
        kind == .bead ? "Fuse beads" : "Cross-stitch thread"
    }

    var palette: [PatternColor] {
        switch self {
        case .perler:  return PatternColor.perler
        case .hama:    return PatternColor.hama
        case .artkalS: return PatternColor.artkalS
        case .dmc:     return PatternColor.dmc
        }
    }

    /// 큰 정사각 페그보드 한 장의 칸 수. 실은 보드가 없다.
    var boardSize: Int? { kind == .bead ? 29 : nil }

    /// 굵은 안내선 간격 — 비즈는 보드 경계, 십자수는 10칸마다.
    var majorGridStep: Int { boardSize ?? 10 }

    /// 비즈 한 알 지름 (mm).
    var beadPitchMM: Double { 5 }

    /// 무료로 만들 수 있는 가장 긴 변의 칸 수.
    var freeMaxSide: Int { kind == .bead ? 29 : 40 }

    /// Pro 로 만들 수 있는 가장 긴 변의 칸 수.
    var proMaxSide: Int { kind == .bead ? 116 : 200 }

    var minSide: Int { kind == .bead ? 10 : 20 }

    /// 크기 고르기에 보여 줄 빠른 선택지.
    var sizePresets: [Int] {
        kind == .bead ? [29, 58, 87, 116] : [40, 60, 80, 100, 150]
    }

    var defaultSide: Int { kind == .bead ? 29 : 40 }
    var defaultMaxColors: Int { kind == .bead ? 12 : 20 }
}

// MARK: - 도안

/// 저장되는 도안 한 장. `cells` 는 행 우선(가로 먼저)이며 값은 `colors` 의 인덱스, -1 은 빈칸.
struct BeadPattern: Codable, Identifiable, Equatable {
    var id = UUID()
    var title: String
    var createdAt = Date()
    var material: PatternMaterial
    /// 십자수 천의 1인치당 칸 수 (Aida 14 등). 비즈는 쓰지 않는다.
    var fabricCount: Int = 14
    var width: Int
    var height: Int
    var cells: [Int]
    var colors: [PatternColor]

    func index(x: Int, y: Int) -> Int { y * width + x }

    func colorIndex(x: Int, y: Int) -> Int { cells[index(x: x, y: y)] }

    /// 색마다 몇 개 쓰는지 — 많이 쓰는 색부터.
    var colorUsage: [(index: Int, color: PatternColor, count: Int)] {
        var counts = [Int](repeating: 0, count: colors.count)
        for c in cells where c >= 0 { counts[c] += 1 }
        return counts.enumerated()
            .filter { $0.element > 0 }
            .map { (index: $0.offset, color: colors[$0.offset], count: $0.element) }
            .sorted { $0.count > $1.count }
    }

    var filledCount: Int { cells.reduce(0) { $0 + ($1 >= 0 ? 1 : 0) } }

    /// 비즈 보드가 가로·세로로 몇 장 필요한지.
    var boards: (across: Int, down: Int)? {
        guard let b = material.boardSize else { return nil }
        return ((width + b - 1) / b, (height + b - 1) / b)
    }

    /// 완성 크기 (cm).
    var finishedSizeCM: (w: Double, h: Double) {
        switch material.kind {
        case .bead:
            return (Double(width) * material.beadPitchMM / 10, Double(height) * material.beadPitchMM / 10)
        case .thread:
            let perCM = Double(fabricCount) / 2.54
            return (Double(width) / perCM, Double(height) / perCM)
        }
    }

    var longestSide: Int { max(width, height) }

    /// 인쇄 도안에서 색마다 쓰는 기호. 사용량 순서대로 배정해 자주 쓰는 색이 읽기 쉬운 기호를 갖는다.
    var symbols: [Int: String] {
        var map: [Int: String] = [:]
        for (i, usage) in colorUsage.enumerated() {
            map[usage.index] = PatternSymbols.all[i % PatternSymbols.all.count]
        }
        return map
    }
}

enum PatternSymbols {
    /// 서로 헷갈리지 않는 기호들 (I·l·1, O·0 처럼 닮은 것은 뺐다).
    static let all: [String] = [
        "●", "■", "▲", "◆", "★", "♥", "✚", "✖",
        "A", "B", "C", "D", "E", "F", "G", "H", "K", "M", "N", "P", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
        "2", "3", "4", "5", "6", "7", "8", "9",
        "○", "□", "△", "◇", "☆", "♡", "◐", "◑", "▼", "▽", "♦", "♣", "♠", "#", "=", "+", "%", "&", "@", "?",
    ]
}
