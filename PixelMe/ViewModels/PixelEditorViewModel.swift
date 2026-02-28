//
//  PixelEditorViewModel.swift
//  PixelMe
//
//  Created by hyunho lee on 2026/03/01.
//

import SwiftUI
import Combine

// MARK: - Undo/Redo Command
protocol CanvasCommand {
    func execute(on canvas: inout PixelCanvas)
    func undo(on canvas: inout PixelCanvas)
}

/// 픽셀 변경 커맨드 (여러 픽셀 동시에)
struct PixelChangeCommand: CanvasCommand {
    let changes: [(point: PixelPoint, oldColor: PixelColor, newColor: PixelColor)]
    
    func execute(on canvas: inout PixelCanvas) {
        for change in changes {
            canvas.setPixel(at: change.point, color: change.newColor)
        }
    }
    
    func undo(on canvas: inout PixelCanvas) {
        for change in changes {
            canvas.setPixel(at: change.point, color: change.oldColor)
        }
    }
}

// MARK: - ViewModel

final class PixelEditorViewModel: ObservableObject {
    // MARK: Canvas
    @Published var layers: [PixelLayer]
    @Published var activeLayerIndex: Int = 0
    let canvasWidth: Int
    let canvasHeight: Int
    
    // MARK: Tools
    @Published var selectedTool: DrawingToolType = .pencil
    @Published var selectedColor: PixelColor = .black
    @Published var mirrorMode: MirrorMode = .none
    @Published var brushSize: Int = 1
    
    // MARK: Viewport
    @Published var scale: CGFloat = 1.0
    @Published var offset: CGSize = .zero
    @Published var showGrid: Bool = true
    
    // MARK: Undo/Redo
    private var undoStack: [CanvasCommand] = []
    private var redoStack: [CanvasCommand] = []
    private let maxHistory = 30
    @Published var canUndo: Bool = false
    @Published var canRedo: Bool = false
    
    // MARK: Stroke 진행 중 수집
    private var currentStrokeChanges: [(point: PixelPoint, oldColor: PixelColor, newColor: PixelColor)] = []
    private var strokeVisited: Set<PixelPoint> = []
    
    // MARK: Shape preview
    @Published var shapePreviewPixels: [PixelPoint] = []
    private var shapeStartPoint: PixelPoint?
    
    var activeCanvas: PixelCanvas {
        get { layers[activeLayerIndex].canvas }
        set { layers[activeLayerIndex].canvas = newValue }
    }
    
    // MARK: Init
    
    init(preset: CanvasPreset = .small) {
        let (w, h) = preset.size
        self.canvasWidth = w
        self.canvasHeight = h
        self.layers = [PixelLayer(name: "레이어 1", width: w, height: h)]
    }
    
    init(width: Int, height: Int) {
        self.canvasWidth = width
        self.canvasHeight = height
        self.layers = [PixelLayer(name: "레이어 1", width: width, height: height)]
    }
    
    // MARK: - Drawing
    
    /// 터치 시작
    func beginStroke(at point: PixelPoint) {
        currentStrokeChanges = []
        strokeVisited = []
        
        switch selectedTool {
        case .pencil, .eraser, .dither:
            applyBrush(at: point)
        case .fill:
            floodFill(at: point)
        case .eyedropper:
            pickColor(at: point)
        case .line, .rectangle, .circle:
            shapeStartPoint = point
            shapePreviewPixels = [point]
        case .select:
            break // TODO: Sprint 3 후반
        }
    }
    
    /// 터치 이동
    func continueStroke(at point: PixelPoint) {
        switch selectedTool {
        case .pencil, .eraser, .dither:
            applyBrush(at: point)
        case .line:
            if let start = shapeStartPoint {
                shapePreviewPixels = bresenhamLine(from: start, to: point)
            }
        case .rectangle:
            if let start = shapeStartPoint {
                shapePreviewPixels = rectanglePoints(from: start, to: point)
            }
        case .circle:
            if let start = shapeStartPoint {
                shapePreviewPixels = circlePoints(center: start, to: point)
            }
        default:
            break
        }
    }
    
    /// 터치 끝
    func endStroke(at point: PixelPoint) {
        switch selectedTool {
        case .line, .rectangle, .circle:
            // shape preview → 실제 적용
            for p in shapePreviewPixels {
                applyPixel(at: p)
            }
            shapePreviewPixels = []
            shapeStartPoint = nil
        default:
            break
        }
        
        commitStroke()
    }
    
    // MARK: - Brush Application
    
    private func applyBrush(at center: PixelPoint) {
        let color: PixelColor = selectedTool == .eraser ? .clear : selectedColor
        let points = mirrorMode.mirroredPoints(from: center, canvasWidth: canvasWidth, canvasHeight: canvasHeight)
        
        for basePoint in points {
            if brushSize <= 1 {
                applyPixel(at: basePoint, color: color)
            } else {
                let half = brushSize / 2
                for dy in -half..<(brushSize - half) {
                    for dx in -half..<(brushSize - half) {
                        let p = PixelPoint(x: basePoint.x + dx, y: basePoint.y + dy)
                        applyPixel(at: p, color: color)
                    }
                }
            }
        }
    }
    
    private func applyPixel(at point: PixelPoint, color: PixelColor? = nil) {
        guard activeCanvas.isValid(point), !strokeVisited.contains(point) else { return }
        strokeVisited.insert(point)
        
        let drawColor: PixelColor
        if let c = color {
            drawColor = c
        } else if selectedTool == .dither {
            // 체커보드 디더링
            drawColor = (point.x + point.y) % 2 == 0 ? selectedColor : .clear
        } else {
            drawColor = selectedTool == .eraser ? .clear : selectedColor
        }
        
        let oldColor = activeCanvas.pixel(at: point) ?? .clear
        guard oldColor != drawColor else { return }
        
        currentStrokeChanges.append((point: point, oldColor: oldColor, newColor: drawColor))
        activeCanvas.setPixel(at: point, color: drawColor)
    }
    
    // MARK: - Flood Fill
    
    private func floodFill(at start: PixelPoint) {
        guard let targetColor = activeCanvas.pixel(at: start) else { return }
        guard targetColor != selectedColor else { return }
        
        var stack = [start]
        var visited = Set<PixelPoint>()
        
        while let point = stack.popLast() {
            guard activeCanvas.isValid(point),
                  !visited.contains(point),
                  activeCanvas.pixel(at: point) == targetColor else { continue }
            
            visited.insert(point)
            let oldColor = activeCanvas.pixel(at: point) ?? .clear
            currentStrokeChanges.append((point: point, oldColor: oldColor, newColor: selectedColor))
            activeCanvas.setPixel(at: point, color: selectedColor)
            
            stack.append(PixelPoint(x: point.x - 1, y: point.y))
            stack.append(PixelPoint(x: point.x + 1, y: point.y))
            stack.append(PixelPoint(x: point.x, y: point.y - 1))
            stack.append(PixelPoint(x: point.x, y: point.y + 1))
        }
    }
    
    // MARK: - Eyedropper
    
    private func pickColor(at point: PixelPoint) {
        if let color = activeCanvas.pixel(at: point), !color.isTransparent {
            selectedColor = color
        }
    }
    
    // MARK: - Shape Algorithms
    
    /// Bresenham 직선
    func bresenhamLine(from p0: PixelPoint, to p1: PixelPoint) -> [PixelPoint] {
        var points: [PixelPoint] = []
        var x0 = p0.x, y0 = p0.y
        let x1 = p1.x, y1 = p1.y
        let dx = abs(x1 - x0), dy = -abs(y1 - y0)
        let sx = x0 < x1 ? 1 : -1
        let sy = y0 < y1 ? 1 : -1
        var err = dx + dy
        
        while true {
            points.append(PixelPoint(x: x0, y: y0))
            if x0 == x1 && y0 == y1 { break }
            let e2 = 2 * err
            if e2 >= dy { err += dy; x0 += sx }
            if e2 <= dx { err += dx; y0 += sy }
        }
        return points
    }
    
    /// 사각형 외곽선
    func rectanglePoints(from p0: PixelPoint, to p1: PixelPoint) -> [PixelPoint] {
        let minX = min(p0.x, p1.x), maxX = max(p0.x, p1.x)
        let minY = min(p0.y, p1.y), maxY = max(p0.y, p1.y)
        var points: [PixelPoint] = []
        for x in minX...maxX {
            points.append(PixelPoint(x: x, y: minY))
            points.append(PixelPoint(x: x, y: maxY))
        }
        for y in (minY + 1)..<maxY {
            points.append(PixelPoint(x: minX, y: y))
            points.append(PixelPoint(x: maxX, y: y))
        }
        return points
    }
    
    /// Midpoint 원 알고리즘
    func circlePoints(center: PixelPoint, to edge: PixelPoint) -> [PixelPoint] {
        let dx = Double(edge.x - center.x)
        let dy = Double(edge.y - center.y)
        let radius = Int(sqrt(dx * dx + dy * dy))
        guard radius > 0 else { return [center] }
        
        var points = Set<PixelPoint>()
        var x = radius, y = 0, err = 1 - radius
        
        while x >= y {
            let symmetricPoints = [
                PixelPoint(x: center.x + x, y: center.y + y),
                PixelPoint(x: center.x - x, y: center.y + y),
                PixelPoint(x: center.x + x, y: center.y - y),
                PixelPoint(x: center.x - x, y: center.y - y),
                PixelPoint(x: center.x + y, y: center.y + x),
                PixelPoint(x: center.x - y, y: center.y + x),
                PixelPoint(x: center.x + y, y: center.y - x),
                PixelPoint(x: center.x - y, y: center.y - x),
            ]
            for p in symmetricPoints { points.insert(p) }
            y += 1
            if err < 0 {
                err += 2 * y + 1
            } else {
                x -= 1
                err += 2 * (y - x) + 1
            }
        }
        return Array(points)
    }
    
    // MARK: - Undo / Redo
    
    private func commitStroke() {
        guard !currentStrokeChanges.isEmpty else { return }
        let command = PixelChangeCommand(changes: currentStrokeChanges)
        undoStack.append(command)
        if undoStack.count > maxHistory { undoStack.removeFirst() }
        redoStack.removeAll()
        currentStrokeChanges = []
        strokeVisited = []
        updateUndoRedoState()
    }
    
    func undo() {
        guard let command = undoStack.popLast() else { return }
        command.undo(on: &layers[activeLayerIndex].canvas)
        redoStack.append(command)
        updateUndoRedoState()
    }
    
    func redo() {
        guard let command = redoStack.popLast() else { return }
        command.execute(on: &layers[activeLayerIndex].canvas)
        undoStack.append(command)
        updateUndoRedoState()
    }
    
    private func updateUndoRedoState() {
        canUndo = !undoStack.isEmpty
        canRedo = !redoStack.isEmpty
    }
    
    // MARK: - Layer Management
    
    func addLayer() {
        let newLayer = PixelLayer(name: "레이어 \(layers.count + 1)", width: canvasWidth, height: canvasHeight)
        layers.append(newLayer)
        activeLayerIndex = layers.count - 1
    }
    
    func removeLayer(at index: Int) {
        guard layers.count > 1 else { return }
        layers.remove(at: index)
        if activeLayerIndex >= layers.count {
            activeLayerIndex = layers.count - 1
        }
    }
    
    func moveLayer(from source: IndexSet, to destination: Int) {
        layers.move(fromOffsets: source, toOffset: destination)
    }
    
    // MARK: - Render
    
    /// 모든 레이어 합성 → UIImage
    func renderToImage(scale: Int = 1) -> UIImage? {
        let w = canvasWidth * scale
        let h = canvasHeight * scale
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: w, height: h), false, 1.0)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        
        // 투명 배경
        ctx.clear(CGRect(x: 0, y: 0, width: w, height: h))
        
        for layer in layers where layer.isVisible {
            ctx.setAlpha(layer.opacity)
            for y in 0..<canvasHeight {
                for x in 0..<canvasWidth {
                    let point = PixelPoint(x: x, y: y)
                    guard let color = layer.canvas.pixel(at: point), !color.isTransparent else { continue }
                    ctx.setFillColor(color.uiColor.cgColor)
                    ctx.fill(CGRect(x: x * scale, y: y * scale, width: scale, height: scale))
                }
            }
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: - Color Palette
    
    /// 기본 팔레트
    static let defaultPalette: [PixelColor] = [
        .black,
        .white,
        PixelColor(r: 255, g: 0, b: 0),
        PixelColor(r: 0, g: 255, b: 0),
        PixelColor(r: 0, g: 0, b: 255),
        PixelColor(r: 255, g: 255, b: 0),
        PixelColor(r: 255, g: 0, b: 255),
        PixelColor(r: 0, g: 255, b: 255),
        PixelColor(r: 255, g: 128, b: 0),
        PixelColor(r: 128, g: 0, b: 255),
        PixelColor(r: 128, g: 128, b: 128),
        PixelColor(r: 64, g: 64, b: 64),
        PixelColor(r: 192, g: 192, b: 192),
        PixelColor(r: 128, g: 64, b: 0),
        PixelColor(r: 255, g: 192, b: 203),
        PixelColor(r: 0, g: 128, b: 128),
    ]
}
