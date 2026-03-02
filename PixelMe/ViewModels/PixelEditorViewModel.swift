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

    // MARK: Palette
    @Published var selectedPalette: BuiltInPalette? = nil

    /// 현재 활성 팔레트 색상 (Lospec 선택 시 해당 팔레트, 아니면 기본 팔레트)
    var activePaletteColors: [PixelColor] {
        if let palette = selectedPalette {
            return palette.colors
        }
        return Self.defaultPalette
    }
    
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

    // MARK: Selection
    @Published var selection: PixelSelection?
    @Published var selectionStart: PixelPoint?
    @Published var selectionEnd: PixelPoint?
    @Published var clipboard: PixelSelection?

    // MARK: Reference Sample (Follow Along)
    @Published var referenceSample: SamplePixelArt?
    @Published var showReferenceSample: Bool = true

    // MARK: Animation
    @Published var frames: [AnimationFrame] = []
    @Published var currentFrameIndex: Int = 0
    @Published var fps: Int = 8
    @Published var isPlaying: Bool = false
    @Published var showOnionSkin: Bool = false
    private var playbackTimer: Timer?
    
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

    /// Aseprite 등 외부에서 가져온 AnimationFrame 배열로 초기화
    init(frames importedFrames: [AnimationFrame], width: Int, height: Int) {
        self.canvasWidth = width
        self.canvasHeight = height
        if let firstFrame = importedFrames.first {
            self.layers = firstFrame.layers
        } else {
            self.layers = [PixelLayer(name: "레이어 1", width: width, height: height)]
        }
        self.frames = importedFrames
        if importedFrames.count > 1 {
            self.currentFrameIndex = 0
        }
    }

    /// Follow Along — 참고 샘플과 함께 빈 캔버스 생성
    init(referenceSample sample: SamplePixelArt) {
        let size = sample.boardSize.count
        self.canvasWidth = size
        self.canvasHeight = size
        self.layers = [PixelLayer(name: "레이어 1", width: size, height: size)]
        self.referenceSample = sample
    }

    /// 사진 변환 결과(UIImage)로부터 에디터 초기화
    init(fromImage image: UIImage, targetSize: Int = 32) {
        let size = min(targetSize, 128)
        self.canvasWidth = size
        self.canvasHeight = size

        // 이미지를 targetSize로 nearest-neighbor 리사이즈
        let scaledImage = Self.resizeImageNearest(image, to: CGSize(width: size, height: size))
        var layer = PixelLayer(name: "변환된 이미지", width: size, height: size)

        // 픽셀 데이터 추출
        if let cgImage = scaledImage.cgImage {
            let w = cgImage.width
            let h = cgImage.height
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bytesPerPixel = 4
            let bytesPerRow = bytesPerPixel * w
            var rawData = [UInt8](repeating: 0, count: h * bytesPerRow)

            if let context = CGContext(
                data: &rawData,
                width: w, height: h,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) {
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: w, height: h))

                for y in 0..<min(h, size) {
                    for x in 0..<min(w, size) {
                        let offset = (y * bytesPerRow) + (x * bytesPerPixel)
                        let r = rawData[offset]
                        let g = rawData[offset + 1]
                        let b = rawData[offset + 2]
                        let a = rawData[offset + 3]
                        if a > 0 {
                            layer.canvas.setPixel(at: PixelPoint(x: x, y: y), color: PixelColor(r: r, g: g, b: b, a: a))
                        }
                    }
                }
            }
        }

        self.layers = [layer]
    }

    /// Nearest-neighbor 리사이즈 (픽셀 아트 보존)
    private static func resizeImageNearest(_ image: UIImage, to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            ctx.cgContext.interpolationQuality = .none
            image.draw(in: CGRect(origin: .zero, size: size))
        }
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
            selectionStart = point
            selectionEnd = point
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
        case .select:
            selectionEnd = point
        default:
            break
        }
    }

    /// 터치 끝
    func endStroke(at point: PixelPoint) {
        switch selectedTool {
        case .line, .rectangle, .circle:
            for p in shapePreviewPixels {
                applyPixel(at: p)
            }
            shapePreviewPixels = []
            shapeStartPoint = nil
        case .select:
            selectionEnd = point
            finalizeSelection()
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
    
    // MARK: - Selection Tool

    private func finalizeSelection() {
        guard let start = selectionStart, let end = selectionEnd else { return }
        let minX = min(start.x, end.x)
        let minY = min(start.y, end.y)
        let maxX = max(start.x, end.x)
        let maxY = max(start.y, end.y)
        let w = maxX - minX + 1
        let h = maxY - minY + 1

        var pixels: [PixelColor] = []
        for y in minY...maxY {
            for x in minX...maxX {
                let p = PixelPoint(x: x, y: y)
                pixels.append(activeCanvas.pixel(at: p) ?? .clear)
            }
        }
        selection = PixelSelection(origin: PixelPoint(x: minX, y: minY), size: (w, h), pixels: pixels)
    }

    /// 선택 영역 복사
    func copySelection() {
        clipboard = selection
    }

    /// 선택 영역 잘라내기
    func cutSelection() {
        guard let sel = selection else { return }
        clipboard = sel
        var changes: [(point: PixelPoint, oldColor: PixelColor, newColor: PixelColor)] = []
        for y in 0..<sel.size.height {
            for x in 0..<sel.size.width {
                let p = PixelPoint(x: sel.origin.x + x, y: sel.origin.y + y)
                if let old = activeCanvas.pixel(at: p) {
                    changes.append((point: p, oldColor: old, newColor: .clear))
                    activeCanvas.setPixel(at: p, color: .clear)
                }
            }
        }
        if !changes.isEmpty {
            let cmd = PixelChangeCommand(changes: changes)
            undoStack.append(cmd)
            if undoStack.count > maxHistory { undoStack.removeFirst() }
            redoStack.removeAll()
            updateUndoRedoState()
        }
        selection = nil
    }

    /// 클립보드 붙여넣기
    func pasteClipboard(at target: PixelPoint = PixelPoint(x: 0, y: 0)) {
        guard let clip = clipboard else { return }
        var changes: [(point: PixelPoint, oldColor: PixelColor, newColor: PixelColor)] = []
        for y in 0..<clip.size.height {
            for x in 0..<clip.size.width {
                let p = PixelPoint(x: target.x + x, y: target.y + y)
                guard activeCanvas.isValid(p) else { continue }
                let newColor = clip.pixels[y * clip.size.width + x]
                guard !newColor.isTransparent else { continue }
                let old = activeCanvas.pixel(at: p) ?? .clear
                changes.append((point: p, oldColor: old, newColor: newColor))
                activeCanvas.setPixel(at: p, color: newColor)
            }
        }
        if !changes.isEmpty {
            let cmd = PixelChangeCommand(changes: changes)
            undoStack.append(cmd)
            if undoStack.count > maxHistory { undoStack.removeFirst() }
            redoStack.removeAll()
            updateUndoRedoState()
        }
    }

    func clearSelection() {
        selection = nil
        selectionStart = nil
        selectionEnd = nil
    }

    // MARK: - Canvas Resize

    func resizeCanvas(newWidth: Int, newHeight: Int) {
        for i in 0..<layers.count {
            var newCanvas = PixelCanvas(width: newWidth, height: newHeight)
            for y in 0..<min(layers[i].canvas.height, newHeight) {
                for x in 0..<min(layers[i].canvas.width, newWidth) {
                    if let color = layers[i].canvas.pixel(at: PixelPoint(x: x, y: y)) {
                        newCanvas.setPixel(at: PixelPoint(x: x, y: y), color: color)
                    }
                }
            }
            layers[i].canvas = newCanvas
        }
    }

    // MARK: - Onion Skinning

    /// 이전 프레임의 레이어들 (어니언 스키닝용)
    var previousFrameLayers: [PixelLayer]? {
        guard currentFrameIndex > 0 else { return nil }
        return frames[currentFrameIndex - 1].layers
    }

    /// 다음 프레임의 레이어들 (어니언 스키닝용)
    var nextFrameLayers: [PixelLayer]? {
        guard currentFrameIndex < frames.count - 1 else { return nil }
        return frames[currentFrameIndex + 1].layers
    }

    // MARK: - Animation

    /// 현재 캔버스를 프레임으로 초기화
    func initializeAnimation() {
        if frames.isEmpty {
            frames = [AnimationFrame(layers: layers, durationMs: 1000 / max(1, fps))]
            currentFrameIndex = 0
        }
    }

    func addFrame() {
        let frame = AnimationFrame(width: canvasWidth, height: canvasHeight, durationMs: 1000 / max(1, fps))
        frames.append(frame)
        currentFrameIndex = frames.count - 1
        layers = frames[currentFrameIndex].layers
    }

    func duplicateFrame() {
        guard currentFrameIndex < frames.count else { return }
        let current = frames[currentFrameIndex]
        // deep copy layers
        var copiedLayers: [PixelLayer] = []
        for layer in current.layers {
            var newLayer = PixelLayer(name: layer.name, width: canvasWidth, height: canvasHeight)
            newLayer.canvas = layer.canvas
            newLayer.isVisible = layer.isVisible
            newLayer.opacity = layer.opacity
            copiedLayers.append(newLayer)
        }
        let newFrame = AnimationFrame(layers: copiedLayers, durationMs: current.durationMs)
        frames.insert(newFrame, at: currentFrameIndex + 1)
        currentFrameIndex += 1
        layers = frames[currentFrameIndex].layers
    }

    func deleteFrame() {
        guard frames.count > 1, currentFrameIndex < frames.count else { return }
        frames.remove(at: currentFrameIndex)
        if currentFrameIndex >= frames.count { currentFrameIndex = frames.count - 1 }
        layers = frames[currentFrameIndex].layers
    }

    func switchToFrame(_ index: Int) {
        guard index >= 0, index < frames.count else { return }
        // 현재 프레임 저장
        if currentFrameIndex < frames.count {
            frames[currentFrameIndex] = AnimationFrame(layers: layers, durationMs: frames[currentFrameIndex].durationMs)
        }
        currentFrameIndex = index
        layers = frames[currentFrameIndex].layers
        activeLayerIndex = 0
    }

    func startPlayback() {
        guard !frames.isEmpty else { return }
        isPlaying = true
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / Double(max(1, fps)), repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let next = (self.currentFrameIndex + 1) % self.frames.count
            self.switchToFrame(next)
        }
    }

    func stopPlayback() {
        isPlaying = false
        playbackTimer?.invalidate()
        playbackTimer = nil
    }

    /// 모든 프레임을 UIImage 배열로 렌더링
    func renderAllFrames(scale: Int = 1) -> [UIImage] {
        return frames.compactMap { frame in
            renderFrame(frame, scale: scale)
        }
    }

    private func renderFrame(_ frame: AnimationFrame, scale: Int = 1) -> UIImage? {
        let w = canvasWidth * scale
        let h = canvasHeight * scale
        UIGraphicsBeginImageContextWithOptions(CGSize(width: w, height: h), false, 1.0)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        ctx.clear(CGRect(x: 0, y: 0, width: w, height: h))
        for layer in frame.layers where layer.isVisible {
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

    /// 스프라이트 시트 렌더링
    func renderSpriteSheet(scale: Int = 4, layout: SpriteSheetLayout = .horizontal) -> UIImage? {
        let images = renderAllFrames(scale: scale)
        guard !images.isEmpty else { return nil }
        let frameW = canvasWidth * scale
        let frameH = canvasHeight * scale
        let totalW: Int
        let totalH: Int
        switch layout {
        case .horizontal:
            totalW = frameW * images.count
            totalH = frameH
        case .vertical:
            totalW = frameW
            totalH = frameH * images.count
        case .grid:
            let cols = Int(ceil(sqrt(Double(images.count))))
            let rows = Int(ceil(Double(images.count) / Double(cols)))
            totalW = frameW * cols
            totalH = frameH * rows
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width: totalW, height: totalH), false, 1.0)
        for (i, img) in images.enumerated() {
            let x: Int, y: Int
            switch layout {
            case .horizontal:
                x = i * frameW; y = 0
            case .vertical:
                x = 0; y = i * frameH
            case .grid:
                let cols = Int(ceil(sqrt(Double(images.count))))
                x = (i % cols) * frameW; y = (i / cols) * frameH
            }
            img.draw(in: CGRect(x: x, y: y, width: frameW, height: frameH))
        }
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }

    // MARK: - AI Smart Palette

    /// 이미지 색상 분석 → 최적 팔레트 추천
    static func suggestPalette(from image: UIImage, colorCount: Int = 16) -> [PixelColor] {
        guard let cgImage = image.cgImage else { return [] }
        let w = min(cgImage.width, 64)
        let h = min(cgImage.height, 64)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * w
        var rawData = [UInt8](repeating: 0, count: h * bytesPerRow)
        guard let ctx = CGContext(data: &rawData, width: w, height: h, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return [] }
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: w, height: h))

        // 색상 빈도 집계 (양자화: 4비트)
        var colorFreq: [UInt32: Int] = [:]
        for y in 0..<h {
            for x in 0..<w {
                let offset = (y * bytesPerRow) + (x * bytesPerPixel)
                let r = rawData[offset] >> 4
                let g = rawData[offset+1] >> 4
                let b = rawData[offset+2] >> 4
                let key = UInt32(r) << 8 | UInt32(g) << 4 | UInt32(b)
                colorFreq[key, default: 0] += 1
            }
        }
        // 빈도 높은 색상 선택
        let sorted = colorFreq.sorted { $0.value > $1.value }.prefix(colorCount)
        return sorted.map { (key, _) in
            let r = UInt8((key >> 8) & 0xF) * 17
            let g = UInt8((key >> 4) & 0xF) * 17
            let b = UInt8(key & 0xF) * 17
            return PixelColor(r: r, g: g, b: b)
        }
    }

    // MARK: - Auto Save & Crash Recovery

    private static let autoSaveKey = "PixelEditor.autoSave"
    private var autoSaveTimer: Timer?

    /// 자동 저장 시작 (30초 간격)
    func startAutoSave() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.saveProject()
        }
    }

    func stopAutoSave() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
    }

    /// 프로젝트 저장
    func saveProject() {
        let project = PixelProject(
            canvasWidth: canvasWidth,
            canvasHeight: canvasHeight,
            layers: layers,
            selectedToolRaw: selectedTool.rawValue,
            mirrorModeRaw: mirrorMode.rawValue,
            brushSize: brushSize,
            showGrid: showGrid,
            savedAt: Date()
        )
        if let data = try? JSONEncoder().encode(project) {
            UserDefaults.standard.set(data, forKey: Self.autoSaveKey)
        }
    }

    /// 복구 가능한 프로젝트가 있는지 확인
    static var hasRecoverableProject: Bool {
        UserDefaults.standard.data(forKey: autoSaveKey) != nil
    }

    /// 크래시 복구 — 저장된 프로젝트 로드
    static func recoverProject() -> PixelEditorViewModel? {
        guard let data = UserDefaults.standard.data(forKey: autoSaveKey),
              let project = try? JSONDecoder().decode(PixelProject.self, from: data) else {
            return nil
        }
        let vm = PixelEditorViewModel(width: project.canvasWidth, height: project.canvasHeight)
        vm.layers = project.layers
        vm.selectedTool = DrawingToolType(rawValue: project.selectedToolRaw) ?? .pencil
        vm.mirrorMode = MirrorMode(rawValue: project.mirrorModeRaw) ?? .none
        vm.brushSize = project.brushSize
        vm.showGrid = project.showGrid
        return vm
    }

    /// 자동 저장 데이터 삭제
    static func clearAutoSave() {
        UserDefaults.standard.removeObject(forKey: autoSaveKey)
    }

    // MARK: - Color Palette

    /// AI 팔레트 (동적)
    @Published var aiPalette: [PixelColor] = []

    /// 현재 캔버스에서 AI 팔레트 생성
    func generateAIPalette() {
        guard let image = renderToImage(scale: 1) else { return }
        aiPalette = Self.suggestPalette(from: image, colorCount: 16)
    }

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
