//
//  PixelIconCatalog.swift
//  PixelMe
//
//  Created by hyunho lee on 2026/03/02.
//

import Foundation

// MARK: - Pixel Icon Catalog
/// 앱 전반에 사용되는 픽셀 아트 애니메이션 아이콘 카탈로그
enum PixelIconCatalog {

    // 공통 색상
    private static let W = PixelColor.white
    private static let B = PixelColor.black
    private static let C = PixelColor.clear

    // MARK: - 1. Camera (camera.fill 대체)
    static let camera: PixelIconDefinition = {
        let body = PixelColor(r: 80, g: 80, b: 80)
        let lens = PixelColor(r: 100, g: 180, b: 255)
        let flash = PixelColor(r: 255, g: 230, b: 100)

        let f1 = PixelIconFrame(pixels: [
            // 카메라 본체
            "3_1": body, "4_1": body, "5_1": body, "6_1": body,
            "1_2": body, "2_2": body, "3_2": body, "4_2": body, "5_2": body, "6_2": body, "7_2": body, "8_2": body,
            "1_3": body, "2_3": B, "3_3": B, "4_3": B, "5_3": B, "6_3": B, "7_3": B, "8_3": body,
            "1_4": body, "2_4": B, "3_4": lens, "4_4": lens, "5_4": lens, "6_4": lens, "7_4": B, "8_4": body,
            "1_5": body, "2_5": B, "3_5": lens, "4_5": W, "5_5": W, "6_5": lens, "7_5": B, "8_5": body,
            "1_6": body, "2_6": B, "3_6": lens, "4_6": lens, "5_6": lens, "6_6": lens, "7_6": B, "8_6": body,
            "1_7": body, "2_7": B, "3_7": B, "4_7": B, "5_7": B, "6_7": B, "7_7": B, "8_7": body,
            "1_8": body, "2_8": body, "3_8": body, "4_8": body, "5_8": body, "6_8": body, "7_8": body, "8_8": body,
        ])
        let f2 = PixelIconFrame(pixels: [
            "3_1": body, "4_1": body, "5_1": body, "6_1": body, "8_0": flash,
            "1_2": body, "2_2": body, "3_2": body, "4_2": body, "5_2": body, "6_2": body, "7_2": body, "8_2": body,
            "1_3": body, "2_3": B, "3_3": B, "4_3": B, "5_3": B, "6_3": B, "7_3": B, "8_3": body,
            "1_4": body, "2_4": B, "3_4": lens, "4_4": lens, "5_4": lens, "6_4": lens, "7_4": B, "8_4": body,
            "1_5": body, "2_5": B, "3_5": lens, "4_5": W, "5_5": lens, "6_5": lens, "7_5": B, "8_5": body,
            "1_6": body, "2_6": B, "3_6": lens, "4_6": lens, "5_6": lens, "6_6": lens, "7_6": B, "8_6": body,
            "1_7": body, "2_7": B, "3_7": B, "4_7": B, "5_7": B, "6_7": B, "7_7": B, "8_7": body,
            "1_8": body, "2_8": body, "3_8": body, "4_8": body, "5_8": body, "6_8": body, "7_8": body, "8_8": body,
        ])
        return PixelIconDefinition(name: "camera", gridSize: 10, frames: [f1, f2, f1], fps: 4)
    }()

    // MARK: - 2. Paintbrush (paintbrush.pointed.fill 대체)
    static let paintbrush: PixelIconDefinition = {
        let handle = PixelColor(r: 180, g: 120, b: 60)
        let tip = PixelColor(r: 200, g: 60, b: 200)
        let tipAlt = PixelColor(r: 60, g: 180, b: 255)

        let f1 = PixelIconFrame(pixels: [
            "7_1": tip, "8_1": tip,
            "6_2": tip, "7_2": tip,
            "5_3": tip, "6_3": tip,
            "4_4": handle, "5_4": handle,
            "3_5": handle, "4_5": handle,
            "2_6": handle, "3_6": handle,
            "1_7": handle, "2_7": handle,
            "0_8": handle, "1_8": handle,
        ])
        let f2 = PixelIconFrame(pixels: [
            "7_1": tipAlt, "8_1": tipAlt,
            "6_2": tipAlt, "7_2": tipAlt,
            "5_3": tipAlt, "6_3": tipAlt,
            "4_4": handle, "5_4": handle,
            "3_5": handle, "4_5": handle,
            "2_6": handle, "3_6": handle,
            "1_7": handle, "2_7": handle,
            "0_8": handle, "1_8": handle,
        ])
        return PixelIconDefinition(name: "paintbrush", gridSize: 10, frames: [f1, f2], fps: 4)
    }()

    // MARK: - 3. Grid (square.grid.3x3.fill 대체)
    static let grid: PixelIconDefinition = {
        let line = PixelColor(r: 0, g: 200, b: 200)
        let lineAlt = PixelColor(r: 100, g: 230, b: 255)
        let fill = PixelColor(r: 30, g: 60, b: 80)

        func makeFrame(lineColor: PixelColor) -> PixelIconFrame {
            var px: [String: PixelColor] = [:]
            // 3x3 grid cells filling
            for y in 1...8 {
                for x in 1...8 {
                    px["\(x)_\(y)"] = fill
                }
            }
            // Grid lines (at x=3,6 and y=3,6)
            for i in 1...8 {
                px["3_\(i)"] = lineColor
                px["6_\(i)"] = lineColor
                px["\(i)_3"] = lineColor
                px["\(i)_6"] = lineColor
            }
            return PixelIconFrame(pixels: px)
        }

        return PixelIconDefinition(name: "grid", gridSize: 10, frames: [makeFrame(lineColor: line), makeFrame(lineColor: lineAlt)], fps: 3)
    }()

    // MARK: - 4. Sparkle (sparkles 대체)
    static let sparkle: PixelIconDefinition = {
        let s = PixelColor(r: 255, g: 220, b: 80)
        let sDim = PixelColor(r: 255, g: 240, b: 160)

        let f1 = PixelIconFrame(pixels: [
            "4_0": s, "4_1": s,
            "0_4": s, "1_4": s,
            "7_4": s, "8_4": s,
            "4_7": s, "4_8": s,
            "4_4": s,
            "2_2": sDim, "6_2": sDim, "2_6": sDim, "6_6": sDim,
        ])
        let f2 = PixelIconFrame(pixels: [
            "4_1": s,
            "1_4": s,
            "7_4": s,
            "4_7": s,
            "4_4": s,
            "2_2": s, "6_2": s, "2_6": s, "6_6": s,
            "1_1": sDim, "7_1": sDim, "1_7": sDim, "7_7": sDim,
        ])
        let f3 = PixelIconFrame(pixels: [
            "4_0": sDim, "4_1": s, "4_2": sDim,
            "0_4": sDim, "1_4": s, "2_4": sDim,
            "6_4": sDim, "7_4": s, "8_4": sDim,
            "4_6": sDim, "4_7": s, "4_8": sDim,
            "4_4": s,
        ])
        return PixelIconDefinition(name: "sparkle", gridSize: 10, frames: [f1, f2, f3], fps: 5)
    }()

    // MARK: - 5. House (house.fill 대체)
    static let house: PixelIconDefinition = {
        let roof = PixelColor(r: 200, g: 60, b: 60)
        let wall = PixelColor(r: 220, g: 200, b: 160)
        let door = PixelColor(r: 140, g: 90, b: 40)
        let window = PixelColor(r: 150, g: 210, b: 255)
        let windowLit = PixelColor(r: 255, g: 240, b: 100)

        let f1 = PixelIconFrame(pixels: [
            // 지붕
            "4_0": roof, "5_0": roof,
            "3_1": roof, "4_1": roof, "5_1": roof, "6_1": roof,
            "2_2": roof, "3_2": roof, "4_2": roof, "5_2": roof, "6_2": roof, "7_2": roof,
            "1_3": roof, "2_3": roof, "3_3": roof, "4_3": roof, "5_3": roof, "6_3": roof, "7_3": roof, "8_3": roof,
            // 벽
            "2_4": wall, "3_4": wall, "4_4": wall, "5_4": wall, "6_4": wall, "7_4": wall,
            "2_5": wall, "3_5": window, "4_5": wall, "5_5": wall, "6_5": window, "7_5": wall,
            "2_6": wall, "3_6": window, "4_6": wall, "5_6": wall, "6_6": window, "7_6": wall,
            "2_7": wall, "3_7": wall, "4_7": door, "5_7": door, "6_7": wall, "7_7": wall,
            "2_8": wall, "3_8": wall, "4_8": door, "5_8": door, "6_8": wall, "7_8": wall,
        ])
        let f2 = PixelIconFrame(pixels: [
            "4_0": roof, "5_0": roof,
            "3_1": roof, "4_1": roof, "5_1": roof, "6_1": roof,
            "2_2": roof, "3_2": roof, "4_2": roof, "5_2": roof, "6_2": roof, "7_2": roof,
            "1_3": roof, "2_3": roof, "3_3": roof, "4_3": roof, "5_3": roof, "6_3": roof, "7_3": roof, "8_3": roof,
            "2_4": wall, "3_4": wall, "4_4": wall, "5_4": wall, "6_4": wall, "7_4": wall,
            "2_5": wall, "3_5": windowLit, "4_5": wall, "5_5": wall, "6_5": windowLit, "7_5": wall,
            "2_6": wall, "3_6": windowLit, "4_6": wall, "5_6": wall, "6_6": windowLit, "7_6": wall,
            "2_7": wall, "3_7": wall, "4_7": door, "5_7": door, "6_7": wall, "7_7": wall,
            "2_8": wall, "3_8": wall, "4_8": door, "5_8": door, "6_8": wall, "7_8": wall,
        ])
        return PixelIconDefinition(name: "house", gridSize: 10, frames: [f1, f2, f1], fps: 2)
    }()

    // MARK: - 6. Pencil (pencil 대체)
    static let pencil: PixelIconDefinition = {
        let wood = PixelColor(r: 240, g: 200, b: 80)
        let tip = PixelColor(r: 60, g: 60, b: 60)
        let eraser = PixelColor(r: 255, g: 140, b: 140)

        let f1 = PixelIconFrame(pixels: [
            "8_1": eraser, "7_1": eraser,
            "7_2": wood, "6_2": wood,
            "6_3": wood, "5_3": wood,
            "5_4": wood, "4_4": wood,
            "4_5": wood, "3_5": wood,
            "3_6": tip, "2_6": tip,
            "2_7": tip, "1_7": tip,
            "1_8": tip,
        ])
        let f2 = PixelIconFrame(pixels: [
            "8_1": eraser, "7_1": eraser,
            "7_2": wood, "6_2": wood,
            "6_3": wood, "5_3": wood,
            "5_4": wood, "4_4": wood,
            "4_5": wood, "3_5": wood,
            "3_6": tip, "2_6": tip,
            "2_7": tip, "1_7": tip,
            "1_8": tip, "0_9": PixelColor(r: 40, g: 40, b: 40),
        ])
        return PixelIconDefinition(name: "pencil", gridSize: 10, frames: [f1, f2], fps: 4)
    }()

    // MARK: - 7. Eraser (eraser 대체)
    static let eraser: PixelIconDefinition = {
        let body = PixelColor(r: 255, g: 180, b: 180)
        let band = PixelColor(r: 100, g: 100, b: 200)
        let tip = PixelColor(r: 230, g: 230, b: 230)

        let f1 = PixelIconFrame(pixels: [
            "7_1": body, "8_1": body,
            "6_2": body, "7_2": body, "8_2": body,
            "5_3": body, "6_3": body, "7_3": body,
            "4_4": band, "5_4": band, "6_4": band,
            "3_5": tip, "4_5": tip, "5_5": tip,
            "2_6": tip, "3_6": tip, "4_6": tip,
            "1_7": tip, "2_7": tip, "3_7": tip,
        ])
        let f2 = PixelIconFrame(pixels: [
            "7_1": body, "8_1": body,
            "6_2": body, "7_2": body, "8_2": body,
            "5_3": body, "6_3": body, "7_3": body,
            "4_4": band, "5_4": band, "6_4": band,
            "3_5": tip, "4_5": tip, "5_5": tip,
            "2_6": tip, "3_6": tip, "4_6": tip,
            "1_7": tip, "2_7": tip, "3_7": tip,
            // 지우기 파티클
            "0_8": PixelColor(r: 200, g: 200, b: 200), "1_9": PixelColor(r: 200, g: 200, b: 200),
        ])
        return PixelIconDefinition(name: "eraser", gridSize: 10, frames: [f1, f2], fps: 4)
    }()

    // MARK: - 8. Paint Drop (drop.fill 대체)
    static let paintDrop: PixelIconDefinition = {
        let drop = PixelColor(r: 80, g: 140, b: 255)
        let highlight = PixelColor(r: 180, g: 220, b: 255)
        let splash = PixelColor(r: 100, g: 160, b: 255)

        let f1 = PixelIconFrame(pixels: [
            "4_1": drop,
            "3_2": drop, "4_2": drop, "5_2": drop,
            "3_3": drop, "4_3": highlight, "5_3": drop,
            "2_4": drop, "3_4": drop, "4_4": highlight, "5_4": drop, "6_4": drop,
            "2_5": drop, "3_5": drop, "4_5": drop, "5_5": drop, "6_5": drop,
            "2_6": drop, "3_6": drop, "4_6": drop, "5_6": drop, "6_6": drop,
            "3_7": drop, "4_7": drop, "5_7": drop,
            "4_8": drop,
        ])
        let f2 = PixelIconFrame(pixels: [
            "4_1": drop,
            "3_2": drop, "4_2": drop, "5_2": drop,
            "3_3": drop, "4_3": highlight, "5_3": drop,
            "2_4": drop, "3_4": drop, "4_4": highlight, "5_4": drop, "6_4": drop,
            "2_5": drop, "3_5": drop, "4_5": drop, "5_5": drop, "6_5": drop,
            "2_6": drop, "3_6": drop, "4_6": drop, "5_6": drop, "6_6": drop,
            "3_7": drop, "4_7": drop, "5_7": drop,
            "4_8": drop,
            // 물방울 splash
            "1_8": splash, "7_8": splash,
            "2_9": splash, "6_9": splash,
        ])
        return PixelIconDefinition(name: "paintDrop", gridSize: 10, frames: [f1, f2], fps: 4)
    }()

    // MARK: - 9. Star (star.fill 대체)
    static let star: PixelIconDefinition = {
        let s = PixelColor(r: 255, g: 200, b: 0)
        let bright = PixelColor(r: 255, g: 240, b: 100)

        let f1 = PixelIconFrame(pixels: [
            "4_0": s, "5_0": s,
            "4_1": s, "5_1": s,
            "3_2": s, "4_2": s, "5_2": s, "6_2": s,
            "0_3": s, "1_3": s, "2_3": s, "3_3": s, "4_3": s, "5_3": s, "6_3": s, "7_3": s, "8_3": s, "9_3": s,
            "1_4": s, "2_4": s, "3_4": s, "4_4": s, "5_4": s, "6_4": s, "7_4": s, "8_4": s,
            "2_5": s, "3_5": s, "4_5": s, "5_5": s, "6_5": s, "7_5": s,
            "2_6": s, "3_6": s, "4_6": s, "5_6": s, "6_6": s, "7_6": s,
            "1_7": s, "2_7": s, "3_7": s, "6_7": s, "7_7": s, "8_7": s,
            "1_8": s, "2_8": s, "7_8": s, "8_8": s,
            "0_9": s, "1_9": s, "8_9": s, "9_9": s,
        ])
        let f2 = PixelIconFrame(pixels: [
            "4_0": bright, "5_0": bright,
            "4_1": bright, "5_1": bright,
            "3_2": s, "4_2": bright, "5_2": bright, "6_2": s,
            "0_3": s, "1_3": s, "2_3": s, "3_3": s, "4_3": bright, "5_3": bright, "6_3": s, "7_3": s, "8_3": s, "9_3": s,
            "1_4": s, "2_4": s, "3_4": s, "4_4": bright, "5_4": bright, "6_4": s, "7_4": s, "8_4": s,
            "2_5": s, "3_5": s, "4_5": s, "5_5": s, "6_5": s, "7_5": s,
            "2_6": s, "3_6": s, "4_6": s, "5_6": s, "6_6": s, "7_6": s,
            "1_7": s, "2_7": s, "3_7": s, "6_7": s, "7_7": s, "8_7": s,
            "1_8": s, "2_8": s, "7_8": s, "8_8": s,
            "0_9": s, "1_9": s, "8_9": s, "9_9": s,
        ])
        return PixelIconDefinition(name: "star", gridSize: 10, frames: [f1, f2], fps: 5)
    }()

    // MARK: - 10. Export / Share (square.and.arrow.up 대체)
    static let export: PixelIconDefinition = {
        let box = PixelColor(r: 100, g: 160, b: 255)
        let arrow = PixelColor(r: 255, g: 255, b: 255)

        let f1 = PixelIconFrame(pixels: [
            // 화살표
            "4_0": arrow, "5_0": arrow,
            "3_1": arrow, "4_1": arrow, "5_1": arrow, "6_1": arrow,
            "4_2": arrow, "5_2": arrow,
            "4_3": arrow, "5_3": arrow,
            "4_4": arrow, "5_4": arrow,
            // 상자
            "1_4": box, "2_4": box, "7_4": box, "8_4": box,
            "1_5": box, "2_5": box, "7_5": box, "8_5": box,
            "1_6": box, "2_6": box, "3_6": box, "4_6": box, "5_6": box, "6_6": box, "7_6": box, "8_6": box,
            "1_7": box, "8_7": box,
            "1_8": box, "2_8": box, "3_8": box, "4_8": box, "5_8": box, "6_8": box, "7_8": box, "8_8": box,
        ])
        let f2 = PixelIconFrame(pixels: [
            // 화살표 (한칸 위)
            "4_0": arrow, "5_0": arrow,
            "3_0": arrow, "6_0": arrow,
            "4_1": arrow, "5_1": arrow,
            "4_2": arrow, "5_2": arrow,
            "4_3": arrow, "5_3": arrow,
            // 상자
            "1_4": box, "2_4": box, "7_4": box, "8_4": box,
            "1_5": box, "2_5": box, "7_5": box, "8_5": box,
            "1_6": box, "2_6": box, "3_6": box, "4_6": box, "5_6": box, "6_6": box, "7_6": box, "8_6": box,
            "1_7": box, "8_7": box,
            "1_8": box, "2_8": box, "3_8": box, "4_8": box, "5_8": box, "6_8": box, "7_8": box, "8_8": box,
        ])
        return PixelIconDefinition(name: "export", gridSize: 10, frames: [f1, f2], fps: 4)
    }()

    // MARK: - 11. Profile (person.crop.square 대체)
    static let profile: PixelIconDefinition = {
        let skin = PixelColor(r: 255, g: 200, b: 160)
        let hair = PixelColor(r: 80, g: 60, b: 40)
        let body = PixelColor(r: 255, g: 160, b: 60)
        let eye = PixelColor(r: 40, g: 40, b: 40)
        let skinAlt = PixelColor(r: 255, g: 210, b: 175)

        let f1 = PixelIconFrame(pixels: [
            // 머리카락
            "3_0": hair, "4_0": hair, "5_0": hair, "6_0": hair,
            "2_1": hair, "3_1": hair, "4_1": hair, "5_1": hair, "6_1": hair, "7_1": hair,
            "2_2": hair, "3_2": hair, "4_2": hair, "5_2": hair, "6_2": hair, "7_2": hair,
            // 얼굴
            "3_3": skin, "4_3": skin, "5_3": skin, "6_3": skin,
            "2_4": skin, "3_4": skin, "4_4": eye, "5_4": skin, "6_4": eye, "7_4": skin,
            "3_5": skin, "4_5": skin, "5_5": skin, "6_5": skin,
            "4_6": skin, "5_6": skin,
            // 몸통
            "2_7": body, "3_7": body, "4_7": body, "5_7": body, "6_7": body, "7_7": body,
            "1_8": body, "2_8": body, "3_8": body, "4_8": body, "5_8": body, "6_8": body, "7_8": body, "8_8": body,
            "1_9": body, "2_9": body, "3_9": body, "4_9": body, "5_9": body, "6_9": body, "7_9": body, "8_9": body,
        ])
        let f2 = PixelIconFrame(pixels: [
            "3_0": hair, "4_0": hair, "5_0": hair, "6_0": hair,
            "2_1": hair, "3_1": hair, "4_1": hair, "5_1": hair, "6_1": hair, "7_1": hair,
            "2_2": hair, "3_2": hair, "4_2": hair, "5_2": hair, "6_2": hair, "7_2": hair,
            "3_3": skinAlt, "4_3": skinAlt, "5_3": skinAlt, "6_3": skinAlt,
            "2_4": skinAlt, "3_4": skinAlt, "4_4": eye, "5_4": skinAlt, "6_4": eye, "7_4": skinAlt,
            "3_5": skinAlt, "4_5": skinAlt, "5_5": skinAlt, "6_5": skinAlt,
            "4_6": skinAlt, "5_6": skinAlt,
            "2_7": body, "3_7": body, "4_7": body, "5_7": body, "6_7": body, "7_7": body,
            "1_8": body, "2_8": body, "3_8": body, "4_8": body, "5_8": body, "6_8": body, "7_8": body, "8_8": body,
            "1_9": body, "2_9": body, "3_9": body, "4_9": body, "5_9": body, "6_9": body, "7_9": body, "8_9": body,
        ])
        return PixelIconDefinition(name: "profile", gridSize: 10, frames: [f1, f2, f1], fps: 3)
    }()

    // MARK: - 12. Floppy Disk (저장 아이콘)
    static let floppyDisk: PixelIconDefinition = {
        let metal = PixelColor(r: 140, g: 140, b: 160)
        let body = PixelColor(r: 70, g: 100, b: 200)
        let label = PixelColor(r: 230, g: 230, b: 230)
        let slot = PixelColor(r: 50, g: 50, b: 60)
        let bodyBright = PixelColor(r: 90, g: 120, b: 230)

        let f1 = PixelIconFrame(pixels: [
            // 상단 금속 슬라이더
            "1_0": body, "2_0": body, "3_0": metal, "4_0": metal, "5_0": metal, "6_0": metal, "7_0": body, "8_0": body,
            "1_1": body, "2_1": body, "3_1": metal, "4_1": slot, "5_1": slot, "6_1": metal, "7_1": body, "8_1": body,
            "1_2": body, "2_2": body, "3_2": metal, "4_2": slot, "5_2": slot, "6_2": metal, "7_2": body, "8_2": body,
            // 본체
            "1_3": body, "2_3": body, "3_3": body, "4_3": body, "5_3": body, "6_3": body, "7_3": body, "8_3": body,
            "1_4": body, "2_4": body, "3_4": body, "4_4": body, "5_4": body, "6_4": body, "7_4": body, "8_4": body,
            // 라벨 영역
            "1_5": body, "2_5": label, "3_5": label, "4_5": label, "5_5": label, "6_5": label, "7_5": label, "8_5": body,
            "1_6": body, "2_6": label, "3_6": label, "4_6": label, "5_6": label, "6_6": label, "7_6": label, "8_6": body,
            "1_7": body, "2_7": label, "3_7": label, "4_7": label, "5_7": label, "6_7": label, "7_7": label, "8_7": body,
            "1_8": body, "2_8": label, "3_8": label, "4_8": label, "5_8": label, "6_8": label, "7_8": label, "8_8": body,
            "1_9": body, "2_9": body, "3_9": body, "4_9": body, "5_9": body, "6_9": body, "7_9": body, "8_9": body,
        ])
        let f2 = PixelIconFrame(pixels: [
            "1_0": bodyBright, "2_0": bodyBright, "3_0": metal, "4_0": metal, "5_0": metal, "6_0": metal, "7_0": bodyBright, "8_0": bodyBright,
            "1_1": bodyBright, "2_1": bodyBright, "3_1": metal, "4_1": slot, "5_1": slot, "6_1": metal, "7_1": bodyBright, "8_1": bodyBright,
            "1_2": bodyBright, "2_2": bodyBright, "3_2": metal, "4_2": slot, "5_2": slot, "6_2": metal, "7_2": bodyBright, "8_2": bodyBright,
            "1_3": bodyBright, "2_3": bodyBright, "3_3": bodyBright, "4_3": bodyBright, "5_3": bodyBright, "6_3": bodyBright, "7_3": bodyBright, "8_3": bodyBright,
            "1_4": bodyBright, "2_4": bodyBright, "3_4": bodyBright, "4_4": bodyBright, "5_4": bodyBright, "6_4": bodyBright, "7_4": bodyBright, "8_4": bodyBright,
            "1_5": bodyBright, "2_5": label, "3_5": label, "4_5": label, "5_5": label, "6_5": label, "7_5": label, "8_5": bodyBright,
            "1_6": bodyBright, "2_6": label, "3_6": label, "4_6": label, "5_6": label, "6_6": label, "7_6": label, "8_6": bodyBright,
            "1_7": bodyBright, "2_7": label, "3_7": label, "4_7": label, "5_7": label, "6_7": label, "7_7": label, "8_7": bodyBright,
            "1_8": bodyBright, "2_8": label, "3_8": label, "4_8": label, "5_8": label, "6_8": label, "7_8": label, "8_8": bodyBright,
            "1_9": bodyBright, "2_9": bodyBright, "3_9": bodyBright, "4_9": bodyBright, "5_9": bodyBright, "6_9": bodyBright, "7_9": bodyBright, "8_9": bodyBright,
        ])
        return PixelIconDefinition(name: "floppyDisk", gridSize: 10, frames: [f1, f2], fps: 3)
    }()

    // MARK: - 13. Film (film 대체 — GIF Animation)
    static let film: PixelIconDefinition = {
        let frame = PixelColor(r: 60, g: 60, b: 70)
        let hole = PixelColor(r: 30, g: 30, b: 40)
        let screen = PixelColor(r: 255, g: 120, b: 180)
        let screenAlt = PixelColor(r: 120, g: 200, b: 255)
        let screenAlt2 = PixelColor(r: 100, g: 255, b: 150)

        func makeFrame(screenColor: PixelColor) -> PixelIconFrame {
            var px: [String: PixelColor] = [:]
            for y in 0...9 { px["0_\(y)"] = frame; px["1_\(y)"] = frame; px["8_\(y)"] = frame; px["9_\(y)"] = frame }
            for x in 2...7 { px["\(x)_0"] = frame; px["\(x)_9"] = frame }
            for y in stride(from: 0, through: 9, by: 2) { px["0_\(y)"] = hole; px["9_\(y)"] = hole }
            for y in 2...7 { for x in 3...6 { px["\(x)_\(y)"] = screenColor } }
            return PixelIconFrame(pixels: px)
        }
        return PixelIconDefinition(name: "film", gridSize: 10, frames: [makeFrame(screenColor: screen), makeFrame(screenColor: screenAlt), makeFrame(screenColor: screenAlt2)], fps: 4)
    }()

    // MARK: - 14. Layers (square.3.layers.3d 대체)
    static let layers: PixelIconDefinition = {
        let l1 = PixelColor(r: 80, g: 200, b: 120)
        let l2 = PixelColor(r: 80, g: 160, b: 255)
        let l3 = PixelColor(r: 200, g: 100, b: 255)

        let f1 = PixelIconFrame(pixels: {
            var px: [String: PixelColor] = [:]
            for x in 0...7 { px["\(x)_7"] = l1; px["\(x)_8"] = l1 }
            for x in 1...8 { px["\(x)_4"] = l2; px["\(x)_5"] = l2 }
            for x in 2...9 { px["\(x)_1"] = l3; px["\(x)_2"] = l3 }
            return px
        }())
        let f2 = PixelIconFrame(pixels: {
            var px: [String: PixelColor] = [:]
            for x in 0...7 { px["\(x)_8"] = l1; px["\(x)_9"] = l1 }
            for x in 1...8 { px["\(x)_5"] = l2; px["\(x)_6"] = l2 }
            for x in 2...9 { px["\(x)_2"] = l3; px["\(x)_3"] = l3 }
            return px
        }())
        return PixelIconDefinition(name: "layers", gridSize: 10, frames: [f1, f2, f1], fps: 3)
    }()

    // MARK: ========== Dynamic Animation Samples ==========

    // MARK: - S1. Running Character (달리는 캐릭터)
    static let runningChar: PixelIconDefinition = {
        let skin = PixelColor(r: 255, g: 200, b: 160)
        let hair = PixelColor(r: 60, g: 40, b: 20)
        let shirt = PixelColor(r: 60, g: 140, b: 255)
        let pants = PixelColor(r: 80, g: 80, b: 120)
        let shoe = PixelColor(r: 200, g: 60, b: 60)
        let eye = B

        // 공통 상체
        func head() -> [String: PixelColor] {
            ["4_0": hair, "5_0": hair, "3_1": hair, "4_1": hair, "5_1": hair, "6_1": hair,
             "3_2": skin, "4_2": skin, "5_2": skin, "6_2": skin,
             "3_3": skin, "4_3": eye, "5_3": skin, "6_3": eye]
        }

        let f1 = PixelIconFrame(pixels: head().merging([
            "3_4": shirt, "4_4": shirt, "5_4": shirt, "6_4": shirt,
            "2_5": skin, "3_5": shirt, "4_5": shirt, "5_5": shirt, "6_5": shirt, "7_5": skin,
            "4_6": pants, "5_6": pants,
            "3_7": pants, "5_7": pants, "6_7": pants,
            "2_8": shoe, "3_8": shoe, "6_8": shoe, "7_8": shoe,
        ], uniquingKeysWith: { _, b in b }))

        let f2 = PixelIconFrame(pixels: head().merging([
            "3_4": shirt, "4_4": shirt, "5_4": shirt, "6_4": shirt,
            "3_5": shirt, "4_5": shirt, "5_5": shirt, "6_5": shirt, "7_5": skin,
            "4_6": pants, "5_6": pants,
            "4_7": pants, "5_7": pants,
            "4_8": shoe, "5_8": shoe,
        ], uniquingKeysWith: { _, b in b }))

        let f3 = PixelIconFrame(pixels: head().merging([
            "3_4": shirt, "4_4": shirt, "5_4": shirt, "6_4": shirt,
            "2_5": skin, "3_5": shirt, "4_5": shirt, "5_5": shirt, "6_5": shirt,
            "4_6": pants, "5_6": pants,
            "5_7": pants, "3_7": pants, "2_7": pants,
            "1_8": shoe, "2_8": shoe, "6_8": shoe, "7_8": shoe,
        ], uniquingKeysWith: { _, b in b }))

        return PixelIconDefinition(name: "runner", gridSize: 10, frames: [f1, f2, f3, f2], fps: 6)
    }()

    // MARK: - S2. Bouncing Ball (튀는 공)
    static let bouncingBall: PixelIconDefinition = {
        let ball = PixelColor(r: 255, g: 80, b: 80)
        let hi = PixelColor(r: 255, g: 180, b: 180)
        let shadow = PixelColor(r: 60, g: 60, b: 60)

        func ballAt(cy: Int, squash: Bool) -> PixelIconFrame {
            var px: [String: PixelColor] = [:]
            // shadow
            for x in 3...6 { px["\(x)_9"] = shadow }
            if squash {
                for x in 3...6 { px["\(x)_\(cy)"] = ball; px["\(x)_\(cy+1)"] = ball }
                px["4_\(cy)"] = hi
            } else {
                px["4_\(cy-1)"] = ball; px["5_\(cy-1)"] = ball
                for x in 3...6 { px["\(x)_\(cy)"] = ball }
                for x in 3...6 { px["\(x)_\(cy+1)"] = ball }
                px["4_\(cy+2)"] = ball; px["5_\(cy+2)"] = ball
                px["4_\(cy-1)"] = hi; px["4_\(cy)"] = hi
            }
            return PixelIconFrame(pixels: px)
        }

        return PixelIconDefinition(name: "bounce", gridSize: 10,
            frames: [ballAt(cy: 1, squash: false), ballAt(cy: 3, squash: false), ballAt(cy: 5, squash: false), ballAt(cy: 7, squash: true), ballAt(cy: 5, squash: false), ballAt(cy: 3, squash: false)],
            fps: 8)
    }()

    // MARK: - S3. Campfire (모닥불)
    static let campfire: PixelIconDefinition = {
        let red = PixelColor(r: 255, g: 60, b: 20)
        let orange = PixelColor(r: 255, g: 160, b: 40)
        let yellow = PixelColor(r: 255, g: 240, b: 80)
        let wood = PixelColor(r: 140, g: 80, b: 30)
        let spark = PixelColor(r: 255, g: 200, b: 100)

        let f1 = PixelIconFrame(pixels: [
            "4_2": yellow, "5_2": yellow,
            "3_3": orange, "4_3": yellow, "5_3": yellow, "6_3": orange,
            "3_4": red, "4_4": orange, "5_4": orange, "6_4": red,
            "2_5": red, "3_5": red, "4_5": orange, "5_5": orange, "6_5": red, "7_5": red,
            "2_6": red, "3_6": red, "4_6": red, "5_6": red, "6_6": red, "7_6": red,
            "1_7": wood, "2_7": wood, "3_7": wood, "4_7": wood, "5_7": wood, "6_7": wood, "7_7": wood, "8_7": wood,
            "2_8": wood, "3_8": wood, "6_8": wood, "7_8": wood,
            "6_1": spark,
        ])
        let f2 = PixelIconFrame(pixels: [
            "5_1": yellow,
            "4_2": orange, "5_2": yellow, "6_2": yellow,
            "3_3": red, "4_3": yellow, "5_3": orange, "6_3": red,
            "2_4": red, "3_4": orange, "4_4": yellow, "5_4": orange, "6_4": orange, "7_4": red,
            "2_5": red, "3_5": red, "4_5": orange, "5_5": red, "6_5": red, "7_5": red,
            "2_6": red, "3_6": red, "4_6": red, "5_6": red, "6_6": red, "7_6": red,
            "1_7": wood, "2_7": wood, "3_7": wood, "4_7": wood, "5_7": wood, "6_7": wood, "7_7": wood, "8_7": wood,
            "2_8": wood, "3_8": wood, "6_8": wood, "7_8": wood,
            "3_0": spark,
        ])
        let f3 = PixelIconFrame(pixels: [
            "4_1": yellow, "5_1": orange,
            "3_2": orange, "4_2": yellow, "5_2": yellow, "6_2": orange,
            "3_3": red, "4_3": orange, "5_3": yellow, "6_3": orange, "7_3": red,
            "2_4": red, "3_4": red, "4_4": orange, "5_4": orange, "6_4": red,
            "2_5": red, "3_5": red, "4_5": red, "5_5": orange, "6_5": red, "7_5": red,
            "3_6": red, "4_6": red, "5_6": red, "6_6": red,
            "1_7": wood, "2_7": wood, "3_7": wood, "4_7": wood, "5_7": wood, "6_7": wood, "7_7": wood, "8_7": wood,
            "2_8": wood, "3_8": wood, "6_8": wood, "7_8": wood,
            "7_0": spark, "2_1": spark,
        ])

        return PixelIconDefinition(name: "campfire", gridSize: 10, frames: [f1, f2, f3, f2], fps: 6)
    }()

    // MARK: - S4. Heart Beat (뛰는 하트)
    static let heartBeat: PixelIconDefinition = {
        let h = PixelColor(r: 255, g: 50, b: 80)
        let hi = PixelColor(r: 255, g: 140, b: 160)

        // Small heart
        let f1 = PixelIconFrame(pixels: [
            "3_3": h, "4_3": h, "6_3": h, "7_3": h,
            "2_4": h, "3_4": hi, "4_4": h, "5_4": h, "6_4": h, "7_4": h, "8_4": h,
            "2_5": h, "3_5": h, "4_5": h, "5_5": h, "6_5": h, "7_5": h, "8_5": h,
            "3_6": h, "4_6": h, "5_6": h, "6_6": h, "7_6": h,
            "4_7": h, "5_7": h, "6_7": h,
            "5_8": h,
        ])
        // Big heart
        let f2 = PixelIconFrame(pixels: [
            "2_2": h, "3_2": h, "4_2": h, "6_2": h, "7_2": h, "8_2": h,
            "1_3": h, "2_3": hi, "3_3": hi, "4_3": h, "5_3": h, "6_3": h, "7_3": h, "8_3": h, "9_3": h,
            "1_4": h, "2_4": hi, "3_4": h, "4_4": h, "5_4": h, "6_4": h, "7_4": h, "8_4": h, "9_4": h,
            "1_5": h, "2_5": h, "3_5": h, "4_5": h, "5_5": h, "6_5": h, "7_5": h, "8_5": h, "9_5": h,
            "2_6": h, "3_6": h, "4_6": h, "5_6": h, "6_6": h, "7_6": h, "8_6": h,
            "3_7": h, "4_7": h, "5_7": h, "6_7": h, "7_7": h,
            "4_8": h, "5_8": h, "6_8": h,
            "5_9": h,
        ])

        return PixelIconDefinition(name: "heartBeat", gridSize: 10, frames: [f1, f2, f1, f1, f2, f2], fps: 5)
    }()

    // MARK: - S5. Rocket Launch (로켓 발사)
    static let rocket: PixelIconDefinition = {
        let body = PixelColor(r: 230, g: 230, b: 240)
        let nose = PixelColor(r: 255, g: 80, b: 60)
        let window = PixelColor(r: 80, g: 180, b: 255)
        let fin = PixelColor(r: 255, g: 80, b: 60)
        let flame = PixelColor(r: 255, g: 180, b: 40)
        let flameR = PixelColor(r: 255, g: 100, b: 20)

        func rocketAt(oy: Int, flameLen: Int) -> PixelIconFrame {
            var px: [String: PixelColor] = [:]
            // nose
            px["4_\(oy)"] = nose; px["5_\(oy)"] = nose
            // body
            for dy in 1...4 {
                px["3_\(oy+dy)"] = body; px["4_\(oy+dy)"] = body; px["5_\(oy+dy)"] = body; px["6_\(oy+dy)"] = body
            }
            // window
            px["4_\(oy+2)"] = window; px["5_\(oy+2)"] = window
            // fins
            px["2_\(oy+4)"] = fin; px["7_\(oy+4)"] = fin
            px["1_\(oy+5)"] = fin; px["8_\(oy+5)"] = fin
            // flames
            for dy in 1...flameLen {
                let fy = oy + 5 + dy
                if fy < 10 {
                    px["4_\(fy)"] = flame; px["5_\(fy)"] = flame
                    if dy > 1 { px["3_\(fy)"] = flameR; px["6_\(fy)"] = flameR }
                }
            }
            return PixelIconFrame(pixels: px)
        }

        return PixelIconDefinition(name: "rocket", gridSize: 10,
            frames: [rocketAt(oy: 3, flameLen: 1), rocketAt(oy: 2, flameLen: 2), rocketAt(oy: 1, flameLen: 3), rocketAt(oy: 0, flameLen: 4), rocketAt(oy: 1, flameLen: 2), rocketAt(oy: 2, flameLen: 1)],
            fps: 6)
    }()

    // MARK: - S6. Sword Slash (검 휘두르기)
    static let swordSlash: PixelIconDefinition = {
        let blade = PixelColor(r: 200, g: 210, b: 230)
        let guard_ = PixelColor(r: 200, g: 170, b: 50)
        let handle = PixelColor(r: 120, g: 80, b: 40)
        let trail = PixelColor(r: 180, g: 220, b: 255)

        // Sword upright
        let f1 = PixelIconFrame(pixels: [
            "4_0": blade, "5_0": blade, "4_1": blade, "5_1": blade,
            "4_2": blade, "5_2": blade, "4_3": blade, "5_3": blade,
            "4_4": blade, "5_4": blade,
            "3_5": guard_, "4_5": guard_, "5_5": guard_, "6_5": guard_,
            "4_6": handle, "5_6": handle, "4_7": handle, "5_7": handle,
        ])
        // Sword swinging right
        let f2 = PixelIconFrame(pixels: [
            "5_0": blade, "6_1": blade, "7_2": blade, "8_3": blade, "9_4": blade,
            "4_1": trail, "5_2": trail, "6_3": trail, "7_4": trail,
            "3_5": guard_, "4_5": guard_, "5_5": guard_, "6_5": guard_,
            "4_6": handle, "5_6": handle, "4_7": handle, "5_7": handle,
        ])
        // Sword horizontal
        let f3 = PixelIconFrame(pixels: [
            "5_3": blade, "6_3": blade, "7_3": blade, "8_3": blade, "9_3": blade,
            "5_4": blade, "6_4": blade, "7_4": blade, "8_4": blade, "9_4": blade,
            "3_2": trail, "4_2": trail, "5_2": trail, "6_2": trail,
            "3_5": guard_, "4_5": guard_, "5_5": guard_,
            "4_6": handle, "5_6": handle, "4_7": handle, "5_7": handle,
        ])
        // Swing down
        let f4 = PixelIconFrame(pixels: [
            "7_4": blade, "8_5": blade, "8_6": blade, "7_7": blade, "6_8": blade,
            "6_3": trail, "7_3": trail, "8_4": trail,
            "3_5": guard_, "4_5": guard_, "5_5": guard_, "6_5": guard_,
            "4_6": handle, "5_6": handle, "4_7": handle, "5_7": handle,
        ])

        return PixelIconDefinition(name: "sword", gridSize: 10, frames: [f1, f2, f3, f4, f3, f2], fps: 8)
    }()

    // MARK: - S7. Spinning Coin (회전하는 동전)
    static let spinCoin: PixelIconDefinition = {
        let gold = PixelColor(r: 255, g: 200, b: 50)
        let dark = PixelColor(r: 200, g: 150, b: 30)
        let hi = PixelColor(r: 255, g: 240, b: 150)
        let edge = PixelColor(r: 170, g: 130, b: 20)

        // Full face
        let f1 = PixelIconFrame(pixels: {
            var px: [String: PixelColor] = [:]
            for y in 2...7 { for x in 2...7 { px["\(x)_\(y)"] = gold } }
            px["3_1"] = gold; px["4_1"] = gold; px["5_1"] = gold; px["6_1"] = gold
            px["3_8"] = gold; px["4_8"] = gold; px["5_8"] = gold; px["6_8"] = gold
            px["1_3"] = gold; px["1_4"] = gold; px["1_5"] = gold; px["1_6"] = gold
            px["8_3"] = gold; px["8_4"] = gold; px["8_5"] = gold; px["8_6"] = gold
            px["3_3"] = hi; px["3_4"] = hi; px["4_3"] = hi
            px["4_4"] = dark; px["5_4"] = dark; px["4_5"] = dark; px["5_5"] = dark // $ sign center
            return px
        }())
        // 3/4 view
        let f2 = PixelIconFrame(pixels: {
            var px: [String: PixelColor] = [:]
            for y in 2...7 { for x in 3...6 { px["\(x)_\(y)"] = gold } }
            px["4_1"] = gold; px["5_1"] = gold
            px["4_8"] = gold; px["5_8"] = gold
            px["2_3"] = gold; px["2_4"] = gold; px["2_5"] = gold; px["2_6"] = gold
            px["7_3"] = dark; px["7_4"] = dark; px["7_5"] = dark; px["7_6"] = dark
            px["3_3"] = hi; px["4_3"] = hi
            return px
        }())
        // Edge view
        let f3 = PixelIconFrame(pixels: {
            var px: [String: PixelColor] = [:]
            for y in 1...8 { px["4_\(y)"] = edge; px["5_\(y)"] = dark }
            px["4_0"] = edge; px["5_0"] = dark; px["4_9"] = edge; px["5_9"] = dark
            return px
        }())
        // 3/4 reverse
        let f4 = PixelIconFrame(pixels: {
            var px: [String: PixelColor] = [:]
            for y in 2...7 { for x in 3...6 { px["\(x)_\(y)"] = gold } }
            px["4_1"] = gold; px["5_1"] = gold
            px["4_8"] = gold; px["5_8"] = gold
            px["2_3"] = dark; px["2_4"] = dark; px["2_5"] = dark; px["2_6"] = dark
            px["7_3"] = gold; px["7_4"] = gold; px["7_5"] = gold; px["7_6"] = gold
            px["6_3"] = hi; px["6_4"] = hi
            return px
        }())

        return PixelIconDefinition(name: "coin", gridSize: 10, frames: [f1, f2, f3, f4], fps: 6)
    }()

    // MARK: - S8. Waving Flag (펄럭이는 깃발)
    static let flag: PixelIconDefinition = {
        let pole = PixelColor(r: 160, g: 160, b: 170)
        let red = PixelColor(r: 255, g: 60, b: 60)
        let white = W

        func makeFrame(wave: Int) -> PixelIconFrame {
            var px: [String: PixelColor] = [:]
            // pole
            for y in 0...9 { px["1_\(y)"] = pole }
            // flag body (6 wide, 5 tall) with wave offset
            for row in 0...4 {
                let wy = row + (wave == 0 ? 1 : (wave == 1 ? (row < 2 ? 0 : 1) : (row < 2 ? 2 : 1)))
                for col in 0...5 {
                    let x = col + 2
                    guard wy >= 0 && wy <= 9 && x <= 9 else { continue }
                    let color: PixelColor = (row < 2) ? red : (row == 2 ? white : red)
                    px["\(x)_\(wy)"] = color
                }
            }
            return PixelIconFrame(pixels: px)
        }

        return PixelIconDefinition(name: "flag", gridSize: 10, frames: [makeFrame(wave: 0), makeFrame(wave: 1), makeFrame(wave: 2), makeFrame(wave: 1)], fps: 5)
    }()
}
