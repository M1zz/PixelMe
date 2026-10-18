//
//  PixelAnimatedIcon.swift
//  PixelMe
//
//  Created by hyunho lee on 2026/03/02.
//

import SwiftUI

/// 픽셀 아트 애니메이션 아이콘 — Canvas API로 효율적으로 렌더링
struct PixelAnimatedIcon: View {
    let icon: PixelIconDefinition
    let size: CGFloat
    var animating: Bool = true

    @State private var currentFrame: Int = 0
    @State private var timer: Timer?

    var body: some View {
        Canvas { context, canvasSize in
            let frame = icon.frames[currentFrame]
            let cellSize = canvasSize.width / CGFloat(icon.gridSize)

            for (key, color) in frame.pixels {
                let parts = key.split(separator: "_")
                guard parts.count == 2,
                      let x = Int(parts[0]),
                      let y = Int(parts[1]) else { continue }

                let rect = CGRect(
                    x: CGFloat(x) * cellSize,
                    y: CGFloat(y) * cellSize,
                    width: cellSize,
                    height: cellSize
                )
                context.fill(Path(rect), with: .color(color.swiftUIColor))
            }
        }
        .frame(width: size, height: size)
        .onAppear { startAnimation() }
        .onDisappear { stopAnimation() }
        .onChange(of: animating) { _, newValue in
            if newValue { startAnimation() } else { stopAnimation() }
        }
    }

    private func startAnimation() {
        guard animating, icon.frames.count > 1, timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / icon.fps, repeats: true) { _ in
            currentFrame = (currentFrame + 1) % icon.frames.count
        }
    }

    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
        currentFrame = 0
    }
}
