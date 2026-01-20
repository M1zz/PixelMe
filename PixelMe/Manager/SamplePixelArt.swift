//
//  SamplePixelArt.swift
//  PixelMe
//
//  Created by Claude on 2026/01/20.
//  Pre-made pixel art samples for user inspiration - 100+ samples
//

import SwiftUI

/// Sample pixel art data structure
struct SamplePixelArt: Identifiable {
    let id = UUID()
    let name: String
    let category: SampleCategory
    let boardSize: PixelBoardSize
    let pixels: [String: Color]
    let backgroundColor: Color

    var filledPixels: [String] { Array(pixels.keys) }
}

/// Categories for organizing samples
enum SampleCategory: String, CaseIterable {
    case nature = "Nature"
    case food = "Food"
    case animals = "Animals"
    case gaming = "Gaming"
    case objects = "Objects"
    case space = "Space"
    case characters = "Characters"
    case seasonal = "Seasonal"
}

// MARK: - Color Palette Helpers
struct PixelColors {
    // Basic
    static let white = Color.white
    static let black = Color.black

    // Reds
    static let red = Color(red: 1.0, green: 0.2, blue: 0.3)
    static let darkRed = Color(red: 0.7, green: 0.1, blue: 0.15)
    static let lightRed = Color(red: 1.0, green: 0.5, blue: 0.5)
    static let pink = Color(red: 1.0, green: 0.4, blue: 0.6)
    static let darkPink = Color(red: 0.9, green: 0.2, blue: 0.4)
    static let hotPink = Color(red: 1.0, green: 0.1, blue: 0.5)
    static let lightPink = Color(red: 1.0, green: 0.75, blue: 0.8)

    // Oranges
    static let orange = Color(red: 1.0, green: 0.6, blue: 0.2)
    static let darkOrange = Color(red: 0.9, green: 0.4, blue: 0.1)
    static let lightOrange = Color(red: 1.0, green: 0.8, blue: 0.5)

    // Yellows
    static let yellow = Color(red: 1.0, green: 0.85, blue: 0.0)
    static let lightYellow = Color(red: 1.0, green: 0.95, blue: 0.6)
    static let gold = Color(red: 0.85, green: 0.65, blue: 0.1)

    // Greens
    static let green = Color(red: 0.2, green: 0.7, blue: 0.3)
    static let darkGreen = Color(red: 0.1, green: 0.5, blue: 0.2)
    static let lightGreen = Color(red: 0.5, green: 0.9, blue: 0.5)
    static let lime = Color(red: 0.7, green: 1.0, blue: 0.3)

    // Blues
    static let blue = Color(red: 0.3, green: 0.6, blue: 1.0)
    static let darkBlue = Color(red: 0.1, green: 0.3, blue: 0.7)
    static let lightBlue = Color(red: 0.6, green: 0.8, blue: 1.0)
    static let skyBlue = Color(red: 0.5, green: 0.8, blue: 1.0)
    static let cyan = Color(red: 0.0, green: 0.9, blue: 0.9)
    static let navy = Color(red: 0.1, green: 0.1, blue: 0.4)

    // Purples
    static let purple = Color(red: 0.6, green: 0.3, blue: 0.9)
    static let darkPurple = Color(red: 0.4, green: 0.1, blue: 0.6)
    static let lightPurple = Color(red: 0.8, green: 0.6, blue: 1.0)
    static let magenta = Color(red: 0.9, green: 0.2, blue: 0.8)

    // Browns
    static let brown = Color(red: 0.55, green: 0.35, blue: 0.15)
    static let darkBrown = Color(red: 0.35, green: 0.2, blue: 0.1)
    static let lightBrown = Color(red: 0.75, green: 0.55, blue: 0.35)
    static let beige = Color(red: 0.95, green: 0.85, blue: 0.7)
    static let tan = Color(red: 0.85, green: 0.7, blue: 0.5)

    // Grays
    static let gray = Color(red: 0.5, green: 0.5, blue: 0.5)
    static let darkGray = Color(red: 0.3, green: 0.3, blue: 0.3)
    static let lightGray = Color(red: 0.75, green: 0.75, blue: 0.75)
    static let silver = Color(red: 0.8, green: 0.8, blue: 0.85)

    // Skin tones
    static let skin1 = Color(red: 1.0, green: 0.87, blue: 0.77)
    static let skin2 = Color(red: 0.87, green: 0.72, blue: 0.53)
    static let skin3 = Color(red: 0.55, green: 0.38, blue: 0.26)
}

// MARK: - Sample Collection
struct SamplePixelArtCollection {

    static let all: [SamplePixelArt] =
        nature8x8 + nature16x16 +
        food8x8 + food16x16 +
        animals8x8 + animals16x16 +
        gaming8x8 + gaming16x16 +
        objects8x8 + objects16x16 +
        space8x8 + space16x16 +
        characters8x8 + characters16x16 +
        seasonal8x8 + seasonal16x16

    static func samples(for category: SampleCategory) -> [SamplePixelArt] {
        all.filter { $0.category == category }
    }

    static func samples(for size: PixelBoardSize) -> [SamplePixelArt] {
        all.filter { $0.boardSize == size }
    }

    // MARK: - Nature 8x8
    static let nature8x8: [SamplePixelArt] = [
        SamplePixelArt(name: "Sunflower", category: .nature, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["3_0","4_0","2_1","5_1","1_2","6_2","0_3","7_3","0_4","7_4","1_5","6_5","2_6","5_6","3_7","4_7"] { p[pos] = PixelColors.yellow }
            for pos in ["3_2","4_2","2_3","3_3","4_3","5_3","2_4","3_4","4_4","5_4","3_5","4_5"] { p[pos] = PixelColors.brown }
            p["3_6"] = PixelColors.green; p["4_6"] = PixelColors.green
            return p
        }(), backgroundColor: PixelColors.skyBlue),

        SamplePixelArt(name: "Tulip", category: .nature, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            p["3_0"] = PixelColors.darkPink; p["4_0"] = PixelColors.darkPink
            for pos in ["2_1","3_1","4_1","5_1","2_2","3_2","4_2","5_2","3_3","4_3"] { p[pos] = PixelColors.pink }
            for pos in ["3_4","4_4","3_5","4_5","3_6","4_6"] { p[pos] = PixelColors.green }
            p["2_5"] = PixelColors.darkGreen; p["5_6"] = PixelColors.darkGreen
            return p
        }(), backgroundColor: PixelColors.beige),

        SamplePixelArt(name: "Rose", category: .nature, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["3_1","4_1","2_2","3_2","4_2","5_2","2_3","3_3","4_3","5_3","3_4","4_4"] { p[pos] = PixelColors.red }
            p["3_2"] = PixelColors.darkRed; p["4_3"] = PixelColors.darkRed
            for pos in ["3_5","4_5","3_6","4_6","3_7","4_7"] { p[pos] = PixelColors.green }
            p["2_6"] = PixelColors.darkGreen; p["5_5"] = PixelColors.darkGreen
            return p
        }(), backgroundColor: Color(red: 0.95, green: 0.95, blue: 0.95)),

        SamplePixelArt(name: "Tree", category: .nature, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["3_0","4_0","2_1","3_1","4_1","5_1","1_2","2_2","3_2","4_2","5_2","6_2","0_3","1_3","2_3","3_3","4_3","5_3","6_3","7_3","1_4","2_4","3_4","4_4","5_4","6_4"] { p[pos] = PixelColors.green }
            for pos in ["3_5","4_5","3_6","4_6","3_7","4_7"] { p[pos] = PixelColors.brown }
            return p
        }(), backgroundColor: PixelColors.skyBlue),

        SamplePixelArt(name: "Cactus", category: .nature, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["3_0","4_0","3_1","4_1","3_2","4_2","1_3","2_3","3_3","4_3","5_3","6_3","1_4","3_4","4_4","6_4","1_5","3_5","4_5","6_5","3_6","4_6","3_7","4_7"] { p[pos] = PixelColors.green }
            p["3_1"] = PixelColors.darkGreen; p["4_4"] = PixelColors.darkGreen
            return p
        }(), backgroundColor: Color(red: 1.0, green: 0.9, blue: 0.7)),

        SamplePixelArt(name: "Leaf", category: .nature, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["4_0","3_1","4_1","5_1","2_2","3_2","4_2","5_2","6_2","1_3","2_3","3_3","4_3","5_3","6_3","2_4","3_4","4_4","5_4","3_5","4_5","4_6"] { p[pos] = PixelColors.green }
            for pos in ["3_3","3_4","4_5","4_6"] { p[pos] = PixelColors.darkGreen }
            return p
        }(), backgroundColor: Color(red: 0.9, green: 0.95, blue: 1.0)),

        SamplePixelArt(name: "Mushroom", category: .nature, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["2_0","3_0","4_0","5_0","1_1","2_1","3_1","4_1","5_1","6_1","0_2","1_2","2_2","3_2","4_2","5_2","6_2","7_2","0_3","1_3","2_3","3_3","4_3","5_3","6_3","7_3"] { p[pos] = PixelColors.red }
            for pos in ["2_1","5_1","1_2","2_2","5_2","6_2"] { p[pos] = PixelColors.white }
            for pos in ["2_4","3_4","4_4","5_4","2_5","3_5","4_5","5_5","2_6","3_6","4_6","5_6"] { p[pos] = PixelColors.beige }
            return p
        }(), backgroundColor: PixelColors.skyBlue),

        SamplePixelArt(name: "Clover", category: .nature, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["2_1","3_1","4_1","5_1","1_2","2_2","5_2","6_2","1_3","2_3","5_3","6_3","2_4","3_4","4_4","5_4"] { p[pos] = PixelColors.green }
            for pos in ["3_5","4_5","3_6","4_6","4_7"] { p[pos] = PixelColors.darkGreen }
            return p
        }(), backgroundColor: Color(red: 0.9, green: 1.0, blue: 0.9))
    ]

    // MARK: - Nature 16x16
    static let nature16x16: [SamplePixelArt] = [
        SamplePixelArt(name: "Pine Tree", category: .nature, boardSize: .low, pixels: {
            var p = [String: Color]()
            for x in 7...8 { p["\(x)_0"] = PixelColors.darkGreen }
            for x in 6...9 { p["\(x)_1"] = PixelColors.green; p["\(x)_2"] = PixelColors.green }
            for x in 5...10 { p["\(x)_3"] = PixelColors.green; p["\(x)_4"] = PixelColors.green }
            for x in 4...11 { p["\(x)_5"] = PixelColors.green; p["\(x)_6"] = PixelColors.green }
            for x in 3...12 { p["\(x)_7"] = PixelColors.green; p["\(x)_8"] = PixelColors.green }
            for x in 2...13 { p["\(x)_9"] = PixelColors.green; p["\(x)_10"] = PixelColors.darkGreen }
            for y in 11...15 { p["7_\(y)"] = PixelColors.brown; p["8_\(y)"] = PixelColors.brown }
            return p
        }(), backgroundColor: PixelColors.skyBlue),

        SamplePixelArt(name: "Daisy", category: .nature, boardSize: .low, pixels: {
            var p = [String: Color]()
            for pos in ["7_2","8_2","6_3","9_3","5_4","10_4","4_5","11_5","4_6","11_6","5_7","10_7","6_8","9_8","7_9","8_9"] { p[pos] = PixelColors.white }
            for x in 6...9 { for y in 4...7 { p["\(x)_\(y)"] = PixelColors.yellow } }
            for y in 10...15 { p["7_\(y)"] = PixelColors.green; p["8_\(y)"] = PixelColors.green }
            p["5_12"] = PixelColors.darkGreen; p["6_11"] = PixelColors.darkGreen
            p["10_13"] = PixelColors.darkGreen; p["9_12"] = PixelColors.darkGreen
            return p
        }(), backgroundColor: Color(red: 0.85, green: 0.95, blue: 1.0)),

        SamplePixelArt(name: "Palm Tree", category: .nature, boardSize: .low, pixels: {
            var p = [String: Color]()
            for y in 6...15 { p["7_\(y)"] = PixelColors.brown; p["8_\(y)"] = PixelColors.lightBrown }
            for pos in ["7_2","8_2","5_3","6_3","9_3","10_3","3_4","4_4","11_4","12_4","2_5","13_5","4_5","5_5","10_5","11_5","5_6","6_6","9_6","10_6"] { p[pos] = PixelColors.green }
            return p
        }(), backgroundColor: Color(red: 0.5, green: 0.8, blue: 1.0)),

        SamplePixelArt(name: "Bamboo", category: .nature, boardSize: .low, pixels: {
            var p = [String: Color]()
            for y in 0...15 { p["7_\(y)"] = PixelColors.green; p["8_\(y)"] = PixelColors.lightGreen }
            for y in [3,7,11] { p["6_\(y)"] = PixelColors.darkGreen; p["9_\(y)"] = PixelColors.darkGreen }
            for pos in ["4_2","5_2","5_3","10_5","11_5","10_6","4_9","5_9","5_10","10_12","11_12","10_13"] { p[pos] = PixelColors.green }
            return p
        }(), backgroundColor: Color(red: 0.9, green: 0.95, blue: 0.85)),

        SamplePixelArt(name: "Bonsai", category: .nature, boardSize: .low, pixels: {
            var p = [String: Color]()
            for x in 5...10 { for y in 2...5 { p["\(x)_\(y)"] = PixelColors.green } }
            for x in 3...6 { p["\(x)_4"] = PixelColors.green; p["\(x)_5"] = PixelColors.darkGreen }
            for x in 9...12 { p["\(x)_3"] = PixelColors.green; p["\(x)_4"] = PixelColors.darkGreen }
            for y in 6...12 { p["7_\(y)"] = PixelColors.brown; p["8_\(y)"] = PixelColors.brown }
            p["6_10"] = PixelColors.brown; p["9_9"] = PixelColors.brown
            for x in 4...11 { p["\(x)_13"] = PixelColors.darkBrown; p["\(x)_14"] = PixelColors.tan }
            return p
        }(), backgroundColor: Color(red: 0.95, green: 0.95, blue: 0.9)),

        SamplePixelArt(name: "Sakura", category: .nature, boardSize: .low, pixels: {
            var p = [String: Color]()
            for y in 8...15 { p["7_\(y)"] = PixelColors.brown; p["8_\(y)"] = PixelColors.brown }
            p["5_10"] = PixelColors.brown; p["6_9"] = PixelColors.brown
            p["10_11"] = PixelColors.brown; p["9_10"] = PixelColors.brown
            for x in 4...11 { for y in 1...6 { if (x+y) % 3 != 0 { p["\(x)_\(y)"] = PixelColors.pink } } }
            for pos in ["6_2","9_3","5_5","10_4","7_1","8_6"] { p[pos] = PixelColors.white }
            return p
        }(), backgroundColor: Color(red: 0.95, green: 0.9, blue: 0.95))
    ]

    // MARK: - Food 8x8
    static let food8x8: [SamplePixelArt] = [
        SamplePixelArt(name: "Apple", category: .food, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            p["4_0"] = PixelColors.brown; p["4_1"] = PixelColors.green
            for pos in ["2_2","3_2","4_2","5_2","1_3","2_3","3_3","4_3","5_3","6_3","1_4","2_4","3_4","4_4","5_4","6_4","1_5","2_5","3_5","4_5","5_5","6_5","2_6","3_6","4_6","5_6"] { p[pos] = PixelColors.red }
            p["2_3"] = PixelColors.lightRed
            return p
        }(), backgroundColor: PixelColors.white),

        SamplePixelArt(name: "Cherry", category: .food, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            p["4_0"] = PixelColors.green; p["3_1"] = PixelColors.green; p["5_1"] = PixelColors.green
            p["2_2"] = PixelColors.green; p["6_2"] = PixelColors.green
            for pos in ["1_3","2_3","0_4","1_4","2_4","3_4","0_5","1_5","2_5","3_5","1_6","2_6"] { p[pos] = PixelColors.red }
            for pos in ["5_3","6_3","4_4","5_4","6_4","7_4","4_5","5_5","6_5","7_5","5_6","6_6"] { p[pos] = PixelColors.red }
            p["1_3"] = PixelColors.white; p["5_3"] = PixelColors.white
            return p
        }(), backgroundColor: PixelColors.beige),

        SamplePixelArt(name: "Banana", category: .food, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["5_1","6_1","4_2","5_2","3_3","4_3","2_4","3_4","2_5","3_5","2_6","3_6","3_7","4_7"] { p[pos] = PixelColors.yellow }
            p["6_1"] = PixelColors.brown; p["4_7"] = PixelColors.brown
            return p
        }(), backgroundColor: PixelColors.white),

        SamplePixelArt(name: "Orange", category: .food, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            p["3_0"] = PixelColors.green; p["4_0"] = PixelColors.green
            for pos in ["2_1","3_1","4_1","5_1","1_2","2_2","3_2","4_2","5_2","6_2","1_3","2_3","3_3","4_3","5_3","6_3","1_4","2_4","3_4","4_4","5_4","6_4","2_5","3_5","4_5","5_5","3_6","4_6"] { p[pos] = PixelColors.orange }
            p["2_2"] = PixelColors.lightOrange
            return p
        }(), backgroundColor: PixelColors.white),

        SamplePixelArt(name: "Watermelon", category: .food, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["1_1","2_1","3_1","4_1","5_1","6_1","0_2","1_2","2_2","3_2","4_2","5_2","6_2","7_2","0_3","1_3","2_3","3_3","4_3","5_3","6_3","7_3"] { p[pos] = PixelColors.red }
            for pos in ["1_4","2_4","3_4","4_4","5_4","6_4","2_5","3_5","4_5","5_5"] { p[pos] = PixelColors.red }
            for pos in ["0_4","7_4","1_5","6_5","2_6","3_6","4_6","5_6"] { p[pos] = PixelColors.green }
            p["2_2"] = PixelColors.black; p["5_3"] = PixelColors.black; p["3_4"] = PixelColors.black
            return p
        }(), backgroundColor: PixelColors.white),

        SamplePixelArt(name: "Pizza", category: .food, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["3_0","4_0","2_1","3_1","4_1","5_1","1_2","2_2","3_2","4_2","5_2","6_2","0_3","1_3","2_3","3_3","4_3","5_3","6_3","7_3"] { p[pos] = PixelColors.yellow }
            for pos in ["3_1","4_1","2_2","5_2","1_3","6_3"] { p[pos] = PixelColors.red }
            for pos in ["3_2","4_2","3_3","4_3"] { p[pos] = PixelColors.orange }
            for x in 0...7 { p["\(x)_4"] = PixelColors.tan }
            return p
        }(), backgroundColor: PixelColors.white),

        SamplePixelArt(name: "Ice Cream", category: .food, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["2_0","3_0","4_0","5_0","1_1","2_1","3_1","4_1","5_1","6_1","2_2","3_2","4_2","5_2","3_3","4_3"] { p[pos] = PixelColors.pink }
            p["2_1"] = PixelColors.white; p["5_2"] = PixelColors.white
            for pos in ["3_4","4_4","3_5","4_5","3_6","4_6","4_7"] { p[pos] = PixelColors.tan }
            return p
        }(), backgroundColor: PixelColors.skyBlue),

        SamplePixelArt(name: "Donut", category: .food, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["2_1","3_1","4_1","5_1","1_2","2_2","5_2","6_2","1_3","2_3","5_3","6_3","1_4","2_4","5_4","6_4","2_5","3_5","4_5","5_5"] { p[pos] = PixelColors.tan }
            for pos in ["2_1","3_1","4_1","5_1","1_2","2_2","5_2","6_2","1_3","6_3"] { p[pos] = PixelColors.pink }
            p["3_1"] = PixelColors.yellow; p["4_2"] = PixelColors.cyan; p["2_3"] = PixelColors.green
            return p
        }(), backgroundColor: PixelColors.white)
    ]

    // MARK: - Food 16x16
    static let food16x16: [SamplePixelArt] = [
        SamplePixelArt(name: "Burger", category: .food, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Top bun
            for x in 4...11 { p["\(x)_2"] = PixelColors.tan }
            for x in 3...12 { p["\(x)_3"] = PixelColors.orange; p["\(x)_4"] = PixelColors.tan }
            // Seeds
            p["5_3"] = PixelColors.white; p["7_3"] = PixelColors.white; p["10_3"] = PixelColors.white
            // Lettuce
            for x in 3...12 { p["\(x)_5"] = PixelColors.green }
            // Cheese
            for x in 3...12 { p["\(x)_6"] = PixelColors.yellow }
            p["2_6"] = PixelColors.yellow; p["13_6"] = PixelColors.yellow
            // Patty
            for x in 3...12 { p["\(x)_7"] = PixelColors.brown; p["\(x)_8"] = PixelColors.darkBrown }
            // Bottom bun
            for x in 3...12 { p["\(x)_9"] = PixelColors.tan; p["\(x)_10"] = PixelColors.orange }
            for x in 4...11 { p["\(x)_11"] = PixelColors.tan }
            return p
        }(), backgroundColor: PixelColors.white),

        SamplePixelArt(name: "Cupcake", category: .food, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Cherry
            p["7_1"] = PixelColors.red; p["8_1"] = PixelColors.red; p["7_2"] = PixelColors.red; p["8_2"] = PixelColors.red
            // Frosting
            for x in 5...10 { p["\(x)_3"] = PixelColors.pink; p["\(x)_4"] = PixelColors.pink }
            for x in 4...11 { p["\(x)_5"] = PixelColors.lightPink; p["\(x)_6"] = PixelColors.pink }
            for x in 3...12 { p["\(x)_7"] = PixelColors.pink }
            // Wrapper
            for x in 4...11 { for y in 8...12 { p["\(x)_\(y)"] = PixelColors.cyan } }
            for x in 5...10 { p["\(x)_13"] = PixelColors.darkBlue }
            return p
        }(), backgroundColor: PixelColors.white),

        SamplePixelArt(name: "Sushi", category: .food, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Rice base
            for x in 3...12 { for y in 6...12 { p["\(x)_\(y)"] = PixelColors.white } }
            // Nori wrap
            for y in 6...12 { p["3_\(y)"] = PixelColors.darkGreen; p["12_\(y)"] = PixelColors.darkGreen }
            // Salmon on top
            for x in 4...11 { for y in 3...6 { p["\(x)_\(y)"] = PixelColors.orange } }
            for x in 5...10 { p["\(x)_2"] = PixelColors.orange }
            // Salmon detail
            for pos in ["5_4","7_3","9_5","6_5","10_4"] { p[pos] = PixelColors.lightOrange }
            return p
        }(), backgroundColor: Color(red: 0.95, green: 0.95, blue: 0.9)),

        SamplePixelArt(name: "Ramen", category: .food, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Bowl
            for x in 2...13 { p["\(x)_6"] = PixelColors.white; p["\(x)_13"] = PixelColors.white }
            for y in 6...13 { p["2_\(y)"] = PixelColors.white; p["13_\(y)"] = PixelColors.white }
            // Broth
            for x in 3...12 { for y in 7...12 { p["\(x)_\(y)"] = PixelColors.yellow } }
            // Egg
            for pos in ["4_8","5_8","4_9","5_9"] { p[pos] = PixelColors.white }
            p["4_8"] = PixelColors.yellow; p["5_9"] = PixelColors.yellow
            // Noodles
            for pos in ["7_9","8_9","9_9","6_10","7_10","8_10","9_10","10_10","7_11","8_11","9_11"] { p[pos] = PixelColors.beige }
            // Nori
            p["10_8"] = PixelColors.darkGreen; p["11_8"] = PixelColors.darkGreen; p["10_9"] = PixelColors.darkGreen; p["11_9"] = PixelColors.darkGreen
            // Chopsticks
            p["14_4"] = PixelColors.brown; p["15_3"] = PixelColors.brown; p["14_5"] = PixelColors.brown; p["15_4"] = PixelColors.brown
            return p
        }(), backgroundColor: Color(red: 0.9, green: 0.9, blue: 0.9)),

        SamplePixelArt(name: "Cake", category: .food, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Candle
            p["7_1"] = PixelColors.yellow; p["8_1"] = PixelColors.orange
            p["7_2"] = PixelColors.red; p["8_2"] = PixelColors.red
            p["7_3"] = PixelColors.red; p["8_3"] = PixelColors.red
            // Top layer
            for x in 3...12 { p["\(x)_4"] = PixelColors.pink; p["\(x)_5"] = PixelColors.lightPink }
            // Cream
            for x in 3...12 { p["\(x)_6"] = PixelColors.white }
            // Middle layer
            for x in 3...12 { p["\(x)_7"] = PixelColors.pink; p["\(x)_8"] = PixelColors.lightPink }
            // Cream
            for x in 3...12 { p["\(x)_9"] = PixelColors.white }
            // Bottom layer
            for x in 3...12 { p["\(x)_10"] = PixelColors.pink; p["\(x)_11"] = PixelColors.lightPink; p["\(x)_12"] = PixelColors.pink }
            // Plate
            for x in 2...13 { p["\(x)_13"] = PixelColors.lightGray }
            return p
        }(), backgroundColor: PixelColors.white),

        SamplePixelArt(name: "Coffee", category: .food, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Steam
            p["6_1"] = PixelColors.lightGray; p["9_0"] = PixelColors.lightGray; p["7_2"] = PixelColors.lightGray
            // Cup
            for x in 4...11 { p["\(x)_4"] = PixelColors.white }
            for y in 4...12 { p["4_\(y)"] = PixelColors.white; p["11_\(y)"] = PixelColors.white }
            for x in 4...11 { p["\(x)_12"] = PixelColors.white }
            // Coffee
            for x in 5...10 { for y in 5...11 { p["\(x)_\(y)"] = PixelColors.brown } }
            for x in 5...10 { p["\(x)_5"] = PixelColors.lightBrown }
            // Handle
            for y in 6...10 { p["12_\(y)"] = PixelColors.white }
            p["13_7"] = PixelColors.white; p["13_8"] = PixelColors.white; p["13_9"] = PixelColors.white
            // Saucer
            for x in 2...13 { p["\(x)_13"] = PixelColors.lightGray; p["\(x)_14"] = PixelColors.white }
            return p
        }(), backgroundColor: Color(red: 0.95, green: 0.92, blue: 0.9))
    ]

    // MARK: - Animals 8x8
    static let animals8x8: [SamplePixelArt] = [
        SamplePixelArt(name: "Cat", category: .animals, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            p["1_0"] = PixelColors.orange; p["6_0"] = PixelColors.orange
            for pos in ["0_1","1_1","2_1","5_1","6_1","7_1","0_2","1_2","2_2","3_2","4_2","5_2","6_2","7_2","1_3","2_3","3_3","4_3","5_3","6_3","2_4","3_4","4_4","5_4","3_5","4_5"] { p[pos] = PixelColors.orange }
            p["2_2"] = PixelColors.black; p["5_2"] = PixelColors.black // eyes
            p["3_3"] = PixelColors.pink; p["4_3"] = PixelColors.pink // nose/mouth
            return p
        }(), backgroundColor: PixelColors.white),

        SamplePixelArt(name: "Dog", category: .animals, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["2_0","3_0","4_0","5_0","1_1","2_1","3_1","4_1","5_1","6_1","0_2","1_2","2_2","3_2","4_2","5_2","6_2","7_2","1_3","2_3","3_3","4_3","5_3","6_3","2_4","3_4","4_4","5_4","2_5","5_5"] { p[pos] = PixelColors.brown }
            p["0_2"] = PixelColors.brown; p["7_2"] = PixelColors.brown // ears
            p["2_2"] = PixelColors.black; p["5_2"] = PixelColors.black // eyes
            p["3_3"] = PixelColors.black; p["4_3"] = PixelColors.black // nose
            p["3_4"] = PixelColors.pink // tongue
            return p
        }(), backgroundColor: PixelColors.white),

        SamplePixelArt(name: "Bunny", category: .animals, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            p["2_0"] = PixelColors.white; p["3_0"] = PixelColors.white; p["4_0"] = PixelColors.white; p["5_0"] = PixelColors.white
            p["2_1"] = PixelColors.pink; p["5_1"] = PixelColors.pink
            for pos in ["2_2","3_2","4_2","5_2","1_3","2_3","3_3","4_3","5_3","6_3","1_4","2_4","3_4","4_4","5_4","6_4","2_5","3_5","4_5","5_5","3_6","4_6"] { p[pos] = PixelColors.white }
            p["2_3"] = PixelColors.black; p["5_3"] = PixelColors.black
            p["3_4"] = PixelColors.pink; p["4_4"] = PixelColors.pink
            return p
        }(), backgroundColor: PixelColors.skyBlue),

        SamplePixelArt(name: "Chick", category: .animals, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["3_1","4_1","2_2","3_2","4_2","5_2","2_3","3_3","4_3","5_3","2_4","3_4","4_4","5_4","3_5","4_5"] { p[pos] = PixelColors.yellow }
            p["2_2"] = PixelColors.black; p["5_2"] = PixelColors.black
            p["3_3"] = PixelColors.orange; p["4_3"] = PixelColors.orange
            p["2_6"] = PixelColors.orange; p["5_6"] = PixelColors.orange
            return p
        }(), backgroundColor: PixelColors.white),

        SamplePixelArt(name: "Fish", category: .animals, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            p["0_3"] = PixelColors.blue; p["0_4"] = PixelColors.blue; p["1_2"] = PixelColors.blue; p["1_5"] = PixelColors.blue
            for pos in ["2_2","2_3","2_4","2_5","3_2","3_3","3_4","3_5","4_2","4_3","4_4","4_5","5_2","5_3","5_4","5_5","6_3","6_4","7_3","7_4"] { p[pos] = PixelColors.lightBlue }
            p["5_3"] = PixelColors.black // eye
            p["3_3"] = PixelColors.blue; p["4_4"] = PixelColors.blue
            return p
        }(), backgroundColor: PixelColors.skyBlue),

        SamplePixelArt(name: "Butterfly", category: .animals, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            // Body
            for y in 2...5 { p["3_\(y)"] = PixelColors.black; p["4_\(y)"] = PixelColors.black }
            // Wings
            for pos in ["0_2","1_2","2_2","0_3","1_3","2_3","0_4","1_4","2_4","5_2","6_2","7_2","5_3","6_3","7_3","5_4","6_4","7_4"] { p[pos] = PixelColors.purple }
            p["1_3"] = PixelColors.lightPurple; p["6_3"] = PixelColors.lightPurple
            // Antenna
            p["3_1"] = PixelColors.black; p["4_1"] = PixelColors.black; p["2_0"] = PixelColors.black; p["5_0"] = PixelColors.black
            return p
        }(), backgroundColor: PixelColors.white),

        SamplePixelArt(name: "Frog", category: .animals, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            p["1_1"] = PixelColors.green; p["2_1"] = PixelColors.green; p["5_1"] = PixelColors.green; p["6_1"] = PixelColors.green
            for pos in ["1_2","2_2","3_2","4_2","5_2","6_2","0_3","1_3","2_3","3_3","4_3","5_3","6_3","7_3","1_4","2_4","3_4","4_4","5_4","6_4","2_5","3_5","4_5","5_5"] { p[pos] = PixelColors.green }
            p["1_1"] = PixelColors.white; p["2_1"] = PixelColors.black; p["5_1"] = PixelColors.white; p["6_1"] = PixelColors.black
            p["3_4"] = PixelColors.pink; p["4_4"] = PixelColors.pink
            return p
        }(), backgroundColor: PixelColors.skyBlue),

        SamplePixelArt(name: "Pig", category: .animals, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["2_1","3_1","4_1","5_1","1_2","2_2","3_2","4_2","5_2","6_2","1_3","2_3","3_3","4_3","5_3","6_3","1_4","2_4","3_4","4_4","5_4","6_4","2_5","3_5","4_5","5_5"] { p[pos] = PixelColors.pink }
            p["0_2"] = PixelColors.pink; p["7_2"] = PixelColors.pink // ears
            p["2_3"] = PixelColors.black; p["5_3"] = PixelColors.black // eyes
            p["3_4"] = PixelColors.lightPink; p["4_4"] = PixelColors.lightPink // snout
            return p
        }(), backgroundColor: PixelColors.white)
    ]

    // MARK: - Animals 16x16
    static let animals16x16: [SamplePixelArt] = [
        SamplePixelArt(name: "Panda", category: .animals, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Ears
            for pos in ["3_1","4_1","3_2","4_2","11_1","12_1","11_2","12_2"] { p[pos] = PixelColors.black }
            // Face
            for x in 4...11 { for y in 3...11 { p["\(x)_\(y)"] = PixelColors.white } }
            for x in 5...10 { p["\(x)_2"] = PixelColors.white }
            for x in 5...10 { p["\(x)_12"] = PixelColors.white }
            // Eye patches
            for pos in ["4_5","5_5","6_5","4_6","5_6","6_6","9_5","10_5","11_5","9_6","10_6","11_6"] { p[pos] = PixelColors.black }
            // Eyes
            p["5_5"] = PixelColors.white; p["10_5"] = PixelColors.white
            // Nose
            p["7_8"] = PixelColors.black; p["8_8"] = PixelColors.black
            // Mouth
            p["7_9"] = PixelColors.black; p["8_9"] = PixelColors.black
            return p
        }(), backgroundColor: PixelColors.lightGreen),

        SamplePixelArt(name: "Penguin", category: .animals, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Body outline (black)
            for x in 5...10 { p["\(x)_1"] = PixelColors.black; p["\(x)_2"] = PixelColors.black }
            for x in 4...11 { for y in 3...10 { p["\(x)_\(y)"] = PixelColors.black } }
            for x in 5...10 { p["\(x)_11"] = PixelColors.black }
            // White belly
            for x in 6...9 { for y in 5...10 { p["\(x)_\(y)"] = PixelColors.white } }
            // Eyes
            p["5_4"] = PixelColors.white; p["10_4"] = PixelColors.white
            // Beak
            p["7_6"] = PixelColors.orange; p["8_6"] = PixelColors.orange
            // Feet
            p["5_12"] = PixelColors.orange; p["6_12"] = PixelColors.orange; p["9_12"] = PixelColors.orange; p["10_12"] = PixelColors.orange
            return p
        }(), backgroundColor: PixelColors.skyBlue),

        SamplePixelArt(name: "Owl", category: .animals, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Ears
            p["4_1"] = PixelColors.brown; p["5_1"] = PixelColors.brown; p["10_1"] = PixelColors.brown; p["11_1"] = PixelColors.brown
            // Head/Body
            for x in 4...11 { for y in 2...12 { p["\(x)_\(y)"] = PixelColors.brown } }
            // Face circle
            for x in 5...10 { for y in 3...8 { p["\(x)_\(y)"] = PixelColors.tan } }
            // Eyes
            for pos in ["5_4","6_4","5_5","6_5","9_4","10_4","9_5","10_5"] { p[pos] = PixelColors.white }
            p["6_5"] = PixelColors.black; p["9_5"] = PixelColors.black
            // Beak
            p["7_6"] = PixelColors.orange; p["8_6"] = PixelColors.orange; p["7_7"] = PixelColors.orange; p["8_7"] = PixelColors.orange
            // Feet
            p["5_13"] = PixelColors.orange; p["6_13"] = PixelColors.orange; p["9_13"] = PixelColors.orange; p["10_13"] = PixelColors.orange
            return p
        }(), backgroundColor: Color(red: 0.2, green: 0.2, blue: 0.4)),

        SamplePixelArt(name: "Fox", category: .animals, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Ears
            p["3_1"] = PixelColors.orange; p["4_2"] = PixelColors.orange; p["12_1"] = PixelColors.orange; p["11_2"] = PixelColors.orange
            p["3_2"] = PixelColors.orange; p["12_2"] = PixelColors.orange
            // Face
            for x in 4...11 { for y in 3...9 { p["\(x)_\(y)"] = PixelColors.orange } }
            for x in 5...10 { p["\(x)_10"] = PixelColors.orange }
            // White face
            for x in 6...9 { for y in 6...10 { p["\(x)_\(y)"] = PixelColors.white } }
            p["7_5"] = PixelColors.white; p["8_5"] = PixelColors.white
            // Eyes
            p["5_5"] = PixelColors.black; p["10_5"] = PixelColors.black
            // Nose
            p["7_7"] = PixelColors.black; p["8_7"] = PixelColors.black
            return p
        }(), backgroundColor: PixelColors.white),

        SamplePixelArt(name: "Elephant", category: .animals, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Head
            for x in 4...12 { for y in 2...9 { p["\(x)_\(y)"] = PixelColors.gray } }
            // Ears
            for y in 3...7 { p["3_\(y)"] = PixelColors.gray; p["2_\(y)"] = PixelColors.lightGray }
            for y in 3...7 { p["13_\(y)"] = PixelColors.gray; p["14_\(y)"] = PixelColors.lightGray }
            // Trunk
            for y in 10...14 { p["7_\(y)"] = PixelColors.gray; p["8_\(y)"] = PixelColors.gray }
            p["6_14"] = PixelColors.gray; p["9_14"] = PixelColors.gray
            // Eyes
            p["5_5"] = PixelColors.black; p["11_5"] = PixelColors.black
            return p
        }(), backgroundColor: PixelColors.skyBlue),

        SamplePixelArt(name: "Koala", category: .animals, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Ears
            for pos in ["2_2","3_2","2_3","3_3","4_3","12_2","13_2","12_3","13_3","11_3"] { p[pos] = PixelColors.gray }
            for pos in ["3_3","12_3"] { p[pos] = PixelColors.white }
            // Face
            for x in 4...11 { for y in 3...11 { p["\(x)_\(y)"] = PixelColors.gray } }
            // White face area
            for x in 5...10 { for y in 6...10 { p["\(x)_\(y)"] = PixelColors.white } }
            // Eyes
            p["5_5"] = PixelColors.black; p["10_5"] = PixelColors.black
            // Nose
            p["7_7"] = PixelColors.black; p["8_7"] = PixelColors.black; p["7_8"] = PixelColors.black; p["8_8"] = PixelColors.black
            return p
        }(), backgroundColor: PixelColors.lightGreen)
    ]

    // MARK: - Gaming 8x8
    static let gaming8x8: [SamplePixelArt] = [
        SamplePixelArt(name: "Sword", category: .gaming, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            p["6_0"] = PixelColors.silver; p["7_0"] = PixelColors.gray
            p["5_1"] = PixelColors.silver; p["6_1"] = PixelColors.silver
            p["4_2"] = PixelColors.silver; p["5_2"] = PixelColors.silver
            p["3_3"] = PixelColors.silver; p["4_3"] = PixelColors.silver
            for x in 1...5 { p["\(x)_4"] = PixelColors.gold }
            p["2_5"] = PixelColors.brown; p["3_5"] = PixelColors.brown
            p["1_6"] = PixelColors.brown; p["2_6"] = PixelColors.brown
            p["0_7"] = PixelColors.gold; p["1_7"] = PixelColors.brown
            return p
        }(), backgroundColor: Color(red: 0.15, green: 0.15, blue: 0.2)),

        SamplePixelArt(name: "Shield", category: .gaming, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["1_0","2_0","3_0","4_0","5_0","6_0","0_1","1_1","2_1","3_1","4_1","5_1","6_1","7_1","0_2","1_2","2_2","3_2","4_2","5_2","6_2","7_2","0_3","1_3","2_3","3_3","4_3","5_3","6_3","7_3","1_4","2_4","3_4","4_4","5_4","6_4","2_5","3_5","4_5","5_5","3_6","4_6"] { p[pos] = PixelColors.blue }
            for pos in ["3_1","4_1","3_2","4_2","2_3","3_3","4_3","5_3","3_4","4_4"] { p[pos] = PixelColors.gold }
            return p
        }(), backgroundColor: Color(red: 0.2, green: 0.2, blue: 0.25)),

        SamplePixelArt(name: "Potion", category: .gaming, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            p["3_0"] = PixelColors.brown; p["4_0"] = PixelColors.brown
            p["3_1"] = PixelColors.gray; p["4_1"] = PixelColors.gray
            for pos in ["2_2","3_2","4_2","5_2","1_3","2_3","3_3","4_3","5_3","6_3","1_4","2_4","3_4","4_4","5_4","6_4","1_5","2_5","3_5","4_5","5_5","6_5","2_6","3_6","4_6","5_6"] { p[pos] = PixelColors.red }
            p["2_3"] = PixelColors.lightRed; p["3_3"] = PixelColors.lightRed
            return p
        }(), backgroundColor: Color(red: 0.15, green: 0.1, blue: 0.2)),

        SamplePixelArt(name: "Coin", category: .gaming, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["2_1","3_1","4_1","5_1","1_2","2_2","3_2","4_2","5_2","6_2","1_3","2_3","3_3","4_3","5_3","6_3","1_4","2_4","3_4","4_4","5_4","6_4","1_5","2_5","3_5","4_5","5_5","6_5","2_6","3_6","4_6","5_6"] { p[pos] = PixelColors.gold }
            p["2_2"] = PixelColors.lightYellow; p["3_2"] = PixelColors.lightYellow
            p["3_3"] = PixelColors.yellow; p["4_3"] = PixelColors.yellow; p["3_4"] = PixelColors.yellow; p["4_4"] = PixelColors.yellow
            return p
        }(), backgroundColor: Color(red: 0.2, green: 0.15, blue: 0.1)),

        SamplePixelArt(name: "Heart Life", category: .gaming, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["1_1","2_1","5_1","6_1","0_2","1_2","2_2","3_2","4_2","5_2","6_2","7_2","0_3","1_3","2_3","3_3","4_3","5_3","6_3","7_3","1_4","2_4","3_4","4_4","5_4","6_4","2_5","3_5","4_5","5_5","3_6","4_6"] { p[pos] = PixelColors.red }
            p["1_2"] = PixelColors.lightRed; p["2_2"] = PixelColors.lightRed
            return p
        }(), backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15)),

        SamplePixelArt(name: "Slime", category: .gaming, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            p["3_1"] = PixelColors.lightBlue; p["4_1"] = PixelColors.lightBlue
            for pos in ["2_2","3_2","4_2","5_2","1_3","2_3","3_3","4_3","5_3","6_3","1_4","2_4","3_4","4_4","5_4","6_4","0_5","1_5","2_5","3_5","4_5","5_5","6_5","7_5","0_6","1_6","2_6","3_6","4_6","5_6","6_6","7_6"] { p[pos] = PixelColors.blue }
            p["2_4"] = PixelColors.white; p["5_4"] = PixelColors.white
            p["2_5"] = PixelColors.darkBlue; p["5_5"] = PixelColors.darkBlue
            p["2_2"] = PixelColors.white
            return p
        }(), backgroundColor: PixelColors.green),

        SamplePixelArt(name: "Ghost", category: .gaming, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["2_0","3_0","4_0","5_0","1_1","2_1","3_1","4_1","5_1","6_1","0_2","1_2","2_2","3_2","4_2","5_2","6_2","7_2","0_3","1_3","2_3","3_3","4_3","5_3","6_3","7_3","0_4","1_4","2_4","3_4","4_4","5_4","6_4","7_4","0_5","1_5","2_5","3_5","4_5","5_5","6_5","7_5","0_6","1_6","3_6","4_6","6_6","7_6"] { p[pos] = PixelColors.cyan }
            p["2_2"] = PixelColors.white; p["5_2"] = PixelColors.white
            p["2_3"] = PixelColors.white; p["3_3"] = PixelColors.darkBlue; p["5_3"] = PixelColors.white; p["6_3"] = PixelColors.darkBlue
            return p
        }(), backgroundColor: Color(red: 0.0, green: 0.0, blue: 0.15)),

        SamplePixelArt(name: "Key", category: .gaming, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["1_2","2_2","3_2","1_3","3_3","1_4","2_4","3_4","2_5","2_6","1_6","3_6","2_7"] { p[pos] = PixelColors.gold }
            p["4_5"] = PixelColors.gold; p["5_5"] = PixelColors.gold; p["6_5"] = PixelColors.gold; p["7_5"] = PixelColors.gold
            p["5_6"] = PixelColors.gold; p["7_6"] = PixelColors.gold
            return p
        }(), backgroundColor: Color(red: 0.15, green: 0.1, blue: 0.2))
    ]

    // MARK: - Gaming 16x16
    static let gaming16x16: [SamplePixelArt] = [
        SamplePixelArt(name: "Treasure Chest", category: .gaming, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Lid
            for x in 3...12 { p["\(x)_3"] = PixelColors.brown; p["\(x)_4"] = PixelColors.brown }
            for x in 4...11 { p["\(x)_2"] = PixelColors.brown }
            // Gold band on lid
            for x in 3...12 { p["\(x)_5"] = PixelColors.gold }
            // Body
            for x in 3...12 { for y in 6...11 { p["\(x)_\(y)"] = PixelColors.brown } }
            // Gold lock
            for x in 7...8 { for y in 6...8 { p["\(x)_\(y)"] = PixelColors.gold } }
            // Coins inside hint
            p["5_4"] = PixelColors.gold; p["10_4"] = PixelColors.gold
            return p
        }(), backgroundColor: Color(red: 0.2, green: 0.15, blue: 0.1)),

        SamplePixelArt(name: "Magic Wand", category: .gaming, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Star tip
            for pos in ["2_1","3_1","1_2","2_2","3_2","4_2","2_3","3_3"] { p[pos] = PixelColors.yellow }
            p["2_2"] = PixelColors.white
            // Wand body
            for i in 0...9 { p["\(4+i)_\(4+i)"] = PixelColors.brown }
            for i in 0...9 { p["\(5+i)_\(4+i)"] = PixelColors.darkBrown }
            // Sparkles
            p["1_4"] = PixelColors.lightYellow; p["5_1"] = PixelColors.lightYellow; p["0_2"] = PixelColors.yellow
            return p
        }(), backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.2)),

        SamplePixelArt(name: "Crystal", category: .gaming, boardSize: .low, pixels: {
            var p = [String: Color]()
            p["7_1"] = PixelColors.lightPurple; p["8_1"] = PixelColors.lightPurple
            for x in 6...9 { p["\(x)_2"] = PixelColors.lightPurple; p["\(x)_3"] = PixelColors.purple }
            for x in 5...10 { for y in 4...9 { p["\(x)_\(y)"] = PixelColors.purple } }
            for x in 6...9 { p["\(x)_10"] = PixelColors.darkPurple; p["\(x)_11"] = PixelColors.darkPurple }
            p["7_12"] = PixelColors.darkPurple; p["8_12"] = PixelColors.darkPurple
            // Shine
            p["6_4"] = PixelColors.white; p["7_5"] = PixelColors.lightPurple; p["6_5"] = PixelColors.white
            return p
        }(), backgroundColor: Color(red: 0.1, green: 0.05, blue: 0.15)),

        SamplePixelArt(name: "Bomb", category: .gaming, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Fuse
            p["10_1"] = PixelColors.orange; p["11_1"] = PixelColors.yellow; p["12_1"] = PixelColors.red
            p["9_2"] = PixelColors.brown; p["10_2"] = PixelColors.brown
            p["8_3"] = PixelColors.brown
            // Body
            for x in 5...10 { for y in 4...11 { p["\(x)_\(y)"] = PixelColors.black } }
            for x in 4...11 { for y in 5...10 { p["\(x)_\(y)"] = PixelColors.black } }
            for x in 6...9 { p["\(x)_3"] = PixelColors.black; p["\(x)_12"] = PixelColors.black }
            // Shine
            p["5_5"] = PixelColors.gray; p["6_5"] = PixelColors.gray; p["5_6"] = PixelColors.gray
            return p
        }(), backgroundColor: Color(red: 0.2, green: 0.15, blue: 0.1)),

        SamplePixelArt(name: "Crown", category: .gaming, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Points
            p["2_3"] = PixelColors.gold; p["7_1"] = PixelColors.gold; p["8_1"] = PixelColors.gold; p["13_3"] = PixelColors.gold
            p["2_4"] = PixelColors.gold; p["7_2"] = PixelColors.gold; p["8_2"] = PixelColors.gold; p["13_4"] = PixelColors.gold
            // Jewels on points
            p["2_3"] = PixelColors.red; p["7_1"] = PixelColors.blue; p["8_1"] = PixelColors.blue; p["13_3"] = PixelColors.red
            // Body
            for x in 2...13 { for y in 5...9 { p["\(x)_\(y)"] = PixelColors.gold } }
            for x in 3...12 { p["\(x)_4"] = PixelColors.gold; p["\(x)_10"] = PixelColors.gold }
            // Jewels
            p["5_7"] = PixelColors.red; p["7_7"] = PixelColors.blue; p["8_7"] = PixelColors.blue; p["10_7"] = PixelColors.red
            // Band
            for x in 2...13 { p["\(x)_9"] = PixelColors.darkOrange }
            return p
        }(), backgroundColor: Color(red: 0.15, green: 0.1, blue: 0.2)),

        SamplePixelArt(name: "Diamond", category: .gaming, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Top facet
            for x in 4...11 { p["\(x)_3"] = PixelColors.lightBlue; p["\(x)_4"] = PixelColors.cyan }
            // Middle
            for x in 3...12 { p["\(x)_5"] = PixelColors.cyan }
            for x in 4...11 { p["\(x)_6"] = PixelColors.blue; p["\(x)_7"] = PixelColors.blue }
            for x in 5...10 { p["\(x)_8"] = PixelColors.blue }
            for x in 6...9 { p["\(x)_9"] = PixelColors.darkBlue }
            for x in 7...8 { p["\(x)_10"] = PixelColors.darkBlue }
            // Shine
            p["5_4"] = PixelColors.white; p["6_4"] = PixelColors.white; p["5_5"] = PixelColors.white
            return p
        }(), backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15))
    ]

    // MARK: - Objects 8x8
    static let objects8x8: [SamplePixelArt] = [
        SamplePixelArt(name: "Light Bulb", category: .objects, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["3_0","4_0","2_1","3_1","4_1","5_1","2_2","3_2","4_2","5_2","2_3","3_3","4_3","5_3","3_4","4_4"] { p[pos] = PixelColors.yellow }
            p["3_1"] = PixelColors.white; p["3_2"] = PixelColors.lightYellow
            for pos in ["3_5","4_5","3_6","4_6"] { p[pos] = PixelColors.gray }
            p["3_7"] = PixelColors.darkGray; p["4_7"] = PixelColors.darkGray
            return p
        }(), backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15)),

        SamplePixelArt(name: "Clock", category: .objects, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["2_0","3_0","4_0","5_0","1_1","2_1","3_1","4_1","5_1","6_1","0_2","1_2","2_2","3_2","4_2","5_2","6_2","7_2","0_3","1_3","2_3","3_3","4_3","5_3","6_3","7_3","0_4","1_4","2_4","3_4","4_4","5_4","6_4","7_4","1_5","2_5","3_5","4_5","5_5","6_5","2_6","3_6","4_6","5_6"] { p[pos] = PixelColors.white }
            p["3_2"] = PixelColors.black; p["4_2"] = PixelColors.black // 12
            p["3_3"] = PixelColors.black; p["4_3"] = PixelColors.black; p["5_3"] = PixelColors.black // hands
            return p
        }(), backgroundColor: PixelColors.skyBlue),

        SamplePixelArt(name: "Camera", category: .objects, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            p["2_1"] = PixelColors.darkGray; p["3_1"] = PixelColors.darkGray
            for pos in ["0_2","1_2","2_2","3_2","4_2","5_2","6_2","7_2","0_3","1_3","2_3","3_3","4_3","5_3","6_3","7_3","0_4","1_4","2_4","3_4","4_4","5_4","6_4","7_4","0_5","1_5","2_5","3_5","4_5","5_5","6_5","7_5"] { p[pos] = PixelColors.darkGray }
            for pos in ["3_3","4_3","3_4","4_4"] { p[pos] = PixelColors.blue }
            p["3_3"] = PixelColors.lightBlue
            p["6_2"] = PixelColors.red
            return p
        }(), backgroundColor: PixelColors.white),

        SamplePixelArt(name: "Phone", category: .objects, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["2_0","3_0","4_0","5_0","2_1","3_1","4_1","5_1","2_2","3_2","4_2","5_2","2_3","3_3","4_3","5_3","2_4","3_4","4_4","5_4","2_5","3_5","4_5","5_5","2_6","3_6","4_6","5_6","2_7","3_7","4_7","5_7"] { p[pos] = PixelColors.darkGray }
            for pos in ["3_1","4_1","3_2","4_2","3_3","4_3","3_4","4_4","3_5","4_5"] { p[pos] = PixelColors.skyBlue }
            p["3_7"] = PixelColors.gray; p["4_7"] = PixelColors.gray
            return p
        }(), backgroundColor: PixelColors.white),

        SamplePixelArt(name: "Book", category: .objects, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["1_1","2_1","3_1","4_1","5_1","6_1","1_2","2_2","3_2","4_2","5_2","6_2","1_3","2_3","3_3","4_3","5_3","6_3","1_4","2_4","3_4","4_4","5_4","6_4","1_5","2_5","3_5","4_5","5_5","6_5","1_6","2_6","3_6","4_6","5_6","6_6"] { p[pos] = PixelColors.blue }
            for y in 1...6 { p["0_\(y)"] = PixelColors.darkBlue }
            for pos in ["2_2","3_2","4_2","5_2","2_4","3_4","4_4"] { p[pos] = PixelColors.gold }
            return p
        }(), backgroundColor: PixelColors.white),

        SamplePixelArt(name: "Pencil", category: .objects, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            p["1_0"] = PixelColors.beige; p["1_1"] = PixelColors.beige
            for y in 2...5 { p["1_\(y)"] = PixelColors.yellow; p["2_\(y)"] = PixelColors.orange }
            p["1_6"] = PixelColors.pink; p["2_6"] = PixelColors.pink
            p["1_7"] = PixelColors.tan; p["2_7"] = PixelColors.tan
            return p
        }(), backgroundColor: PixelColors.white),

        SamplePixelArt(name: "Gift Box", category: .objects, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            // Ribbon bow
            p["2_0"] = PixelColors.gold; p["5_0"] = PixelColors.gold
            p["3_1"] = PixelColors.gold; p["4_1"] = PixelColors.gold
            // Box
            for pos in ["0_2","1_2","2_2","3_2","4_2","5_2","6_2","7_2","0_3","1_3","2_3","3_3","4_3","5_3","6_3","7_3","0_4","1_4","2_4","3_4","4_4","5_4","6_4","7_4","0_5","1_5","2_5","3_5","4_5","5_5","6_5","7_5","0_6","1_6","2_6","3_6","4_6","5_6","6_6","7_6"] { p[pos] = PixelColors.red }
            // Ribbon vertical
            for y in 2...6 { p["3_\(y)"] = PixelColors.gold; p["4_\(y)"] = PixelColors.gold }
            return p
        }(), backgroundColor: PixelColors.white),

        SamplePixelArt(name: "Music Note", category: .objects, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            p["5_0"] = PixelColors.black; p["6_0"] = PixelColors.black; p["7_0"] = PixelColors.black
            for y in 0...5 { p["5_\(y)"] = PixelColors.black }
            for y in 0...4 { p["7_\(y)"] = PixelColors.black }
            for pos in ["3_5","4_5","5_5","3_6","4_6","5_6"] { p[pos] = PixelColors.black }
            for pos in ["5_3","6_3","7_3","5_4","6_4","7_4"] { p[pos] = PixelColors.black }
            return p
        }(), backgroundColor: PixelColors.white)
    ]

    // MARK: - Objects 16x16
    static let objects16x16: [SamplePixelArt] = [
        SamplePixelArt(name: "Game Controller", category: .objects, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Body
            for x in 3...12 { for y in 5...10 { p["\(x)_\(y)"] = PixelColors.darkGray } }
            for x in 1...3 { for y in 6...9 { p["\(x)_\(y)"] = PixelColors.darkGray } }
            for x in 12...14 { for y in 6...9 { p["\(x)_\(y)"] = PixelColors.darkGray } }
            // D-pad
            p["4_7"] = PixelColors.black; p["5_7"] = PixelColors.black; p["6_7"] = PixelColors.black
            p["5_6"] = PixelColors.black; p["5_8"] = PixelColors.black
            // Buttons
            p["10_6"] = PixelColors.red; p["11_7"] = PixelColors.blue
            p["10_8"] = PixelColors.green; p["9_7"] = PixelColors.yellow
            return p
        }(), backgroundColor: PixelColors.white),

        SamplePixelArt(name: "Television", category: .objects, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Frame
            for x in 2...13 { p["\(x)_2"] = PixelColors.darkGray; p["\(x)_11"] = PixelColors.darkGray }
            for y in 2...11 { p["2_\(y)"] = PixelColors.darkGray; p["13_\(y)"] = PixelColors.darkGray }
            // Screen
            for x in 3...12 { for y in 3...10 { p["\(x)_\(y)"] = PixelColors.skyBlue } }
            // Stand
            for x in 6...9 { p["\(x)_12"] = PixelColors.darkGray; p["\(x)_13"] = PixelColors.gray }
            // Antenna
            p["5_1"] = PixelColors.gray; p["10_1"] = PixelColors.gray
            p["6_0"] = PixelColors.gray; p["9_0"] = PixelColors.gray
            return p
        }(), backgroundColor: PixelColors.white),

        SamplePixelArt(name: "Headphones", category: .objects, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Band
            for x in 4...11 { p["\(x)_2"] = PixelColors.darkGray; p["\(x)_3"] = PixelColors.darkGray }
            p["3_3"] = PixelColors.darkGray; p["12_3"] = PixelColors.darkGray
            p["3_4"] = PixelColors.darkGray; p["12_4"] = PixelColors.darkGray
            // Sides
            for y in 4...10 { p["2_\(y)"] = PixelColors.darkGray; p["13_\(y)"] = PixelColors.darkGray }
            // Ear cups
            for y in 6...10 { p["1_\(y)"] = PixelColors.gray; p["14_\(y)"] = PixelColors.gray }
            for y in 7...9 { p["0_\(y)"] = PixelColors.gray; p["15_\(y)"] = PixelColors.gray }
            // Cushion
            for y in 7...9 { p["1_\(y)"] = PixelColors.black; p["14_\(y)"] = PixelColors.black }
            return p
        }(), backgroundColor: PixelColors.white),

        SamplePixelArt(name: "Laptop", category: .objects, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Screen
            for x in 2...13 { for y in 2...8 { p["\(x)_\(y)"] = PixelColors.darkGray } }
            for x in 3...12 { for y in 3...7 { p["\(x)_\(y)"] = PixelColors.skyBlue } }
            // Keyboard
            for x in 1...14 { p["\(x)_9"] = PixelColors.gray; p["\(x)_10"] = PixelColors.darkGray }
            for x in 2...13 { p["\(x)_11"] = PixelColors.darkGray }
            // Keys hint
            for x in 3...12 { if x % 2 == 0 { p["\(x)_10"] = PixelColors.gray } }
            return p
        }(), backgroundColor: PixelColors.white),

        SamplePixelArt(name: "Hourglass", category: .objects, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Top/bottom frames
            for x in 4...11 { p["\(x)_1"] = PixelColors.gold; p["\(x)_14"] = PixelColors.gold }
            // Glass sides
            for y in 2...6 { p["4_\(y)"] = PixelColors.lightBlue; p["11_\(y)"] = PixelColors.lightBlue }
            for y in 9...13 { p["4_\(y)"] = PixelColors.lightBlue; p["11_\(y)"] = PixelColors.lightBlue }
            // Narrow middle
            p["7_7"] = PixelColors.lightBlue; p["8_7"] = PixelColors.lightBlue
            p["7_8"] = PixelColors.lightBlue; p["8_8"] = PixelColors.lightBlue
            // Sand top
            for x in 5...10 { p["\(x)_5"] = PixelColors.tan; p["\(x)_6"] = PixelColors.tan }
            for x in 6...9 { p["\(x)_4"] = PixelColors.tan }
            // Sand bottom
            for x in 5...10 { p["\(x)_12"] = PixelColors.tan; p["\(x)_13"] = PixelColors.tan }
            for x in 6...9 { p["\(x)_11"] = PixelColors.tan }
            // Falling sand
            p["7_8"] = PixelColors.tan; p["8_8"] = PixelColors.tan
            return p
        }(), backgroundColor: Color(red: 0.2, green: 0.15, blue: 0.25)),

        SamplePixelArt(name: "Robot", category: .objects, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Antenna
            p["7_0"] = PixelColors.red; p["8_0"] = PixelColors.red
            p["7_1"] = PixelColors.gray; p["8_1"] = PixelColors.gray
            // Head
            for x in 4...11 { for y in 2...6 { p["\(x)_\(y)"] = PixelColors.silver } }
            // Eyes
            p["5_4"] = PixelColors.cyan; p["6_4"] = PixelColors.cyan; p["9_4"] = PixelColors.cyan; p["10_4"] = PixelColors.cyan
            // Mouth
            for x in 6...9 { p["\(x)_5"] = PixelColors.darkGray }
            // Body
            for x in 5...10 { for y in 7...12 { p["\(x)_\(y)"] = PixelColors.gray } }
            // Arms
            p["3_8"] = PixelColors.gray; p["4_8"] = PixelColors.gray; p["4_9"] = PixelColors.gray
            p["12_8"] = PixelColors.gray; p["11_8"] = PixelColors.gray; p["11_9"] = PixelColors.gray
            // Legs
            p["6_13"] = PixelColors.gray; p["6_14"] = PixelColors.darkGray
            p["9_13"] = PixelColors.gray; p["9_14"] = PixelColors.darkGray
            return p
        }(), backgroundColor: PixelColors.skyBlue)
    ]

    // MARK: - Space 8x8
    static let space8x8: [SamplePixelArt] = [
        SamplePixelArt(name: "Star", category: .space, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            p["3_0"] = PixelColors.yellow; p["4_0"] = PixelColors.yellow
            p["3_1"] = PixelColors.yellow; p["4_1"] = PixelColors.yellow
            for x in 0...7 { p["\(x)_2"] = PixelColors.yellow }
            for x in 1...6 { p["\(x)_3"] = PixelColors.yellow }
            for x in 2...5 { p["\(x)_4"] = PixelColors.yellow }
            for x in 1...2 { p["\(x)_5"] = PixelColors.yellow }
            for x in 5...6 { p["\(x)_5"] = PixelColors.yellow }
            p["0_6"] = PixelColors.yellow; p["1_6"] = PixelColors.yellow; p["6_6"] = PixelColors.yellow; p["7_6"] = PixelColors.yellow
            p["3_1"] = PixelColors.lightYellow; p["3_2"] = PixelColors.lightYellow
            return p
        }(), backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.2)),

        SamplePixelArt(name: "Moon", category: .space, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["3_0","4_0","5_0","2_1","3_1","4_1","5_1","6_1","1_2","2_2","3_2","6_2","1_3","2_3","6_3","1_4","2_4","3_4","6_4","1_5","2_5","3_5","4_5","5_5","6_5","2_6","3_6","4_6","5_6","3_7","4_7"] { p[pos] = PixelColors.lightYellow }
            p["2_1"] = PixelColors.yellow; p["1_2"] = PixelColors.yellow
            return p
        }(), backgroundColor: Color(red: 0.05, green: 0.05, blue: 0.15)),

        SamplePixelArt(name: "Rocket", category: .space, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            p["3_0"] = PixelColors.red; p["4_0"] = PixelColors.red
            for pos in ["3_1","4_1","3_2","4_2","3_3","4_3","3_4","4_4"] { p[pos] = PixelColors.white }
            p["3_2"] = PixelColors.lightBlue; p["4_2"] = PixelColors.lightBlue // window
            p["2_3"] = PixelColors.red; p["5_3"] = PixelColors.red // fins
            p["2_4"] = PixelColors.red; p["5_4"] = PixelColors.red
            p["3_5"] = PixelColors.orange; p["4_5"] = PixelColors.orange // fire
            p["3_6"] = PixelColors.yellow; p["4_6"] = PixelColors.red
            return p
        }(), backgroundColor: Color(red: 0.05, green: 0.05, blue: 0.15)),

        SamplePixelArt(name: "Planet", category: .space, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["2_1","3_1","4_1","5_1","1_2","2_2","3_2","4_2","5_2","6_2","1_3","2_3","3_3","4_3","5_3","6_3","1_4","2_4","3_4","4_4","5_4","6_4","1_5","2_5","3_5","4_5","5_5","6_5","2_6","3_6","4_6","5_6"] { p[pos] = PixelColors.orange }
            // Ring
            for pos in ["0_3","7_3","0_4","7_4"] { p[pos] = PixelColors.tan }
            p["2_2"] = PixelColors.lightOrange; p["3_2"] = PixelColors.lightOrange
            return p
        }(), backgroundColor: Color(red: 0.05, green: 0.05, blue: 0.1)),

        SamplePixelArt(name: "Alien", category: .space, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["2_1","3_1","4_1","5_1","1_2","2_2","3_2","4_2","5_2","6_2","1_3","2_3","3_3","4_3","5_3","6_3","2_4","3_4","4_4","5_4","3_5","4_5"] { p[pos] = PixelColors.green }
            p["2_2"] = PixelColors.black; p["5_2"] = PixelColors.black // eyes
            p["3_3"] = PixelColors.darkGreen; p["4_3"] = PixelColors.darkGreen // mouth
            p["1_5"] = PixelColors.green; p["2_5"] = PixelColors.green // arms
            p["5_5"] = PixelColors.green; p["6_5"] = PixelColors.green
            p["2_6"] = PixelColors.green; p["5_6"] = PixelColors.green // legs
            return p
        }(), backgroundColor: Color(red: 0.1, green: 0.05, blue: 0.15)),

        SamplePixelArt(name: "UFO", category: .space, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            p["3_1"] = PixelColors.lightBlue; p["4_1"] = PixelColors.lightBlue
            for pos in ["2_2","3_2","4_2","5_2"] { p[pos] = PixelColors.cyan }
            for x in 0...7 { p["\(x)_3"] = PixelColors.silver }
            for x in 1...6 { p["\(x)_4"] = PixelColors.gray }
            // Lights
            p["1_4"] = PixelColors.yellow; p["3_4"] = PixelColors.green; p["4_4"] = PixelColors.red; p["6_4"] = PixelColors.blue
            return p
        }(), backgroundColor: Color(red: 0.05, green: 0.05, blue: 0.1)),

        SamplePixelArt(name: "Comet", category: .space, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            // Head
            for pos in ["5_2","6_2","5_3","6_3"] { p[pos] = PixelColors.lightBlue }
            p["6_2"] = PixelColors.white
            // Tail
            p["4_3"] = PixelColors.cyan; p["3_4"] = PixelColors.blue; p["2_4"] = PixelColors.blue
            p["4_4"] = PixelColors.cyan; p["1_5"] = PixelColors.darkBlue; p["2_5"] = PixelColors.blue; p["3_5"] = PixelColors.cyan
            p["0_6"] = PixelColors.darkBlue; p["1_6"] = PixelColors.darkBlue
            return p
        }(), backgroundColor: Color(red: 0.02, green: 0.02, blue: 0.08)),

        SamplePixelArt(name: "Sun", category: .space, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            p["3_0"] = PixelColors.yellow; p["4_0"] = PixelColors.yellow
            p["0_3"] = PixelColors.yellow; p["7_3"] = PixelColors.yellow
            p["0_4"] = PixelColors.yellow; p["7_4"] = PixelColors.yellow
            p["3_7"] = PixelColors.yellow; p["4_7"] = PixelColors.yellow
            for pos in ["2_1","3_1","4_1","5_1","1_2","2_2","3_2","4_2","5_2","6_2","1_3","2_3","3_3","4_3","5_3","6_3","1_4","2_4","3_4","4_4","5_4","6_4","1_5","2_5","3_5","4_5","5_5","6_5","2_6","3_6","4_6","5_6"] { p[pos] = PixelColors.orange }
            p["3_3"] = PixelColors.yellow; p["4_3"] = PixelColors.yellow; p["3_4"] = PixelColors.yellow; p["4_4"] = PixelColors.yellow
            return p
        }(), backgroundColor: PixelColors.skyBlue)
    ]

    // MARK: - Space 16x16
    static let space16x16: [SamplePixelArt] = [
        SamplePixelArt(name: "Astronaut", category: .space, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Helmet
            for x in 5...10 { for y in 1...6 { p["\(x)_\(y)"] = PixelColors.white } }
            for x in 6...9 { p["\(x)_0"] = PixelColors.white }
            // Visor
            for x in 6...9 { for y in 2...4 { p["\(x)_\(y)"] = PixelColors.gold } }
            // Body
            for x in 4...11 { for y in 7...12 { p["\(x)_\(y)"] = PixelColors.white } }
            // Backpack
            p["3_8"] = PixelColors.gray; p["3_9"] = PixelColors.gray; p["3_10"] = PixelColors.gray
            p["12_8"] = PixelColors.gray; p["12_9"] = PixelColors.gray; p["12_10"] = PixelColors.gray
            // Arms
            for y in 8...10 { p["2_\(y)"] = PixelColors.white; p["13_\(y)"] = PixelColors.white }
            // Legs
            for y in 13...15 { p["5_\(y)"] = PixelColors.white; p["6_\(y)"] = PixelColors.white; p["9_\(y)"] = PixelColors.white; p["10_\(y)"] = PixelColors.white }
            return p
        }(), backgroundColor: Color(red: 0.05, green: 0.05, blue: 0.1)),

        SamplePixelArt(name: "Space Station", category: .space, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Main module
            for x in 5...10 { for y in 5...10 { p["\(x)_\(y)"] = PixelColors.silver } }
            // Solar panels left
            for x in 0...4 { p["\(x)_7"] = PixelColors.blue; p["\(x)_8"] = PixelColors.darkBlue }
            // Solar panels right
            for x in 11...15 { p["\(x)_7"] = PixelColors.blue; p["\(x)_8"] = PixelColors.darkBlue }
            // Windows
            p["6_6"] = PixelColors.cyan; p["9_6"] = PixelColors.cyan
            p["6_9"] = PixelColors.cyan; p["9_9"] = PixelColors.cyan
            // Docking port
            for y in 3...4 { p["7_\(y)"] = PixelColors.gray; p["8_\(y)"] = PixelColors.gray }
            return p
        }(), backgroundColor: Color(red: 0.02, green: 0.02, blue: 0.08)),

        SamplePixelArt(name: "Galaxy", category: .space, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Spiral arms
            for pos in ["7_2","8_2","9_3","10_4","11_5","11_6","10_7","9_8","8_9","7_10","6_10","5_9","4_8","3_7","3_6","4_5","5_4","6_3"] { p[pos] = PixelColors.purple }
            for pos in ["6_4","7_4","8_5","9_6","9_7","8_8","7_8","6_7","5_6","5_5","6_5","7_6"] { p[pos] = PixelColors.lightPurple }
            // Center
            p["7_6"] = PixelColors.white; p["8_6"] = PixelColors.white; p["7_7"] = PixelColors.white; p["8_7"] = PixelColors.white
            // Stars
            p["2_3"] = PixelColors.white; p["12_4"] = PixelColors.yellow; p["4_11"] = PixelColors.white
            p["13_9"] = PixelColors.lightYellow; p["1_8"] = PixelColors.white
            return p
        }(), backgroundColor: Color(red: 0.02, green: 0.02, blue: 0.08)),

        SamplePixelArt(name: "Earth", category: .space, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Ocean base
            for x in 4...11 { for y in 2...13 { p["\(x)_\(y)"] = PixelColors.blue } }
            for x in 5...10 { p["\(x)_1"] = PixelColors.blue; p["\(x)_14"] = PixelColors.blue }
            for x in 6...9 { p["\(x)_0"] = PixelColors.blue; p["\(x)_15"] = PixelColors.blue }
            for y in 3...12 { p["3_\(y)"] = PixelColors.blue; p["12_\(y)"] = PixelColors.blue }
            // Continents
            for pos in ["5_3","6_3","7_3","5_4","6_4","9_5","10_5","9_6","10_6","11_6","5_8","6_8","7_8","5_9","6_9","8_10","9_10","8_11","9_11","10_11"] { p[pos] = PixelColors.green }
            // Clouds
            p["6_2"] = PixelColors.white; p["10_4"] = PixelColors.white; p["4_7"] = PixelColors.white; p["11_9"] = PixelColors.white
            return p
        }(), backgroundColor: Color(red: 0.02, green: 0.02, blue: 0.08))
    ]

    // MARK: - Characters 8x8
    static let characters8x8: [SamplePixelArt] = [
        SamplePixelArt(name: "Ninja", category: .characters, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            // Head wrap
            for pos in ["2_0","3_0","4_0","5_0","1_1","2_1","3_1","4_1","5_1","6_1","1_2","2_2","5_2","6_2"] { p[pos] = PixelColors.black }
            // Eyes
            p["3_2"] = PixelColors.white; p["4_2"] = PixelColors.white
            // Body
            for pos in ["2_3","3_3","4_3","5_3","1_4","2_4","3_4","4_4","5_4","6_4","2_5","3_5","4_5","5_5"] { p[pos] = PixelColors.black }
            // Legs
            p["2_6"] = PixelColors.black; p["3_6"] = PixelColors.black; p["4_6"] = PixelColors.black; p["5_6"] = PixelColors.black
            return p
        }(), backgroundColor: Color(red: 0.15, green: 0.1, blue: 0.1)),

        SamplePixelArt(name: "Wizard", category: .characters, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            // Hat
            p["3_0"] = PixelColors.purple; p["4_0"] = PixelColors.purple
            for pos in ["2_1","3_1","4_1","5_1","1_2","2_2","3_2","4_2","5_2","6_2"] { p[pos] = PixelColors.purple }
            // Face
            p["3_3"] = PixelColors.skin1; p["4_3"] = PixelColors.skin1
            // Robe
            for pos in ["2_4","3_4","4_4","5_4","1_5","2_5","3_5","4_5","5_5","6_5","1_6","2_6","5_6","6_6"] { p[pos] = PixelColors.purple }
            // Staff
            p["0_3"] = PixelColors.yellow; p["0_4"] = PixelColors.brown; p["0_5"] = PixelColors.brown; p["0_6"] = PixelColors.brown
            return p
        }(), backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.2)),

        SamplePixelArt(name: "Knight", category: .characters, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            // Helmet
            for pos in ["2_0","3_0","4_0","5_0","1_1","2_1","3_1","4_1","5_1","6_1","2_2","3_2","4_2","5_2"] { p[pos] = PixelColors.silver }
            p["3_2"] = PixelColors.black; p["4_2"] = PixelColors.black // visor
            // Armor
            for pos in ["2_3","3_3","4_3","5_3","1_4","2_4","3_4","4_4","5_4","6_4","2_5","3_5","4_5","5_5"] { p[pos] = PixelColors.silver }
            // Legs
            p["2_6"] = PixelColors.gray; p["3_6"] = PixelColors.gray; p["4_6"] = PixelColors.gray; p["5_6"] = PixelColors.gray
            // Shield
            p["0_3"] = PixelColors.red; p["0_4"] = PixelColors.red; p["0_5"] = PixelColors.red
            return p
        }(), backgroundColor: Color(red: 0.2, green: 0.2, blue: 0.25)),

        SamplePixelArt(name: "Princess", category: .characters, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            // Crown
            p["2_0"] = PixelColors.gold; p["3_0"] = PixelColors.gold; p["4_0"] = PixelColors.gold; p["5_0"] = PixelColors.gold
            // Hair & face
            for pos in ["1_1","2_1","3_1","4_1","5_1","6_1","1_2","2_2","5_2","6_2"] { p[pos] = PixelColors.yellow }
            p["3_2"] = PixelColors.skin1; p["4_2"] = PixelColors.skin1
            p["3_3"] = PixelColors.skin1; p["4_3"] = PixelColors.skin1
            // Dress
            for pos in ["2_4","3_4","4_4","5_4","1_5","2_5","3_5","4_5","5_5","6_5","0_6","1_6","2_6","3_6","4_6","5_6","6_6","7_6"] { p[pos] = PixelColors.pink }
            return p
        }(), backgroundColor: Color(red: 0.95, green: 0.9, blue: 0.95)),

        SamplePixelArt(name: "Pirate", category: .characters, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            // Hat
            for pos in ["1_0","2_0","3_0","4_0","5_0","6_0","1_1","2_1","3_1","4_1","5_1","6_1"] { p[pos] = PixelColors.black }
            p["3_0"] = PixelColors.white // skull
            // Face
            for pos in ["2_2","3_2","4_2","5_2","2_3","3_3","4_3","5_3"] { p[pos] = PixelColors.skin1 }
            p["2_2"] = PixelColors.black // eyepatch
            // Body
            for pos in ["2_4","3_4","4_4","5_4","2_5","3_5","4_5","5_5","2_6","3_6","4_6","5_6"] { p[pos] = PixelColors.red }
            return p
        }(), backgroundColor: PixelColors.skyBlue),

        SamplePixelArt(name: "Robot Guy", category: .characters, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            // Antenna
            p["3_0"] = PixelColors.red; p["4_0"] = PixelColors.red
            // Head
            for pos in ["2_1","3_1","4_1","5_1","2_2","3_2","4_2","5_2"] { p[pos] = PixelColors.silver }
            p["3_2"] = PixelColors.cyan; p["4_2"] = PixelColors.cyan // eyes
            // Body
            for pos in ["2_3","3_3","4_3","5_3","1_4","2_4","3_4","4_4","5_4","6_4","2_5","3_5","4_5","5_5"] { p[pos] = PixelColors.gray }
            // Legs
            p["2_6"] = PixelColors.darkGray; p["3_6"] = PixelColors.darkGray; p["4_6"] = PixelColors.darkGray; p["5_6"] = PixelColors.darkGray
            return p
        }(), backgroundColor: PixelColors.skyBlue),

        SamplePixelArt(name: "Zombie", category: .characters, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            // Head
            for pos in ["2_0","3_0","4_0","5_0","2_1","3_1","4_1","5_1","2_2","3_2","4_2","5_2"] { p[pos] = PixelColors.green }
            p["3_1"] = PixelColors.red; p["4_1"] = PixelColors.red // eyes
            // Body
            for pos in ["2_3","3_3","4_3","5_3","1_4","2_4","3_4","4_4","5_4","6_4","2_5","3_5","4_5","5_5"] { p[pos] = PixelColors.brown }
            // Arms out
            p["0_4"] = PixelColors.green; p["7_4"] = PixelColors.green
            // Legs
            p["2_6"] = PixelColors.darkBrown; p["3_6"] = PixelColors.darkBrown; p["4_6"] = PixelColors.darkBrown; p["5_6"] = PixelColors.darkBrown
            return p
        }(), backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15)),

        SamplePixelArt(name: "Elf", category: .characters, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            // Ears & hair
            p["1_1"] = PixelColors.skin1; p["6_1"] = PixelColors.skin1 // pointed ears
            for pos in ["2_0","3_0","4_0","5_0","2_1","3_1","4_1","5_1"] { p[pos] = PixelColors.yellow }
            // Face
            for pos in ["2_2","3_2","4_2","5_2","3_3","4_3"] { p[pos] = PixelColors.skin1 }
            // Tunic
            for pos in ["2_4","3_4","4_4","5_4","1_5","2_5","3_5","4_5","5_5","6_5","2_6","3_6","4_6","5_6"] { p[pos] = PixelColors.green }
            return p
        }(), backgroundColor: Color(red: 0.85, green: 0.9, blue: 0.85))
    ]

    // MARK: - Characters 16x16
    static let characters16x16: [SamplePixelArt] = [
        SamplePixelArt(name: "Hero", category: .characters, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Hair
            for x in 5...10 { p["\(x)_1"] = PixelColors.brown; p["\(x)_2"] = PixelColors.brown }
            for x in 6...9 { p["\(x)_0"] = PixelColors.brown }
            // Face
            for x in 5...10 { for y in 3...5 { p["\(x)_\(y)"] = PixelColors.skin1 } }
            p["6_4"] = PixelColors.black; p["9_4"] = PixelColors.black // eyes
            // Body (armor)
            for x in 4...11 { for y in 6...10 { p["\(x)_\(y)"] = PixelColors.silver } }
            // Cape
            for y in 6...12 { p["3_\(y)"] = PixelColors.red; p["12_\(y)"] = PixelColors.red }
            // Sword
            p["13_6"] = PixelColors.silver; p["14_5"] = PixelColors.silver; p["15_4"] = PixelColors.silver
            p["13_7"] = PixelColors.gold; p["14_7"] = PixelColors.brown
            // Legs
            for y in 11...14 { p["6_\(y)"] = PixelColors.gray; p["7_\(y)"] = PixelColors.gray; p["8_\(y)"] = PixelColors.gray; p["9_\(y)"] = PixelColors.gray }
            // Boots
            p["5_14"] = PixelColors.brown; p["6_14"] = PixelColors.brown; p["9_14"] = PixelColors.brown; p["10_14"] = PixelColors.brown
            return p
        }(), backgroundColor: Color(red: 0.85, green: 0.9, blue: 1.0)),

        SamplePixelArt(name: "Mage", category: .characters, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Hat
            p["7_0"] = PixelColors.darkPurple; p["8_0"] = PixelColors.darkPurple
            for x in 6...9 { p["\(x)_1"] = PixelColors.purple }
            for x in 5...10 { p["\(x)_2"] = PixelColors.purple }
            for x in 4...11 { p["\(x)_3"] = PixelColors.purple }
            p["7_1"] = PixelColors.yellow // star
            // Face
            for x in 5...10 { for y in 4...6 { p["\(x)_\(y)"] = PixelColors.skin1 } }
            p["6_5"] = PixelColors.black; p["9_5"] = PixelColors.black // eyes
            // Beard
            for x in 6...9 { for y in 7...9 { p["\(x)_\(y)"] = PixelColors.white } }
            // Robe
            for x in 4...11 { for y in 7...13 { p["\(x)_\(y)"] = PixelColors.purple } }
            // Staff
            for y in 5...14 { p["2_\(y)"] = PixelColors.brown }
            p["1_4"] = PixelColors.cyan; p["2_4"] = PixelColors.cyan; p["3_4"] = PixelColors.cyan
            p["2_3"] = PixelColors.cyan
            return p
        }(), backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.2)),

        SamplePixelArt(name: "Archer", category: .characters, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Hood
            for x in 5...10 { for y in 0...3 { p["\(x)_\(y)"] = PixelColors.green } }
            // Face
            for x in 6...9 { for y in 3...5 { p["\(x)_\(y)"] = PixelColors.skin1 } }
            p["6_4"] = PixelColors.black; p["9_4"] = PixelColors.black
            // Body
            for x in 5...10 { for y in 6...11 { p["\(x)_\(y)"] = PixelColors.green } }
            // Bow
            for y in 4...10 { p["13_\(y)"] = PixelColors.brown }
            p["12_5"] = PixelColors.brown; p["12_9"] = PixelColors.brown
            // String
            for y in 5...9 { p["14_\(y)"] = PixelColors.white }
            // Arrow
            for x in 10...14 { p["\(x)_7"] = PixelColors.brown }
            p["15_7"] = PixelColors.gray
            // Legs
            for y in 12...14 { p["6_\(y)"] = PixelColors.brown; p["7_\(y)"] = PixelColors.brown; p["8_\(y)"] = PixelColors.brown; p["9_\(y)"] = PixelColors.brown }
            return p
        }(), backgroundColor: Color(red: 0.85, green: 0.95, blue: 0.85)),

        SamplePixelArt(name: "Vampire", category: .characters, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Hair
            for x in 5...10 { p["\(x)_0"] = PixelColors.black; p["\(x)_1"] = PixelColors.black }
            p["4_1"] = PixelColors.black; p["11_1"] = PixelColors.black
            // Face
            for x in 5...10 { for y in 2...5 { p["\(x)_\(y)"] = PixelColors.white } }
            p["6_3"] = PixelColors.red; p["9_3"] = PixelColors.red // eyes
            // Fangs
            p["6_5"] = PixelColors.white; p["9_5"] = PixelColors.white
            // Cape (outside)
            for y in 3...13 { p["3_\(y)"] = PixelColors.darkRed; p["12_\(y)"] = PixelColors.darkRed }
            for y in 5...13 { p["2_\(y)"] = PixelColors.darkRed; p["13_\(y)"] = PixelColors.darkRed }
            // Cape inside
            for y in 6...13 { p["4_\(y)"] = PixelColors.red; p["11_\(y)"] = PixelColors.red }
            // Body
            for x in 5...10 { for y in 6...11 { p["\(x)_\(y)"] = PixelColors.black } }
            // Legs
            for y in 12...14 { p["6_\(y)"] = PixelColors.black; p["9_\(y)"] = PixelColors.black }
            return p
        }(), backgroundColor: Color(red: 0.15, green: 0.1, blue: 0.2)),

        SamplePixelArt(name: "Fairy", category: .characters, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Hair
            for x in 6...9 { p["\(x)_2"] = PixelColors.yellow; p["\(x)_3"] = PixelColors.yellow }
            // Face
            for x in 6...9 { for y in 4...6 { p["\(x)_\(y)"] = PixelColors.skin1 } }
            p["6_5"] = PixelColors.black; p["9_5"] = PixelColors.black
            // Wings
            for pos in ["3_4","4_4","5_4","3_5","4_5","5_5","4_6","5_6","10_4","11_4","12_4","10_5","11_5","12_5","10_6","11_6"] { p[pos] = PixelColors.lightPurple }
            p["4_5"] = PixelColors.white; p["11_5"] = PixelColors.white
            // Dress
            for x in 6...9 { for y in 7...10 { p["\(x)_\(y)"] = PixelColors.pink } }
            for x in 5...10 { p["\(x)_11"] = PixelColors.pink }
            // Wand sparkle
            p["13_3"] = PixelColors.yellow; p["14_2"] = PixelColors.lightYellow; p["14_4"] = PixelColors.lightYellow; p["15_3"] = PixelColors.lightYellow
            p["12_4"] = PixelColors.brown; p["13_5"] = PixelColors.brown
            return p
        }(), backgroundColor: Color(red: 0.9, green: 0.85, blue: 1.0)),

        SamplePixelArt(name: "Samurai", category: .characters, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Helmet
            for x in 4...11 { p["\(x)_1"] = PixelColors.darkGray; p["\(x)_2"] = PixelColors.gray }
            p["7_0"] = PixelColors.gold; p["8_0"] = PixelColors.gold // crest
            // Face mask
            for x in 5...10 { for y in 3...5 { p["\(x)_\(y)"] = PixelColors.darkGray } }
            p["6_4"] = PixelColors.black; p["9_4"] = PixelColors.black // eyes
            // Armor
            for x in 4...11 { for y in 6...11 { p["\(x)_\(y)"] = PixelColors.red } }
            for x in 5...10 { p["\(x)_6"] = PixelColors.gold } // gold trim
            // Katana
            for y in 4...12 { p["13_\(y)"] = PixelColors.silver }
            p["13_3"] = PixelColors.white // blade tip
            p["13_13"] = PixelColors.brown // handle
            // Legs
            for y in 12...14 { p["5_\(y)"] = PixelColors.darkGray; p["6_\(y)"] = PixelColors.darkGray; p["9_\(y)"] = PixelColors.darkGray; p["10_\(y)"] = PixelColors.darkGray }
            return p
        }(), backgroundColor: Color(red: 0.95, green: 0.9, blue: 0.85))
    ]

    // MARK: - Seasonal 8x8
    static let seasonal8x8: [SamplePixelArt] = [
        SamplePixelArt(name: "Pumpkin", category: .seasonal, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            p["3_0"] = PixelColors.green; p["4_0"] = PixelColors.green // stem
            for pos in ["2_1","3_1","4_1","5_1","1_2","2_2","3_2","4_2","5_2","6_2","1_3","2_3","3_3","4_3","5_3","6_3","1_4","2_4","3_4","4_4","5_4","6_4","2_5","3_5","4_5","5_5"] { p[pos] = PixelColors.orange }
            // Face
            p["2_2"] = PixelColors.black; p["5_2"] = PixelColors.black // eyes
            p["2_4"] = PixelColors.black; p["3_4"] = PixelColors.black; p["4_4"] = PixelColors.black; p["5_4"] = PixelColors.black // mouth
            return p
        }(), backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15)),

        SamplePixelArt(name: "Snowman", category: .seasonal, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            // Hat
            p["3_0"] = PixelColors.black; p["4_0"] = PixelColors.black
            for x in 2...5 { p["\(x)_1"] = PixelColors.black }
            // Head
            for pos in ["2_2","3_2","4_2","5_2","2_3","3_3","4_3","5_3"] { p[pos] = PixelColors.white }
            p["3_2"] = PixelColors.black; p["4_2"] = PixelColors.black // eyes
            p["3_3"] = PixelColors.orange // nose
            // Body
            for pos in ["1_4","2_4","3_4","4_4","5_4","6_4","1_5","2_5","3_5","4_5","5_5","6_5","2_6","3_6","4_6","5_6"] { p[pos] = PixelColors.white }
            p["3_5"] = PixelColors.black; p["4_5"] = PixelColors.black // buttons
            return p
        }(), backgroundColor: PixelColors.skyBlue),

        SamplePixelArt(name: "Christmas Tree", category: .seasonal, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            p["3_0"] = PixelColors.yellow; p["4_0"] = PixelColors.yellow // star
            for pos in ["3_1","4_1","2_2","3_2","4_2","5_2","1_3","2_3","3_3","4_3","5_3","6_3","0_4","1_4","2_4","3_4","4_4","5_4","6_4","7_4","1_5","2_5","3_5","4_5","5_5","6_5"] { p[pos] = PixelColors.green }
            // Ornaments
            p["3_2"] = PixelColors.red; p["2_3"] = PixelColors.blue; p["5_3"] = PixelColors.gold; p["2_4"] = PixelColors.red; p["5_4"] = PixelColors.blue
            // Trunk
            p["3_6"] = PixelColors.brown; p["4_6"] = PixelColors.brown
            return p
        }(), backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.2)),

        SamplePixelArt(name: "Easter Egg", category: .seasonal, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["3_0","4_0","2_1","3_1","4_1","5_1","1_2","2_2","3_2","4_2","5_2","6_2","1_3","2_3","3_3","4_3","5_3","6_3","1_4","2_4","3_4","4_4","5_4","6_4","2_5","3_5","4_5","5_5","3_6","4_6"] { p[pos] = PixelColors.pink }
            // Pattern
            for x in 1...6 { p["\(x)_2"] = PixelColors.yellow }
            for x in 1...6 { p["\(x)_4"] = PixelColors.cyan }
            return p
        }(), backgroundColor: PixelColors.lightGreen),

        SamplePixelArt(name: "Heart Balloon", category: .seasonal, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            for pos in ["1_0","2_0","5_0","6_0","0_1","1_1","2_1","3_1","4_1","5_1","6_1","7_1","0_2","1_2","2_2","3_2","4_2","5_2","6_2","7_2","1_3","2_3","3_3","4_3","5_3","6_3","2_4","3_4","4_4","5_4","3_5","4_5"] { p[pos] = PixelColors.red }
            p["1_1"] = PixelColors.lightRed; p["2_1"] = PixelColors.lightRed
            // String
            p["3_6"] = PixelColors.white; p["4_6"] = PixelColors.white; p["3_7"] = PixelColors.white; p["4_7"] = PixelColors.white
            return p
        }(), backgroundColor: PixelColors.skyBlue),

        SamplePixelArt(name: "Firework", category: .seasonal, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            // Center
            p["3_3"] = PixelColors.white; p["4_3"] = PixelColors.white; p["3_4"] = PixelColors.white; p["4_4"] = PixelColors.white
            // Rays
            p["3_1"] = PixelColors.yellow; p["4_1"] = PixelColors.yellow
            p["1_3"] = PixelColors.red; p["6_3"] = PixelColors.red
            p["1_4"] = PixelColors.red; p["6_4"] = PixelColors.red
            p["3_6"] = PixelColors.blue; p["4_6"] = PixelColors.blue
            p["1_1"] = PixelColors.orange; p["6_1"] = PixelColors.green; p["1_6"] = PixelColors.purple; p["6_6"] = PixelColors.cyan
            // Sparks
            p["0_0"] = PixelColors.yellow; p["7_0"] = PixelColors.yellow; p["0_7"] = PixelColors.yellow; p["7_7"] = PixelColors.yellow
            return p
        }(), backgroundColor: Color(red: 0.05, green: 0.05, blue: 0.1)),

        SamplePixelArt(name: "Candy Cane", category: .seasonal, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            // Hook
            p["5_0"] = PixelColors.red; p["6_0"] = PixelColors.white; p["7_0"] = PixelColors.red
            p["4_1"] = PixelColors.white; p["7_1"] = PixelColors.white
            p["4_2"] = PixelColors.red
            // Straight part
            for y in 2...7 {
                if y % 2 == 0 { p["4_\(y)"] = PixelColors.red; p["5_\(y)"] = PixelColors.white }
                else { p["4_\(y)"] = PixelColors.white; p["5_\(y)"] = PixelColors.red }
            }
            return p
        }(), backgroundColor: PixelColors.white),

        SamplePixelArt(name: "Clover Luck", category: .seasonal, boardSize: .extraLow, pixels: {
            var p = [String: Color]()
            // Four leaves
            for pos in ["2_1","3_1","4_1","5_1","1_2","2_2","5_2","6_2","1_3","2_3","5_3","6_3","2_4","3_4","4_4","5_4"] { p[pos] = PixelColors.green }
            p["2_2"] = PixelColors.lightGreen; p["5_2"] = PixelColors.lightGreen
            // Stem
            for y in 5...7 { p["3_\(y)"] = PixelColors.darkGreen; p["4_\(y)"] = PixelColors.darkGreen }
            return p
        }(), backgroundColor: PixelColors.white)
    ]

    // MARK: - Seasonal 16x16
    static let seasonal16x16: [SamplePixelArt] = [
        SamplePixelArt(name: "Santa", category: .seasonal, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Hat
            for x in 5...11 { p["\(x)_0"] = PixelColors.red; p["\(x)_1"] = PixelColors.red }
            p["11_0"] = PixelColors.white; p["12_0"] = PixelColors.white; p["12_1"] = PixelColors.white // pom
            for x in 4...12 { p["\(x)_2"] = PixelColors.white } // fur trim
            // Face
            for x in 5...10 { for y in 3...6 { p["\(x)_\(y)"] = PixelColors.skin1 } }
            p["6_4"] = PixelColors.black; p["9_4"] = PixelColors.black // eyes
            p["7_5"] = PixelColors.red; p["8_5"] = PixelColors.red // nose
            // Beard
            for x in 4...11 { for y in 6...9 { p["\(x)_\(y)"] = PixelColors.white } }
            // Body
            for x in 4...11 { for y in 10...13 { p["\(x)_\(y)"] = PixelColors.red } }
            // Belt
            for x in 4...11 { p["\(x)_11"] = PixelColors.black }
            p["7_11"] = PixelColors.gold; p["8_11"] = PixelColors.gold
            // Boots
            for x in 5...6 { p["\(x)_14"] = PixelColors.black }
            for x in 9...10 { p["\(x)_14"] = PixelColors.black }
            return p
        }(), backgroundColor: PixelColors.skyBlue),

        SamplePixelArt(name: "Present Stack", category: .seasonal, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Top box (small)
            for x in 6...9 { for y in 2...5 { p["\(x)_\(y)"] = PixelColors.blue } }
            p["7_2"] = PixelColors.gold; p["8_2"] = PixelColors.gold; p["7_5"] = PixelColors.gold; p["8_5"] = PixelColors.gold
            for y in 2...5 { p["7_\(y)"] = PixelColors.gold; p["8_\(y)"] = PixelColors.gold }
            // Middle box
            for x in 4...11 { for y in 6...10 { p["\(x)_\(y)"] = PixelColors.red } }
            for y in 6...10 { p["7_\(y)"] = PixelColors.white; p["8_\(y)"] = PixelColors.white }
            // Bottom box (large)
            for x in 2...13 { for y in 11...14 { p["\(x)_\(y)"] = PixelColors.green } }
            for y in 11...14 { p["7_\(y)"] = PixelColors.gold; p["8_\(y)"] = PixelColors.gold }
            // Bows
            p["6_1"] = PixelColors.gold; p["9_1"] = PixelColors.gold
            p["3_5"] = PixelColors.white; p["12_5"] = PixelColors.white
            p["1_10"] = PixelColors.gold; p["14_10"] = PixelColors.gold
            return p
        }(), backgroundColor: PixelColors.white),

        SamplePixelArt(name: "Snowflake", category: .seasonal, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Center
            for x in 7...8 { for y in 7...8 { p["\(x)_\(y)"] = PixelColors.white } }
            // Main arms (vertical & horizontal)
            for i in 2...13 { p["7_\(i)"] = PixelColors.lightBlue; p["8_\(i)"] = PixelColors.lightBlue }
            for i in 2...13 { p["\(i)_7"] = PixelColors.lightBlue; p["\(i)_8"] = PixelColors.lightBlue }
            // Diagonal arms
            for i in 0...6 { p["\(3+i)_\(3+i)"] = PixelColors.cyan; p["\(12-i)_\(3+i)"] = PixelColors.cyan }
            // Branch details
            p["5_4"] = PixelColors.white; p["10_4"] = PixelColors.white; p["4_5"] = PixelColors.white; p["11_5"] = PixelColors.white
            p["5_11"] = PixelColors.white; p["10_11"] = PixelColors.white; p["4_10"] = PixelColors.white; p["11_10"] = PixelColors.white
            return p
        }(), backgroundColor: Color(red: 0.1, green: 0.15, blue: 0.3)),

        SamplePixelArt(name: "Witch", category: .seasonal, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Hat
            p["7_0"] = PixelColors.black; p["8_0"] = PixelColors.black
            for x in 6...9 { p["\(x)_1"] = PixelColors.black }
            for x in 5...10 { p["\(x)_2"] = PixelColors.black }
            for x in 3...12 { p["\(x)_3"] = PixelColors.black }
            p["7_1"] = PixelColors.purple // buckle
            // Face
            for x in 5...10 { for y in 4...7 { p["\(x)_\(y)"] = PixelColors.lightGreen } }
            p["6_5"] = PixelColors.black; p["9_5"] = PixelColors.black // eyes
            p["7_6"] = PixelColors.green; p["8_6"] = PixelColors.green // nose
            // Robe
            for x in 4...11 { for y in 8...13 { p["\(x)_\(y)"] = PixelColors.black } }
            // Broom
            for y in 10...15 { p["13_\(y)"] = PixelColors.brown }
            for x in 12...15 { p["\(x)_14"] = PixelColors.yellow; p["\(x)_15"] = PixelColors.yellow }
            return p
        }(), backgroundColor: Color(red: 0.2, green: 0.1, blue: 0.3)),

        SamplePixelArt(name: "Turkey", category: .seasonal, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Tail feathers
            for x in 2...6 { p["\(x)_2"] = PixelColors.red }
            for x in 3...7 { p["\(x)_3"] = PixelColors.orange }
            for x in 4...8 { p["\(x)_4"] = PixelColors.yellow }
            for x in 5...9 { p["\(x)_5"] = PixelColors.green }
            for x in 6...10 { p["\(x)_6"] = PixelColors.brown }
            // Body
            for x in 7...11 { for y in 7...11 { p["\(x)_\(y)"] = PixelColors.brown } }
            // Head
            for x in 11...13 { for y in 5...8 { p["\(x)_\(y)"] = PixelColors.brown } }
            p["13_6"] = PixelColors.black // eye
            // Wattle
            p["14_7"] = PixelColors.red; p["14_8"] = PixelColors.red
            // Beak
            p["14_6"] = PixelColors.orange
            // Legs
            p["8_12"] = PixelColors.orange; p["8_13"] = PixelColors.orange; p["10_12"] = PixelColors.orange; p["10_13"] = PixelColors.orange
            return p
        }(), backgroundColor: Color(red: 0.95, green: 0.9, blue: 0.8)),

        SamplePixelArt(name: "Lantern", category: .seasonal, boardSize: .low, pixels: {
            var p = [String: Color]()
            // Handle
            for x in 6...9 { p["\(x)_1"] = PixelColors.gold }
            p["5_2"] = PixelColors.gold; p["10_2"] = PixelColors.gold
            // Top cap
            for x in 5...10 { p["\(x)_3"] = PixelColors.red }
            // Body
            for x in 4...11 { for y in 4...11 { p["\(x)_\(y)"] = PixelColors.red } }
            // Inner glow
            for x in 5...10 { for y in 5...10 { p["\(x)_\(y)"] = PixelColors.orange } }
            for x in 6...9 { for y in 6...9 { p["\(x)_\(y)"] = PixelColors.yellow } }
            // Bottom cap
            for x in 5...10 { p["\(x)_12"] = PixelColors.red }
            // Tassel
            for y in 13...15 { p["7_\(y)"] = PixelColors.gold; p["8_\(y)"] = PixelColors.gold }
            return p
        }(), backgroundColor: Color(red: 0.1, green: 0.05, blue: 0.1))
    ]
}

// MARK: - Sample Art Gallery View

struct SampleArtGalleryView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedSample: SamplePixelArt?
    let onSelect: (SamplePixelArt) -> Void

    @State private var selectedCategory: SampleCategory? = nil
    @State private var selectedSize: PixelBoardSize? = nil

    private var filteredSamples: [SamplePixelArt] {
        var samples = SamplePixelArtCollection.all
        if let category = selectedCategory {
            samples = samples.filter { $0.category == category }
        }
        if let size = selectedSize {
            samples = samples.filter { $0.boardSize == size }
        }
        return samples
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            Color(AppConfig.backgroundColor).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button { presentationMode.wrappedValue.dismiss() } label: {
                        Image(systemName: "xmark").font(.system(size: 18))
                    }
                    Spacer()
                    Text("Sample Gallery").font(.system(size: 18, weight: .bold))
                    Spacer()
                    Text("\(filteredSamples.count)").font(.system(size: 14)).foregroundColor(.gray)
                }
                .padding()
                .foregroundColor(.white)

                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(title: "All", isSelected: selectedCategory == nil && selectedSize == nil) {
                            selectedCategory = nil
                            selectedSize = nil
                        }
                        ForEach(SampleCategory.allCases, id: \.self) { category in
                            FilterChip(title: category.rawValue, isSelected: selectedCategory == category) {
                                selectedCategory = selectedCategory == category ? nil : category
                            }
                        }
                        Divider().frame(height: 20).background(Color.gray)
                        FilterChip(title: "8×8", isSelected: selectedSize == .extraLow) {
                            selectedSize = selectedSize == .extraLow ? nil : .extraLow
                        }
                        FilterChip(title: "16×16", isSelected: selectedSize == .low) {
                            selectedSize = selectedSize == .low ? nil : .low
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 10)

                // Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredSamples) { sample in
                            SampleArtCard(sample: sample) {
                                onSelect(sample)
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.white : Color(AppConfig.toolBackgroundColor))
                .cornerRadius(15)
        }
    }
}

struct SampleArtCard: View {
    let sample: SamplePixelArt
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                SampleArtPreview(sample: sample)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(sample.name)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(sample.boardSize.rawValue)
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(AppConfig.toolBackgroundColor)))
        }
    }
}

struct SampleArtPreview: View {
    let sample: SamplePixelArt

    var body: some View {
        let gridSize = sample.boardSize.count

        GeometryReader { geometry in
            let pixelSize = geometry.size.width / CGFloat(gridSize)

            ZStack {
                Rectangle().fill(sample.backgroundColor)

                ForEach(0..<gridSize, id: \.self) { row in
                    ForEach(0..<gridSize, id: \.self) { col in
                        if let color = sample.pixels["\(col)_\(row)"] {
                            Rectangle()
                                .fill(color)
                                .frame(width: pixelSize, height: pixelSize)
                                .position(
                                    x: CGFloat(col) * pixelSize + pixelSize / 2,
                                    y: CGFloat(row) * pixelSize + pixelSize / 2
                                )
                        }
                    }
                }
            }
        }
    }
}

struct SampleArtGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        SampleArtGalleryView(selectedSample: .constant(nil)) { _ in }
    }
}
