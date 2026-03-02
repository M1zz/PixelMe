//
//  PixelCanvasView.swift
//  PixelMe
//
//  Created by hyunho lee on 2026/03/01.
//

import SwiftUI

/// 메인 픽셀 캔버스 뷰 — 줌/팬 + 터치 드로잉
struct PixelCanvasView: View {
    @ObservedObject var viewModel: PixelEditorViewModel

    /// 캔버스 1픽셀의 화면 크기
    private var pixelSize: CGFloat {
        max(4, 12 * viewModel.scale)
    }

    var body: some View {
        GeometryReader { geo in
            let canvasPixelW = CGFloat(viewModel.canvasWidth) * pixelSize
            let canvasPixelH = CGFloat(viewModel.canvasHeight) * pixelSize

            ZStack {
                // 투명 배경 체커보드
                CheckerboardBackground(
                    width: viewModel.canvasWidth,
                    height: viewModel.canvasHeight,
                    pixelSize: pixelSize
                )

                // Follow Along 참고 샘플 오버레이
                if let sample = viewModel.referenceSample, viewModel.showReferenceSample {
                    SampleArtPreview(sample: sample)
                        .frame(
                            width: CGFloat(viewModel.canvasWidth) * pixelSize,
                            height: CGFloat(viewModel.canvasHeight) * pixelSize
                        )
                        .opacity(0.25)
                        .allowsHitTesting(false)
                }

                // 어니언 스킨: 이전 프레임 (빨간 틴트)
                if viewModel.showOnionSkin && viewModel.frames.count > 1 {
                    if let prevLayers = viewModel.previousFrameLayers {
                        OnionSkinOverlay(
                            layers: prevLayers,
                            pixelSize: pixelSize,
                            tintColor: Color(red: 1.0, green: 0.3, blue: 0.3)
                        )
                    }
                    if let nextLayers = viewModel.nextFrameLayers {
                        OnionSkinOverlay(
                            layers: nextLayers,
                            pixelSize: pixelSize,
                            tintColor: Color(red: 0.3, green: 0.5, blue: 1.0)
                        )
                    }
                }

                // 레이어 렌더링 — UIImage 기반 (Canvas 캐시 문제 회피)
                ForEach(viewModel.layers) { layer in
                    if layer.isVisible {
                        PixelLayerView(
                            canvas: layer.canvas,
                            pixelSize: pixelSize,
                            opacity: layer.opacity
                        )
                    }
                }

                // Shape preview
                ForEach(viewModel.shapePreviewPixels, id: \.self) { point in
                    Rectangle()
                        .fill(viewModel.selectedColor.swiftUIColor.opacity(0.5))
                        .frame(width: pixelSize, height: pixelSize)
                        .position(
                            x: CGFloat(point.x) * pixelSize + pixelSize / 2,
                            y: CGFloat(point.y) * pixelSize + pixelSize / 2
                        )
                }

                // 그리드
                if viewModel.showGrid && pixelSize >= 6 {
                    GridOverlay(
                        width: viewModel.canvasWidth,
                        height: viewModel.canvasHeight,
                        pixelSize: pixelSize
                    )
                }
            }
            .frame(width: canvasPixelW, height: canvasPixelH)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let x = Int(value.location.x / pixelSize)
                        let y = Int(value.location.y / pixelSize)
                        let point = PixelPoint(x: x, y: y)
                        guard viewModel.activeCanvas.isValid(point) else { return }
                        if value.translation == .zero {
                            viewModel.beginStroke(at: point)
                        } else {
                            viewModel.continueStroke(at: point)
                        }
                    }
                    .onEnded { value in
                        let x = Int(value.location.x / pixelSize)
                        let y = Int(value.location.y / pixelSize)
                        let point = PixelPoint(x: x, y: y)
                        guard viewModel.activeCanvas.isValid(point) else { return }
                        viewModel.endStroke(at: point)
                    }
            )
            .offset(viewModel.offset)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
            .simultaneousGesture(
                MagnificationGesture()
                    .onChanged { value in
                        viewModel.scale = max(0.5, min(value, 10))
                    }
            )
        }
        .background(Color(AppConfig.backgroundColor))
        .clipped()
    }
}

// MARK: - Sub Views

/// 단일 레이어 렌더 — UIImage 기반 (SwiftUI Canvas 캐시 문제 회피)
struct PixelLayerView: View {
    let canvas: PixelCanvas
    let pixelSize: CGFloat
    let opacity: Double

    var body: some View {
        if let image = renderLayer() {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .frame(
                    width: CGFloat(canvas.width) * pixelSize,
                    height: CGFloat(canvas.height) * pixelSize
                )
                .opacity(opacity)
                .allowsHitTesting(false)
        }
    }

    /// 캔버스 → UIImage (1px = 1px, 나중에 resizable로 확대)
    private func renderLayer() -> UIImage? {
        let w = canvas.width
        let h = canvas.height
        guard w > 0 && h > 0 else { return nil }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: w, height: h), false, 1)
        defer { UIGraphicsEndImageContext() }
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        ctx.clear(CGRect(x: 0, y: 0, width: w, height: h))

        for y in 0..<h {
            for x in 0..<w {
                let point = PixelPoint(x: x, y: y)
                guard let color = canvas.pixel(at: point), !color.isTransparent else { continue }
                ctx.setFillColor(color.uiColor.cgColor)
                ctx.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

/// 투명 배경 체커보드
struct CheckerboardBackground: View {
    let width: Int
    let height: Int
    let pixelSize: CGFloat

    var body: some View {
        Canvas { context, size in
            let lightGray = Color(white: 0.9)
            let white = Color.white
            let checkSize = pixelSize / 2

            for y in 0..<(height * 2) {
                for x in 0..<(width * 2) {
                    let color = (x + y) % 2 == 0 ? white : lightGray
                    let rect = CGRect(
                        x: CGFloat(x) * checkSize,
                        y: CGFloat(y) * checkSize,
                        width: checkSize,
                        height: checkSize
                    )
                    context.fill(Path(rect), with: .color(color))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

/// 어니언 스킨 오버레이 — 인접 프레임을 반투명 틴트로 렌더링
struct OnionSkinOverlay: View {
    let layers: [PixelLayer]
    let pixelSize: CGFloat
    let tintColor: Color

    var body: some View {
        ForEach(layers) { layer in
            if layer.isVisible {
                PixelLayerView(
                    canvas: layer.canvas,
                    pixelSize: pixelSize,
                    opacity: layer.opacity
                )
            }
        }
        .opacity(0.3)
        .colorMultiply(tintColor)
        .allowsHitTesting(false)
    }
}

/// 그리드 오버레이
struct GridOverlay: View {
    let width: Int
    let height: Int
    let pixelSize: CGFloat

    var body: some View {
        Canvas { context, size in
            let gridColor = Color.gray.opacity(0.3)

            for x in 0...width {
                let xPos = CGFloat(x) * pixelSize
                var path = Path()
                path.move(to: CGPoint(x: xPos, y: 0))
                path.addLine(to: CGPoint(x: xPos, y: CGFloat(height) * pixelSize))
                context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
            }
            for y in 0...height {
                let yPos = CGFloat(y) * pixelSize
                var path = Path()
                path.move(to: CGPoint(x: 0, y: yPos))
                path.addLine(to: CGPoint(x: CGFloat(width) * pixelSize, y: yPos))
                context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
            }
        }
        .allowsHitTesting(false)
    }
}
