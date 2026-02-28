//
//  CreatorToolbarView.swift
//  PixelMe
//
//  Extracted toolbar subview (Task 3) with accessibility (Task 2)
//

import SwiftUI

/// Toolbar for the drawing screen with eraser, background color, and settings
struct CreatorToolbarView: View {
    @ObservedObject var viewModel: CreatorViewModel

    var body: some View {
        HStack(spacing: 20) {
            // Eraser toggle
            Button {
                viewModel.eraserToolEnabled.toggle()
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: viewModel.eraserToolEnabled ? "eraser.fill" : "eraser")
                        .font(.system(size: 24))
                        .foregroundColor(viewModel.eraserToolEnabled ? .orange : .white)
                    Text("Eraser")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
            .accessibilityLabel("지우개")
            .accessibilityHint("탭하여 지우개 도구를 켜거나 끕니다")
            .accessibilityValue(viewModel.eraserToolEnabled ? "켜짐" : "꺼짐")

            // Background color
            VStack(spacing: 4) {
                ColorPicker("", selection: $viewModel.backgroundColor)
                    .labelsHidden()
                    .frame(width: 30, height: 30)
                    .accessibilityLabel("보드 배경 색상")
                    .accessibilityHint("탭하여 배경 색상을 변경합니다")
                Text("Board")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }

            // Settings button
            Button {
                viewModel.showSettingsSheet = true
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                    Text("Settings")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
            .accessibilityLabel("설정")
            .accessibilityHint("탭하여 보드 설정을 엽니다")
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 15)
        .background(Color(AppConfig.toolBackgroundColor).opacity(0.8))
        .cornerRadius(20)
    }
}
