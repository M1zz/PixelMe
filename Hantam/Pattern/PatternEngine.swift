//
//  PatternEngine.swift
//  Hantam
//
//  사진 → 도안. 칸마다 평균색을 내고, 그 재료에서 실제로 파는 색 중 가장 가까운 색을 고른 뒤,
//  색 수 상한에 맞춰 적게 쓰인 색부터 지워 가까운 색으로 옮긴다.
//

import UIKit

struct PatternSettings: Equatable {
    var material: PatternMaterial = .perler
    /// 가장 긴 변의 칸 수. 짧은 변은 사진 비율로 정한다.
    var longestSide: Int = 29
    var maxColors: Int = 12
    /// 투명한 칸(배경을 지운 사진)을 빈칸으로 둔다.
    var keepTransparentEmpty: Bool = true
    var fabricCount: Int = 14
}

enum PatternEngine {

    /// 사진 비율에 맞춘 칸 수.
    static func gridSize(for image: UIImage, longestSide: Int) -> (w: Int, h: Int) {
        let size = image.size
        guard size.width > 0, size.height > 0 else { return (longestSide, longestSide) }
        if size.width >= size.height {
            let h = max(1, Int((Double(longestSide) * Double(size.height / size.width)).rounded()))
            return (longestSide, h)
        } else {
            let w = max(1, Int((Double(longestSide) * Double(size.width / size.height)).rounded()))
            return (w, longestSide)
        }
    }

    /// 도안을 만든다. 무거우므로 메인 스레드 밖에서 부른다.
    static func makePattern(from image: UIImage, settings: PatternSettings, title: String) -> BeadPattern? {
        let (w, h) = gridSize(for: image, longestSide: settings.longestSide)
        guard let samples = averageColors(of: image, width: w, height: h) else { return nil }

        let palette = settings.material.palette
        let paletteLab = palette.map { Lab(r: $0.r, g: $0.g, b: $0.b) }

        // 1) 칸마다 원래 색(Lab)과 가장 가까운 재료 색.
        var cellLab = [Lab?](repeating: nil, count: w * h)
        var assigned = [Int](repeating: -1, count: w * h)
        var cache: [UInt32: Int] = [:]
        for i in 0..<(w * h) {
            let s = samples[i]
            if settings.keepTransparentEmpty && s.a < 128 { continue }
            let lab = Lab(r: s.r, g: s.g, b: s.b)
            cellLab[i] = lab
            let key = UInt32(s.r) << 16 | UInt32(s.g) << 8 | UInt32(s.b)
            if let hit = cache[key] {
                assigned[i] = hit
            } else {
                let best = nearest(lab, in: paletteLab, allowed: nil)
                cache[key] = best
                assigned[i] = best
            }
        }

        // 2) 색 수 줄이기 — 가장 적게 쓴 색을 지우고 그 칸들을 남은 색 중 가까운 색으로.
        var counts = [Int](repeating: 0, count: palette.count)
        for a in assigned where a >= 0 { counts[a] += 1 }
        var allowed = Set(counts.indices.filter { counts[$0] > 0 })
        let limit = max(2, settings.maxColors)
        while allowed.count > limit {
            guard let victim = allowed.min(by: { counts[$0] < counts[$1] }) else { break }
            allowed.remove(victim)
            for i in assigned.indices where assigned[i] == victim {
                guard let lab = cellLab[i] else { continue }
                let next = nearest(lab, in: paletteLab, allowed: allowed)
                assigned[i] = next
                counts[next] += 1
            }
            counts[victim] = 0
        }

        // 3) 재료 팔레트 인덱스 → 도안 안의 작은 색 목록 인덱스.
        let used = allowed.sorted()
        var remap: [Int: Int] = [:]
        for (newIndex, old) in used.enumerated() { remap[old] = newIndex }
        let cells = assigned.map { $0 >= 0 ? (remap[$0] ?? -1) : -1 }

        return BeadPattern(
            title: title,
            material: settings.material,
            fabricCount: settings.fabricCount,
            width: w,
            height: h,
            cells: cells,
            colors: used.map { palette[$0] }
        )
    }

    // MARK: - 칸 평균색

    struct RGBA { var r: UInt8; var g: UInt8; var b: UInt8; var a: UInt8 }

    /// 사진을 w×h 칸으로 나눠 칸마다 평균색을 낸다. 한 칸을 4×4 로 그려 평균해, 축소 보간보다 정확하다.
    static func averageColors(of image: UIImage, width w: Int, height h: Int) -> [RGBA]? {
        let oversample = 4
        let bw = w * oversample, bh = h * oversample
        guard let cg = image.normalizedCGImage() else { return nil }
        var buffer = [UInt8](repeating: 0, count: bw * bh * 4)
        let drawn: Bool = buffer.withUnsafeMutableBytes { ptr in
            guard let ctx = CGContext(
                data: ptr.baseAddress, width: bw, height: bh, bitsPerComponent: 8, bytesPerRow: bw * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return false }
            ctx.interpolationQuality = .high
            ctx.draw(cg, in: CGRect(x: 0, y: 0, width: bw, height: bh))
            return true
        }
        guard drawn else { return nil }

        var out = [RGBA](repeating: RGBA(r: 0, g: 0, b: 0, a: 0), count: w * h)
        for cy in 0..<h {
            for cx in 0..<w {
                var r = 0, g = 0, b = 0, a = 0
                for sy in 0..<oversample {
                    for sx in 0..<oversample {
                        let px = cx * oversample + sx
                        let py = cy * oversample + sy
                        let o = (py * bw + px) * 4
                        r += Int(buffer[o]); g += Int(buffer[o + 1]); b += Int(buffer[o + 2]); a += Int(buffer[o + 3])
                    }
                }
                let n = oversample * oversample
                let alpha = a / n
                // premultiplied → 원래 색. 투명한 픽셀은 색에 끼지 않는다.
                if a > 0 {
                    out[cy * w + cx] = RGBA(
                        r: UInt8(clamping: r * 255 / a),
                        g: UInt8(clamping: g * 255 / a),
                        b: UInt8(clamping: b * 255 / a),
                        a: UInt8(clamping: alpha)
                    )
                }
            }
        }
        return out
    }

    // MARK: - 색 거리 (CIE94)

    struct Lab { let l: Double; let a: Double; let b: Double }

    static func nearest(_ lab: Lab, in palette: [Lab], allowed: Set<Int>?) -> Int {
        var best = 0
        var bestD = Double.greatestFiniteMagnitude
        for (i, p) in palette.enumerated() {
            if let allowed, !allowed.contains(i) { continue }
            let d = deltaE94(lab, p)
            if d < bestD { bestD = d; best = i }
        }
        return best
    }

    static func deltaE94(_ x: Lab, _ y: Lab) -> Double {
        let dL = x.l - y.l
        let c1 = (x.a * x.a + x.b * x.b).squareRoot()
        let c2 = (y.a * y.a + y.b * y.b).squareRoot()
        let dC = c1 - c2
        let da = x.a - y.a, db = x.b - y.b
        let dH2 = max(0, da * da + db * db - dC * dC)
        let sC = 1 + 0.045 * c1
        let sH = 1 + 0.015 * c1
        return (dL * dL + (dC / sC) * (dC / sC) + dH2 / (sH * sH)).squareRoot()
    }
}

extension PatternEngine.Lab {
    /// sRGB(D65) → CIELAB.
    init(r: UInt8, g: UInt8, b: UInt8) {
        func lin(_ v: UInt8) -> Double {
            let c = Double(v) / 255
            return c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        let R = lin(r), G = lin(g), B = lin(b)
        let X = (0.4124 * R + 0.3576 * G + 0.1805 * B) / 0.95047
        let Y = (0.2126 * R + 0.7152 * G + 0.0722 * B)
        let Z = (0.0193 * R + 0.1192 * G + 0.9505 * B) / 1.08883
        func f(_ t: Double) -> Double { t > 0.008856 ? cbrt(t) : (7.787 * t + 16.0 / 116) }
        let fx = f(X), fy = f(Y), fz = f(Z)
        self.init(l: 116 * fy - 16, a: 500 * (fx - fy), b: 200 * (fy - fz))
    }
}

extension UIImage {
    /// 방향 정보를 반영해 위가 위인 CGImage 로.
    func normalizedCGImage() -> CGImage? {
        if imageOrientation == .up, let cg = cgImage { return cg }
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in draw(in: CGRect(origin: .zero, size: size)) }.cgImage
    }
}
