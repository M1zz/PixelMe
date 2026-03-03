//
//  PixelEditorView.swift
//  PixelMe
//
//  Created by hyunho lee on 2026/03/01.
//

import SwiftUI
import UniformTypeIdentifiers
import ImageIO

/// 메인 픽셀 에디터 화면 — 캔버스 + 도구바 + 팔레트 + 레이어
struct PixelEditorView: View {
    @StateObject private var viewModel: PixelEditorViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showLayerPanel = false
    @State private var showExportSheet = false
    @State private var showColorPicker = false
    @State private var showAdvancedColorPicker = false
    @State private var showAnimationTimeline = false
    @State private var showCanvasResize = false
    @State private var showAsepriteImporter = false
    @State private var asepriteImportError: String?
    @State private var showAsepriteImportError = false
    @State private var showDiscardAlert = false

    private let initialShowTimeline: Bool

    init(preset: CanvasPreset = .small, initialShowTimeline: Bool = false) {
        self.initialShowTimeline = initialShowTimeline
        _viewModel = StateObject(wrappedValue: PixelEditorViewModel(preset: preset))
    }

    init(width: Int, height: Int, initialShowTimeline: Bool = false) {
        self.initialShowTimeline = initialShowTimeline
        _viewModel = StateObject(wrappedValue: PixelEditorViewModel(width: width, height: height))
    }

    /// Aseprite 등 외부에서 가져온 프레임으로 편집기 로드
    init(frames: [AnimationFrame], width: Int, height: Int, initialShowTimeline: Bool = false) {
        self.initialShowTimeline = initialShowTimeline
        _viewModel = StateObject(wrappedValue: PixelEditorViewModel(frames: frames, width: width, height: height))
    }

    /// 사진 변환 결과를 편집기에 로드
    init(fromImage image: UIImage, targetSize: Int = 32, initialShowTimeline: Bool = false) {
        self.initialShowTimeline = initialShowTimeline
        _viewModel = StateObject(wrappedValue: PixelEditorViewModel(fromImage: image, targetSize: targetSize))
    }

    /// Follow Along — 참고 샘플과 함께 빈 캔버스
    init(referenceSample: SamplePixelArt) {
        self.initialShowTimeline = false
        _viewModel = StateObject(wrappedValue: PixelEditorViewModel(referenceSample: referenceSample))
    }

    var body: some View {
        VStack(spacing: 0) {
            // 상단 바
            topBar

            // 캔버스 + 줌 컨트롤
            ZStack(alignment: .bottomTrailing) {
                PixelCanvasView(viewModel: viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // 줌 컨트롤 오버레이
                VStack(spacing: 8) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.scale = min(viewModel.scale * 1.5, 10)
                        }
                    } label: {
                        Image(systemName: "plus.magnifyingglass")
                            .font(.system(size: 16))
                            .frame(width: 36, height: 36)
                            .background(Color(AppConfig.toolBackgroundColor))
                            .clipShape(Circle())
                    }

                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.scale = max(viewModel.scale / 1.5, 0.5)
                        }
                    } label: {
                        Image(systemName: "minus.magnifyingglass")
                            .font(.system(size: 16))
                            .frame(width: 36, height: 36)
                            .background(Color(AppConfig.toolBackgroundColor))
                            .clipShape(Circle())
                    }

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.scale = 1.0
                            viewModel.offset = .zero
                        }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 14))
                            .frame(width: 36, height: 36)
                            .background(Color(AppConfig.toolBackgroundColor))
                            .clipShape(Circle())
                    }
                }
                .padding(12)
            }

            // 팔레트
            colorPaletteBar

            // 도구 바
            toolBar
        }
        .background(Color(AppConfig.backgroundColor))
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showLayerPanel) {
            LayerPanelView(viewModel: viewModel)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showExportSheet) {
            ExportSheetView(viewModel: viewModel)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showAdvancedColorPicker) {
            AdvancedColorPickerView(selectedColor: $viewModel.selectedColor)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showAnimationTimeline) {
            AnimationTimelineView(viewModel: viewModel)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showCanvasResize) {
            CanvasResizeView(viewModel: viewModel)
                .presentationDetents([.medium])
        }
        .fileImporter(
            isPresented: $showAsepriteImporter,
            allowedContentTypes: [UTType(filenameExtension: "aseprite") ?? .data, UTType(filenameExtension: "ase") ?? .data],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                guard url.startAccessingSecurityScopedResource() else { return }
                defer { url.stopAccessingSecurityScopedResource() }
                do {
                    let (width, height, frames) = try AsepriteManager.importFile(from: url)
                    let newVM = PixelEditorViewModel(width: width, height: height)
                    newVM.frames = frames
                    if let first = frames.first {
                        newVM.layers = first.layers
                    }
                    // 현재 ViewModel에 데이터 적용
                    viewModel.frames = frames
                    if let first = frames.first {
                        viewModel.layers = first.layers
                    }
                } catch {
                    asepriteImportError = error.localizedDescription
                    showAsepriteImportError = true
                }
            case .failure(let error):
                asepriteImportError = error.localizedDescription
                showAsepriteImportError = true
            }
        }
        .alert("Aseprite 가져오기 실패", isPresented: $showAsepriteImportError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(asepriteImportError ?? "알 수 없는 오류")
        }
        .onAppear {
            viewModel.startAutoSave()
            if initialShowTimeline {
                showAnimationTimeline = true
            }
        }
        .onDisappear {
            viewModel.saveProject()
            viewModel.stopAutoSave()
        }
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack {
            Button {
                if viewModel.canUndo {
                    showDiscardAlert = true
                } else {
                    dismiss()
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
            }
            .alert("작업을 종료할까요?", isPresented: $showDiscardAlert) {
                Button("저장하지 않고 닫기", role: .destructive) { dismiss() }
                Button("계속 편집", role: .cancel) {}
            } message: {
                Text("저장하지 않은 변경사항은 사라집니다.")
            }
            
            Spacer()
            
            Text("\(viewModel.canvasWidth)×\(viewModel.canvasHeight)")
                .font(.caption)
                .foregroundStyle(.secondary)

            if viewModel.referenceSample != nil {
                Button {
                    viewModel.showReferenceSample.toggle()
                } label: {
                    Image(systemName: viewModel.showReferenceSample ? "eye.fill" : "eye.slash.fill")
                        .font(.caption)
                        .foregroundStyle(viewModel.showReferenceSample ? .blue : .secondary)
                }
            }

            Spacer()

            HStack(spacing: 16) {
                Button { viewModel.undo() } label: {
                    Image(systemName: "arrow.uturn.backward")
                }
                .disabled(!viewModel.canUndo)

                Button { viewModel.redo() } label: {
                    Image(systemName: "arrow.uturn.forward")
                }
                .disabled(!viewModel.canRedo)

                Button { showLayerPanel = true } label: {
                    Image(systemName: "square.3.layers.3d")
                }

                Button { showAnimationTimeline = true } label: {
                    Image(systemName: "film")
                }

                Button { showExportSheet = true } label: {
                    Image(systemName: "square.and.arrow.up")
                }

                Menu {
                    Toggle("그리드", isOn: $viewModel.showGrid)

                    Menu("대칭") {
                        ForEach(MirrorMode.allCases, id: \.self) { mode in
                            Button {
                                viewModel.mirrorMode = mode
                            } label: {
                                HStack {
                                    Text(mode.rawValue)
                                    if viewModel.mirrorMode == mode {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }

                    Divider()

                    Button { showAsepriteImporter = true } label: {
                        Label("Aseprite 가져오기", systemImage: "doc.badge.arrow.up")
                    }

                    Button { showCanvasResize = true } label: {
                        Label("캔버스 크기 변경", systemImage: "arrow.up.left.and.arrow.down.right")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(AppConfig.toolBackgroundColor))
    }

    // MARK: - Color Palette
    
    private var colorPaletteBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                // 현재 선택 색상 (탭하면 커스텀 피커)
                ColorPicker("", selection: Binding(
                    get: { viewModel.selectedColor.swiftUIColor },
                    set: { newColor in
                        if let uiColor = UIColor(newColor).cgColor.components, uiColor.count >= 3 {
                            viewModel.selectedColor = PixelColor(uiColor: UIColor(newColor))
                        }
                    }
                ))
                .labelsHidden()
                .frame(width: 32, height: 32)
                
                // 고급 색상 피커 버튼
                Button { showAdvancedColorPicker = true } label: {
                    Image(systemName: "slider.horizontal.3")
                        .frame(width: 28, height: 28)
                        .background(Color.blue.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }

                // AI 팔레트 추천 버튼
                Button { viewModel.generateAIPalette() } label: {
                    Image(systemName: "wand.and.stars")
                        .frame(width: 28, height: 28)
                        .background(Color.purple.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }

                // Lospec 팔레트 전환
                Menu {
                    Button {
                        viewModel.selectedPalette = nil
                    } label: {
                        HStack {
                            Text("Default (16색)")
                            if viewModel.selectedPalette == nil { Image(systemName: "checkmark") }
                        }
                    }
                    Divider()
                    ForEach(BuiltInPalette.allCases) { palette in
                        Button {
                            viewModel.selectedPalette = palette
                        } label: {
                            HStack {
                                Text(palette.rawValue)
                                if viewModel.selectedPalette == palette { Image(systemName: "checkmark") }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "paintpalette")
                        .frame(width: 28, height: 28)
                        .background(Color.green.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }

                Divider().frame(height: 24)

                // AI 추천 팔레트 (있을 경우)
                ForEach(viewModel.aiPalette, id: \.self) { color in
                    Rectangle()
                        .fill(color.swiftUIColor)
                        .frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(viewModel.selectedColor == color ? Color.purple : Color.clear, lineWidth: 2)
                        )
                        .onTapGesture { viewModel.selectedColor = color }
                }

                if !viewModel.aiPalette.isEmpty {
                    Divider().frame(height: 24)
                }

                // Follow Along: 샘플 팔레트 라벨
                if viewModel.referenceSample != nil && viewModel.selectedPalette == nil {
                    Text("Sample")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color(AppConfig.continueButtonColor))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color(AppConfig.continueButtonColor).opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }

                // 활성 팔레트 색상
                ForEach(viewModel.activePaletteColors, id: \.self) { color in
                    Rectangle()
                        .fill(color.swiftUIColor)
                        .frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(viewModel.selectedColor == color ? Color(AppConfig.continueButtonColor) : Color.clear, lineWidth: 2)
                        )
                        .onTapGesture {
                            viewModel.selectedColor = color
                        }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .background(Color(AppConfig.toolBackgroundColor))
    }

    // MARK: - Tool Bar
    
    private var toolBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // 브러시 크기 컨트롤
                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Button { viewModel.brushSize = max(1, viewModel.brushSize - 1) } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 10, weight: .bold))
                        }
                        Text("\(viewModel.brushSize)")
                            .font(.system(size: 14, weight: .bold))
                            .frame(width: 16)
                        Button { viewModel.brushSize = min(8, viewModel.brushSize + 1) } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .bold))
                        }
                    }
                    .frame(width: 56, height: 36)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    Text("Size")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .tint(.primary)

                Divider().frame(height: 40)

                ForEach(DrawingToolType.allCases) { tool in
                    Button {
                        viewModel.selectedTool = tool
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: tool.icon)
                                .font(.title3)
                                .frame(width: 36, height: 36)
                            .background(
                                viewModel.selectedTool == tool
                                ? Color.blue.opacity(0.2)
                                : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                            Text(tool.rawValue)
                                .font(.system(size: 9))
                                .foregroundStyle(viewModel.selectedTool == tool ? .blue : .secondary)
                        }
                    }
                    .tint(viewModel.selectedTool == tool ? .blue : .primary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(Color(AppConfig.toolBackgroundColor))
    }
}

// MARK: - Layer Panel

struct LayerPanelView: View {
    @ObservedObject var viewModel: PixelEditorViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(viewModel.layers.enumerated()), id: \.element.id) { index, layer in
                    VStack(spacing: 8) {
                        HStack {
                            Button {
                                viewModel.layers[index].isVisible.toggle()
                            } label: {
                                Image(systemName: layer.isVisible ? "eye" : "eye.slash")
                                    .foregroundStyle(layer.isVisible ? .primary : .secondary)
                            }
                            .buttonStyle(.plain)

                            Text(layer.name)
                                .fontWeight(viewModel.activeLayerIndex == index ? .bold : .regular)

                            Spacer()

                            if viewModel.activeLayerIndex == index {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.blue)
                            }
                        }

                        // 불투명도 슬라이더
                        HStack(spacing: 8) {
                            Image(systemName: "circle.lefthalf.filled")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                            Slider(
                                value: Binding(
                                    get: { viewModel.layers[index].opacity },
                                    set: { viewModel.layers[index].opacity = $0 }
                                ),
                                in: 0...1
                            )
                            Text("\(Int(layer.opacity * 100))%")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                                .frame(width: 36, alignment: .trailing)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.activeLayerIndex = index
                    }
                }
                .onMove { source, destination in
                    viewModel.moveLayer(from: source, to: destination)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.removeLayer(at: index)
                    }
                }
            }
            .navigationTitle("레이어")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("닫기") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { viewModel.addLayer() } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

// MARK: - Export Sheet

struct ExportSheetView: View {
    @ObservedObject var viewModel: PixelEditorViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var exportScale = 4
    @State private var exportStatus: String?
    @State private var selectedLayout: SpriteSheetLayout = .horizontal
    @State private var showAsepriteShareSheet = false
    @State private var asepriteFileURL: URL?

    private let scales = [1, 2, 4, 8]

    var body: some View {
        NavigationStack {
            List {
                Section("스케일") {
                    Picker("배율", selection: $exportScale) {
                        ForEach(scales, id: \.self) { s in
                            Text("\(s)x (\(viewModel.canvasWidth * s)×\(viewModel.canvasHeight * s))")
                                .tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("PNG 내보내기") {
                    Button {
                        exportPNG()
                    } label: {
                        Label("PNG로 저장", systemImage: "photo")
                    }
                }

                if viewModel.frames.count > 1 {
                    Section("애니메이션 내보내기") {
                        Button {
                            exportGIF()
                        } label: {
                            Label("GIF로 저장", systemImage: "play.rectangle")
                        }

                        Button {
                            exportSpriteSheet()
                        } label: {
                            Label("스프라이트 시트로 저장", systemImage: "square.grid.3x3")
                        }

                        Picker("레이아웃", selection: $selectedLayout) {
                            ForEach(SpriteSheetLayout.allCases, id: \.self) { layout in
                                Text(layout.rawValue).tag(layout)
                            }
                        }
                    }
                }

                Section("Aseprite") {
                    Button {
                        exportAseprite()
                    } label: {
                        Label("Aseprite (.ase)로 내보내기", systemImage: "doc.badge.arrow.up")
                    }
                }

                if let status = exportStatus {
                    Section {
                        HStack {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                            Text(status)
                        }
                    }
                }
            }
            .navigationTitle("내보내기")
            .sheet(isPresented: $showAsepriteShareSheet) {
                if let url = asepriteFileURL {
                    ShareSheet(items: [url])
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }

    private func exportPNG() {
        guard let image = viewModel.renderToImage(scale: exportScale) else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        exportStatus = "PNG 저장 완료"
    }

    private func exportGIF() {
        let images = viewModel.renderAllFrames(scale: exportScale)
        guard !images.isEmpty else { return }
        let delay = 1.0 / Double(max(1, viewModel.fps))
        // GIF 생성
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("pixel_animation.gif")
        let dest = CGImageDestinationCreateWithURL(tempURL as CFURL, UTType.gif.identifier as CFString, images.count, nil)
        guard let destination = dest else { return }
        let gifProps = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]] as CFDictionary
        CGImageDestinationSetProperties(destination, gifProps)
        for img in images {
            guard let cgImg = img.cgImage else { continue }
            let frameProps = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: delay]] as CFDictionary
            CGImageDestinationAddImage(destination, cgImg, frameProps)
        }
        if CGImageDestinationFinalize(destination) {
            if let data = try? Data(contentsOf: tempURL) {
                if let gifImage = UIImage(data: data) {
                    UIImageWriteToSavedPhotosAlbum(gifImage, nil, nil, nil)
                }
            }
            exportStatus = "GIF 저장 완료 (\(images.count)프레임)"
        }
    }

    private func exportSpriteSheet() {
        guard let image = viewModel.renderSpriteSheet(scale: exportScale, layout: selectedLayout) else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        exportStatus = "스프라이트 시트 저장 완료"
    }

    private func exportAseprite() {
        let frames: [AnimationFrame]
        if viewModel.frames.isEmpty {
            frames = [AnimationFrame(layers: viewModel.layers)]
        } else {
            frames = viewModel.frames
        }

        do {
            let data = try AsepriteManager.exportFile(
                width: viewModel.canvasWidth,
                height: viewModel.canvasHeight,
                frames: frames
            )
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("pixel_art.aseprite")
            try data.write(to: url)
            asepriteFileURL = url
            showAsepriteShareSheet = true
            exportStatus = "Aseprite 파일 준비 완료"
        } catch {
            exportStatus = "Aseprite 내보내기 실패: \(error.localizedDescription)"
        }
    }
}


// MARK: - Canvas Preset Picker (Entry Point)

struct NewCanvasView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPreset: CanvasPreset = .small
    @State private var showEditor = false
    @State private var showRecovery = false

    var body: some View {
        ZStack {
            Color(AppConfig.backgroundColor).ignoresSafeArea()

            VStack(spacing: 0) {
                // 헤더
                HStack {
                    Button("취소") { dismiss() }
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("새 캔버스")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button("생성") {
                        PixelEditorViewModel.clearAutoSave()
                        showEditor = true
                    }
                    .foregroundColor(Color(AppConfig.continueButtonColor))
                    .fontWeight(.bold)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)

                ScrollView {
                    VStack(spacing: 16) {
                        // 복구 섹션
                        if PixelEditorViewModel.hasRecoverableProject {
                            Button {
                                showRecovery = true
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.orange)
                                    Text("이전 작업 복구하기")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                .padding(16)
                                .background(Color(AppConfig.toolBackgroundColor))
                                .cornerRadius(12)
                            }
                        }

                        // 캔버스 크기 섹션
                        VStack(alignment: .leading, spacing: 12) {
                            Text("캔버스 크기")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)

                            ForEach(CanvasPreset.allCases, id: \.self) { preset in
                                Button {
                                    selectedPreset = preset
                                } label: {
                                    HStack {
                                        Text(preset.rawValue)
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                        Spacer()
                                        if selectedPreset == preset {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(Color(AppConfig.continueButtonColor))
                                        } else {
                                            Circle()
                                                .stroke(Color.gray.opacity(0.4), lineWidth: 1.5)
                                                .frame(width: 20, height: 20)
                                        }
                                    }
                                    .padding(16)
                                    .background(Color(AppConfig.toolBackgroundColor))
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
        }
        .fullScreenCover(isPresented: $showEditor) {
            PixelEditorView(preset: selectedPreset)
        }
        .fullScreenCover(isPresented: $showRecovery) {
            if let vm = PixelEditorViewModel.recoverProject() {
                RecoveredPixelEditorView(viewModel: vm)
            }
        }
    }
}

/// 복구된 프로젝트 에디터 래퍼
struct RecoveredPixelEditorView: View {
    @StateObject var viewModel: PixelEditorViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showLayerPanel = false
    @State private var showExportSheet = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark").font(.title3)
                }
                Spacer()
                Text("\(viewModel.canvasWidth)×\(viewModel.canvasHeight)")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                HStack(spacing: 16) {
                    Button { viewModel.undo() } label: { Image(systemName: "arrow.uturn.backward") }.disabled(!viewModel.canUndo)
                    Button { viewModel.redo() } label: { Image(systemName: "arrow.uturn.forward") }.disabled(!viewModel.canRedo)
                    Button { showLayerPanel = true } label: { Image(systemName: "square.3.layers.3d") }
                    Button { showExportSheet = true } label: { Image(systemName: "square.and.arrow.up") }
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 8)
            .background(Color(AppConfig.toolBackgroundColor))

            PixelCanvasView(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ColorPicker("", selection: Binding(
                        get: { viewModel.selectedColor.swiftUIColor },
                        set: { viewModel.selectedColor = PixelColor(uiColor: UIColor($0)) }
                    )).labelsHidden().frame(width: 32, height: 32)
                    Divider().frame(height: 24)
                    ForEach(PixelEditorViewModel.defaultPalette, id: \.self) { color in
                        Rectangle().fill(color.swiftUIColor).frame(width: 28, height: 28)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(viewModel.selectedColor == color ? Color.blue : Color.clear, lineWidth: 2))
                            .onTapGesture { viewModel.selectedColor = color }
                    }
                }.padding(.horizontal, 12).padding(.vertical, 6)
            }.background(Color(AppConfig.toolBackgroundColor))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(DrawingToolType.allCases) { tool in
                        Button { viewModel.selectedTool = tool } label: {
                            VStack(spacing: 2) {
                                Image(systemName: tool.icon).font(.title3).frame(width: 36, height: 36)
                                    .background(viewModel.selectedTool == tool ? Color.blue.opacity(0.2) : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                Text(tool.rawValue).font(.system(size: 9))
                                    .foregroundStyle(viewModel.selectedTool == tool ? .blue : .secondary)
                            }
                        }.tint(viewModel.selectedTool == tool ? .blue : .primary)
                    }
                }.padding(.horizontal, 12).padding(.vertical, 8)
            }.background(Color(AppConfig.toolBackgroundColor))
        }
        .background(Color(AppConfig.backgroundColor))
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showLayerPanel) { LayerPanelView(viewModel: viewModel).presentationDetents([.medium]) }
        .sheet(isPresented: $showExportSheet) { ExportSheetView(viewModel: viewModel).presentationDetents([.medium]) }
        .onAppear { viewModel.startAutoSave() }
        .onDisappear { viewModel.saveProject(); viewModel.stopAutoSave() }
    }
}

#Preview {
    PixelEditorView(preset: .small)
}
