//
//  PixelEditorView.swift
//  PixelMe
//
//  Created by hyunho lee on 2026/03/01.
//

import SwiftUI

/// 메인 픽셀 에디터 화면 — 캔버스 + 도구바 + 팔레트 + 레이어
struct PixelEditorView: View {
    @StateObject private var viewModel: PixelEditorViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showLayerPanel = false
    @State private var showExportSheet = false
    @State private var showColorPicker = false
    
    init(preset: CanvasPreset = .small) {
        _viewModel = StateObject(wrappedValue: PixelEditorViewModel(preset: preset))
    }
    
    init(width: Int, height: Int) {
        _viewModel = StateObject(wrappedValue: PixelEditorViewModel(width: width, height: height))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 바
            topBar
            
            // 캔버스
            PixelCanvasView(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 팔레트
            colorPaletteBar
            
            // 도구 바
            toolBar
        }
        .background(Color(uiColor: .systemBackground))
        .sheet(isPresented: $showLayerPanel) {
            LayerPanelView(viewModel: viewModel)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showExportSheet) {
            ExportSheetView(viewModel: viewModel)
                .presentationDetents([.medium])
        }
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.title3)
            }
            
            Spacer()
            
            Text("\(viewModel.canvasWidth)×\(viewModel.canvasHeight)")
                .font(.caption)
                .foregroundStyle(.secondary)
            
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
                    
                    Button { showExportSheet = true } label: {
                        Label("내보내기", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(uiColor: .secondarySystemBackground))
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
                
                Divider().frame(height: 24)
                
                ForEach(PixelEditorViewModel.defaultPalette, id: \.self) { color in
                    Rectangle()
                        .fill(color.swiftUIColor)
                        .frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(viewModel.selectedColor == color ? Color.blue : Color.clear, lineWidth: 2)
                        )
                        .onTapGesture {
                            viewModel.selectedColor = color
                        }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .background(Color(uiColor: .secondarySystemBackground))
    }
    
    // MARK: - Tool Bar
    
    private var toolBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
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
        .background(Color(uiColor: .secondarySystemBackground))
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
                
                Section {
                    Button {
                        exportPNG()
                    } label: {
                        Label("PNG로 저장", systemImage: "photo")
                    }
                }
            }
            .navigationTitle("내보내기")
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
        dismiss()
    }
}

// MARK: - Canvas Preset Picker (Entry Point)

struct NewCanvasView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPreset: CanvasPreset = .small
    @State private var showEditor = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("캔버스 크기") {
                    ForEach(CanvasPreset.allCases, id: \.self) { preset in
                        Button {
                            selectedPreset = preset
                        } label: {
                            HStack {
                                Text(preset.rawValue)
                                Spacer()
                                if selectedPreset == preset {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                        .tint(.primary)
                    }
                }
            }
            .navigationTitle("새 캔버스")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("생성") {
                        showEditor = true
                    }
                }
            }
            .fullScreenCover(isPresented: $showEditor) {
                PixelEditorView(preset: selectedPreset)
            }
        }
    }
}

#Preview {
    PixelEditorView(preset: .small)
}
