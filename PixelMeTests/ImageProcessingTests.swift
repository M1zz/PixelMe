//
//  ImageProcessingTests.swift
//  PixelMeTests
//
//  Unit tests for core image processing logic (Task 5)
//

import XCTest
@testable import PixelMe

final class ImageProcessingTests: XCTestCase {

    // MARK: - Helper: Create a test image

    private func createTestImage(width: Int = 100, height: Int = 100, color: UIColor = .red) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        }
    }

    private func createGradientTestImage(width: Int = 100, height: Int = 100) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        return renderer.image { context in
            for y in 0..<height {
                let brightness = CGFloat(y) / CGFloat(height)
                UIColor(red: brightness, green: 0, blue: 1.0 - brightness, alpha: 1.0).setFill()
                context.fill(CGRect(x: 0, y: y, width: width, height: 1))
            }
        }
    }

    // MARK: - Test 1: Color Reduction with valid image

    func testColorReductionWithValidImage() {
        let image = createGradientTestImage()
        let result = ColorReductionEngine.applyColorReduction(to: image, colorCount: 8)

        XCTAssertNotNil(result, "Color reduction should return a non-nil image")
        XCTAssertEqual(result!.size.width, image.size.width, "Output width should match input")
        XCTAssertEqual(result!.size.height, image.size.height, "Output height should match input")
    }

    // MARK: - Test 2: Color Reduction with custom palette

    func testColorReductionWithCustomPalette() {
        let image = createTestImage(color: .blue)
        let palette: [UIColor] = [.red, .green, .blue, .white]
        let result = ColorReductionEngine.applyColorReduction(to: image, colorCount: 0, palette: palette)

        XCTAssertNotNil(result, "Color reduction with palette should return a non-nil image")
    }

    // MARK: - Test 3: Floyd-Steinberg Dithering

    func testFloydSteinbergDithering() {
        let image = createGradientTestImage()
        let palette: [UIColor] = [.black, .white]
        let result = ColorReductionEngine.applyDithering(to: image, type: .floydSteinberg, palette: palette)

        XCTAssertNotNil(result, "Floyd-Steinberg dithering should return a non-nil image")
        XCTAssertEqual(result!.size, image.size, "Output size should match input size")
    }

    // MARK: - Test 4: Atkinson Dithering

    func testAtkinsonDithering() {
        let image = createGradientTestImage()
        let palette: [UIColor] = [.black, .white, .red]
        let result = ColorReductionEngine.applyDithering(to: image, type: .atkinson, palette: palette)

        XCTAssertNotNil(result, "Atkinson dithering should return a non-nil image")
    }

    // MARK: - Test 5: Ordered (Bayer) Dithering

    func testOrderedDithering() {
        let image = createGradientTestImage()
        let palette: [UIColor] = [.black, .white]
        let result = ColorReductionEngine.applyDithering(to: image, type: .ordered, palette: palette)

        XCTAssertNotNil(result, "Ordered dithering should return a non-nil image")
    }

    // MARK: - Test 6: No Dithering passthrough

    func testNoDitheringPassthrough() {
        let image = createTestImage(color: .green)
        let palette: [UIColor] = [.green, .blue]
        let result = ColorReductionEngine.applyDithering(to: image, type: .none, palette: palette)

        XCTAssertNotNil(result, "No dithering should still return a valid image")
    }

    // MARK: - Test 7: Filter Effects - CRT

    func testCRTFilterEffect() {
        let image = createTestImage()
        let result = FilterEffectsEngine.applyFilter(to: image, type: .crt, intensity: 0.5)

        XCTAssertNotNil(result, "CRT filter should return a non-nil image")
    }

    // MARK: - Test 8: Filter Effects - None returns original

    func testNoFilterReturnsOriginal() {
        let image = createTestImage()
        let result = FilterEffectsEngine.applyFilter(to: image, type: .none, intensity: 1.0)

        XCTAssertNotNil(result, "No filter should return the original image")
        XCTAssertEqual(result!.size, image.size, "Size should match")
    }

    // MARK: - Test 9: Filter Effects - Scanlines

    func testScanlinesFilterEffect() {
        let image = createTestImage()
        let result = FilterEffectsEngine.applyFilter(to: image, type: .scanlines, intensity: 0.8)

        XCTAssertNotNil(result, "Scanlines filter should return a non-nil image")
    }

    // MARK: - Test 10: Color closest match

    func testClosestColorMatch() {
        let palette: [UIColor] = [
            UIColor.red,
            UIColor.green,
            UIColor.blue
        ]

        // A color close to red should match red
        let nearRed = UIColor(red: 0.9, green: 0.1, blue: 0.1, alpha: 1.0)
        let closest = nearRed.closestColor(in: palette)

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        closest.getRed(&r, green: &g, blue: &b, alpha: &a)

        // Should be closest to pure red
        XCTAssertGreaterThan(r, 0.5, "Closest color should have high red component")
        XCTAssertLessThan(g, 0.5, "Closest color should have low green component")
    }

    // MARK: - Test 11: Small image edge case

    func testSmallImageProcessing() {
        let tinyImage = createTestImage(width: 1, height: 1, color: .yellow)
        let result = ColorReductionEngine.applyColorReduction(to: tinyImage, colorCount: 2)

        XCTAssertNotNil(result, "Processing a 1x1 image should not crash")
    }

    // MARK: - Test 12: Glitch filter

    func testGlitchFilterEffect() {
        let image = createTestImage(width: 50, height: 50)
        let result = FilterEffectsEngine.applyFilter(to: image, type: .glitch, intensity: 0.5)

        XCTAssertNotNil(result, "Glitch filter should return a non-nil image")
    }
}
