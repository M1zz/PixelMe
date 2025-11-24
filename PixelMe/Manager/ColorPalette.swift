//
//  ColorPalette.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/01.
//

import SwiftUI
import UIKit

/// Color palette types
enum ColorPaletteType: String, CaseIterable, Identifiable {
    case none = "Original"
    case gameboy = "GameBoy"
    case nes = "NES"
    case snes = "SNES"
    case vaporwave = "Vaporwave"
    case cyberpunk = "Cyberpunk"
    case pastel = "Pastel"
    case retro8bit = "8-Bit Retro"
    case noir = "Film Noir"

    var id: String { rawValue }

    var colors: [UIColor] {
        switch self {
        case .none:
            return []
        case .gameboy:
            return [
                UIColor(red: 15/255, green: 56/255, blue: 15/255, alpha: 1),
                UIColor(red: 48/255, green: 98/255, blue: 48/255, alpha: 1),
                UIColor(red: 139/255, green: 172/255, blue: 15/255, alpha: 1),
                UIColor(red: 155/255, green: 188/255, blue: 15/255, alpha: 1)
            ]
        case .nes:
            return [
                UIColor(red: 124/255, green: 124/255, blue: 124/255, alpha: 1),
                UIColor(red: 0/255, green: 0/255, blue: 252/255, alpha: 1),
                UIColor(red: 0/255, green: 0/255, blue: 188/255, alpha: 1),
                UIColor(red: 68/255, green: 40/255, blue: 188/255, alpha: 1),
                UIColor(red: 148/255, green: 0/255, blue: 132/255, alpha: 1),
                UIColor(red: 168/255, green: 0/255, blue: 32/255, alpha: 1),
                UIColor(red: 168/255, green: 16/255, blue: 0/255, alpha: 1),
                UIColor(red: 136/255, green: 20/255, blue: 0/255, alpha: 1),
                UIColor(red: 80/255, green: 48/255, blue: 0/255, alpha: 1),
                UIColor(red: 0/255, green: 120/255, blue: 0/255, alpha: 1),
                UIColor(red: 0/255, green: 104/255, blue: 0/255, alpha: 1),
                UIColor(red: 0/255, green: 88/255, blue: 0/255, alpha: 1),
                UIColor(red: 0/255, green: 64/255, blue: 88/255, alpha: 1),
                UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1),
                UIColor(red: 188/255, green: 188/255, blue: 188/255, alpha: 1),
                UIColor(red: 0/255, green: 120/255, blue: 248/255, alpha: 1),
                UIColor(red: 0/255, green: 88/255, blue: 248/255, alpha: 1),
                UIColor(red: 104/255, green: 68/255, blue: 252/255, alpha: 1),
                UIColor(red: 216/255, green: 0/255, blue: 204/255, alpha: 1),
                UIColor(red: 228/255, green: 0/255, blue: 88/255, alpha: 1),
                UIColor(red: 248/255, green: 56/255, blue: 0/255, alpha: 1),
                UIColor(red: 228/255, green: 92/255, blue: 16/255, alpha: 1),
                UIColor(red: 172/255, green: 124/255, blue: 0/255, alpha: 1),
                UIColor(red: 0/255, green: 184/255, blue: 0/255, alpha: 1),
                UIColor(red: 0/255, green: 168/255, blue: 0/255, alpha: 1),
                UIColor(red: 0/255, green: 168/255, blue: 68/255, alpha: 1),
                UIColor(red: 0/255, green: 136/255, blue: 136/255, alpha: 1),
                UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1),
                UIColor(red: 60/255, green: 188/255, blue: 252/255, alpha: 1),
                UIColor(red: 92/255, green: 148/255, blue: 252/255, alpha: 1),
                UIColor(red: 164/255, green: 140/255, blue: 252/255, alpha: 1),
                UIColor(red: 248/255, green: 120/255, blue: 248/255, alpha: 1)
            ]
        case .snes:
            return [
                UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1),
                UIColor(red: 64/255, green: 64/255, blue: 64/255, alpha: 1),
                UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1),
                UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1),
                UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
                UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1),
                UIColor(red: 255/255, green: 128/255, blue: 0/255, alpha: 1),
                UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 1),
                UIColor(red: 128/255, green: 255/255, blue: 0/255, alpha: 1),
                UIColor(red: 0/255, green: 255/255, blue: 0/255, alpha: 1),
                UIColor(red: 0/255, green: 255/255, blue: 128/255, alpha: 1),
                UIColor(red: 0/255, green: 255/255, blue: 255/255, alpha: 1),
                UIColor(red: 0/255, green: 128/255, blue: 255/255, alpha: 1),
                UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1),
                UIColor(red: 128/255, green: 0/255, blue: 255/255, alpha: 1),
                UIColor(red: 255/255, green: 0/255, blue: 255/255, alpha: 1)
            ]
        case .vaporwave:
            return [
                UIColor(red: 1/255, green: 0/255, blue: 38/255, alpha: 1),
                UIColor(red: 255/255, green: 71/255, blue: 166/255, alpha: 1),
                UIColor(red: 1/255, green: 168/255, blue: 233/255, alpha: 1),
                UIColor(red: 179/255, green: 0/255, blue: 255/255, alpha: 1),
                UIColor(red: 94/255, green: 53/255, blue: 177/255, alpha: 1),
                UIColor(red: 255/255, green: 128/255, blue: 255/255, alpha: 1),
                UIColor(red: 0/255, green: 229/255, blue: 255/255, alpha: 1),
                UIColor(red: 255/255, green: 85/255, blue: 255/255, alpha: 1)
            ]
        case .cyberpunk:
            return [
                UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1),
                UIColor(red: 255/255, green: 0/255, blue: 255/255, alpha: 1),
                UIColor(red: 0/255, green: 255/255, blue: 255/255, alpha: 1),
                UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 1),
                UIColor(red: 255/255, green: 0/255, blue: 110/255, alpha: 1),
                UIColor(red: 0/255, green: 204/255, blue: 255/255, alpha: 1),
                UIColor(red: 163/255, green: 0/255, blue: 255/255, alpha: 1),
                UIColor(red: 255/255, green: 154/255, blue: 0/255, alpha: 1)
            ]
        case .pastel:
            return [
                UIColor(red: 255/255, green: 209/255, blue: 220/255, alpha: 1),
                UIColor(red: 255/255, green: 242/255, blue: 204/255, alpha: 1),
                UIColor(red: 255/255, green: 255/255, blue: 204/255, alpha: 1),
                UIColor(red: 204/255, green: 255/255, blue: 229/255, alpha: 1),
                UIColor(red: 204/255, green: 239/255, blue: 255/255, alpha: 1),
                UIColor(red: 230/255, green: 204/255, blue: 255/255, alpha: 1),
                UIColor(red: 255/255, green: 204/255, blue: 229/255, alpha: 1),
                UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            ]
        case .retro8bit:
            return [
                UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1),
                UIColor(red: 29/255, green: 43/255, blue: 83/255, alpha: 1),
                UIColor(red: 126/255, green: 37/255, blue: 83/255, alpha: 1),
                UIColor(red: 0/255, green: 135/255, blue: 81/255, alpha: 1),
                UIColor(red: 171/255, green: 82/255, blue: 54/255, alpha: 1),
                UIColor(red: 95/255, green: 87/255, blue: 79/255, alpha: 1),
                UIColor(red: 194/255, green: 195/255, blue: 199/255, alpha: 1),
                UIColor(red: 255/255, green: 241/255, blue: 232/255, alpha: 1),
                UIColor(red: 255/255, green: 0/255, blue: 77/255, alpha: 1),
                UIColor(red: 255/255, green: 163/255, blue: 0/255, alpha: 1),
                UIColor(red: 255/255, green: 236/255, blue: 39/255, alpha: 1),
                UIColor(red: 0/255, green: 228/255, blue: 54/255, alpha: 1),
                UIColor(red: 41/255, green: 173/255, blue: 255/255, alpha: 1),
                UIColor(red: 131/255, green: 118/255, blue: 156/255, alpha: 1),
                UIColor(red: 255/255, green: 119/255, blue: 168/255, alpha: 1),
                UIColor(red: 255/255, green: 204/255, blue: 170/255, alpha: 1)
            ]
        case .noir:
            return [
                UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1),
                UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1),
                UIColor(red: 64/255, green: 64/255, blue: 64/255, alpha: 1),
                UIColor(red: 96/255, green: 96/255, blue: 96/255, alpha: 1),
                UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1),
                UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1),
                UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1),
                UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1),
                UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            ]
        }
    }

    var description: String {
        switch self {
        case .none:
            return "Keep original colors"
        case .gameboy:
            return "Classic GameBoy green tones"
        case .nes:
            return "Nintendo Entertainment System palette"
        case .snes:
            return "Super Nintendo bright colors"
        case .vaporwave:
            return "Pink, purple, and cyan aesthetic"
        case .cyberpunk:
            return "Neon colors for futuristic look"
        case .pastel:
            return "Soft and gentle colors"
        case .retro8bit:
            return "Classic 8-bit game colors"
        case .noir:
            return "Black and white film style"
        }
    }
}

/// Custom color palette that users can create
struct CustomColorPalette: Identifiable, Codable {
    let id: UUID
    var name: String
    var colors: [String] // Hex color strings

    init(id: UUID = UUID(), name: String, colors: [UIColor]) {
        self.id = id
        self.name = name
        self.colors = colors.map { $0.toHexString() }
    }

    func getUIColors() -> [UIColor] {
        return colors.compactMap { UIColor(hexString: $0) }
    }
}

// MARK: - UIColor extensions for color palette
extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format: "#%06x", rgb)
    }

    convenience init?(hexString: String) {
        let r, g, b: CGFloat

        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: 1.0)
                    return
                }
            }
        }

        return nil
    }

    /// Find closest color in palette
    func closestColor(in palette: [UIColor]) -> UIColor {
        guard !palette.isEmpty else { return self }

        var closestColor = palette[0]
        var minDistance = colorDistance(to: palette[0])

        for color in palette {
            let distance = colorDistance(to: color)
            if distance < minDistance {
                minDistance = distance
                closestColor = color
            }
        }

        return closestColor
    }

    /// Calculate color distance using Euclidean distance in RGB space
    private func colorDistance(to color: UIColor) -> CGFloat {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return sqrt(pow(r1 - r2, 2) + pow(g1 - g2, 2) + pow(b1 - b2, 2))
    }
}
