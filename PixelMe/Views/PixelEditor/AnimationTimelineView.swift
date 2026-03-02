//
//  AnimationTimelineView.swift
//  PixelMe
//
//  애니메이션 타임라인 — 프레임 추가/삭제/복제, 어니언 스키닝, FPS 조절, 미리보기
//

import SwiftUI

struct AnimationTimelineView: View {
    @ObservedObject var viewModel: PixelEditorViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // FPS 조절
                HStack {
                    Text("FPS: \(viewModel.fps)")
                        .font(.system(.body, design: .monospaced))
                    Slider(value: Binding(
                        get: { Double(viewModel.fps) },
                        set: { viewModel.fps = Int($0) }
                    ), in: 1...30, step: 1)
                    .tint(.blue)
                }
                .padding(.horizontal)

                // 재생 컨트롤
                HStack(spacing: 20) {
                    Button {
                        if viewModel.isPlaying {
                            viewModel.stopPlayback()
                        } else {
                            viewModel.initializeAnimation()
                            viewModel.startPlayback()
                        }
                    } label: {
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title2)
                    }

                    Toggle("어니언 스킨", isOn: $viewModel.showOnionSkin)
                        .toggleStyle(.switch)
                }
                .padding(.horizontal)

                Divider()

                // 프레임 목록
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(viewModel.frames.enumerated()), id: \.element.id) { index, frame in
                            frameThumb(index: index, frame: frame)
                        }

                        // 프레임 추가 버튼
                        Button {
                            viewModel.initializeAnimation()
                            viewModel.addFrame()
                        } label: {
                            VStack {
                                Image(systemName: "plus")
                                    .font(.title3)
                                Text("추가")
                                    .font(.caption2)
                            }
                            .frame(width: 60, height: 70)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 90)

                // 프레임 액션 버튼
                HStack(spacing: 16) {
                    Button {
                        viewModel.duplicateFrame()
                    } label: {
                        Label("복제", systemImage: "doc.on.doc")
                            .font(.caption)
                    }
                    .disabled(viewModel.frames.isEmpty)

                    Button(role: .destructive) {
                        viewModel.deleteFrame()
                    } label: {
                        Label("삭제", systemImage: "trash")
                            .font(.caption)
                    }
                    .disabled(viewModel.frames.count <= 1)
                }
                .padding(.horizontal)

                Text("\(viewModel.frames.count)프레임 · \(viewModel.fps) FPS · \(String(format: "%.1f", Double(viewModel.frames.count) / Double(max(1, viewModel.fps))))초")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical)
            .navigationTitle("애니메이션")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func frameThumb(index: Int, frame: AnimationFrame) -> some View {
        let isSelected = index == viewModel.currentFrameIndex
        Button {
            viewModel.stopPlayback()
            viewModel.switchToFrame(index)
        } label: {
            VStack(spacing: 2) {
                // 미니 캔버스 미리보기
                Rectangle()
                    .fill(isSelected ? Color.blue.opacity(0.3) : Color.gray.opacity(0.15))
                    .frame(width: 60, height: 50)
                    .overlay(
                        Text("\(index + 1)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(isSelected ? .blue : .secondary)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )

                Text("\(frame.durationMs)ms")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
