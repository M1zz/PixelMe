//
//  PixelatedImage.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/01.
//

import SwiftUI

/// Shows the pixelated image selected by the user
struct PixelatedImage: View {
    
    @EnvironmentObject var manager: DataManager
    @State var exportMode: Bool = false
    @State var exportImage: UIImage?
    
    // MARK: - Main rendering function
    var body: some View {
        let size = exportMode ? AppConfig.exportSize : min(UIScreen.main.bounds.width - 40, 350)
        return ZStack {
            if let image = manager.pixelatedImage {
                // Display image as square to match grid
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .cornerRadius(12)
                    .contentShape(Rectangle())
                    .overlay(
                        PixelGridOverlay(size: size)
                            .environmentObject(manager)
                    )
                    .overlay(WatermarkLogoView)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: size)
    }
    
    private var WatermarkLogoView: some View {
        ZStack {
            if manager.useCustomWatermark {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        if let watermarkImage = manager.getWatermarkImage() {
                            Image(uiImage: watermarkImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .shadow(color: Color.black.opacity(0.3), radius: 10)
                        }
                    }
                }.padding()
            }
        }
    }
}

// Checkered background to show transparency
private struct TransparencyBackground: View {
    var body: some View {
        GeometryReader { geometry in
            let size: CGFloat = 20
            let rows = Int(geometry.size.height / size) + 1
            let cols = Int(geometry.size.width / size) + 1

            VStack(spacing: 0) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<cols, id: \.self) { col in
                            Rectangle()
                                .fill((row + col) % 2 == 0 ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                                .frame(width: size, height: size)
                        }
                    }
                }
            }
        }
    }
}

// Pixel grid overlay to show pixel density
private struct PixelGridOverlay: View {
    @EnvironmentObject var manager: DataManager
    let size: CGFloat

    var body: some View {
        GeometryReader { geometry in
            if let boardSize = manager.pixelBoardSize {
                let gridCount = boardSize.count
                let cellSize = geometry.size.width / CGFloat(gridCount)

                Canvas { context, canvasSize in
                    // Draw vertical lines
                    for i in 0...gridCount {
                        let x = CGFloat(i) * cellSize
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: canvasSize.height))
                        context.stroke(path, with: .color(.white.opacity(0.3)), lineWidth: 1)
                    }

                    // Draw horizontal lines
                    for i in 0...gridCount {
                        let y = CGFloat(i) * cellSize
                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: canvasSize.width, y: y))
                        context.stroke(path, with: .color(.white.opacity(0.3)), lineWidth: 1)
                    }
                }
            }
        }
    }
}

// MARK: - Preview UI
struct PixelatedImage_Previews: PreviewProvider {
    static var previews: some View {
        PixelatedImage().environmentObject(DataManager())
    }
}
