//
//  CreatorColorPaletteView.swift
//  PixelMe
//
//  Extracted color palette subview (Task 3) with accessibility (Task 2)
//

import SwiftUI

/// Color palette selector for the drawing screen
struct CreatorColorPaletteView: View {
    @ObservedObject var viewModel: CreatorViewModel

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Color Palette")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                Spacer()
                Text("Tap to select, hold to edit")
                    .font(.system(size: 11))
                    .foregroundColor(.gray.opacity(0.7))
            }
            .padding(.horizontal, 20)

            HStack(spacing: 8) {
                ForEach(0..<10, id: \.self) { index in
                    Button {
                        viewModel.selectColor(at: index)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(viewModel.customPalette[index])
                                .frame(width: 32, height: 32)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(viewModel.selectedPaletteIndex == index ? Color.white : Color.clear, lineWidth: 3)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black.opacity(0.3), lineWidth: 1)
                                )

                            if viewModel.selectedPaletteIndex == index {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(viewModel.customPalette[index].isLight ? .black : .white)
                            }
                        }
                    }
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 0.5)
                            .onEnded { _ in
                                viewModel.editingColorIndex = index
                                viewModel.editingColor = viewModel.customPalette[index]
                                viewModel.showColorEditor = true
                            }
                    )
                    .accessibilityLabel("색상 \(index + 1)")
                    .accessibilityHint("탭하여 선택, 길게 눌러 편집")
                    .accessibilityValue(viewModel.selectedPaletteIndex == index ? "선택됨" : "선택되지 않음")
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 10)
        .background(Color(AppConfig.toolBackgroundColor).opacity(0.5))
        .sheet(isPresented: $viewModel.showColorEditor) {
            ColorEditorSheetView(viewModel: viewModel)
        }
    }
}

/// Color editor sheet for modifying palette colors
struct ColorEditorSheetView: View {
    @ObservedObject var viewModel: CreatorViewModel

    var body: some View {
        ZStack {
            Color(AppConfig.backgroundColor).ignoresSafeArea()
            VStack(spacing: 20) {
                HStack {
                    Text("Edit Color")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button {
                        viewModel.showColorEditor = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                    .accessibilityLabel("닫기")
                }
                .padding()

                RoundedRectangle(cornerRadius: 15)
                    .fill(viewModel.editingColor)
                    .frame(width: 100, height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                    .padding()
                    .accessibilityLabel("현재 편집 색상 미리보기")

                ColorPicker("Select a new color", selection: $viewModel.editingColor)
                    .labelsHidden()
                    .scaleEffect(1.5)
                    .padding()
                    .onChange(of: viewModel.editingColor) { oldValue, newValue in
                        viewModel.updateEditingColor(newValue)
                    }
                    .accessibilityLabel("색상 선택")

                VStack(spacing: 10) {
                    Text("Quick Colors")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)

                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 10), count: 6), spacing: 10) {
                        ForEach(viewModel.presetColors, id: \.self) { color in
                            Button {
                                viewModel.editingColor = color
                            } label: {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            .accessibilityLabel("빠른 색상")
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
        }
        .presentationDetents([.medium])
    }
}
