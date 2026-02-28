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
                
                // 레이어 렌더링
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
            .offset(viewModel.offset)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
            .gesture(drawGesture(in: geo.size, canvasSize: CGSize(width: canvasPixelW, height: canvasPixelH)))
            .simultaneousGesture(zoomGesture())
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .clipped()
    }
    
    // MARK: - Gestures
    
    private func drawGesture(in viewSize: CGSize, canvasSize: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if let point = hitTest(value.location, viewSize: viewSize, canvasSize: canvasSize) {
                    if value.translation == .zero {
                        viewModel.beginStroke(at: point)
                    } else {
                        viewModel.continueStroke(at: point)
                    }
                }
            }
            .onEnded { value in
                if let point = hitTest(value.location, viewSize: viewSize, canvasSize: canvasSize) {
                    viewModel.endStroke(at: point)
                }
            }
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                viewModel.scale = max(0.5, min(value, 10))
            }
    }
    
    /// 화면 좌표 → 캔버스 픽셀 좌표
    private func hitTest(_ location: CGPoint, viewSize: CGSize, canvasSize: CGSize) -> PixelPoint? {
        let originX = (viewSize.width - canvasSize.width) / 2 + viewModel.offset.width
        let originY = (viewSize.height - canvasSize.height) / 2 + viewModel.offset.height
        
        let canvasX = Int((location.x - originX) / pixelSize)
        let canvasY = Int((location.y - originY) / pixelSize)
        
        let point = PixelPoint(x: canvasX, y: canvasY)
        guard viewModel.activeCanvas.isValid(point) else { return nil }
        return point
    }
}

// MARK: - Sub Views

/// 단일 레이어 렌더
struct PixelLayerView: View {
    let canvas: PixelCanvas
    let pixelSize: CGFloat
    let opacity: Double
    
    var body: some View {
        Canvas { context, size in
            for y in 0..<canvas.height {
                for x in 0..<canvas.width {
                    let point = PixelPoint(x: x, y: y)
                    guard let color = canvas.pixel(at: point), !color.isTransparent else { continue }
                    let rect = CGRect(
                        x: CGFloat(x) * pixelSize,
                        y: CGFloat(y) * pixelSize,
                        width: pixelSize,
                        height: pixelSize
                    )
                    context.fill(Path(rect), with: .color(color.swiftUIColor))
                }
            }
        }
        .opacity(opacity)
        .allowsHitTesting(false)
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
