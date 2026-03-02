//
//  LospecPalette.swift
//  PixelMe
//
//  Created by hyunho lee on 2026/03/01.
//

import Foundation

/// Lospec 팔레트 모델
struct LospecPalette: Codable, Identifiable, Equatable {
    let name: String
    let author: String?
    let colors: [String] // hex strings e.g. "1a1c2c"
    
    var id: String { name }
    
    /// hex → PixelColor 배열
    var pixelColors: [PixelColor] {
        colors.compactMap { PixelColor(hex: $0) }
    }
}

/// 인기 내장 팔레트 (Lospec에서 가장 많이 쓰이는 것들)
enum BuiltInPalette: String, CaseIterable, Identifiable {
    case pico8 = "PICO-8"
    case sweetie16 = "Sweetie 16"
    case endesga32 = "Endesga 32"
    case resurrect64 = "Resurrect 64"
    case gameboy = "GameBoy"
    case nes = "NES"
    case zughy32 = "Zughy 32"
    case dawnBringer16 = "DawnBringer 16"
    
    var id: String { rawValue }
    
    var colors: [PixelColor] {
        switch self {
        case .pico8:
            return hexArray(["000000","1d2b53","7e2553","008751",
                           "ab5236","5f574f","c2c3c7","fff1e8",
                           "ff004d","ffa300","ffec27","00e436",
                           "29adff","83769c","ff77a8","ffccaa"])
        case .sweetie16:
            return hexArray(["1a1c2c","5d275d","b13e53","ef7d57",
                           "ffcd75","a7f070","38b764","257179",
                           "29366f","3b5dc9","41a6f6","73eff7",
                           "f4f4f4","94b0c2","566c86","333c57"])
        case .endesga32:
            return hexArray(["be4a2f","d77643","ead4aa","e4a672",
                           "b86f50","733e39","3e2731","a22633",
                           "e43b44","f77622","feae34","fee761",
                           "63c74d","3e8948","265c42","193c3e",
                           "124e89","0099db","2ce8f5","ffffff",
                           "c0cbdc","8b9bb4","5a6988","3a4466",
                           "262b44","181425","ff0044","68386c",
                           "b55088","f6757a","e8b796","c28569"])
        case .resurrect64:
            return hexArray(["2e222f","3e3546","625565","966c6c",
                           "ab947a","694f62","7f708a","9babb2",
                           "c7dcd0","ffffff","6d3580","905ea9",
                           "a884f3","eaaded","8fd3ff","46cdcf",
                           "68a8ad","3e6958","41945f","63c64d",
                           "afdd6f","dcf57e","f4c85e","eb8a44",
                           "e06337","cc3636","862929","661c1e",
                           "4f0e0e","7d1b2f","b22241","e7374f",
                           "fc6f6b","fdb7b1","f2d1a4","c9a17c",
                           "976b4b","7c5c4b","6c524b","5b3a3a",
                           "4a2a2a","3a1a1a","2a0a0a","1a0a0a",
                           "574b67","50507c","687a86","6a8fa2",
                           "7eb1c4","a1cfdf","c3e5f0","e1f0f5",
                           "f0f5f0","d0dcd0","b0c0b0","90a090",
                           "708070","506050","304030","102010"])
        case .gameboy:
            return hexArray(["0f380f","306230","8bac0f","9bbc0f"])
        case .nes:
            return hexArray(["000000","fcfcfc","f8f8f8","bcbcbc",
                           "7c7c7c","a4e4fc","3cbcfc","0078f8",
                           "0000fc","b8b8f8","6888fc","0058f8",
                           "0000bc","d8b8f8","9878f8","6844fc",
                           "4428bc","f8b8f8","f878f8","d800cc",
                           "940084","f8a4c0","f85898","e40058",
                           "a80020","f0d0b0","f87858","f83800",
                           "a81000","fce0a8","fca044","e45c10",
                           "881400","f8d878","f8b800","ac7c00",
                           "503000","d8f878","b8f818","00b800",
                           "007800","b8f8b8","58d854","00a800",
                           "006800","b8f8d8","58f898","00a844",
                           "005800","00fcfc","00e8d8","008888",
                           "004058"])
        case .zughy32:
            return hexArray(["472d3c","5e3643","7a444a","a05b53",
                           "bf7958","eea160","f4cca1","b6d53c",
                           "71aa34","397b44","3c5956","302c2e",
                           "5a5353","7d7071","a0938e","cfc6b8",
                           "dff6f5","8aebf1","28ccdf","3978a8",
                           "394778","39314b","564064","8e478c",
                           "cd6093","ffaeb6","f4b41b","f47e1b",
                           "e6482e","a93b3b","827094","4f546b"])
        case .dawnBringer16:
            return hexArray(["140c1c","442434","30346d","4e4a4e",
                           "854c30","346524","d04648","757161",
                           "597dce","d27d2c","8595a1","6daa2c",
                           "d2aa99","6dc2ca","dad45e","deeed6"])
        }
    }
    
    private func hexArray(_ hexes: [String]) -> [PixelColor] {
        hexes.compactMap { PixelColor(hex: $0) }
    }
}

// MARK: - PixelColor hex init

extension PixelColor {
    init?(hex: String) {
        let clean = hex.trimmingCharacters(in: .init(charactersIn: "#"))
        guard clean.count == 6 else { return nil }
        
        var rgb: UInt64 = 0
        Scanner(string: clean).scanHexInt64(&rgb)
        
        self.init(
            r: UInt8((rgb >> 16) & 0xFF),
            g: UInt8((rgb >> 8) & 0xFF),
            b: UInt8(rgb & 0xFF),
            a: 255
        )
    }
    
    var hexString: String {
        String(format: "#%02X%02X%02X", r, g, b)
    }
}
