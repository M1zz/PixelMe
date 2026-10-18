//
//  PatternEngineTests.swift
//  HantamTests
//
//  사진 → 도안 엔진, 인쇄 PDF, 통계 이름 붙이기.
//

import XCTest
import LeeoKit
@testable import Hantam

final class PatternEngineTests: XCTestCase {

    /// 왼쪽 절반 빨강, 오른쪽 절반 파랑.
    private func halves(width: Int = 200, height: Int = 100) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format).image { ctx in
            UIColor(red: 0.85, green: 0.1, blue: 0.1, alpha: 1).setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: width / 2, height: height))
            UIColor(red: 0.1, green: 0.2, blue: 0.85, alpha: 1).setFill()
            ctx.fill(CGRect(x: width / 2, y: 0, width: width / 2, height: height))
        }
    }

    func testGridKeepsPhotoAspect() {
        let size = PatternEngine.gridSize(for: halves(width: 200, height: 100), longestSide: 58)
        XCTAssertEqual(size.w, 58)
        XCTAssertEqual(size.h, 29)
    }

    func testTwoColorPhotoMakesTwoBrandColors() throws {
        var s = PatternSettings()
        s.material = .perler
        s.longestSide = 20
        s.maxColors = 12
        let p = try XCTUnwrap(PatternEngine.makePattern(from: halves(), settings: s, title: "t"))
        XCTAssertEqual(p.width, 20)
        XCTAssertEqual(p.height, 10)
        XCTAssertEqual(p.colorUsage.count, 2)
        XCTAssertEqual(p.filledCount, 200)
        // 왼쪽은 붉고 오른쪽은 푸르다
        let left = p.colors[p.colorIndex(x: 0, y: 0)]
        let right = p.colors[p.colorIndex(x: 19, y: 0)]
        XCTAssertGreaterThan(Int(left.r), Int(left.b))
        XCTAssertGreaterThan(Int(right.b), Int(right.r))
        // 모든 색이 실제 Perler 색표에 있다
        for c in p.colors { XCTAssertTrue(PatternColor.perler.contains(c)) }
    }

    func testMaxColorsIsRespected() throws {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let gradient = UIGraphicsImageRenderer(size: CGSize(width: 120, height: 120), format: format).image { ctx in
            for x in 0..<120 {
                UIColor(hue: CGFloat(x) / 120, saturation: 0.8, brightness: 0.9, alpha: 1).setFill()
                ctx.fill(CGRect(x: x, y: 0, width: 1, height: 120))
            }
        }
        var s = PatternSettings()
        s.material = .dmc
        s.longestSide = 60
        s.maxColors = 6
        let p = try XCTUnwrap(PatternEngine.makePattern(from: gradient, settings: s, title: "t"))
        XCTAssertLessThanOrEqual(p.colorUsage.count, 6)
        XCTAssertEqual(p.filledCount, 60 * 60)
    }

    func testTransparentCellsStayEmpty() throws {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false
        let img = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 100), format: format).image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 50, height: 100))
        }
        var s = PatternSettings()
        s.longestSide = 10
        let p = try XCTUnwrap(PatternEngine.makePattern(from: img, settings: s, title: "t"))
        XCTAssertEqual(p.colorIndex(x: 9, y: 5), -1)
        XCTAssertGreaterThanOrEqual(p.colorIndex(x: 0, y: 5), 0)
    }

    func testBoardsAndFinishedSize() {
        let bead = BeadPattern(title: "b", material: .hama, width: 58, height: 30,
                               cells: Array(repeating: 0, count: 58 * 30), colors: [PatternColor.hama[0]])
        XCTAssertEqual(bead.boards?.across, 2)
        XCTAssertEqual(bead.boards?.down, 2)
        XCTAssertEqual(bead.finishedSizeCM.w, 29, accuracy: 0.01)

        let stitch = BeadPattern(title: "s", material: .dmc, fabricCount: 14, width: 140, height: 70,
                                 cells: Array(repeating: 0, count: 140 * 70), colors: [PatternColor.dmc[0]])
        XCTAssertNil(stitch.boards)
        XCTAssertEqual(stitch.finishedSizeCM.w, 25.4, accuracy: 0.01)
    }

    func testPDFHasCoverPlusOnePagePerBoard() throws {
        let p = BeadPattern(title: "pdf", material: .perler, width: 58, height: 58,
                            cells: Array(repeating: 0, count: 58 * 58), colors: [PatternColor.perler[0]])
        let data = PatternRenderer.pdfData(for: p)
        let doc = try XCTUnwrap(CGPDFDocument(CGDataProvider(data: data as CFData)!))
        XCTAssertEqual(doc.numberOfPages, 1 + 4)
    }

    func testSymbolsAreUniquePerColor() {
        let colors = Array(PatternColor.dmc.prefix(50))
        let p = BeadPattern(title: "s", material: .dmc, width: 50, height: 1, cells: Array(0..<50), colors: colors)
        XCTAssertEqual(Set(p.symbols.values).count, 50)
    }

    func testAnalyticsNameCarriesParameters() {
        XCTAssertEqual(HantamAnalytics.flatName(.purchaseCompleted(productID: "com.pixelme.pro.lifetime")),
                       "purchase_completed.com.pixelme.pro.lifetime")
        XCTAssertEqual(HantamAnalytics.flatName(.custom(name: "pattern_created.perler", parameters: [:])),
                       "pattern_created.perler")
    }

    func testPatternRoundTripsThroughJSON() throws {
        let p = BeadPattern(title: "j", material: .artkalS, width: 2, height: 1, cells: [0, -1], colors: [PatternColor.artkalS[3]])
        let back = try JSONDecoder().decode(BeadPattern.self, from: JSONEncoder().encode(p))
        XCTAssertEqual(back, p)
    }
}
