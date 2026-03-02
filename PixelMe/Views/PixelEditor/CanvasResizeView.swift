//
//  CanvasResizeView.swift
//  PixelMe
//
//  비파괴 캔버스 리사이즈 UI
//

import SwiftUI

struct CanvasResizeView: View {
    @ObservedObject var viewModel: PixelEditorViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var newWidth: Int = 32
    @State private var newHeight: Int = 32

    var body: some View {
        NavigationStack {
            Form {
                Section("현재 크기") {
                    Text("\(viewModel.canvasWidth) × \(viewModel.canvasHeight)")
                        .font(.system(.body, design: .monospaced))
                }

                Section("새 크기") {
                    Stepper("너비: \(newWidth)", value: $newWidth, in: 8...256, step: 8)
                    Stepper("높이: \(newHeight)", value: $newHeight, in: 8...256, step: 8)

                    // 프리셋
                    HStack(spacing: 8) {
                        ForEach(CanvasPreset.allCases, id: \.self) { preset in
                            Button(preset.rawValue) {
                                newWidth = preset.size.width
                                newHeight = preset.size.height
                            }
                            .font(.caption)
                            .buttonStyle(.bordered)
                        }
                    }
                }

                Section {
                    if newWidth < viewModel.canvasWidth || newHeight < viewModel.canvasHeight {
                        Label("축소 시 잘리는 픽셀은 삭제됩니다", systemImage: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                    if newWidth > viewModel.canvasWidth || newHeight > viewModel.canvasHeight {
                        Label("확장된 영역은 투명으로 채워집니다", systemImage: "info.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("캔버스 크기 변경")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("적용") {
                        viewModel.resizeCanvas(newWidth: newWidth, newHeight: newHeight)
                        dismiss()
                    }
                    .disabled(newWidth == viewModel.canvasWidth && newHeight == viewModel.canvasHeight)
                }
            }
            .onAppear {
                newWidth = viewModel.canvasWidth
                newHeight = viewModel.canvasHeight
            }
        }
    }
}
