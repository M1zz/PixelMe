//
//  PixelatedPhotoView.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/30.
//

import SwiftUI

/// Shows the pixelated photo effect with advanced options
struct PixelatedPhotoView: View {

    @EnvironmentObject var manager: DataManager
    @State private var didShowInterstitial: Bool = false
    @State private var showAdvancedSettings: Bool = false
    @State private var showSNSShare: Bool = false
    @State private var selectedTab: Int = 0
    @State private var showShareSheet: Bool = false
    @State private var shareBeforeAfter: Bool = false
    @State private var isGeneratingVideo: Bool = false
    @State private var generatedVideoURL: URL?
    @State private var showVideoShareSheet: Bool = false
    @State private var videoGenerationError: String?
    @State private var showFilterPackStore: Bool = false
    @State private var selectedPackFilter: PackFilter?
    @State private var showPixelEditor: Bool = false

    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.02, blue: 0.09),
                    Color(red: 0.07, green: 0.04, blue: 0.16)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HeaderView
                    .padding(.top, 50)
                    .padding(.bottom, 8)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Pixelated Image Preview
                        PixelatedImage()
                            .environmentObject(manager)
                            .padding(.top, 12)
                            .padding(.bottom, 4)

                        // Tab selector — pill style
                        TabSelector
                            .padding(.horizontal, 16)

                        // Tab content
                        VStack(spacing: 14) {
                            switch selectedTab {
                            case 0:
                                PixelBoardSizeSelector
                            case 1:
                                ColorPaletteSelector
                            case 2:
                                FilterEffectsSelector
                            case 3:
                                PresetsSelector
                            default:
                                PixelBoardSizeSelector
                            }

                            // Dithering quick toggle (visible in Size & Palette tabs)
                            if selectedTab == 0 || selectedTab == 1 {
                                DitheringQuickSelector
                            }

                            // Advanced button
                            AdvancedSettingsButton

                            // Before/After toggle
                            if manager.selectedImage != nil && manager.pixelatedImage != nil {
                                Toggle(isOn: $shareBeforeAfter) {
                                    HStack {
                                        Image(systemName: "rectangle.split.2x1")
                                        Text("비포/애프터로 공유")
                                            .font(.system(size: 15))
                                    }
                                    .foregroundColor(.white)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(AppConfig.toolBackgroundColor))
                                )
                                
                                if shareBeforeAfter,
                                   let original = manager.selectedImage,
                                   let pixelated = manager.pixelatedImage,
                                   let comparison = BeforeAfterImageGenerator.generate(original: original, pixelated: pixelated) {
                                    Image(uiImage: comparison)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxHeight: 180)
                                        .cornerRadius(12)
                                }
                            }

                            // Action buttons
                            VStack(spacing: 12) {
                                OpenInPixelEditorButton
                                CreateReelButton
                                ShareToSNSButton
                                BeforeAfterShareButton
                                EditButton
                                DownloadButton
                            }
                            .padding(.top, 15)
                            .padding(.bottom, 30)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }

            // Loading overlay
            if manager.showLoading {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                        .scaleEffect(1.5)

                    Text("Processing...")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .sheet(isPresented: $showSNSShare) {
            SNSShareView()
                .environmentObject(manager)
        }
        .sheet(isPresented: $showAdvancedSettings) {
            AdvancedSettingsView()
                .environmentObject(manager)
        }
        .sheet(isPresented: $showShareSheet) {
            if let original = manager.selectedImage,
               let pixelated = manager.pixelatedImage {
                let shareImage: UIImage = shareBeforeAfter
                    ? (BeforeAfterImageGenerator.generate(original: original, pixelated: pixelated) ?? pixelated)
                    : pixelated
                ShareSheet(items: [shareImage])
            }
        }
        .onAppear {
            if !manager.isPremiumUser && !didShowInterstitial {
                didShowInterstitial = true
            }
        }
    }

    // MARK: - Header View
    private var HeaderView: some View {
        ZStack {
            HStack {
                Button {
                    manager.savePixelatedImage()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 40, height: 40)
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.cyan)
                    }
                }
                .accessibilityLabel("저장")
                .accessibilityHint("픽셀화된 이미지를 저장합니다")
                Spacer()
                Button {
                    manager.fullScreenMode = nil
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 40, height: 40)
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .accessibilityLabel("닫기")
            }
            Text("Pixel Effect")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Tab Selector — Pill style
    private var TabSelector: some View {
        HStack(spacing: 6) {
            ForEach(Array(["Size", "Palette", "Filters", "Presets"].enumerated()), id: \.offset) { index, title in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedTab = index }
                } label: {
                    Text(title)
                        .font(.system(size: 13, weight: selectedTab == index ? .bold : .medium))
                        .foregroundColor(selectedTab == index ? .white : .white.opacity(0.4))
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedTab == index
                                      ? LinearGradient(colors: [Color.cyan.opacity(0.5), Color.blue.opacity(0.5)], startPoint: .leading, endPoint: .trailing)
                                      : LinearGradient(colors: [Color.white.opacity(0.05)], startPoint: .leading, endPoint: .trailing)
                                )
                        )
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.04))
        )
    }

    // MARK: - Pixel Board Size Selector
    private var PixelBoardSizeSelector: some View {
        VStack(spacing: 14) {

            // Background color picker for transparent images
            if manager.isBackgroundRemovalEnabled {
                HStack {
                    Text("Background Color")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                    Spacer()
                    ColorPicker("", selection: $manager.pixelateBackgroundColor)
                        .labelsHidden()
                        .onChange(of: manager.pixelateBackgroundColor) { oldValue, newValue in
                            // Reapply pixel effect when background color changes
                            if manager.pixelBoardSize != nil {
                                manager.applyPixelEffect(showFilterFlow: false)
                            }
                        }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(AppConfig.toolBackgroundColor))
                )
            }

            LazyVGrid(columns: Array(repeating: GridItem(spacing: 12), count: 2), spacing: 12) {
                ForEach(PixelBoardSize.allCases) { type in
                    PixelBoardSizeItem(type)
                }
            }
        }
        .padding(.top, 5)
    }

    @ViewBuilder
    private func PixelBoardSizeItem(_ type: PixelBoardSize) -> some View {
        let isLocked = !FeatureGating.shared.canUsePixelSize(type)
        let isSelected = manager.pixelBoardSize == type

        Button {
            if isLocked {
                showAdvancedSettings = true
            } else {
                manager.pixelBoardSize = type
                manager.applyPixelEffect(showFilterFlow: false)
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 4) {
                        Text(LocalizedStringKey(type.rawValue))
                            .font(.system(size: 14, weight: .bold))
                        if isLocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.yellow.opacity(0.8))
                        }
                    }
                    Text(type.density)
                        .font(.system(size: 11))
                        .foregroundColor(isSelected ? .white.opacity(0.6) : .white.opacity(0.35))
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.cyan)
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.cyan.opacity(0.15) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.cyan.opacity(0.3) : (isLocked ? Color.yellow.opacity(0.2) : Color.clear), lineWidth: 1)
                    )
            )
        }
        .frame(minHeight: 56)
    }

    // MARK: - Color Palette Selector
    private var ColorPaletteSelector: some View {
        VStack(spacing: 10) {
            ForEach(ColorPaletteType.allCases) { palette in
                ColorPaletteItem(palette)
            }
        }
        .padding(.top, 4)
    }

    @ViewBuilder
    private func ColorPaletteItem(_ palette: ColorPaletteType) -> some View {
        let isLocked = !FeatureGating.shared.canUsePalette(palette)
        
        Button {
            if isLocked {
                // Show paywall for locked palettes
                showAdvancedSettings = true
            } else {
                manager.selectedColorPalette = palette
                manager.applyPixelEffect(showFilterFlow: false)
            }
        } label: {
            HStack(spacing: 12) {
                // Color preview
                HStack(spacing: 3) {
                    ForEach(palette.colors.prefix(4).indices, id: \.self) { index in
                        if index < palette.colors.count {
                            Color(palette.colors[index])
                                .frame(width: 20, height: 50)
                        }
                    }
                }
                .cornerRadius(8)

                // Palette info
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedStringKey(palette.rawValue))
                        .font(.system(size: 16, weight: .semibold))
                    Text(LocalizedStringKey(palette.description))
                        .font(.caption)
                        .lineLimit(2)
                }
                .foregroundColor(.white)

                Spacer()

                if isLocked {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 16))
                } else if manager.selectedColorPalette == palette {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(manager.selectedColorPalette == palette ? Color.cyan.opacity(0.12) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                manager.selectedColorPalette == palette ? Color.cyan.opacity(0.25) : (isLocked ? Color.yellow.opacity(0.2) : Color.clear),
                                lineWidth: 1
                            )
                    )
            )
            .opacity(isLocked ? 0.7 : 1.0)
        }
    }

    // MARK: - Filter Effects Selector
    private var FilterEffectsSelector: some View {
        VStack(spacing: 18) {
            Text("Filter Effects")
                .foregroundColor(.white)
                .font(.headline)

            // Intensity slider if filter is selected
            if manager.filterEffect != .none {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Intensity: \(Int(manager.filterIntensity * 100))%")
                        .foregroundColor(.white)
                        .font(.subheadline)

                    Slider(value: $manager.filterIntensity, in: 0...1) { _ in
                        manager.applyPixelEffect(showFilterFlow: false)
                    }
                    .accentColor(.blue)
                }
                .padding(.bottom, 5)
            }

            LazyVGrid(columns: Array(repeating: GridItem(spacing: 12), count: 2), spacing: 12) {
                ForEach(FilterEffectType.allCases) { filter in
                    FilterEffectItem(filter)
                }
            }

            // Filter Packs Section
            FilterPacksSection
        }
        .padding(.top, 5)
    }

    // MARK: - Filter Packs Section
    private var FilterPacksSection: some View {
        VStack(spacing: 12) {
            Divider().background(Color.gray.opacity(0.3))

            HStack {
                Image(systemName: "paintpalette.fill")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Text("Filter Packs")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button {
                    showFilterPackStore = true
                } label: {
                    Text("See All")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            // Owned pack filters (quick access)
            let ownedFilters = ownedPackFilters()
            if ownedFilters.isEmpty {
                // Promo card
                Button {
                    showFilterPackStore = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.title3)
                            .foregroundColor(.purple)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Get Filter Packs")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            Text("Unique filter + palette combos")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.purple.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(spacing: 12), count: 2), spacing: 12) {
                    ForEach(ownedFilters, id: \.id) { pf in
                        PackFilterItem(pf)
                    }
                }
            }
        }
        .sheet(isPresented: $showFilterPackStore) {
            FilterPackStoreView()
        }
    }

    private func ownedPackFilters() -> [PackFilter] {
        let pm = FilterPackManager.shared
        return pm.availablePacks
            .filter { pm.hasAccess(to: $0) }
            .flatMap { $0.filters }
    }

    @ViewBuilder
    private func PackFilterItem(_ pf: PackFilter) -> some View {
        let isSelected = selectedPackFilter?.id == pf.id
        Button {
            if isSelected {
                selectedPackFilter = nil
                // 팩 필터 해제 → 기본 필터 다시 적용
                manager.applyPixelEffect(showFilterFlow: false)
            } else {
                selectedPackFilter = pf
                applySelectedPackFilter(pf)
            }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(pf.name)
                        .font(.system(size: 14, weight: .bold))
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.purple)
                            .font(.system(size: 14))
                    }
                }
                Text(pf.description)
                    .font(.system(size: 11))
                    .lineLimit(2)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.purple.opacity(0.3) : Color(AppConfig.toolBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? Color.purple.opacity(0.6) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .frame(minHeight: 70)
    }

    private func applySelectedPackFilter(_ pf: PackFilter) {
        guard let source = manager.pixelatedImage else { return }
        // 백그라운드에서 팩 필터 적용
        DispatchQueue.global(qos: .userInitiated).async {
            let result = FilterPackManager.applyPackFilter(pf, to: source)
            DispatchQueue.main.async {
                if let result = result {
                    manager.pixelatedImage = result
                }
            }
        }
    }

    @ViewBuilder
    private func FilterEffectItem(_ filter: FilterEffectType) -> some View {
        // Note: FilterType in FeatureGating might be different, need to map
        let isLocked = !SubscriptionManager.shared.hasAccess(to: .pro) && filter != .crt
        
        Button {
            if isLocked {
                // Show paywall for locked filters
                showAdvancedSettings = true
            } else {
                manager.filterEffect = filter
                if filter != .none {
                    manager.filterIntensity = 0.8
                }
                manager.applyPixelEffect(showFilterFlow: false)
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(LocalizedStringKey(filter.rawValue))
                        .font(.system(size: 15, weight: .bold))
                    Spacer()
                    
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 14))
                    } else if manager.filterEffect == filter {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }

                Text(LocalizedStringKey(filter.description))
                    .font(.caption)
                    .lineLimit(2)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(manager.filterEffect == filter ? Color.blue.opacity(0.3) : Color(AppConfig.toolBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isLocked ? Color.yellow.opacity(0.5) : Color.clear,
                                lineWidth: 1
                            )
                    )
            )
            .opacity(isLocked ? 0.7 : 1.0)
        }
        .frame(height: 90)
    }

    // MARK: - Presets Selector
    private var PresetsSelector: some View {
        VStack(spacing: 18) {
            VStack(spacing: 8) {
                Text("Quick Presets")
                    .foregroundColor(.white)
                    .font(.headline)

                Text("One-tap perfect styles")
                    .foregroundColor(.gray)
                    .font(.caption)
            }

            VStack(spacing: 10) {
                ForEach(EffectPreset.presets) { preset in
                    PresetItem(preset)
                }
            }
        }
        .padding(.top, 5)
    }

    private func PresetItem(_ preset: EffectPreset) -> some View {
        Button {
            manager.applyPreset(preset)
        } label: {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: "sparkles")
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                }

                // Preset info
                VStack(alignment: .leading, spacing: 4) {
                    Text(preset.name)
                        .font(.system(size: 16, weight: .semibold))
                    Text(LocalizedStringKey(preset.description))
                        .font(.caption)
                        .lineLimit(2)
                }
                .foregroundColor(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(AppConfig.toolBackgroundColor))
            )
        }
    }

    // MARK: - Dithering Quick Selector
    private var DitheringQuickSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dithering")
                .foregroundColor(.white)
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(DitheringType.allCases) { dithering in
                        let isLocked = !FeatureGating.shared.canUseDithering && dithering != .none

                        Button {
                            if isLocked {
                                showAdvancedSettings = true
                            } else {
                                manager.ditheringType = dithering
                                manager.applyPixelEffect(showFilterFlow: false)
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(dithering.rawValue)
                                    .font(.system(size: 13, weight: manager.ditheringType == dithering ? .bold : .regular))

                                if isLocked {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.yellow)
                                }
                            }
                            .foregroundColor(manager.ditheringType == dithering ? .white : .gray)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(manager.ditheringType == dithering ? Color(AppConfig.continueButtonColor) : Color(AppConfig.toolBackgroundColor))
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Action Buttons
    private var AdvancedSettingsButton: some View {
        Button {
            showAdvancedSettings = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14))
                Text("Advanced")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white.opacity(0.6))
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
            )
        }
    }

    private var CreateReelButton: some View {
        Button {
            guard let original = manager.selectedImage,
                  let pixelated = manager.pixelatedImage else { return }

            isGeneratingVideo = true
            videoGenerationError = nil

            BeforeAfterVideoGenerator.generate(original: original, pixelated: pixelated, format: .reels) { result in
                isGeneratingVideo = false
                switch result {
                case .success(let url):
                    generatedVideoURL = url
                    showVideoShareSheet = true
                case .failure(let error):
                    videoGenerationError = error.localizedDescription
                }
            }
        } label: {
            HStack {
                if isGeneratingVideo {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "video.fill")
                }
                Text(isGeneratingVideo ? "Creating Reel..." : "Create Reel / TikTok")
            }
            .font(.system(size: 15, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [Color.pink.opacity(0.7), Color.orange.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
        .disabled(manager.pixelatedImage == nil || isGeneratingVideo)
        .sheet(isPresented: $showVideoShareSheet) {
            if let videoURL = generatedVideoURL {
                VideoShareSheet(videoURL: videoURL)
            }
        }
        .alert("Video Error", isPresented: .init(
            get: { videoGenerationError != nil },
            set: { if !$0 { videoGenerationError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(videoGenerationError ?? "")
        }
    }

    private var ShareToSNSButton: some View {
        Button {
            showSNSShare = true
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Share to SNS")
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.purple)
            )
        }
        .disabled(manager.pixelatedImage == nil)
        .accessibilityLabel("SNS 공유")
        .accessibilityHint("SNS 사이즈 프리셋을 선택하고 공유합니다")
    }

    private var BeforeAfterShareButton: some View {
        Button {
            guard let original = manager.selectedImage,
                  let pixelated = manager.pixelatedImage else { return }
            
            let shareImage: UIImage
            if shareBeforeAfter,
               let comparison = BeforeAfterImageGenerator.generate(original: original, pixelated: pixelated) {
                shareImage = comparison
            } else {
                shareImage = pixelated
            }
            showShareSheet = true
        } label: {
            HStack {
                Image(systemName: shareBeforeAfter ? "rectangle.split.2x1" : "square.and.arrow.up")
                Text(shareBeforeAfter ? "Share Before/After" : "Share")
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue)
            )
        }
        .disabled(manager.pixelatedImage == nil)
    }

    private var DownloadButton: some View {
        Button {
            manager.savePixelatedImage()
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.down")
                Text("Download")
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(AppConfig.continueButtonColor))
            )
        }
        .accessibilityLabel("다운로드")
        .accessibilityHint("픽셀 아트를 사진 앨범에 저장합니다")
    }

    private var EditButton: some View {
        Button {
            // Extract pixel data from pixelated image
            print("🎨 [PixelatedPhotoView] Extracting pixel data...")
            manager.extractPixelDataFromImage()
            // Signal to dismiss photo preview sheet
            manager.shouldDismissPhotoPreview = true
            // Close all modals and return to Pixel Creator
            manager.fullScreenMode = nil
        } label: {
            HStack {
                Image(systemName: "square.grid.3x3.fill.square")
                Text("Use this Pixel")
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(manager.pixelBoardSize == nil ? .gray : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(manager.pixelBoardSize == nil ? Color.gray.opacity(0.5) : Color.blue)
            )
        }
        .disabled(manager.pixelBoardSize == nil)
    }

    // MARK: - Open in Pixel Editor
    private var OpenInPixelEditorButton: some View {
        Button {
            showPixelEditor = true
        } label: {
            HStack {
                Image(systemName: "paintbrush.pointed.fill")
                Text("픽셀 에디터에서 편집")
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
            )
        }
        .disabled(manager.pixelatedImage == nil)
        .fullScreenCover(isPresented: $showPixelEditor) {
            if let pixelImage = manager.pixelatedImage,
               let boardSize = manager.pixelBoardSize {
                PixelEditorView(fromImage: pixelImage, targetSize: boardSize.count)
            }
        }
    }
}

// MARK: - Tab Button Component
struct TabButton: View {
    let title: String
    let index: Int
    @Binding var selected: Int

    var body: some View {
        Button {
            selected = index
        } label: {
            Text(title)
                .font(.system(size: 14, weight: selected == index ? .bold : .regular))
                .foregroundColor(selected == index ? .white : .gray)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(selected == index ? Color(AppConfig.continueButtonColor) : Color(AppConfig.toolBackgroundColor))
                )
        }
    }
}

// MARK: - Preview UI
struct PixelatedPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PixelatedPhotoView().environmentObject(DataManager())
    }
}
//
//  AdvancedSettingsView.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/30.
//

import SwiftUI

struct AdvancedSettingsView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showBatchPicker = false
    @State private var showGIFCreator = false
    @State private var showLayerEditor = false
    @State private var showTemplateGallery = false
    @State private var showExportOptions = false
    @State private var showWatermarkPicker = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(AppConfig.backgroundColor).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Dithering Section
                        DitheringSection

                        // Color Reduction Section
                        ColorReductionSection

                        // Watermark Section
                        WatermarkSection

                        // Export Options Section
                        ExportSection

                        // Advanced Features Section
                        AdvancedFeaturesSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Advanced Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showBatchPicker) {
            BatchProcessingView()
                .environmentObject(manager)
        }
        .sheet(isPresented: $showGIFCreator) {
            GIFCreatorView()
                .environmentObject(manager)
        }
        .sheet(isPresented: $showLayerEditor) {
            LayerEditorView()
                .environmentObject(manager)
        }
        .sheet(isPresented: $showTemplateGallery) {
            TemplateGalleryView()
                .environmentObject(manager)
        }
        .sheet(isPresented: $showExportOptions) {
            ExportOptionsView()
                .environmentObject(manager)
        }
        .sheet(isPresented: $showWatermarkPicker) {
            PhotoPicker { image in
                if let selectedImage = image {
                    manager.saveCustomWatermark(selectedImage)
                }
                showWatermarkPicker = false
            }
        }
    }

    // MARK: - Watermark Section
    private var WatermarkSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Custom Watermark")
                .font(.headline)
                .foregroundColor(.white)

            VStack(spacing: 10) {
                // Preview
                if let watermarkImage = manager.getWatermarkImage() {
                    HStack {
                        Text("Current:")
                            .foregroundColor(.gray)
                            .font(.subheadline)

                        Image(uiImage: watermarkImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )

                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(AppConfig.toolBackgroundColor))
                    )
                }

                // Select New Watermark
                Button {
                    showWatermarkPicker = true
                } label: {
                    HStack {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 20))
                        Text("Select Custom Watermark")
                            .font(.system(size: 16, weight: .semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(AppConfig.toolBackgroundColor))
                    )
                }

                // Remove Custom Watermark
                if manager.useCustomWatermark {
                    Button {
                        manager.removeCustomWatermark()
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                                .font(.system(size: 20))
                            Text("Remove Custom Watermark")
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                        }
                        .foregroundColor(.red)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(AppConfig.toolBackgroundColor))
                        )
                    }
                }
            }
        }
    }

    // MARK: - Dithering Section
    private var DitheringSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dithering Algorithm")
                .font(.headline)
                .foregroundColor(.white)

            ForEach(DitheringType.allCases) { dithering in
                Button {
                    manager.ditheringType = dithering
                    manager.applyPixelEffect(showFilterFlow: false)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(LocalizedStringKey(dithering.rawValue))
                                .font(.system(size: 16, weight: .semibold))
                            Text(LocalizedStringKey(dithering.description))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .foregroundColor(.white)

                        Spacer()

                        if manager.ditheringType == dithering {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(manager.ditheringType == dithering ? Color.blue.opacity(0.2) : Color(AppConfig.toolBackgroundColor))
                    )
                }
            }
        }
    }

    // MARK: - Color Reduction Section
    private var ColorReductionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Color Reduction")
                .font(.headline)
                .foregroundColor(.white)

            Text("Reduce the number of colors in the image")
                .font(.caption)
                .foregroundColor(.gray)

            ForEach(ColorReductionType.allCases) { reduction in
                Button {
                    manager.colorReduction = reduction
                    if reduction != .none {
                        manager.selectedColorPalette = .none
                    }
                    manager.applyPixelEffect(showFilterFlow: false)
                } label: {
                    HStack {
                        Text(LocalizedStringKey(reduction.rawValue))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)

                        Spacer()

                        if manager.colorReduction == reduction {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(manager.colorReduction == reduction ? Color.blue.opacity(0.2) : Color(AppConfig.toolBackgroundColor))
                    )
                }
            }
        }
    }

    // MARK: - Export Section
    private var ExportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Export Settings")
                .font(.headline)
                .foregroundColor(.white)

            Button {
                showExportOptions = true
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Advanced Export")
                            .font(.system(size: 16, weight: .semibold))
                        Text("PNG, SVG, PDF, 4K resolution")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .foregroundColor(.white)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(AppConfig.toolBackgroundColor))
                )
            }
        }
    }

    // MARK: - Advanced Features Section
    private var AdvancedFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Premium Features")
                .font(.headline)
                .foregroundColor(.white)

            // Batch Processing
            FeatureButton(
                icon: "photo.stack",
                title: "Batch Processing",
                description: "Process multiple images at once",
                action: { showBatchPicker = true }
            )

            // GIF Creator
            FeatureButton(
                icon: "film",
                title: "GIF Animation",
                description: "Create animated pixel art GIFs",
                action: { showGIFCreator = true }
            )

            // Layer Editor
            FeatureButton(
                icon: "square.3.layers.3d",
                title: "Layer Editor",
                description: "Professional multi-layer editing",
                action: { showLayerEditor = true }
            )

            // Template Gallery
            FeatureButton(
                icon: "square.grid.3x3",
                title: "Templates",
                description: "Pixel avatars, game sprites & more",
                action: { showTemplateGallery = true }
            )
        }
    }
}

// MARK: - Feature Button Component
struct FeatureButton: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .foregroundColor(.blue)
                        .font(.system(size: 22))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .foregroundColor(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(AppConfig.toolBackgroundColor))
            )
        }
    }
}

// MARK: - Preview
struct AdvancedSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedSettingsView()
            .environmentObject(DataManager())
    }
}
//
//  BatchProcessingView.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/30.
//

import SwiftUI
import PhotosUI

struct BatchProcessingView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    @State private var isProcessing = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(AppConfig.backgroundColor).ignoresSafeArea()

                VStack(spacing: 20) {
                    if selectedImages.isEmpty {
                        // Empty state
                        EmptyStateView
                    } else {
                        // Image grid
                        ImageGridView

                        // Current settings
                        CurrentSettingsView

                        // Progress
                        if isProcessing {
                            ProgressView
                        }

                        // Action buttons
                        ActionButtons
                    }
                }
                .padding()
            }
            .navigationTitle("Batch Processing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showImagePicker = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            MultipleImagePicker(images: $selectedImages)
        }
    }

    // MARK: - Empty State
    private var EmptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.stack")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Images Selected")
                .font(.title2)
                .bold()
                .foregroundColor(.white)

            Text("Tap the + button to select multiple images")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Button(action: { showImagePicker = true }) {
                Text("Select Images")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(AppConfig.continueButtonColor))
                    )
            }
            .padding(.top, 20)
        }
        .padding()
    }

    // MARK: - Image Grid
    private var ImageGridView: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 10), count: 3), spacing: 10) {
                ForEach(selectedImages.indices, id: \.self) { index in
                    Image(uiImage: selectedImages[index])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipped()
                        .cornerRadius(8)
                        .overlay(
                            Button(action: {
                                selectedImages.remove(at: index)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.black.opacity(0.5)))
                            }
                            .padding(4),
                            alignment: .topTrailing
                        )
                }
            }
        }
        .frame(maxHeight: 300)
    }

    // MARK: - Current Settings
    private var CurrentSettingsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Settings")
                .font(.headline)
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 8) {
                SettingRow(label: "Images", value: "\(selectedImages.count)")
                SettingRow(label: "Pixel Size", value: manager.pixelBoardSize?.rawValue ?? "16x16")
                SettingRow(label: "Palette", value: manager.selectedColorPalette.rawValue)
                SettingRow(label: "Filter", value: manager.filterEffect.rawValue)
                SettingRow(label: "Export Format", value: manager.exportFormat.rawValue)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(AppConfig.toolBackgroundColor))
            )
        }
    }

    // MARK: - Progress View
    private var ProgressView: some View {
        VStack(spacing: 12) {
            SwiftUI.ProgressView(value: manager.batchProcessor.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))

            Text("Processing \(manager.batchProcessor.currentImageIndex) of \(manager.batchProcessor.totalImages)")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    // MARK: - Action Buttons
    private var ActionButtons: some View {
        VStack(spacing: 12) {
            Button(action: startBatchProcessing) {
                HStack {
                    if isProcessing {
                        SwiftUI.ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    Text(isProcessing ? "Processing..." : "Start Processing")
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isProcessing ? Color.gray : Color(AppConfig.continueButtonColor))
                )
            }
            .disabled(isProcessing || selectedImages.isEmpty)

            if !isProcessing && !manager.batchProcessor.results.isEmpty {
                Button(action: saveResults) {
                    Text("Save All to Photos")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green)
                        )
                }
            }
        }
    }

    // MARK: - Actions
    private func startBatchProcessing() {
        isProcessing = true

        let config = BatchProcessingConfig(
            pixelSize: manager.pixelBoardSize ?? .normal,
            colorPalette: manager.selectedColorPalette,
            colorReduction: manager.colorReduction,
            ditheringType: manager.ditheringType,
            filterEffect: manager.filterEffect,
            filterIntensity: manager.filterIntensity,
            exportFormat: manager.exportFormat,
            exportSize: 1000
        )

        manager.batchProcessor.processBatch(images: selectedImages, config: config) { results in
            isProcessing = false
            presentAlert(
                title: "Batch Complete",
                message: "Processed \(results.filter { $0.success }.count) images successfully"
            )
        }
    }

    private func saveResults() {
        manager.batchProcessor.saveAllToPhotos(results: manager.batchProcessor.results) { success, message in
            presentAlert(title: success ? "Saved" : "Error", message: message)
            if success {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

// MARK: - Setting Row Component
struct SettingRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .foregroundColor(.white)
                .bold()
        }
        .font(.subheadline)
    }
}

// MARK: - Preview
struct BatchProcessingView_Previews: PreviewProvider {
    static var previews: some View {
        BatchProcessingView()
            .environmentObject(DataManager())
    }
}
//
//  ExportOptionsView.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/30.
//

import SwiftUI

struct ExportOptionsView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var customSize: String = "2000"
    @State private var customBackgroundColor: Color = .white
    @State private var isExporting = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(AppConfig.backgroundColor).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Preview
                        PreviewSection

                        // Format selection
                        FormatSection

                        // Size selection
                        SizeSection

                        // Background selection
                        BackgroundSection

                        // Export button
                        ExportButton
                    }
                    .padding()
                }
            }
            .navigationTitle("Export Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - Preview Section
    private var PreviewSection: some View {
        VStack(spacing: 12) {
            Text("Preview")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let image = manager.pixelatedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .overlay(
                        Text("No image to export")
                            .foregroundColor(.gray)
                    )
            }
        }
    }

    // MARK: - Format Section
    private var FormatSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Export Format")
                .font(.headline)
                .foregroundColor(.white)

            ForEach(ExportFormat.allCases) { format in
                Button {
                    manager.exportFormat = format
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(LocalizedStringKey(format.rawValue))
                                .font(.system(size: 16, weight: .semibold))
                            Text(LocalizedStringKey(format.description))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .foregroundColor(.white)

                        Spacer()

                        if manager.exportFormat == format {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(manager.exportFormat == format ? Color.blue.opacity(0.2) : Color(AppConfig.toolBackgroundColor))
                    )
                }
            }
        }
    }

    // MARK: - Size Section
    private var SizeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Export Size")
                .font(.headline)
                .foregroundColor(.white)

            ForEach(ExportSize.allCases) { size in
                Button {
                    manager.exportSize = size
                } label: {
                    HStack {
                        Text(LocalizedStringKey(size.rawValue))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)

                        Spacer()

                        if manager.exportSize == size {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(manager.exportSize == size ? Color.blue.opacity(0.2) : Color(AppConfig.toolBackgroundColor))
                    )
                }
            }

            // Custom size input
            if manager.exportSize == .custom {
                HStack {
                    Text("Custom Size:")
                        .foregroundColor(.white)
                    TextField("2000", text: $customSize)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                    Text("px")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(AppConfig.toolBackgroundColor))
                )
            }
        }
    }

    // MARK: - Background Section
    private var BackgroundSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Background")
                .font(.headline)
                .foregroundColor(.white)

            ForEach(ExportBackgroundType.allCases) { background in
                Button {
                    manager.exportBackground = background
                } label: {
                    HStack {
                        Text(LocalizedStringKey(background.rawValue))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)

                        Spacer()

                        if manager.exportBackground == background {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(manager.exportBackground == background ? Color.blue.opacity(0.2) : Color(AppConfig.toolBackgroundColor))
                    )
                }
            }

            // Custom color picker
            if manager.exportBackground == .custom {
                ColorPicker("Custom Color", selection: $customBackgroundColor)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(AppConfig.toolBackgroundColor))
                    )
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: - Export Button
    private var ExportButton: some View {
        Button(action: exportImage) {
            HStack {
                if isExporting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                Text(isExporting ? "Exporting..." : "Export Image")
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isExporting ? Color.gray : Color(AppConfig.continueButtonColor))
            )
        }
        .disabled(isExporting || manager.pixelatedImage == nil)
    }

    // MARK: - Export Action
    private func exportImage() {
        guard let image = manager.pixelatedImage else { return }

        isExporting = true

        // Parse custom size if needed
        let customSizeValue: CGFloat? = manager.exportSize == .custom ? CGFloat(Double(customSize) ?? 2000) : nil

        // Get custom background color if needed
        let customBG = manager.exportBackground == .custom ? UIColor(customBackgroundColor) : nil

        // Export image
        if let result = ExportManager.exportImage(
            image,
            format: manager.exportFormat,
            size: manager.exportSize,
            customSize: customSizeValue,
            background: manager.exportBackground,
            customBackgroundColor: customBG
        ), let data = result.data {
            // Save to files
            ExportManager.saveToFiles(data: data, filename: result.filename) { success, url in
                isExporting = false

                if success {
                    presentAlert(
                        title: "Exported",
                        message: "Image exported as \(result.filename)"
                    )
                    presentationMode.wrappedValue.dismiss()
                } else {
                    presentAlert(title: "Error", message: "Failed to export image")
                }
            }
        } else {
            isExporting = false
            presentAlert(title: "Error", message: "Failed to export image")
        }
    }
}

// MARK: - Preview
struct ExportOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        ExportOptionsView()
            .environmentObject(DataManager())
    }
}
//
//  GIFCreatorView.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/30.
//

import SwiftUI

struct GIFCreatorView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedMode: GIFMode = .progressive
    @State private var isCreating = false

    enum GIFMode: String, CaseIterable {
        case progressive = "Progressive Pixelation"
        case glitch = "Glitch Animation"
        case colorCycle = "Color Cycling"

        var icon: String {
            switch self {
            case .progressive: return "square.grid.3x2"
            case .glitch: return "bolt.fill"
            case .colorCycle: return "paintpalette"
            }
        }

        var description: String {
            switch self {
            case .progressive: return "Gradually increase pixelation"
            case .glitch: return "Digital glitch effect animation"
            case .colorCycle: return "Cycle through color palettes"
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(AppConfig.backgroundColor).ignoresSafeArea()

                VStack(spacing: 20) {
                    // Preview image
                    if let image = manager.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(12)
                    }

                    // Mode selector
                    ModeSelectorView

                    // Description
                    Text(LocalizedStringKey(selectedMode.description))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)

                    // Settings based on mode
                    SettingsView

                    Spacer()

                    // Create button
                    CreateButton
                }
                .padding()
            }
            .navigationTitle("GIF Creator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - Mode Selector
    private var ModeSelectorView: some View {
        VStack(spacing: 12) {
            Text("Animation Type")
                .font(.headline)
                .foregroundColor(.white)

            ForEach(GIFMode.allCases, id: \.self) { mode in
                Button {
                    selectedMode = mode
                } label: {
                    HStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(selectedMode == mode ? Color.blue : Color(AppConfig.toolBackgroundColor))
                                .frame(width: 40, height: 40)

                            Image(systemName: mode.icon)
                                .foregroundColor(.white)
                        }

                        Text(LocalizedStringKey(mode.rawValue))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)

                        Spacer()

                        if selectedMode == mode {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedMode == mode ? Color.blue.opacity(0.2) : Color(AppConfig.toolBackgroundColor))
                    )
                }
            }
        }
    }

    // MARK: - Settings View
    private var SettingsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.headline)
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 8) {
                switch selectedMode {
                case .progressive:
                    Text("Frames: 10")
                    Text("Duration: 0.1s per frame")
                case .glitch:
                    Text("Frames: 8")
                    Text("Intensity: High")
                case .colorCycle:
                    Text("Palettes: Vaporwave, Cyberpunk, Pastel")
                    Text("Duration: 0.5s per palette")
                }
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(AppConfig.toolBackgroundColor))
            )
        }
    }

    // MARK: - Create Button
    private var CreateButton: some View {
        Button(action: createGIF) {
            HStack {
                if isCreating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                Text(isCreating ? "Creating GIF..." : "Create GIF")
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isCreating ? Color.gray : Color(AppConfig.continueButtonColor))
            )
        }
        .disabled(isCreating || manager.selectedImage == nil)
    }

    // MARK: - Create GIF Action
    private func createGIF() {
        guard let image = manager.selectedImage else { return }

        isCreating = true

        switch selectedMode {
        case .progressive:
            manager.gifCreator.createProgressivePixelationGIF(
                from: image,
                startPixelSize: .extraLarge,
                endPixelSize: .extraLow,
                frameCount: 10,
                frameDuration: 0.1,
                quality: .medium
            ) { url in
                handleGIFCreated(url: url)
            }

        case .glitch:
            manager.gifCreator.createGlitchAnimationGIF(
                from: image,
                frameCount: 8,
                frameDuration: 0.1,
                glitchIntensity: 0.8,
                quality: .medium
            ) { url in
                handleGIFCreated(url: url)
            }

        case .colorCycle:
            let palettes: [ColorPaletteType] = [.vaporwave, .cyberpunk, .pastel]
            manager.gifCreator.createColorCycleGIF(
                from: image,
                palettes: palettes,
                frameDuration: 0.5,
                quality: .medium
            ) { url in
                handleGIFCreated(url: url)
            }
        }
    }

    private func handleGIFCreated(url: URL?) {
        isCreating = false

        if let url = url {
            // Save GIF
            GIFCreator.saveGIFToPhotos(url: url) { success, error in
                if success {
                    presentAlert(title: "Success", message: "GIF saved to Photos")
                    presentationMode.wrappedValue.dismiss()
                } else {
                    presentAlert(title: "Error", message: error?.localizedDescription ?? "Failed to save GIF")
                }
            }
        } else {
            presentAlert(title: "Error", message: "Failed to create GIF")
        }
    }
}

// MARK: - Preview
struct GIFCreatorView_Previews: PreviewProvider {
    static var previews: some View {
        GIFCreatorView()
            .environmentObject(DataManager())
    }
}
//
//  LayerEditorView.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/30.
//

import SwiftUI

struct LayerEditorView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                Color(AppConfig.backgroundColor).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Canvas preview
                    CanvasPreview

                    Divider()
                        .background(Color.gray)

                    // Layer list
                    LayerList

                    // Control buttons
                    ControlButtons
                }
            }
            .navigationTitle("Layers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveComposite()
                    }
                    .foregroundColor(.blue)
                    .bold()
                }
            }
        }
    }

    // MARK: - Canvas Preview
    private var CanvasPreview: some View {
        ZStack {
            Color.gray.opacity(0.3)

            if let compositeImage = manager.layerManager.renderFinalImage() {
                Image(uiImage: compositeImage)
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(height: 300)
    }

    // MARK: - Layer List
    private var LayerList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(manager.layerManager.layers.indices.reversed(), id: \.self) { index in
                    LayerRow(index: index)
                }
            }
            .padding()
        }
    }

    // MARK: - Layer Row
    private func LayerRow(index: Int) -> some View {
        let layer = manager.layerManager.layers[index]

        return HStack(spacing: 12) {
            // Visibility toggle
            Button {
                manager.layerManager.toggleLayerVisibility(at: index)
            } label: {
                Image(systemName: layer.isVisible ? "eye" : "eye.slash")
                    .foregroundColor(layer.isVisible ? .blue : .gray)
                    .frame(width: 30)
            }

            // Thumbnail
            if let image = layer.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipped()
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
            }

            // Layer info
            VStack(alignment: .leading, spacing: 4) {
                Text(layer.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Text("\(Int(layer.opacity * 100))%")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text(layer.blendMode.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)

                    if layer.isLocked {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }

            Spacer()

            // Selection indicator
            if manager.layerManager.selectedLayerIndex == index {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(manager.layerManager.selectedLayerIndex == index ? Color.blue.opacity(0.2) : Color(AppConfig.toolBackgroundColor))
        )
        .onTapGesture {
            manager.layerManager.selectedLayerIndex = index
        }
    }

    // MARK: - Control Buttons
    private var ControlButtons: some View {
        HStack(spacing: 12) {
            // Add layer
            Button {
                if let image = manager.selectedImage {
                    manager.layerManager.addLayer(name: "Layer \(manager.layerManager.layers.count + 1)", image: image)
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "plus.square")
                    Text("Add")
                        .font(.caption)
                }
            }

            Divider()
                .frame(height: 30)

            // Duplicate layer
            Button {
                if let index = manager.layerManager.selectedLayerIndex {
                    manager.layerManager.duplicateLayer(at: index)
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "doc.on.doc")
                    Text("Duplicate")
                        .font(.caption)
                }
            }
            .disabled(manager.layerManager.selectedLayerIndex == nil)

            Divider()
                .frame(height: 30)

            // Delete layer
            Button {
                if let index = manager.layerManager.selectedLayerIndex {
                    manager.layerManager.removeLayer(at: index)
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "trash")
                    Text("Delete")
                        .font(.caption)
                }
            }
            .disabled(manager.layerManager.selectedLayerIndex == nil || manager.layerManager.layers.count <= 1)
            .foregroundColor(.red)

            Divider()
                .frame(height: 30)

            // Merge menu
            Menu {
                Button {
                    if let index = manager.layerManager.selectedLayerIndex {
                        manager.layerManager.mergeLayerDown(at: index)
                    }
                } label: {
                    Label("Merge Down", systemImage: "arrow.down.square")
                }
                .disabled(manager.layerManager.selectedLayerIndex == nil || manager.layerManager.selectedLayerIndex == 0)

                Button {
                    manager.layerManager.mergeVisibleLayers()
                } label: {
                    Label("Merge Visible", systemImage: "eye.square")
                }
                .disabled(manager.layerManager.visibleLayerCount < 2)

                Divider()

                Button(role: .destructive) {
                    manager.layerManager.flattenLayers()
                } label: {
                    Label("Flatten All", systemImage: "square.3.layers.3d.down.right")
                }
                .disabled(manager.layerManager.layers.count < 2)
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "square.3.layers.3d.down.right")
                    Text("Merge")
                        .font(.caption)
                }
            }
        }
        .foregroundColor(.white)
        .padding()
        .background(Color(AppConfig.toolBackgroundColor))
    }

    // MARK: - Actions
    private func saveComposite() {
        if let finalImage = manager.layerManager.renderFinalImage() {
            manager.pixelatedImage = finalImage
            presentAlert(title: "Success", message: "Layers merged successfully")
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Preview
struct LayerEditorView_Previews: PreviewProvider {
    static var previews: some View {
        LayerEditorView()
            .environmentObject(DataManager())
    }
}
//
//  TemplateGalleryView.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/30.
//

import SwiftUI

struct TemplateGalleryView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedCategory: TemplateCategory = .profile

    var body: some View {
        NavigationView {
            ZStack {
                Color(AppConfig.backgroundColor).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Category selector
                    CategorySelector

                    // Template grid
                    TemplateGrid
                }
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - Category Selector
    private var CategorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TemplateCategory.allCases) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Text(LocalizedStringKey(category.rawValue))
                            .font(.system(size: 14, weight: selectedCategory == category ? .bold : .regular))
                            .foregroundColor(selectedCategory == category ? .white : .gray)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedCategory == category ? Color.blue : Color(AppConfig.toolBackgroundColor))
                            )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(AppConfig.backgroundColor))
    }

    // MARK: - Template Grid
    private var TemplateGrid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 15), count: 2), spacing: 15) {
                ForEach(selectedCategory.templates) { template in
                    TemplateCard(template: template)
                }
            }
            .padding()
        }
    }

    // MARK: - Template Card
    private func TemplateCard(template: Template) -> some View {
        Button {
            applyTemplate(template)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Template preview
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(template.aspectRatio, contentMode: .fit)

                    VStack(spacing: 4) {
                        Image(systemName: "photo")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)

                        Text("\(Int(template.size.width))x\(Int(template.size.height))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                // Template info
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)

                    Text(LocalizedStringKey(template.description))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        Label("\(template.pixelSize)px", systemImage: "square.grid.3x3")
                        if template.hasBorder {
                            Label("Border", systemImage: "rectangle.dashed")
                        }
                    }
                    .font(.caption2)
                    .foregroundColor(.blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(AppConfig.toolBackgroundColor))
            )
        }
    }

    // MARK: - Apply Template
    private func applyTemplate(_ template: Template) {
        guard let image = manager.selectedImage else {
            presentAlert(title: "No Image", message: "Please select an image first")
            return
        }

        // Apply template
        if let processedImage = manager.templateManager.applyTemplate(to: image, template: template) {
            manager.selectedImage = processedImage

            // Apply recommended palette if available
            if let paletteName = template.recommendedPalette,
               let palette = ColorPaletteType.allCases.first(where: { $0.rawValue.lowercased() == paletteName.lowercased() }) {
                manager.selectedColorPalette = palette
            }

            // Set pixel size based on template
            if let pixelSize = PixelBoardSize.allCases.first(where: { $0.count == template.pixelSize }) {
                manager.pixelBoardSize = pixelSize
            }

            // Apply effect
            manager.applyPixelEffect(showFilterFlow: false)

            presentAlert(title: "Template Applied", message: "Template '\(template.name)' has been applied")
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Preview
struct TemplateGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateGalleryView()
            .environmentObject(DataManager())
    }
}
//
//  PhotoPreviewView.swift
//  PixelMe
//
//  Photo preview with Pixelize and Remove Background options
//

import SwiftUI

struct PhotoPreviewView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.presentationMode) var presentationMode

    let selectedImage: UIImage
    @State private var showRemoveBackgroundResult = false
    @State private var removedBackgroundImage: UIImage?
    @State private var isProcessing = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.02, blue: 0.10),
                    Color(red: 0.08, green: 0.05, blue: 0.18)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                ppHeaderView
                    .padding(.top, 60)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        ppImagePreview
                            .padding(.top, 16)

                        VStack(spacing: 12) {
                            PixelizeButton
                            RemoveBackgroundButton
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }

            if manager.showLoading {
                Color.black.opacity(0.6).ignoresSafeArea()
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    Text("Pixelating...")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .sheet(isPresented: $showRemoveBackgroundResult) {
            if let bgRemovedImage = removedBackgroundImage {
                BackgroundRemovalResultView(
                    originalImage: selectedImage,
                    removedBackgroundImage: bgRemovedImage
                )
                .environmentObject(manager)
            }
        }
        .onChange(of: manager.fullScreenMode) { newValue in
            if newValue == .applyFilter {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    private var ppHeaderView: some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                ZStack {
                    Circle().fill(Color.white.opacity(0.08)).frame(width: 40, height: 40)
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            Spacer()

            Text("Transform")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            Spacer()

            Circle().fill(Color.clear).frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
    }

    private var ppImagePreview: some View {
        VStack(spacing: 16) {
            Image(uiImage: selectedImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: min(UIScreen.main.bounds.width - 48, 340))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))
                .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)

            Text("Choose how to transform your photo")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.4))
        }
    }

    private var PixelizeButton: some View {
        Button {
            manager.selectedImage = selectedImage
            manager.applyPixelEffect()
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(LinearGradient(colors: [Color.cyan.opacity(0.2), Color.blue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 52, height: 52)
                    Image(systemName: "square.grid.3x3.fill")
                        .font(.system(size: 22)).foregroundColor(.cyan)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pixelize").font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                    Text("Create pixel art instantly").font(.system(size: 13)).foregroundColor(.white.opacity(0.45))
                }
                Spacer()
                Image(systemName: "arrow.right.circle.fill").font(.system(size: 24)).foregroundColor(.cyan.opacity(0.6))
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.06))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.cyan.opacity(0.15), lineWidth: 1))
            )
        }
    }

    private var RemoveBackgroundButton: some View {
        Button {
            isProcessing = true

            BackgroundRemovalManager.removeBackgroundSmart(from: selectedImage) { result in
                isProcessing = false

                if let removedBgImage = result {
                    removedBackgroundImage = removedBgImage
                    showRemoveBackgroundResult = true
                } else {
                    presentAlert(
                        title: "Error",
                        message: "Failed to remove background. This feature requires iOS 15 or later."
                    )
                }
            }
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14).fill(Color.purple.opacity(0.15)).frame(width: 52, height: 52)
                    if isProcessing {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .purple))
                    } else {
                        Image(systemName: "person.crop.circle").font(.system(size: 22)).foregroundColor(.purple)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Remove Background").font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                    Text(isProcessing ? "Processing..." : "Keep only the subject").font(.system(size: 13)).foregroundColor(.white.opacity(0.45))
                }
                Spacer()
                if !isProcessing {
                    Image(systemName: "arrow.right.circle.fill").font(.system(size: 24)).foregroundColor(.purple.opacity(0.5))
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.06))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.purple.opacity(0.12), lineWidth: 1))
            )
        }
        .disabled(isProcessing)
    }
}
//
//  BackgroundRemovalResultView.swift
//  PixelMe
//
//  Shows the result of background removal with option to choose or keep original
//

import SwiftUI

struct BackgroundRemovalResultView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.presentationMode) var presentationMode

    let originalImage: UIImage
    let removedBackgroundImage: UIImage

    @State private var showComparison = false

    var body: some View {
        ZStack {
            Color(AppConfig.backgroundColor).ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                HeaderView

                ScrollView {
                    VStack(spacing: 25) {
                        // Result Image Preview
                        ResultPreview

                        // Toggle Comparison
                        ComparisonToggle

                        // Title
                        VStack(spacing: 8) {
                            Text("Background Removed!")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)

                            Text("Choose the version you want to pixelize")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 10)

                        // Options
                        VStack(spacing: 15) {
                            ChooseButton
                            KeepBackgroundButton
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
    }

    private var HeaderView: some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22))
            }

            Spacer()

            Text("Result")
                .font(.system(size: 20, weight: .bold))

            Spacer()

            // Invisible spacer for center alignment
            Image(systemName: "chevron.left")
                .font(.system(size: 22))
                .opacity(0)
        }
        .padding(.horizontal)
        .padding(.top, 30)
        .foregroundColor(.white)
    }

    private var ResultPreview: some View {
        ZStack {
            // Checkered background to show transparency
            CheckeredBackground()
                .frame(maxWidth: min(UIScreen.main.bounds.width - 40, 350))
                .frame(height: min(UIScreen.main.bounds.width - 40, 350))
                .cornerRadius(12)

            Image(uiImage: showComparison ? originalImage : removedBackgroundImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: min(UIScreen.main.bounds.width - 40, 350))
                .cornerRadius(12)
        }
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }

    private var ComparisonToggle: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                showComparison.toggle()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: showComparison ? "eye.slash" : "eye")
                    .font(.system(size: 14))

                Text(showComparison ? "Original" : "Background Removed")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(AppConfig.toolBackgroundColor))
            )
        }
    }

    private var ChooseButton: some View {
        Button {
            // Use background removed image
            manager.selectedImage = removedBackgroundImage
            manager.isBackgroundRemovalEnabled = true
            manager.applyPixelEffect()

            // Dismiss all sheets
            presentationMode.wrappedValue.dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + AppConfig.dismissAnimationDelay) {
                // Dismiss the parent PhotoPreviewView too
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.dismiss(animated: true)
                }
            }
        } label: {
            HStack(spacing: 15) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Choose This")
                        .font(.system(size: 18, weight: .bold))
                    Text("Pixelize without background")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .foregroundColor(.white)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.green.opacity(0.7))
            )
        }
    }

    private var KeepBackgroundButton: some View {
        Button {
            // Use original image
            manager.selectedImage = originalImage
            manager.isBackgroundRemovalEnabled = false
            manager.applyPixelEffect()

            // Dismiss all sheets
            presentationMode.wrappedValue.dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + AppConfig.dismissAnimationDelay) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.dismiss(animated: true)
                }
            }
        } label: {
            HStack(spacing: 15) {
                Image(systemName: "photo")
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Keep Background")
                        .font(.system(size: 18, weight: .bold))
                    Text("Pixelize with original image")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .foregroundColor(.white)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(AppConfig.toolBackgroundColor))
            )
        }
    }
}

// Checkered background to show transparency
struct CheckeredBackground: View {
    var body: some View {
        GeometryReader { geometry in
            let size: CGFloat = 20
            let rows = Int(geometry.size.height / size) + 1
            let cols = Int(geometry.size.width / size) + 1

            VStack(spacing: 0) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<cols, id: \.self) { col in
                            Rectangle()
                                .fill((row + col) % 2 == 0 ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                                .frame(width: size, height: size)
                        }
                    }
                }
            }
        }
    }
}
