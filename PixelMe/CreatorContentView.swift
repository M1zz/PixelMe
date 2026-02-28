//
//  CreatorContentView.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/01.
//
//  Refactored: Task 2 (Accessibility) & Task 3 (Complexity reduction)
//

import SwiftUI

/// Pixel creator flow to draw pixels
struct CreatorContentView: View {

    @EnvironmentObject var manager: DataManager
    @StateObject private var viewModel = CreatorViewModel()

    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            Color(AppConfig.backgroundColor).ignoresSafeArea()

            if viewModel.showHomeScreen {
                HomeScreenView
            } else {
                DrawingScreenView
            }
        }
        .fullScreenCover(isPresented: $viewModel.showOnboarding) {
            OnboardingView(isPresented: $viewModel.showOnboarding)
        }
        .sheet(isPresented: $viewModel.showSampleGallery) {
            SampleArtGalleryView(selectedSample: $viewModel.selectedSample) { sample in
                viewModel.loadSampleArt(sample, manager: manager)
            }
        }
        .fullScreenCover(item: $manager.fullScreenMode) { type in
            Group {
                switch type {
                case .createPixelArt:
                    CreatorContentView().environmentObject(manager)
                case .applyFilter:
                    PixelatedPhotoView().environmentObject(manager)
                case .settings:
                    Text("Setting")
                }
            }
        }
        .sheet(isPresented: $viewModel.showPhotoPicker) {
            PhotoPicker { image in
                manager.tempPhotoForPreview = image
                DispatchQueue.main.asyncAfter(deadline: .now() + AppConfig.sheetTransitionDelay) {
                    viewModel.showPhotoPreview = true
                }
            }
        }
        .sheet(isPresented: $viewModel.showPhotoPreview) {
            Group {
                if let selectedImage = manager.tempPhotoForPreview {
                    PhotoPreviewView(selectedImage: selectedImage)
                        .environmentObject(manager)
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.large])
                } else {
                    Color.clear
                }
            }
        }
        .sheet(isPresented: $viewModel.showPaywall) {
            PaywallView(isProUser: $manager.isPremiumUser)
        }
        .sheet(isPresented: $viewModel.showBoardSizeChanger) {
            BoardSizeChangerSheet
        }
        .sheet(isPresented: $viewModel.showWatermarkPicker) {
            PhotoPicker { image in
                if let selectedImage = image {
                    manager.saveCustomWatermark(selectedImage)
                }
            }
        }
        .onChange(of: manager.shouldLoadPixelGrid) { oldValue, shouldLoad in
            if shouldLoad {
                viewModel.loadPixelData(from: manager)
            }
        }
        .onChange(of: manager.shouldDismissPhotoPreview) { oldValue, shouldDismiss in
            if shouldDismiss {
                viewModel.showPhotoPreview = false
                manager.shouldDismissPhotoPreview = false
            }
        }
        .onChange(of: manager.useCustomWatermark) { oldValue, newValue in
            UserDefaults.standard.set(newValue, forKey: "useCustomWatermark")
        }
    }

    // MARK: - Drawing Screen (extracted)
    private var DrawingScreenView: some View {
        VStack(spacing: 15) {
            DrawingHeaderView
            ZStack {
                PixelsGridView()

                if !viewModel.didSelectBoardSize {
                    GridHintOverlay
                }
            }

            if let sample = viewModel.referenceSample, viewModel.showReferenceImage, viewModel.didSelectBoardSize {
                ReferenceImageView(sample: sample)
            }

            if viewModel.didSelectBoardSize {
                CreatorColorPaletteView(viewModel: viewModel)
            }

            if viewModel.didSelectBoardSize {
                CreatorToolbarView(viewModel: viewModel)
                    .sheet(isPresented: $viewModel.showSettingsSheet) {
                        SettingsSheetView
                    }
            } else {
                PixelBoardSizeSelector
            }
        }
    }

    // MARK: - Home Screen
    private var HomeScreenView: some View {
        VStack(spacing: 0) {
            Text("Pixel Creator")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 60)
                .padding(.bottom, 30)
                .accessibilityAddTraits(.isHeader)

            ScrollView {
                VStack(spacing: 25) {
                    VStack(spacing: 15) {
                        Button {
                            viewModel.showSampleGallery = true
                        } label: {
                            HomeActionButton(
                                icon: "paintbrush.pointed.fill",
                                title: "Follow Along",
                                subtitle: "Pick a sample and draw along",
                                color: .purple
                            )
                        }
                        .accessibilityLabel("따라 그리기")
                        .accessibilityHint("샘플을 선택하고 따라 그립니다")

                        Button {
                            viewModel.showPhotoPicker = true
                        } label: {
                            HomeActionButton(
                                icon: "photo.fill",
                                title: "Pixelate Photo",
                                subtitle: "Turn your photo into pixel art",
                                color: .blue
                            )
                        }
                        .accessibilityLabel("사진 픽셀화")
                        .accessibilityHint("사진을 픽셀 아트로 변환합니다")

                        Button {
                            viewModel.referenceSample = nil
                            viewModel.showHomeScreen = false
                        } label: {
                            HomeActionButton(
                                icon: "scribble.variable",
                                title: "Free Drawing",
                                subtitle: "Create your own pixel art",
                                color: .green
                            )
                        }
                        .accessibilityLabel("자유 그리기")
                        .accessibilityHint("나만의 픽셀 아트를 만듭니다")

                        if !SubscriptionManager.shared.isProUser {
                            Button {
                                viewModel.showPaywall = true
                            } label: {
                                HomeActionButton(
                                    icon: "crown.fill",
                                    title: "PixelMe Pro",
                                    subtitle: "Unlock all premium features",
                                    color: .yellow
                                )
                            }
                            .accessibilityLabel("PixelMe 프로")
                            .accessibilityHint("모든 프리미엄 기능을 잠금 해제합니다")
                        }
                    }
                    .padding(.horizontal, 20)

                    // Sample Preview Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Sample Gallery")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .accessibilityAddTraits(.isHeader)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(SamplePixelArtCollection.all) { sample in
                                    Button {
                                        viewModel.startFollowAlongDrawing(sample, manager: manager)
                                    } label: {
                                        SamplePreviewCard(sample: sample)
                                    }
                                    .accessibilityLabel("샘플: \(sample.name)")
                                    .accessibilityHint("탭하여 이 샘플을 따라 그립니다")
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 20)

                    Spacer(minLength: 50)
                }
            }
        }
    }

    // MARK: - Drawing Screen Header
    private var DrawingHeaderView: some View {
        ZStack {
            HStack {
                Button {
                    viewModel.goHome()
                } label: {
                    Image(systemName: "house.fill")
                }
                .accessibilityLabel("홈으로 돌아가기")

                Button {
                    manager.savePixelGrid(view: AnyView(PixelsGridView(height: AppConfig.exportSize, export: true)))
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
                .accessibilityLabel("저장")
                .accessibilityHint("현재 픽셀 아트를 저장합니다")

                if viewModel.didSelectBoardSize {
                    Button {
                        viewModel.resetCanvas()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .accessibilityLabel("초기화")
                    .accessibilityHint("캔버스를 지웁니다")
                }

                Spacer()

                if viewModel.referenceSample != nil {
                    Button {
                        viewModel.showReferenceImage.toggle()
                    } label: {
                        Image(systemName: viewModel.showReferenceImage ? "eye.fill" : "eye.slash.fill")
                    }
                    .accessibilityLabel("참고 이미지")
                    .accessibilityValue(viewModel.showReferenceImage ? "표시 중" : "숨김")
                    .accessibilityHint("참고 이미지를 표시하거나 숨깁니다")
                }
            }.font(.system(size: 22))

            Text(viewModel.referenceSample != nil ? "Follow Along" : "Free Drawing")
                .font(.system(size: 18, weight: .bold))
                .accessibilityAddTraits(.isHeader)
        }
        .padding(.horizontal)
        .foregroundColor(.white)
        .padding(.top, 50)
    }

    // MARK: - Reference Image View
    private func ReferenceImageView(sample: SamplePixelArt) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text("Reference: \(sample.name)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                Spacer()
            }

            HStack(spacing: 15) {
                SampleArtPreview(sample: sample)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .accessibilityLabel("참고 이미지: \(sample.name)")

                VStack(alignment: .leading, spacing: 4) {
                    Text("Look at the reference and draw!")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.8))
                    Text("Tap eye icon to hide/show")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }

                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(AppConfig.toolBackgroundColor).opacity(0.5))
    }

    /// Hint overlay for empty grid
    private var GridHintOverlay: some View {
        VStack(spacing: 20) {
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.6))

            VStack(spacing: 8) {
                Text("Select a board size below")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))

                Text("or tap the grid icon to load a sample")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.4))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("보드 크기를 아래에서 선택하세요")
    }

    /// Pixels grid view
    private func PixelsGridView(height: CGFloat = UIScreen.main.bounds.width, export: Bool = false) -> some View {
        ZStack {
            if let sample = viewModel.referenceSample, !export {
                SampleArtPreview(sample: sample)
                    .frame(width: height, height: height)
                    .opacity(0.3)
                    .allowsHitTesting(false)
            }

            HStack(spacing: 0) {
                ForEach(0..<(manager.pixelBoardSize?.count ?? 16), id: \.self) { column in
                    Pixels(forColumn: column, height: height, export: export)
                }
            }
        }
        .frame(height: height)
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged { dragGesture in
            guard let boardSize = manager.pixelBoardSize else { return }
            viewModel.handleDrag(at: dragGesture.location, boardSize: boardSize, height: height)
        }).disabled(!viewModel.didSelectBoardSize).overlay(WatermarkLogoView)
        .accessibilityLabel("픽셀 그리기 캔버스")
        .accessibilityHint("드래그하여 픽셀을 그립니다")
    }

    private func Pixels(forColumn column: Int, height: CGFloat, export: Bool = false) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<(manager.pixelBoardSize?.count ?? 16), id: \.self) { row in
                ZStack {
                    let isFilled = viewModel.filledPixels.contains("\(column)_\(row)")
                    let isFollowAlongMode = viewModel.referenceSample != nil && !export

                    if isFollowAlongMode && !isFilled {
                        Rectangle().foregroundColor(viewModel.backgroundColor.opacity(0.5))
                    } else {
                        Rectangle().foregroundColor(viewModel.backgroundColor)
                    }

                    if export == false {
                        Rectangle().stroke(viewModel.invertGridLinesColor ? Color.white : Color.black, lineWidth: 1)
                            .opacity(viewModel.showGridView ? 1 : 0)
                    }

                    if isFilled {
                        Rectangle().foregroundColor(viewModel.filledColors["\(column)_\(row)"])
                    }
                }.frame(height: height / CGFloat(manager.pixelBoardSize?.count ?? 16))
            }
        }
    }

    private var WatermarkLogoView: some View {
        ZStack {
            if viewModel.didSelectBoardSize && manager.useCustomWatermark {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        if let watermarkImage = manager.getWatermarkImage() {
                            Image(uiImage: watermarkImage)
                                .resizable().aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .shadow(color: Color.black.opacity(0.3), radius: 10)
                        }
                    }
                }.padding()
            }
        }
    }

    // MARK: - Initial Pixel Canvas/Board size
    private var PixelBoardSizeSelector: some View {
        VStack(spacing: 15) {
            VStack(spacing: 8) {
                Text("Select Board Size")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .accessibilityAddTraits(.isHeader)
                Text("Choose a size to start drawing pixel art")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 15), count: 2), spacing: 15) {
                        ForEach(PixelBoardSize.allCases) { type in
                            PixelBoardSizeItem(type)
                        }
                    }
                }
            }
        }.padding(.horizontal)
    }

    private func PixelBoardSizeItem(_ type: PixelBoardSize) -> some View {
        let isSelected = manager.pixelBoardSize == type
        let isLocked = !FeatureGating.shared.canUsePixelSize(type)

        return Button {
            if !isLocked {
                viewModel.selectBoardSize(type, manager: manager)
            }
        } label: {
            ZStack {
                Color.white.cornerRadius(15)
                    .opacity(isSelected ? 1 : (isLocked ? 0.1 : 0.3))

                HStack {
                    Text(type.rawValue)
                        .foregroundColor(isSelected ? .black : .white)
                        .opacity(isSelected ? 1 : (isLocked ? 0.3 : 0.5))

                    if isLocked {
                        Spacer()
                        Image(systemName: "lock.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 12))
                    }
                }
                .padding(.horizontal, 12)
            }
        }
        .frame(height: 60)
        .disabled(isLocked)
        .accessibilityLabel("보드 크기: \(type.rawValue)")
        .accessibilityValue(isSelected ? "선택됨" : (isLocked ? "잠김" : "선택되지 않음"))
        .accessibilityHint(isLocked ? "프로 버전이 필요합니다" : "탭하여 이 보드 크기를 선택합니다")
    }

    // MARK: - Settings Sheet
    private var SettingsSheetView: some View {
        ZStack {
            Color(AppConfig.backgroundColor).ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("Settings")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    Button {
                        viewModel.showSettingsSheet = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }
                    .accessibilityLabel("닫기")
                }
                .padding()

                ScrollView {
                    VStack(spacing: 15) {
                        SettingsSectionHeader(title: "Board")
                        BoardSizeChangeView
                        BackgroundColorView
                        ResetCanvasView

                        SettingsSectionHeader(title: "Display")
                        ShowHideGridView
                        InvertGridColorView

                        SettingsSectionHeader(title: "Watermark")
                        WatermarkView

                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal)
                    .foregroundColor(.white)
                }
            }
        }
        .presentationDetents([.large])
    }

    private func SettingsSectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
                .accessibilityAddTraits(.isHeader)
            Spacer()
        }
        .padding(.top, 10)
    }

    private var ResetCanvasView: some View {
        Button {
            viewModel.resetCanvas()
        } label: {
            ZStack {
                Color(AppConfig.toolBackgroundColor).cornerRadius(15)
                HStack {
                    Text("Reset Canvas").font(.system(size: 18))
                    Spacer()
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 18))
                        .foregroundColor(.orange)
                }.padding(.horizontal, 15)
            }
        }
        .frame(height: 60)
        .accessibilityLabel("캔버스 초기화")
        .accessibilityHint("모든 픽셀을 지우고 배경을 초기화합니다")
    }

    private var BackgroundColorView: some View {
        ZStack {
            Color(AppConfig.toolBackgroundColor).cornerRadius(15)
            HStack {
                Text("Board Color").font(.system(size: 18))
                Spacer()
                ColorPicker("", selection: $viewModel.backgroundColor).labelsHidden()
            }.padding(.horizontal, 15)
        }
        .frame(height: 60)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("보드 색상")
    }

    private var WatermarkView: some View {
        ZStack {
            Color(AppConfig.toolBackgroundColor).cornerRadius(15)
            HStack {
                Text("Watermark").font(.system(size: 18))
                Spacer()

                Button {
                    viewModel.showWatermarkPicker = true
                } label: {
                    HStack(spacing: 4) {
                        if manager.customWatermarkImage != nil {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 16))
                        }
                        Image(systemName: "photo")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                }
                .accessibilityLabel("워터마크 이미지 선택")

                Toggle(isOn: $manager.useCustomWatermark) { EmptyView() }
                    .disabled(manager.customWatermarkImage == nil)
                    .labelsHidden()
                    .accessibilityLabel("워터마크 사용")
                    .accessibilityValue(manager.useCustomWatermark ? "켜짐" : "꺼짐")
            }.padding(.horizontal, 15)
        }.frame(height: 60)
    }

    private var ShowHideGridView: some View {
        ZStack {
            Color(AppConfig.toolBackgroundColor).cornerRadius(15)
            HStack {
                Text("Show Board Grid Lines").font(.system(size: 18))
                Spacer()
                Toggle(isOn: $viewModel.showGridView) { EmptyView() }.labelsHidden()
                    .accessibilityLabel("그리드 라인 표시")
                    .accessibilityValue(viewModel.showGridView ? "켜짐" : "꺼짐")
            }.padding(.horizontal, 15)
        }.frame(height: 60)
    }

    private var InvertGridColorView: some View {
        ZStack {
            Color(AppConfig.toolBackgroundColor).cornerRadius(15)
            HStack {
                Text("Invert Grid Lines Color").font(.system(size: 18))
                Spacer()
                Toggle(isOn: $viewModel.invertGridLinesColor) { EmptyView() }.labelsHidden()
                    .accessibilityLabel("그리드 라인 색상 반전")
                    .accessibilityValue(viewModel.invertGridLinesColor ? "켜짐" : "꺼짐")
            }.padding(.horizontal, 15)
        }.frame(height: 60)
    }

    private var BoardSizeChangeView: some View {
        Button {
            viewModel.showBoardSizeChanger = true
        } label: {
            ZStack {
                Color(AppConfig.toolBackgroundColor).cornerRadius(15)
                HStack {
                    Text("Board Size").font(.system(size: 18))
                    Spacer()
                    Text(manager.pixelBoardSize?.rawValue ?? "N/A")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }.padding(.horizontal, 15)
            }
        }
        .frame(height: 60)
        .accessibilityLabel("보드 크기 변경")
        .accessibilityValue(manager.pixelBoardSize?.rawValue ?? "없음")
    }

    private var BoardSizeChangerSheet: some View {
        ZStack {
            Color(AppConfig.backgroundColor).ignoresSafeArea()
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Text("Change Board Size")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    Button {
                        viewModel.showBoardSizeChanger = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                    .accessibilityLabel("닫기")
                }
                .padding()

                Text("Warning: Changing board size will clear your current drawing")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 15), count: 2), spacing: 15) {
                        ForEach(PixelBoardSize.allCases) { type in
                            Button {
                                viewModel.changeBoardSize(type, manager: manager)
                            } label: {
                                ZStack {
                                    Color.white.cornerRadius(15)
                                        .opacity(manager.pixelBoardSize == type ? 1 : 0.3)
                                    Text(type.rawValue)
                                        .foregroundColor(manager.pixelBoardSize == type ? .black : .white)
                                        .opacity(manager.pixelBoardSize == type ? 1 : 0.5)
                                }
                            }
                            .frame(height: 60)
                            .accessibilityLabel("보드 크기: \(type.rawValue)")
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
        }
    }
}

// MARK: - Home Action Button
struct HomeActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .padding(18)
        .background(Color(AppConfig.toolBackgroundColor))
        .cornerRadius(15)
    }
}

// MARK: - Sample Preview Card
struct SamplePreviewCard: View {
    let sample: SamplePixelArt

    var body: some View {
        VStack(spacing: 8) {
            SampleArtPreview(sample: sample)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )

            Text(sample.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .frame(width: 90)
    }
}

// MARK: - Preview UI
struct CreatorContentView_Previews: PreviewProvider {
    static var previews: some View {
        CreatorContentView().environmentObject(DataManager())
    }
}
