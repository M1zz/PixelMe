//
//  PatternRenderer.swift
//  Hantam
//
//  도안을 그림으로 — 화면용 이미지, 공유용 PNG, 인쇄용 PDF.
//

import UIKit

enum PatternDisplayStyle: String, CaseIterable, Identifiable {
    /// 실물처럼 — 구멍 난 비즈 / 엑스(X) 땀.
    case preview
    /// 색 칸.
    case color
    /// 기호 도안 (인쇄용과 같은 모양).
    case symbol

    var id: String { rawValue }
}

enum PatternRenderer {

    // MARK: - 화면 · PNG

    static func image(
        for pattern: BeadPattern,
        cell: CGFloat,
        style: PatternDisplayStyle,
        showGrid: Bool = true
    ) -> UIImage {
        let size = CGSize(width: CGFloat(pattern.width) * cell, height: CGFloat(pattern.height) * cell)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let symbols = pattern.symbols
        return UIGraphicsImageRenderer(size: size, format: format).image { ctx in
            let g = ctx.cgContext
            UIColor.white.setFill()
            g.fill(CGRect(origin: .zero, size: size))
            drawCells(pattern, in: g, origin: .zero, cell: cell, style: style, symbols: symbols,
                      xRange: 0..<pattern.width, yRange: 0..<pattern.height)
            if showGrid && cell >= 6 {
                drawGrid(pattern, in: g, origin: .zero, cell: cell,
                         xRange: 0..<pattern.width, yRange: 0..<pattern.height)
            }
        }
    }

    /// 공유용 PNG — 한 변 2,000px 안팎. 무료는 워터마크를 단다.
    static func shareImage(for pattern: BeadPattern, style: PatternDisplayStyle, watermark: Bool) -> UIImage {
        let cell = max(8, min(40, (2000 / CGFloat(pattern.longestSide)).rounded()))
        let img = image(for: pattern, cell: cell, style: style, showGrid: style != .preview)
        return watermark ? FreeUsageManager.applyWatermark(to: img) : img
    }

    // MARK: - 칸 그리기

    private static func drawCells(
        _ p: BeadPattern, in g: CGContext, origin: CGPoint, cell: CGFloat, style: PatternDisplayStyle,
        symbols: [Int: String], xRange: Range<Int>, yRange: Range<Int>
    ) {
        let font = UIFont.systemFont(ofSize: cell * 0.62, weight: .semibold)
        for y in yRange {
            for x in xRange {
                let ci = p.colorIndex(x: x, y: y)
                let rect = CGRect(
                    x: origin.x + CGFloat(x - xRange.lowerBound) * cell,
                    y: origin.y + CGFloat(y - yRange.lowerBound) * cell,
                    width: cell, height: cell
                )
                guard ci >= 0 else {
                    if style == .preview && p.material.kind == .bead {
                        // 빈 보드 핀
                        UIColor(white: 0.9, alpha: 1).setFill()
                        g.fillEllipse(in: rect.insetBy(dx: cell * 0.38, dy: cell * 0.38))
                    }
                    continue
                }
                let c = p.colors[ci]
                switch style {
                case .color:
                    c.uiColor.setFill()
                    g.fill(rect)
                case .preview:
                    if p.material.kind == .bead {
                        c.uiColor.setFill()
                        g.fillEllipse(in: rect.insetBy(dx: cell * 0.02, dy: cell * 0.02))
                        UIColor.white.withAlphaComponent(0.6).setFill()
                        g.fillEllipse(in: rect.insetBy(dx: cell * 0.38, dy: cell * 0.38))
                    } else {
                        g.setStrokeColor(c.uiColor.cgColor)
                        g.setLineWidth(max(1, cell * 0.22))
                        g.setLineCap(.round)
                        let r = rect.insetBy(dx: cell * 0.16, dy: cell * 0.16)
                        g.move(to: CGPoint(x: r.minX, y: r.minY)); g.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
                        g.move(to: CGPoint(x: r.maxX, y: r.minY)); g.addLine(to: CGPoint(x: r.minX, y: r.maxY))
                        g.strokePath()
                    }
                case .symbol:
                    c.uiColor.withAlphaComponent(0.55).setFill()
                    g.fill(rect)
                    if let s = symbols[ci], cell >= 7 {
                        let attrs: [NSAttributedString.Key: Any] = [
                            .font: font,
                            .foregroundColor: c.isLight ? UIColor.black : UIColor.white,
                        ]
                        let str = s as NSString
                        let sz = str.size(withAttributes: attrs)
                        str.draw(at: CGPoint(x: rect.midX - sz.width / 2, y: rect.midY - sz.height / 2), withAttributes: attrs)
                    }
                }
            }
        }
    }

    private static func drawGrid(
        _ p: BeadPattern, in g: CGContext, origin: CGPoint, cell: CGFloat,
        xRange: Range<Int>, yRange: Range<Int>
    ) {
        let w = CGFloat(xRange.count) * cell, h = CGFloat(yRange.count) * cell
        let major = p.material.majorGridStep
        func line(_ a: CGPoint, _ b: CGPoint, _ width: CGFloat, _ color: UIColor) {
            g.setStrokeColor(color.cgColor); g.setLineWidth(width)
            g.move(to: a); g.addLine(to: b); g.strokePath()
        }
        for i in 0...xRange.count {
            let gx = xRange.lowerBound + i
            let isMajor = gx % major == 0 || gx == p.width
            let x = origin.x + CGFloat(i) * cell
            line(CGPoint(x: x, y: origin.y), CGPoint(x: x, y: origin.y + h),
                 isMajor ? max(1.5, cell * 0.12) : max(0.5, cell * 0.04),
                 isMajor ? UIColor(white: 0.15, alpha: 0.9) : UIColor(white: 0.4, alpha: 0.35))
        }
        for i in 0...yRange.count {
            let gy = yRange.lowerBound + i
            let isMajor = gy % major == 0 || gy == p.height
            let y = origin.y + CGFloat(i) * cell
            line(CGPoint(x: origin.x, y: y), CGPoint(x: origin.x + w, y: y),
                 isMajor ? max(1.5, cell * 0.12) : max(0.5, cell * 0.04),
                 isMajor ? UIColor(white: 0.15, alpha: 0.9) : UIColor(white: 0.4, alpha: 0.35))
        }
    }

    // MARK: - 인쇄용 PDF

    /// A4 PDF — 1쪽 미리보기·정보·색 목록, 그다음 쪽마다 도안 한 조각(비즈는 보드 한 장).
    static func pdfData(for p: BeadPattern) -> Data {
        let page = CGRect(x: 0, y: 0, width: 595, height: 842)
        let margin: CGFloat = 36
        let renderer = UIGraphicsPDFRenderer(bounds: page)
        let symbols = p.symbols
        let usage = p.colorUsage

        return renderer.pdfData { ctx in
            // ── 1쪽: 표지 ──
            ctx.beginPage()
            var y = margin
            y = drawText(p.title, at: CGPoint(x: margin, y: y), width: page.width - margin * 2,
                         font: .systemFont(ofSize: 22, weight: .bold))
            y += 4
            for line in infoLines(for: p) {
                y = drawText(line, at: CGPoint(x: margin, y: y), width: page.width - margin * 2,
                             font: .systemFont(ofSize: 11), color: .darkGray)
            }
            y += 10
            let previewMax = CGSize(width: page.width - margin * 2, height: 300)
            let cell = min(previewMax.width / CGFloat(p.width), previewMax.height / CGFloat(p.height))
            let preview = image(for: p, cell: max(1, cell * 2), style: .preview, showGrid: false)
            let pw = CGFloat(p.width) * cell, ph = CGFloat(p.height) * cell
            preview.draw(in: CGRect(x: (page.width - pw) / 2, y: y, width: pw, height: ph))
            y += ph + 18

            // 색 목록 (넘치면 다음 쪽으로)
            y = drawText(NSLocalizedString("Colors you need", comment: "PDF: legend title"),
                         at: CGPoint(x: margin, y: y), width: 400, font: .systemFont(ofSize: 14, weight: .bold))
            y += 4
            let rowH: CGFloat = 18
            let colW = (page.width - margin * 2) / 2
            var col = 0
            for u in usage {
                if y + rowH > page.height - margin {
                    if col == 0 { col = 1; y = margin } else { ctx.beginPage(); col = 0; y = margin }
                }
                let x = margin + CGFloat(col) * colW
                let sw = CGRect(x: x, y: y + 2, width: 14, height: 14)
                u.color.uiColor.withAlphaComponent(0.55).setFill()
                UIRectFill(sw)
                UIColor.gray.setStroke()
                UIRectFrame(sw)
                let sym = symbols[u.index] ?? ""
                let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 9, weight: .semibold),
                                                            .foregroundColor: u.color.isLight ? UIColor.black : UIColor.white]
                let ss = (sym as NSString).size(withAttributes: attrs)
                (sym as NSString).draw(at: CGPoint(x: sw.midX - ss.width / 2, y: sw.midY - ss.height / 2), withAttributes: attrs)
                let label = "\(u.color.code)  \(u.color.name)  ×\(u.count)"
                _ = drawText(label, at: CGPoint(x: x + 20, y: y + 2), width: colW - 24, font: .systemFont(ofSize: 10))
                y += rowH
            }

            // ── 도안 조각 ──
            let tileW: Int, tileH: Int
            if let b = p.material.boardSize { tileW = b; tileH = b } else { tileW = 40; tileH = 54 }
            let across = (p.width + tileW - 1) / tileW
            let down = (p.height + tileH - 1) / tileH
            let gridTop: CGFloat = margin + 26
            let avail = CGSize(width: page.width - margin * 2 - 16, height: page.height - gridTop - margin - 10)
            let c = min(avail.width / CGFloat(tileW), avail.height / CGFloat(tileH))
            for ty in 0..<down {
                for tx in 0..<across {
                    ctx.beginPage()
                    let xr = (tx * tileW)..<min(p.width, (tx + 1) * tileW)
                    let yr = (ty * tileH)..<min(p.height, (ty + 1) * tileH)
                    let header: String
                    if p.material.kind == .bead {
                        header = String(format: NSLocalizedString("Board %lld of %lld · row %lld, column %lld", comment: "PDF: bead board page header"),
                                        ty * across + tx + 1, across * down, ty + 1, tx + 1)
                    } else {
                        header = String(format: NSLocalizedString("Page %lld of %lld · columns %lld–%lld, rows %lld–%lld", comment: "PDF: stitch chart page header"),
                                        ty * across + tx + 1, across * down, xr.lowerBound + 1, xr.upperBound, yr.lowerBound + 1, yr.upperBound)
                    }
                    _ = drawText("\(p.title) — \(header)", at: CGPoint(x: margin, y: margin), width: page.width - margin * 2,
                                 font: .systemFont(ofSize: 10, weight: .semibold), color: .darkGray)
                    let origin = CGPoint(x: margin + 16, y: gridTop)
                    let g = ctx.cgContext
                    drawCells(p, in: g, origin: origin, cell: c, style: .symbol, symbols: symbols, xRange: xr, yRange: yr)
                    drawGrid(p, in: g, origin: origin, cell: c, xRange: xr, yRange: yr)
                    // 가장자리 칸 번호 (10칸마다)
                    let numFont = UIFont.monospacedDigitSystemFont(ofSize: 6.5, weight: .regular)
                    for x in xr where (x + 1) % 10 == 0 || x == xr.lowerBound {
                        let s = "\(x + 1)" as NSString
                        s.draw(at: CGPoint(x: origin.x + CGFloat(x - xr.lowerBound) * c + 1, y: origin.y - 9),
                               withAttributes: [.font: numFont, .foregroundColor: UIColor.gray])
                    }
                    for yy in yr where (yy + 1) % 10 == 0 || yy == yr.lowerBound {
                        let s = "\(yy + 1)" as NSString
                        s.draw(at: CGPoint(x: margin, y: origin.y + CGFloat(yy - yr.lowerBound) * c + 1),
                               withAttributes: [.font: numFont, .foregroundColor: UIColor.gray])
                    }
                }
            }
        }
    }

    /// 도안 정보 — 재료, 칸 수, 완성 크기, 개수.
    static func infoLines(for p: BeadPattern) -> [String] {
        var lines: [String] = []
        lines.append("\(p.material.brandName) · \(p.width) × \(p.height)")
        let size = p.finishedSizeCM
        lines.append(String(format: NSLocalizedString("Finished size about %.1f × %.1f cm", comment: "Pattern info: finished size"), size.w, size.h))
        if let b = p.boards {
            lines.append(String(format: NSLocalizedString("%lld pegboards (%lld × %lld)", comment: "Pattern info: pegboards needed"), b.across * b.down, b.across, b.down))
            lines.append(String(format: NSLocalizedString("%lld beads in %lld colors", comment: "Pattern info: bead count and colors"), p.filledCount, p.colorUsage.count))
        } else {
            lines.append(String(format: NSLocalizedString("%lld-count fabric", comment: "Pattern info: Aida fabric count"), p.fabricCount))
            lines.append(String(format: NSLocalizedString("%lld stitches in %lld colors", comment: "Pattern info: stitch count and colors"), p.filledCount, p.colorUsage.count))
        }
        return lines
    }

    @discardableResult
    private static func drawText(_ text: String, at point: CGPoint, width: CGFloat, font: UIFont, color: UIColor = .black) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let str = text as NSString
        let rect = str.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                                    options: [.usesLineFragmentOrigin], attributes: attrs, context: nil)
        str.draw(with: CGRect(origin: point, size: CGSize(width: width, height: rect.height)),
                 options: [.usesLineFragmentOrigin], attributes: attrs, context: nil)
        return point.y + ceil(rect.height)
    }

    /// 쇼핑 목록 — 복사해 메모나 장바구니에 붙여 넣는다. 비즈는 10% 여유분을 더한다.
    static func shoppingList(for p: BeadPattern) -> String {
        var lines = [p.title, infoLines(for: p).joined(separator: "\n"), ""]
        for u in p.colorUsage {
            if p.material.kind == .bead {
                let spare = Int((Double(u.count) * 1.1).rounded(.up))
                lines.append("\(u.color.code) \(u.color.name) — \(u.count) (+\(spare - u.count))")
            } else {
                lines.append("\(u.color.code) \(u.color.name) — \(u.count)")
            }
        }
        return lines.joined(separator: "\n")
    }
}
