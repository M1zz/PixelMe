//
//  CreatorContentView.swift
//  Hantam
//
//  Created by hyunho lee on 2023/06/01.
//
//  Refactored: Task 2 (Accessibility) & Task 3 (Complexity reduction)
//

import SwiftUI
import UniformTypeIdentifiers
import LeeoKit

/// Pixel creator flow to draw pixels
struct CreatorContentView: View {

    @EnvironmentObject var manager: DataManager
    @StateObject private var viewModel = CreatorViewModel()
    @State private var showAsepriteEditor = false
    @State private var showNewCanvasSheet = false
    @State private var showHomeAsepriteImporter = false
    @State private var showFollowAlongEditor = false
    @State private var importedAsepriteFrames: [AnimationFrame]? = nil
    @State private var showPatternMaker = false
    @State private var openedPattern: BeadPattern?
    @State private var showHantamSettings = false
    /// 펼친 화면에서 결과 쪽 판에 세울 내 도안. 없으면 가장 최근 도안.
    @State private var paneSelection: BeadPattern.ID?
    @ObservedObject private var patternStore = PatternStore.shared
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.foldLayout) private var fold

    // MARK: - Main rendering function
    var body: some View {
        presentationLayer
            .onChange(of: manager.shouldLoadPixelGrid) { _, shouldLoad in
                if shouldLoad { viewModel.loadPixelData(from: manager) }
            }
            .onChange(of: manager.shouldDismissPhotoPreview) { _, shouldDismiss in
                if shouldDismiss {
                    viewModel.showPhotoPreview = false
                    manager.shouldDismissPhotoPreview = false
                }
            }
            .onChange(of: manager.useCustomWatermark) { _, newValue in
                UserDefaults.standard.set(newValue, forKey: "useCustomWatermark")
            }
            .fileImporter(
                isPresented: $showHomeAsepriteImporter,
                allowedContentTypes: [UTType(filenameExtension: "aseprite") ?? .data, UTType(filenameExtension: "ase") ?? .data],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    guard url.startAccessingSecurityScopedResource() else { return }
                    defer { url.stopAccessingSecurityScopedResource() }
                    do {
                        let (_, _, frames) = try AsepriteManager.importFile(from: url)
                        importedAsepriteFrames = frames
                        showAsepriteEditor = true
                    } catch {}
                case .failure:
                    break
                }
            }
    }

    // MARK: - Presentation layer (sheets & full-screen covers)
    private var presentationLayer: some View {
        sheetLayer
            .sheet(isPresented: $viewModel.showWatermarkPicker) {
                PhotoPicker { image in
                    if let selectedImage = image {
                        manager.saveCustomWatermark(selectedImage)
                    }
                }
            }
            .fullScreenCover(isPresented: $showAsepriteEditor) {
                if let frames = importedAsepriteFrames,
                   let firstLayer = frames.first?.layers.first {
                    PixelEditorView(
                        frames: frames,
                        width: firstLayer.canvas.width,
                        height: firstLayer.canvas.height
                    )
                    .foldConfined()
                }
            }
            .sheet(isPresented: $showNewCanvasSheet) {
                NewCanvasView()
            }
    }

    // MARK: - Sheet layer (primary sheets & covers)
    private var sheetLayer: some View {
        // 아이폰 듀오를 펴면 고르는 쪽(가로면 왼쪽, 세로면 아래)에 홈, 결과 쪽에 내 도안이 선다.
        // 접혀 있거나 보통 아이폰이면 지금 화면 그대로다 (LeeoKit Fold).
        FoldSplitView {
            ZStack {
                Color.hantamBackground.ignoresSafeArea()
                HomeScreenView
            }
        } result: {
            homeResultPane
                .environment(\.foldLayout, .single)
        }
        .fullScreenCover(isPresented: $showPatternMaker) {
            PatternMakerView()
        }
        .fullScreenCover(item: $openedPattern) { pattern in
            PatternDetailView(pattern: pattern)
        }
        .sheet(isPresented: $showHantamSettings) {
            HantamSettingsView()
        }
        .fullScreenCover(isPresented: $viewModel.showOnboarding) {
            OnboardingView(isPresented: $viewModel.showOnboarding)
                .foldConfined()
        }
        .sheet(isPresented: $viewModel.showSampleGallery, onDismiss: {
            if viewModel.selectedSample != nil { showFollowAlongEditor = true }
        }) {
            SampleArtGalleryView(selectedSample: $viewModel.selectedSample) { sample in
                viewModel.selectedSample = sample
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
            .foldConfined()
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
            if let selectedImage = manager.tempPhotoForPreview {
                PhotoPreviewView(selectedImage: selectedImage)
                    .environmentObject(manager)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.large])
            }
        }
        .sheet(isPresented: $viewModel.showPaywall) {
            PaywallView(isProUser: .constant(false), reason: viewModel.paywallReason)
        }
        .sheet(isPresented: $viewModel.showBoardSizeChanger) {
            BoardSizeChangerSheet
        }
        .fullScreenCover(isPresented: $showFollowAlongEditor) {
            if let sample = viewModel.selectedSample {
                PixelEditorView(referenceSample: sample)
                    .foldConfined()
            }
        }
    }

    // MARK: - Home Screen
    private var HomeScreenView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                HantamHomeHeader { showHantamSettings = true }
                    .padding(.top, 8)

                // ── 1) 도안 만들기 (주 기능) ──
                PatternHeroCard {
                    HantamEvent.track("home_pattern_tapped")
                    showPatternMaker = true
                }
                // 펼친 화면에서 도안이 아직 없으면 세 걸음 안내는 결과 쪽 판에 선다.
                if !(fold.isUnfolded && patternStore.patterns.isEmpty) {
                    PatternStepsRow()
                }

                // ── 2) 내 도안 ── (펼친 화면에서는 띄우지 않고 결과 쪽 판에 연다)
                MyPatternsSection {
                    if fold.isUnfolded { paneSelection = $0.id } else { openedPattern = $0 }
                }

                // ── 3) 픽셀 아트 도구 ──
                HomeToolGrid

                // ── 4) Pro ──
                if !SubscriptionManager.shared.isProUser {
                    HomeProBanner
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - 아이폰 듀오: 결과 쪽

    /// 펼친 화면의 결과 쪽 판. 고른 도안(없으면 가장 최근 도안)을 그 자리에서 보고 고친다.
    /// 도안이 하나도 없으면 무엇을 하는 앱인지 세 걸음 안내.
    @ViewBuilder
    private var homeResultPane: some View {
        let patterns = patternStore.patterns
        if let pattern = patterns.first(where: { $0.id == paneSelection }) ?? patterns.first {
            PatternDetailView(pattern: pattern, isPane: true)
                .id(pattern.id)
        } else {
            ZStack {
                Color.hantamBackground.ignoresSafeArea()
                PatternStepsRow().padding(24)
            }
        }
    }

    // MARK: - Tool Grid
    private var HomeToolGrid: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Pixel art tools")
                .font(.title3.bold())
                .foregroundColor(Color.hantamInk)
                .accessibilityAddTraits(.isHeader)

            // 아주 큰 글자에서는 한 줄에 하나씩.
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: typeSize.isAccessibilitySize ? 1 : 2), spacing: 12) {

                // Pixelate Photo
                Button {
                    viewModel.showPhotoPicker = true
                } label: {
                    HomeToolCard(
                        pixelIcon: PixelIconCatalog.camera,
                        title: "Pixelate Photo",
                        subtitle: "Photo → pixel art",
                        color: .blue
                    )
                }

                // Follow Along
                Button {
                    viewModel.showSampleGallery = true
                } label: {
                    HomeToolCard(
                        pixelIcon: PixelIconCatalog.paintbrush,
                        title: "Follow Along",
                        subtitle: "Draw with a sample",
                        color: .purple
                    )
                }

                // Free Drawing → PixelEditorView (레이어·애니메이션·내보내기 통합)
                Button {
                    showNewCanvasSheet = true
                } label: {
                    HomeToolCard(
                        pixelIcon: PixelIconCatalog.pencil,
                        title: "Free Drawing",
                        subtitle: "Draw · Animate · Export",
                        color: .green
                    )
                }

                // Import
                Button {
                    showHomeAsepriteImporter = true
                } label: {
                    HomeToolCard(
                        pixelIcon: PixelIconCatalog.export,
                        title: "Import",
                        subtitle: "Import .ase files",
                        color: .indigo
                    )
                }
            }
        }
    }

    // MARK: - Pro Banner (컴팩트한 프리미엄 배너)
    private var HomeProBanner: some View {
        Button {
            viewModel.paywallReason = .homeBanner
            viewModel.showPaywall = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "printer.fill")
                    .font(.title3)
                    .foregroundStyle(Color.hantamAccent)
                    .frame(width: 40, height: 40)
                    .background(Color.hantamAccent.opacity(0.12), in: Circle())
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Hantam Pro")
                        .font(.subheadline.bold())
                        .foregroundColor(Color.hantamInk)
                    Text("Printable PDFs · Bigger patterns · No mark")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .padding(14)
            .background(Color.hantamCard, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Drawing Screen Header
    private var DrawingHeaderView: some View {
        ZStack {
            HStack {
                Button {
                    viewModel.goHome()
                } label: {
                    Image(systemName: "house.fill")
                        .font(.system(size: 20))
                        .frame(width: 36, height: 36)
                }
                .accessibilityLabel("홈으로 돌아가기")

                Button {
                    manager.savePixelGrid(view: AnyView(PixelsGridView(height: AppConfig.exportSize, export: true)))
                } label: {
                    Image(systemName: "square.and.arrow.down.fill")
                        .font(.system(size: 20))
                        .frame(width: 36, height: 36)
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

            Text(viewModel.referenceSample != nil ? LocalizedStringKey("Follow Along") : LocalizedStringKey("Free Drawing"))
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
            if isLocked {
                viewModel.paywallReason = .boardSize
                viewModel.showPaywall = true
            } else {
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

                NavigationStack {
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

                            SettingsSectionHeader(title: "Contact")
                            ContactEmailView
                            ContactInstagramView

                            SettingsSectionHeader(title: "Support")
                            SupportSectionView

                            Spacer(minLength: 50)
                        }
                        .padding(.horizontal)
                        .foregroundColor(.white)
                    }
                    .navigationBarHidden(true)
                }
            }
        }
        .presentationDetents([.large])
    }

    private var SupportSectionView: some View {
        VStack(spacing: 0) {
            LeeoSupportSection<HantamSpec>()
                .tint(.white)
            // 앞으로 만들 기능 — 원본은 HantamRoadmap.swift
            NavigationLink { RoadmapScreen() } label: {
                Label(LeeoRoadmapText.entry, systemImage: "map")
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .tint(.white)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 6)
        .background(Color(AppConfig.toolBackgroundColor).cornerRadius(15))
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

    // MARK: - Developer Contact
    private var ContactEmailView: some View {
        Link(destination: URL(string: "mailto:leeo@kakao.com")!) {
            ZStack {
                Color(AppConfig.toolBackgroundColor).cornerRadius(15)
                HStack {
                    Text("Contact via Email").font(.system(size: 18))
                    Spacer()
                    Image(systemName: "envelope")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                }.padding(.horizontal, 15)
            }
        }
        .frame(height: 60)
        .accessibilityLabel(Text("Contact via Email"))
        .accessibilityHint(Text("Bug reports and feature ideas are welcome"))
    }

    private var ContactInstagramView: some View {
        Link(destination: URL(string: "https://instagram.com/lee25_ios")!) {
            ZStack {
                Color(AppConfig.toolBackgroundColor).cornerRadius(15)
                HStack {
                    Text("Instagram DM (@lee25_ios)").font(.system(size: 18))
                    Spacer()
                    Image(systemName: "paperplane")
                        .font(.system(size: 18))
                        .foregroundColor(.purple)
                }.padding(.horizontal, 15)
            }
        }
        .frame(height: 60)
        .accessibilityLabel(Text("Instagram DM (@lee25_ios)"))
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

// MARK: - Home Tool Card (2x2 grid)
struct HomeToolCard: View {
    let pixelIcon: PixelIconDefinition
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            PixelAnimatedIcon(icon: pixelIcon, size: 48)

            VStack(spacing: 3) {
                Text(title)
                    .font(.callout.bold())
                    .foregroundColor(Color.hantamInk)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 6)
        .padding(.vertical, 20)
        .background(Color.hantamCard)
        .cornerRadius(12)
    }
}

// MARK: - Feature Highlight Card (가로 스크롤 카드)
struct FeatureHighlightCard: View {
    let pixelIcon: PixelIconDefinition
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let gradientColors: [Color]
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                PixelAnimatedIcon(icon: pixelIcon, size: 28)

                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .frame(width: 160, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    colors: gradientColors.map { $0.opacity(0.3) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text(description))
    }
}

// MARK: - Preview UI
struct CreatorContentView_Previews: PreviewProvider {
    static var previews: some View {
        CreatorContentView().environmentObject(DataManager())
    }
}
